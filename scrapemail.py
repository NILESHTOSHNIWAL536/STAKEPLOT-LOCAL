import re
import json
from datetime import datetime
import spacy
import sys
import traceback
import base64
from io import BytesIO

try:
    from pypdf import PdfReader
except ImportError:
    try:
        from PyPDF2 import PdfReader
    except ImportError:
        PdfReader = None

try:
    nlp = spacy.load("en_core_web_sm")
except OSError:
    raise OSError("spaCy model 'en_core_web_sm' not found. Run: python -m spacy download en_core_web_sm")

# ========================================
# BANK IDENTIFIERS (for filtering emails)
# ========================================
BANK_IDENTIFIERS = {
    'HDFC': {
        'keywords': ['hdfc', 'hdfcbank', 'alerts@hdfcbank'],
        'exclude_keywords': ['slice', 'axis', 'icici', 'sbi', 'citi']
    },
    'ICICI': {
        'keywords': ['icici', 'icicibank'],
        'exclude_keywords': ['hdfc', 'slice', 'axis', 'sbi']
    },
    'Axis': {
        'keywords': ['axis', 'axisbank'],
        'exclude_keywords': ['hdfc', 'slice', 'icici', 'sbi']
    },
    'SBI': {
        'keywords': ['sbi', 'state bank'],
        'exclude_keywords': ['hdfc', 'slice', 'axis', 'icici']
    },
    'Slice': {
        'keywords': ['slice', 'sliceit', 'slicebank'],
        'exclude_keywords': ['hdfc', 'axis', 'icici', 'sbi']
    },
}

# ========================================
# TRANSACTION TYPE KEYWORDS
# ========================================
TRANSACTION_KEYWORDS = {
    'debit': ['debited', 'charged', 'deducted', 'withdrawn', 'spent', 'paid', 'transaction alert'],
    'credit': ['credited', 'received', 'added', 'deposited', 'salary', 'refund', 'cashback'],
    'statement': ['statement', 'bill generated', 'outstanding', 'due', 'summary'],
    'loan': ['loan', 'borrow', 'emi', 'disbursed', 'sanctioned', 'transferred'],
    'reward': ['reward', 'cashback', 'points', 'bonus', 'offer']
}

def sanitize_text(text: str) -> str:
    """Clean and normalize text"""
    if not text:
        return ""
    # Replace all variants of rupee symbols
    text = text.replace('â‚¹', 'Rs').replace('Ã¢â€šÂ¹', 'Rs').replace('Rs.', 'Rs')
    # Remove zero-width spaces and other hidden Unicode
    text = re.sub(r'[\u200b\u200c\u200d\ufeff]', '', text)
    # Decode and clean
    return text.encode("utf-8", "ignore").decode("utf-8", "ignore").strip()

def normalize_bank_name(bank_name: str) -> str:
    """Normalize bank name to match BANK_IDENTIFIERS keys"""
    bank_lower = bank_name.lower().strip()
    
    # Map common variations to standardized names
    bank_map = {
        'hdfc bank': 'HDFC',
        'hdfc': 'HDFC',
        'icici bank': 'ICICI',
        'icici': 'ICICI',
        'axis bank': 'Axis',
        'axis': 'Axis',
        'sbi': 'SBI',
        'sbi card': 'SBI',
        'state bank': 'SBI',
        'slice': 'Slice',
        'slicebank': 'Slice',
    }
    
    return bank_map.get(bank_lower, bank_name.upper())

def belongs_to_any_bank(text: str, target_banks: list) -> tuple:
    """
    Check if email belongs to any of the target banks.
    Returns (matched_bank, belongs) tuple
    """
    if not target_banks:
        return (None, True)
    
    text_lower = text.lower()
    
    for bank in target_banks:
        normalized_bank = normalize_bank_name(bank)
        bank_config = BANK_IDENTIFIERS.get(normalized_bank, {})
        
        # Check for excluding keywords first (stronger negative signal)
        exclude_keywords = bank_config.get('exclude_keywords', [])
        exclude_match = any(keyword in text_lower for keyword in exclude_keywords)
        
        # Check for include keywords
        keywords = bank_config.get('keywords', [])
        if keywords:
            include_match = any(keyword in text_lower for keyword in keywords)
        else:
            include_match = True
        
        # If this bank matches and no exclude keywords found, return it
        if include_match and not exclude_match:
            return (normalized_bank, True)
    
    return (None, False)

def classify_transaction(text: str) -> str:
    """Classify transaction type"""
    clean = text.lower()
    
    if any(k in clean for k in ["repayment", "emi paid", "installment paid", "loan closed", "payment successful"]):
        return "Repayment"
    elif any(k in clean for k in TRANSACTION_KEYWORDS['debit']):
        return "Debit"
    elif any(k in clean for k in TRANSACTION_KEYWORDS['credit']):
        return "Credit"
    elif any(k in clean for k in TRANSACTION_KEYWORDS['statement']):
        return "Statement"
    elif any(k in clean for k in TRANSACTION_KEYWORDS['loan']):
        return "Borrow"
    elif any(k in clean for k in TRANSACTION_KEYWORDS['reward']):
        return "Reward"
    else:
        return "Other"

def extract_date(text: str) -> str:
    """Extract and normalize date from text"""
    patterns = [
        r"\b(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})\b",
        r"([A-Za-z]{3,9}\s+\d{1,2}(?:st|nd|rd|th)?,?\s+\d{2,4})",
        r"\b(\d{1,2}\s+[A-Za-z]{3,9}\s+\d{4})\b",
        r"\b(\d{4}[-/]\d{1,2}[-/]\d{1,2})\b",
    ]
    
    for pattern in patterns:
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            date_str = match.group(1).replace("st", "").replace("nd", "").replace("rd", "").replace("th", "").replace(",", "").strip()
            
            date_formats = [
                "%d-%m-%Y", "%d/%m/%Y", "%d %m %Y",
                "%d-%m-%y", "%d/%m/%y",
                "%d %B %Y", "%d %b %Y", "%B %d %Y", "%b %d %Y",
                "%Y-%m-%d", "%Y/%m/%d", "%b %d, %Y"
            ]
            
            for fmt in date_formats:
                try:
                    parsed_date = datetime.strptime(date_str, fmt)
                    return parsed_date.strftime("%Y-%m-%d")
                except ValueError:
                    continue
            
            return date_str
    
    return None

def extract_primary_amount(text: str, category: str) -> str:
    """
    Extract PRIMARY transaction amount.
    Handles amounts with formatting issues (commas, spaces, etc.)
    """
    # Clean text first - remove all hidden chars and normalize spaces
    clean_text = re.sub(r'\s+', ' ', text)
    
    # Patterns for finding amounts with robust matching
    patterns = [
        # Pattern 1: "transferred â‚¹1,660" or "transferred Rs 1660"
        r'(?:transferred|disbursed|credited)\s+(?:Rs|rupees|â‚¹)\s*[\s,]*(\d+)(?:[,\s]*(\d{3}))*(?:[.,](\d{2}))?',
        
        # Pattern 2: "Rs.1,660 debited/credited"
        r'(?:Rs|rupees|â‚¹)\s*[\s,]*(\d+)(?:[,\s]*(\d{3}))*(?:[.,](\d{2}))?\s+(?:is\s+)?(?:debited|credited|charged|transferred)',
        
        # Pattern 3: "Amount: Rs 1660" or "Amount: Rs.1,660"
        r'(?:amount|total)[:\s]+(?:Rs|rupees|â‚¹)[\s,]*(\d+)(?:[,\s]*(\d{3}))*(?:[.,](\d{2}))?',
        
        # Pattern 4: Generic number after Rs/rupees
        r'(?:Rs|rupees|â‚¹)[\s,]*(\d+)(?:[,\s]*(\d{3}))*(?:[.,](\d{2}))?',
        
        r'(?:Rs|rupees|â‚¹|INR)[\s,]*(\d+)(?:[,\s]*(\d{3}))*(?:[.,](\d{2}))?',
    ]
    
    for pattern in patterns:
        matches = re.finditer(pattern, clean_text, re.IGNORECASE)
        for match in matches:
            # Reconstruct the number from groups
            groups = match.groups()
            
            if groups[0]:  # Main amount
                main = groups[0]
                
                # Handle thousands
                thousands = groups[1] if len(groups) > 1 and groups[1] else ''
                
                # Handle decimals
                decimals = groups[2] if len(groups) > 2 and groups[2] else ''
                
                if thousands:
                    amount_str = main + thousands
                else:
                    amount_str = main
                
                if decimals:
                    amount_str = amount_str + '.' + decimals
                
                try:
                    amount_val = float(amount_str)
                    # Reasonable range for transactions
                    if 1 <= amount_val <= 100000000:
                        return amount_str
                except ValueError:
                    continue
    
    return ""

def extract_card_number(text: str) -> str:
    """Extract card number (usually last 4 digits)"""
    patterns = [
        r"(?:ending\s+(?:in|with)[:\s]*)(\d{4})",
        r"(?:\*{2,}|\*\*)\s*(\d{4})",
        r"(?:\*{4}[-\s]?){3}(\d{4})",
    ]
    
    for pattern in patterns:
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            return match.group(1)
    
    return ""

def extract_order_id(text: str) -> str:
    """Extract Order ID, Txn ID, Reference ID"""
    patterns = [
        r"(?:order\s+id|order\s+no)[:\s]+([A-Za-z0-9]{6,})",
        r"(?:txn(?:\s+ref)?|transaction\s+(?:id|ref)|reference\s+(?:no|number))[:\s]+([A-Za-z0-9\-]{6,})",
        r"\b(BW[A-Za-z0-9]{15,})\b",
        r"\b(RID-[A-Za-z0-9\-]{6,})\b",
    ]
    
    for pattern in patterns:
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            val = match.group(1)
            if val.lower() not in ["is", "no", "transaction", "reference", "purposes"]:
                return val
    
    return ""

def extract_mode(text: str) -> str:
    """Extract payment mode"""
    pattern = r"\b(UPI|IMPS|NEFT|RTGS|Net\s*Banking|Wallet|Credit\s*Card|Debit\s*Card|ATM|Auto\s*Debit|Cheque|Bank\s*Transfer|PhonePe|Google\s*Pay|Paytm|Amazon\s*Pay)\b"
    match = re.search(pattern, text, re.IGNORECASE)
    if match:
        return match.group(0).replace(" ", "").upper()
    return ""

def is_financial_email(text: str) -> bool:
    """Check if email is actually financial/banking related"""
    financial_keywords = [
        'bank', 'credit card', 'debit', 'credited', 'debited', 
        'transaction', 'payment', 'amount', 'rs', 'rupees',
        'loan', 'emi', 'statement', 'bill', 'alert', 'charged',
        'borrow', 'transferred'
    ]
    
    text_lower = text.lower()
    count = sum(1 for keyword in financial_keywords if keyword in text_lower)
    return count >= 2

def extract_details(text: str, user_banks: list = None):
    """Extract transaction details from email text for multiple banks"""
    details = {}
    clean_text = sanitize_text(text)
    
    # Normalize user_banks to handle various input formats
    if user_banks is None:
        user_banks = []
    elif isinstance(user_banks, str):
        user_banks = [user_banks]
    
    # Check if email belongs to any target bank
    matched_bank, belongs = belongs_to_any_bank(clean_text, user_banks)
    
    if user_banks and not belongs:
        return {
            "category": "Other",
            "banks_checked": user_banks,
            "matched_bank": None,
            "date": datetime.now().strftime("%Y-%m-%d"),
            "confidence_score": 0,
            "skipped": True,
            "reason": "Email does not belong to any selected bank"
        }
    
    # Check if it's a financial email
    if not is_financial_email(clean_text):
        return {
            "category": "Other",
            "banks_checked": user_banks,
            "matched_bank": matched_bank,
            "date": datetime.now().strftime("%Y-%m-%d"),
            "confidence_score": 0,
        }
    
    # Classify transaction
    category = classify_transaction(clean_text)
    details["category"] = category
    details["banks_checked"] = user_banks
    details["matched_bank"] = matched_bank if matched_bank else "unknown"
    
    # ========================================
    # AMOUNT EXTRACTION
    # ========================================
    amount = extract_primary_amount(clean_text, category)
    if amount:
        details["amount"] = amount
    
    # ========================================
    # DATE EXTRACTION
    # ========================================
    date_result = extract_date(clean_text)
    if date_result:
        details["date"] = date_result
    
    # ========================================
    # CARD NUMBER EXTRACTION
    # ========================================
    card_number = extract_card_number(clean_text)
    if card_number:
        details["card_number"] = card_number
    
    # ========================================
    # ORDER/TRANSACTION ID EXTRACTION
    # ========================================
    order_id = extract_order_id(clean_text)
    if order_id:
        details["transaction_id"] = order_id
    
    # ========================================
    # PAYMENT MODE EXTRACTION
    # ========================================
    mode = extract_mode(clean_text)
    if mode:
        details["mode"] = mode
    
    return details

def _decode_attachment_data(data: str) -> bytes:
    if not data:
        return b""

    padded = data + "=" * (-len(data) % 4)
    try:
        return base64.urlsafe_b64decode(padded)
    except Exception:
        return base64.b64decode(padded)

def _password_candidates(pdf_passwords, user_banks):
    candidates = []

    if isinstance(pdf_passwords, str):
        candidates.append(pdf_passwords)
    elif isinstance(pdf_passwords, list):
        candidates.extend(pdf_passwords)
    elif isinstance(pdf_passwords, dict):
        for bank in user_banks or []:
            values = pdf_passwords.get(bank) or pdf_passwords.get(str(bank).lower())
            if isinstance(values, str):
                candidates.append(values)
            elif isinstance(values, list):
                candidates.extend(values)
        for values in pdf_passwords.values():
            if isinstance(values, str):
                candidates.append(values)
            elif isinstance(values, list):
                candidates.extend(values)

    seen = set()
    unique = []
    for password in candidates:
        if not password or password in seen:
            continue
        seen.add(password)
        unique.append(password)
    return unique

def _extract_pdf_text(attachment, password_candidates):
    filename = attachment.get("filename") or attachment.get("name") or "statement.pdf"
    mime_type = attachment.get("mimeType") or attachment.get("mime") or ""
    is_pdf = filename.lower().endswith(".pdf") or mime_type.lower() == "application/pdf"

    if not is_pdf:
        return {"text": "", "processed": False}

    if PdfReader is None:
        return {
            "text": "",
            "processed": True,
            "needs_password": True,
            "password_error": "pdf_reader_unavailable",
            "password_file": filename,
        }

    raw = _decode_attachment_data(attachment.get("data") or "")
    if not raw:
        return {"text": "", "processed": True}

    try:
        reader = PdfReader(BytesIO(raw))
        if getattr(reader, "is_encrypted", False):
            if not password_candidates:
                return {
                    "text": "",
                    "processed": True,
                    "needs_password": True,
                    "password_error": "password_required",
                    "password_file": filename,
                }

            decrypted = False
            for password in password_candidates:
                try:
                    if reader.decrypt(password):
                        decrypted = True
                        break
                except Exception:
                    continue

            if not decrypted:
                return {
                    "text": "",
                    "processed": True,
                    "needs_password": True,
                    "password_error": "invalid_password",
                    "password_file": filename,
                }

        text = "\n".join((page.extract_text() or "") for page in reader.pages)
        return {"text": text, "processed": True}
    except Exception as exc:
        message = str(exc).lower()
        if "password" in message or "decrypt" in message or "encrypted" in message:
            return {
                "text": "",
                "processed": True,
                "needs_password": True,
                "password_error": "password_required",
                "password_file": filename,
            }

        return {
            "text": "",
            "processed": True,
            "needs_password": False,
            "password_error": "pdf_parse_failed",
            "password_file": filename,
        }

def scrape_email(email, user_banks=None, pdf_passwords=None):
    """Main email scraping function supporting multiple banks"""
    subject = email.get("subject", "") or ""
    body = email.get("body", "") or ""
    
    # Normalize user_banks to handle various input formats
    if user_banks is None:
        user_banks = []
    elif isinstance(user_banks, str):
        user_banks = [user_banks]

    attachments = email.get("attachments") or []
    password_candidates = _password_candidates(pdf_passwords, user_banks)
    attachment_text_parts = []
    attachment_status = {
        "attachments_processed": 0,
        "needs_password": False,
        "password_error": None,
        "password_file": None,
    }

    for attachment in attachments:
        pdf_result = _extract_pdf_text(attachment, password_candidates)
        if not pdf_result.get("processed"):
            continue

        attachment_status["attachments_processed"] += 1
        if pdf_result.get("text"):
            attachment_text_parts.append(pdf_result["text"])

        if pdf_result.get("needs_password"):
            attachment_status["needs_password"] = True
            attachment_status["password_error"] = pdf_result.get("password_error")
            attachment_status["password_file"] = pdf_result.get("password_file")
            break
        elif pdf_result.get("password_error"):
            attachment_status["password_error"] = pdf_result.get("password_error")

    # Combine all text
    full_text = f"{subject}\n\n{body}\n\n{chr(10).join(attachment_text_parts)}".strip()

    if attachment_status["needs_password"]:
        matched_bank, _ = belongs_to_any_bank(f"{subject}\n{body}", user_banks)
        return {
            "category": "Other",
            "banks_checked": user_banks,
            "matched_bank": matched_bank or (user_banks[0] if user_banks else "unknown"),
            "date": datetime.now().strftime("%Y-%m-%d"),
            "confidence_score": 0,
            "message_id": email.get("messageId", ""),
            "sources_processed": {
                "subject": bool(subject),
                "body": bool(body),
                **attachment_status,
            }
        }
    
    # If no text, return empty result
    if not full_text or len(full_text) < 10:
        return {
            "category": "Other",
            "banks_checked": user_banks,
            "matched_bank": "unknown",
            "date": datetime.now().strftime("%Y-%m-%d"),
            "confidence_score": 0,
            "sources_processed": {
                "subject": bool(subject),
                "body": bool(body),
                **attachment_status,
            }
        }
    
    # Extract details
    details = extract_details(full_text, user_banks)
    
    # Skip if email doesn't belong to any bank
    if details.get("skipped"):
        return details
    
    # Add metadata
    details["sources_processed"] = {
        "subject": bool(subject),
        "body": bool(body),
        **attachment_status,
    }
    details["message_id"] = email.get("messageId", "")
    
    # Set matched_bank if not found
    if "matched_bank" not in details or details["matched_bank"] == "unknown":
        details["matched_bank"] = details.get("matched_bank", "unknown")
    
    # Set date if not found
    if "date" not in details:
        details["date"] = datetime.now().strftime("%Y-%m-%d")
    
    # Convert amount to numeric
    if "amount" in details:
        try:
            details["amount"] = float(str(details["amount"]).replace(",", ""))
        except (ValueError, TypeError):
            details.pop("amount", None)
    
    # Confidence score
    extracted_fields = sum(1 for k in ["amount", "date", "category"] if k in details and details[k])
    details["confidence_score"] = round((extracted_fields / 3) * 100, 2)
    
    return details

# ========================================
# MAIN EXECUTION
# ========================================
if __name__ == "__main__":
    try:
        email_data = json.load(sys.stdin)
        user_banks = email_data.pop("user_bank", None)
        pdf_password = email_data.pop("pdf_passwords", None) or email_data.pop("pdf_password", None)
        
        result = scrape_email(email_data, user_banks, pdf_password)
        print(json.dumps(result, indent=2, ensure_ascii=False))
        
    except json.JSONDecodeError as e:
        error_result = {
            "error": f"Invalid JSON input: {str(e)}",
            "type": "json_error"
        }
        print(json.dumps(error_result, indent=2))
        sys.exit(1)
    except Exception as e:
        error_result = {
            "error": str(e),
            "traceback": traceback.format_exc(),
            "type": "runtime_error"
        }
        print(json.dumps(error_result, indent=2))
        sys.exit(1)
