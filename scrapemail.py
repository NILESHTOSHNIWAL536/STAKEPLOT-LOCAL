import re
import json
from datetime import datetime
import spacy
import sys
import traceback

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
    text = text.replace('₹', 'Rs').replace('â‚¹', 'Rs').replace('Rs.', 'Rs')
    # Remove zero-width spaces and other hidden Unicode
    text = re.sub(r'[\u200b\u200c\u200d\ufeff]', '', text)
    # Decode and clean
    return text.encode("utf-8", "ignore").decode("utf-8", "ignore").strip()

def belongs_to_bank(text: str, target_bank: str) -> bool:
    """
    Check if email belongs to the target bank.
    This prevents Slice emails from being matched when searching for HDFC, etc.
    """
    if not target_bank or target_bank == 'unknown':
        return True
    
    text_lower = text.lower()
    bank_config = BANK_IDENTIFIERS.get(target_bank, {})
    
    # Check for excluding keywords first (stronger negative signal)
    exclude_keywords = bank_config.get('exclude_keywords', [])
    for keyword in exclude_keywords:
        if keyword in text_lower:
            return False
    
    # Check for include keywords
    keywords = bank_config.get('keywords', [])
    if keywords:
        return any(keyword in text_lower for keyword in keywords)
    
    return True

def classify_transaction(text: str) -> str:
    """Classify transaction type"""
    clean = text.lower()
    
    if any(k in clean for k in TRANSACTION_KEYWORDS['loan']):
        return "Borrow"
    elif any(k in clean for k in ["repayment", "emi paid", "installment paid", "loan closed", "payment successful"]):
        return "Repayment"
    elif any(k in clean for k in TRANSACTION_KEYWORDS['statement']):
        return "Statement"
    elif any(k in clean for k in TRANSACTION_KEYWORDS['debit']):
        return "Debit"
    elif any(k in clean for k in TRANSACTION_KEYWORDS['credit']):
        return "Credit"
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
        # Pattern 1: "transferred ₹1,660" or "transferred Rs 1660"
        r'(?:transferred|disbursed|credited)\s+(?:Rs|rupees|₹)\s*[\s,]*(\d+)(?:[,\s]*(\d{3}))*(?:[.,](\d{2}))?',
        
        # Pattern 2: "Rs.1,660 debited/credited"
        r'(?:Rs|rupees|₹)\s*[\s,]*(\d+)(?:[,\s]*(\d{3}))*(?:[.,](\d{2}))?\s+(?:is\s+)?(?:debited|credited|charged|transferred)',
        
        # Pattern 3: "Amount: Rs 1660" or "Amount: Rs.1,660"
        r'(?:amount|total)[:\s]+(?:Rs|rupees|₹)[\s,]*(\d+)(?:[,\s]*(\d{3}))*(?:[.,](\d{2}))?',
        
        # Pattern 4: Generic number after Rs/rupees
        r'(?:Rs|rupees|₹)[\s,]*(\d+)(?:[,\s]*(\d{3}))*(?:[.,](\d{2}))?',
        
        r'(?:Rs|rupees|₹|INR)[\s,]*(\d+)(?:[,\s]*(\d{3}))*(?:[.,](\d{2}))?',
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

def extract_details(text: str, user_bank: str = None):
    """Extract transaction details from email text"""
    details = {}
    clean_text = sanitize_text(text)
    
    # Check if email belongs to the target bank
    if user_bank and not belongs_to_bank(clean_text, user_bank):
        return {
            "category": "Other",
            "bank": user_bank,
            "date": datetime.now().strftime("%Y-%m-%d"),
            "confidence_score": 0,
            "skipped": True,
            "reason": "Email does not belong to selected bank"
        }
    
    # Check if it's a financial email
    if not is_financial_email(clean_text):
        return {
            "category": "Other",
            "bank": user_bank if user_bank else "unknown",
            "date": datetime.now().strftime("%Y-%m-%d"),
            "confidence_score": 0,
        }
    
    # Classify transaction
    category = classify_transaction(clean_text)
    details["category"] = category
    details["bank"] = user_bank if user_bank else "unknown"
    
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

def scrape_email(email, user_bank=None, pdf_password=None):
    """Main email scraping function"""
    subject = email.get("subject", "") or ""
    body = email.get("body", "") or ""
    
    # Combine all text
    full_text = f"{subject}\n\n{body}".strip()
    
    # If no text, return empty result
    if not full_text or len(full_text) < 10:
        return {
            "category": "Other",
            "bank": user_bank if user_bank else "unknown",
            "date": datetime.now().strftime("%Y-%m-%d"),
            "confidence_score": 0,
            "sources_processed": {
                "subject": bool(subject),
                "body": bool(body),
            }
        }
    
    # Extract details
    details = extract_details(full_text, user_bank)
    
    # Skip if email doesn't belong to bank
    if details.get("skipped"):
        return details
    
    # Add metadata
    details["sources_processed"] = {
        "subject": bool(subject),
        "body": bool(body),
        "attachments_processed": 0,
        "needs_password": False,
        "password_error": None
    }
    
    # Set bank if not found
    if "bank" not in details or details["bank"] == "unknown":
        details["bank"] = user_bank if user_bank else "unknown"
    
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
        user_bank = email_data.pop("user_bank", None)
        pdf_password = email_data.pop("pdf_password", None)
        
        result = scrape_email(email_data, user_bank, pdf_password)
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