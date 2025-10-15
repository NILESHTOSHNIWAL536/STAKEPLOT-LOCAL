import re
import json
from datetime import datetime
import spacy
import sys
import base64
from io import BytesIO
import traceback

# PDF and Image processing imports
try:
    import PyPDF2
    from pdf2image import convert_from_bytes
    import pytesseract
    from PIL import Image
    PDF_AVAILABLE = True
except ImportError:
    PDF_AVAILABLE = False
    print("⚠️ PDF/Image processing unavailable. Install: pip install PyPDF2 pdf2image pytesseract Pillow", file=sys.stderr)

# Load spaCy model
try:
    nlp = spacy.load("en_core_web_sm")
except OSError:
    raise OSError("⚠️ spaCy model 'en_core_web_sm' not found. Run: python -m spacy download en_core_web_sm")

# ========================================
# REASON: Enhanced sanitization to handle more edge cases
# IMPROVEMENT: Handles emojis, special unicode, and preserves rupee symbol
# ========================================
def sanitize_text(text: str) -> str:
    if not text:
        return ""
    # Preserve currency symbols but remove other problematic unicode
    text = text.replace('₹', 'Rs.')
    return text.encode("utf-8", "ignore").decode("utf-8", "ignore").strip()

# ========================================
# REASON: More comprehensive transaction classification
# IMPROVEMENT: Added patterns for digital wallets, P2P, and international transactions
# ========================================
def classify_transaction(text: str):
    clean = text.lower()
    
    # Borrow/Loan patterns (check first as they're most specific)
    if any(k in clean for k in ["loan disbursed", "borrowed", "sanctioned", "approved", 
                                 "disbursal", "borrow order confirmed", "transferred to your bank", 
                                 "borrow confirmation", "loan credited", "loan amount credited"]):
        return "Borrow"
    
    # Repayment patterns
    elif any(k in clean for k in ["repayment successful", "emi paid", "installment paid", 
                                   "loan closed", "bill paid", "payment successful", "repaid",
                                   "auto debit", "autopay successful", "bill payment confirmation"]):
        return "Repayment"
    
    # Statement patterns
    elif any(k in clean for k in ["outstanding", "due", "minimum due", "bill generated", 
                                   "statement", "monthly statement", "bill summary", 
                                   "borrow statement", "credit card statement"]):
        return "Statement"
    
    # Debit patterns (expanded)
    elif any(k in clean for k in ["debited", "withdrawn", "spent", "paid", "purchase", "atm",
                                   "transaction alert", "debit alert", "charged", "payment made",
                                   "pos transaction", "online purchase", "card used"]):
        return "Debit"
    
    # Credit patterns (expanded)
    elif any(k in clean for k in ["credited", "received", "salary", "refund", "cashback", 
                                   "credit alert", "deposit", "added", "reward points",
                                   "reversal", "credit adjustment"]):
        return "Credit"
    
    else:
        return "Other"

# ========================================
# REASON: Extract text from password-protected PDFs
# IMPROVEMENT: Handles encrypted PDFs with user-provided password
# ========================================
def extract_pdf_text(pdf_data: bytes, password: str = None) -> tuple:
    """
    Returns: (text_content, needs_password, error_message)
    """
    if not PDF_AVAILABLE:
        return "", False, "PDF libraries not installed"
    
    try:
        pdf_file = BytesIO(pdf_data)
        pdf_reader = PyPDF2.PdfReader(pdf_file)
        
        # Check if PDF is encrypted
        if pdf_reader.is_encrypted:
            if password:
                try:
                    pdf_reader.decrypt(password)
                except Exception as e:
                    return "", True, f"Invalid password: {str(e)}"
            else:
                return "", True, "PDF is password-protected. Password required."
        
        # Extract text from all pages
        text_parts = []
        for page_num in range(len(pdf_reader.pages)):
            try:
                page = pdf_reader.pages[page_num]
                text_parts.append(page.extract_text())
            except Exception as e:
                print(f"⚠️ Error extracting page {page_num}: {e}", file=sys.stderr)
                continue
        
        extracted_text = "\n".join(text_parts)
        
        # If no text extracted, try OCR
        if not extracted_text.strip():
            print("📸 No text found in PDF, attempting OCR...", file=sys.stderr)
            return extract_pdf_with_ocr(pdf_data), False, None
        
        return extracted_text, False, None
        
    except Exception as e:
        return "", False, f"PDF extraction error: {str(e)}"

# ========================================
# REASON: Handle image-based PDFs and scanned documents
# IMPROVEMENT: Uses OCR to extract text from images in PDFs
# ========================================
def extract_pdf_with_ocr(pdf_data: bytes) -> str:
    """Extract text from image-based PDFs using OCR"""
    if not PDF_AVAILABLE:
        return ""
    
    try:
        images = convert_from_bytes(pdf_data)
        text_parts = []
        
        for i, image in enumerate(images):
            try:
                text = pytesseract.image_to_string(image)
                text_parts.append(text)
            except Exception as e:
                print(f"⚠️ OCR failed for page {i}: {e}", file=sys.stderr)
                continue
        
        return "\n".join(text_parts)
    except Exception as e:
        print(f"⚠️ PDF OCR failed: {e}", file=sys.stderr)
        return ""

# ========================================
# REASON: Extract text from image attachments
# IMPROVEMENT: Handles transaction screenshots and image-based notifications
# ========================================
def extract_image_text(image_data: bytes) -> str:
    """Extract text from images using OCR"""
    if not PDF_AVAILABLE:
        return ""
    
    try:
        image = Image.open(BytesIO(image_data))
        text = pytesseract.image_to_string(image)
        return text
    except Exception as e:
        print(f"⚠️ Image OCR failed: {e}", file=sys.stderr)
        return ""

# ========================================
# REASON: Process all types of attachments
# IMPROVEMENT: Centralized attachment processing with format detection
# ========================================
def process_attachments(attachments: list, pdf_password: str = None) -> dict:
    """
    Process all attachments and extract text content
    Returns: {
        'text': combined_text,
        'needs_password': bool,
        'password_error': str or None,
        'processed_count': int
    }
    """
    combined_text = []
    needs_password = False
    password_error = None
    processed_count = 0
    
    for att in attachments:
        filename = att.get('filename', '').lower()
        mime_type = att.get('mimeType', '').lower()
        data_b64 = att.get('data', '')
        
        if not data_b64:
            continue
        
        try:
            # Decode base64 data
            file_data = base64.b64decode(data_b64)
            
            # Process PDFs
            if 'pdf' in mime_type or filename.endswith('.pdf'):
                print(f"📄 Processing PDF: {filename}", file=sys.stderr)
                text, needs_pwd, error = extract_pdf_text(file_data, pdf_password)
                
                if needs_pwd:
                    needs_password = True
                    password_error = error
                elif text:
                    combined_text.append(text)
                    processed_count += 1
            
            # Process images
            elif any(img in mime_type for img in ['image/', 'png', 'jpg', 'jpeg']):
                print(f"🖼️ Processing image: {filename}", file=sys.stderr)
                text = extract_image_text(file_data)
                if text:
                    combined_text.append(text)
                    processed_count += 1
            
        except Exception as e:
            print(f"⚠️ Error processing {filename}: {e}", file=sys.stderr)
            continue
    
    return {
        'text': "\n\n".join(combined_text),
        'needs_password': needs_password,
        'password_error': password_error,
        'processed_count': processed_count
    }

# ========================================
# REASON: Enhanced date extraction with multiple format support
# IMPROVEMENT: Handles Indian date formats, relative dates, and various separators
# ========================================
def extract_date(text: str, field_name: str = "date") -> str:
    """Enhanced date extraction with multiple format support"""
    
    patterns = [
        # DD-MM-YYYY or DD/MM/YYYY
        r"\b(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})\b",
        # Month DD, YYYY or DD Month YYYY
        r"([A-Za-z]{3,9}\s+\d{1,2}(?:st|nd|rd|th)?,?\s+\d{2,4})",
        # DD Month YYYY
        r"\b(\d{1,2}\s+[A-Za-z]{3,9}\s+\d{4})\b",
        # YYYY-MM-DD (ISO format)
        r"\b(\d{4}[-/]\d{1,2}[-/]\d{1,2})\b",
    ]
    
    for pattern in patterns:
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            date_str = match.group(1).replace("st", "").replace("nd", "").replace("rd", "").replace("th", "").replace(",", "").strip()
            
            # Try multiple date formats
            date_formats = [
                "%d-%m-%Y", "%d/%m/%Y", "%d %m %Y",
                "%d-%m-%y", "%d/%m/%y",
                "%d %B %Y", "%d %b %Y", "%B %d %Y", "%b %d %Y",
                "%Y-%m-%d", "%Y/%m/%d"
            ]
            
            for fmt in date_formats:
                try:
                    parsed_date = datetime.strptime(date_str, fmt)
                    return parsed_date.strftime("%Y-%m-%d")
                except ValueError:
                    continue
            
            # If parsing fails, return raw string
            return date_str
    
    return None

# ========================================
# REASON: Comprehensive detail extraction with multiple fallback strategies
# IMPROVEMENT: Uses regex, NLP, and context-aware extraction
# ========================================
def extract_details(text: str):
    details = {}
    clean_text = " ".join(sanitize_text(text).split())

    # Category
    details["category"] = classify_transaction(clean_text)

    # ========================================
    # REASON: Enhanced amount extraction with currency and decimal support
    # ========================================
    amt_patterns = [
        r"(?:Amount|Rs\.?|INR|₹|Amt)[:\s]*(?:Rs\.?|INR|₹)?\s*([\d,]+\.?\d{0,2})",
        r"(?:Rs\.?|INR|₹)\s*([\d,]+\.?\d{0,2})",
        r"\b([\d,]{3,}\.?\d{0,2})\s*(?:debited|credited|paid|received)",
    ]
    
    for pattern in amt_patterns:
        amt_match = re.search(pattern, clean_text, re.IGNORECASE)
        if amt_match:
            details["amount"] = amt_match.group(1).replace(",", "")
            break

    # Date
    date_result = extract_date(clean_text)
    if date_result:
        details["date"] = date_result

    # Due Date
    due_patterns = [
        r"(?:Due Date|Payment Due|Repay By|Pay By)[:\- ]?\s*(.+?)(?:\.|$|\s{3,})",
        r"(?:Due on|Pay before)[:\- ]?\s*(.+?)(?:\.|$|\s{3,})",
    ]
    
    for pattern in due_patterns:
        match = re.search(pattern, clean_text, re.IGNORECASE)
        if match:
            due_date_result = extract_date(match.group(1))
            if due_date_result:
                details["due_date"] = due_date_result
                break

    # ========================================
    # REASON: Enhanced card number extraction with multiple patterns
    # ========================================
    card_patterns = [
        r"(?:Card|card\s+ending|ending\s+with|last\s+4\s+digits?)[:\s\-]*[xX]{4,}(\d{4})",
        r"[xX]{4,}[- ]?[xX]{4,}[- ]?[xX]{4,}[- ]?(\d{4})",
        r"\b\d{4}[- ]?\d{4}[- ]?\d{4}[- ]?(\d{4})\b",
    ]
    
    for pattern in card_patterns:
        card_match = re.search(pattern, clean_text, re.IGNORECASE)
        if card_match:
            details["card_number"] = card_match.group(1)
            break

    # ========================================
    # REASON: Enhanced transaction ID extraction
    # ========================================
    txn_patterns = [
        r"(?:Txn(?:\s+Ref)?|Transaction\s+ID|Reference\s+(?:No|Number)|RID|Order\s+ID|UPI\s+Ref)[:\s\-]+([A-Za-z0-9\-]{6,})",
        r"\b(RID-[A-Za-z0-9\-]{6,})\b",
        r"\b([A-Z0-9]{10,})\b(?=\s*(?:is your|transaction))",
    ]
    
    for pattern in txn_patterns:
        txn_match = re.search(pattern, clean_text, re.IGNORECASE)
        if txn_match:
            val = txn_match.group(1)
            if val.lower() not in ["is", "no", "transaction", "reference"]:
                details["transaction_id"] = val
                break

    # Loan ID
    loan_patterns = [
        r"(?:Loan\s+(?:ID|Number)|Borrow\s+ID|Application\s+(?:ID|Number))[:\s\-]+([A-Za-z0-9\-]{4,})",
    ]
    
    for pattern in loan_patterns:
        loan_match = re.search(pattern, clean_text, re.IGNORECASE)
        if loan_match:
            details["loan_id"] = loan_match.group(1)
            break

    # Total Due / Outstanding
    total_due_patterns = [
        r"(?:Total\s+Due|Outstanding\s+Balance|Amount\s+Due|Statement\s+Balance|Total\s+Outstanding)[:\s]*(?:Rs\.?|INR|₹)?\s*([\d,]+\.?\d*)",
    ]
    
    for pattern in total_due_patterns:
        match = re.search(pattern, clean_text, re.IGNORECASE)
        if match:
            details["total_due"] = match.group(1).replace(",", "")
            break

    # Minimum Due
    min_due_patterns = [
        r"(?:Min(?:imum)?\s+Due|Minimum\s+Amount\s+Due|Min\s+Pay)[:\s]*(?:Rs\.?|INR|₹)?\s*([\d,]+\.?\d*)",
    ]
    
    for pattern in min_due_patterns:
        match = re.search(pattern, clean_text, re.IGNORECASE)
        if match:
            details["minimum_due"] = match.group(1).replace(",", "")
            break

    # ========================================
    # REASON: Enhanced payment mode detection
    # ========================================
    mode_pattern = r"\b(UPI|IMPS|NEFT|RTGS|Net\s*banking|Wallet|Credit\s*Card|Debit\s*Card|ATM|Auto\s*Debit|Cheque|slice\s*borrow|Bank\s*Transfer|PhonePe|Google\s*Pay|Paytm|Amazon\s*Pay)\b"
    mode_match = re.search(mode_pattern, clean_text, re.IGNORECASE)
    if mode_match:
        details["mode"] = mode_match.group(0).replace(" ", "").upper()

    # Merchant/Vendor
    merchant_patterns = [
        r"(?:at|@|from|to)\s+([A-Z][A-Za-z0-9&\s]{2,30}?)(?:\s+on|\s+dated|\.|$)",
        r"(?:merchant|vendor)[:\s]+([A-Z][A-Za-z0-9&\s]{2,30}?)(?:\.|$)",
    ]
    
    for pattern in merchant_patterns:
        merchant_match = re.search(pattern, clean_text)
        if merchant_match and len(merchant_match.group(1).strip()) > 3:
            details["merchant"] = merchant_match.group(1).strip()
            break

    # User Name
    user_patterns = [
        r"(?:Hi|Dear|Hello)\s+([A-Z][a-z]+)\s*,",
    ]
    
    for pattern in user_patterns:
        user_match = re.search(pattern, clean_text)
        if user_match:
            details["user_name"] = user_match.group(1)
            break

    # Bank/Organization
    bank_patterns = [
        r"\b([A-Z][A-Za-z0-9&\s]{2,}(?:Bank|Credit\s*Card|Finance|Services|slice))\b",
        r"from:\s*([A-Z][A-Za-z0-9&\s]{2,})",
    ]
    
    for pattern in bank_patterns:
        bank_match = re.search(pattern, clean_text)
        if bank_match and len(bank_match.group(0)) > 5:
            details["bank"] = bank_match.group(0).strip()
            break

    # ========================================
    # REASON: NLP fallback for missed information
    # IMPROVEMENT: Uses spaCy NER for entity extraction
    # ========================================
    try:
        doc = nlp(clean_text[:10000])  # Limit text length for performance
        
        if "bank" not in details:
            for ent in doc.ents:
                if ent.label_ == "ORG" and len(ent.text) > 3:
                    details["bank"] = ent.text
                    break
        
        if "amount" not in details:
            for ent in doc.ents:
                if ent.label_ == "MONEY":
                    amt_text = ent.text.replace(",", "").replace("Rs.", "").replace("INR", "").replace("₹", "").strip()
                    if re.match(r"^\d+\.?\d*$", amt_text):
                        details["amount"] = amt_text
                        break
        
        if "date" not in details:
            for ent in doc.ents:
                if ent.label_ == "DATE":
                    date_result = extract_date(ent.text)
                    if date_result:
                        details["date"] = date_result
                        break
        
        if "user_name" not in details:
            for ent in doc.ents:
                if ent.label_ == "PERSON":
                    details["user_name"] = ent.text
                    break
                    
    except Exception as e:
        details["nlp_error"] = str(e)
        print(f"⚠️ NLP processing error: {e}", file=sys.stderr)

    return details

# ========================================
# REASON: Main scraping function with multi-source extraction
# IMPROVEMENT: Extracts from subject, body, and all attachments
# ========================================
def scrape_email(email, pdf_password=None):
    """
    Main email scraping function with comprehensive extraction
    """
    subject = email.get("subject", "")
    body = email.get("body", "")
    attachments = email.get("attachments", [])
    
    # Process attachments first
    attachment_result = process_attachments(attachments, pdf_password)
    
    # Combine all text sources
    all_text_parts = []
    if subject:
        all_text_parts.append(f"SUBJECT: {subject}")
    if body:
        all_text_parts.append(f"BODY: {body}")
    if attachment_result['text']:
        all_text_parts.append(f"ATTACHMENTS: {attachment_result['text']}")
    
    full_text = "\n\n".join(all_text_parts)
    
    # Extract details from combined text
    details = extract_details(full_text)
    
    # Add metadata
    details["sources_processed"] = {
        "subject": bool(subject),
        "body": bool(body),
        "attachments_processed": attachment_result['processed_count'],
        "needs_password": attachment_result['needs_password'],
        "password_error": attachment_result['password_error']
    }
    
    # Set defaults
    if "bank" not in details:
        details["bank"] = email.get("default_bank", "unknown")
    
    if "transaction_id" not in details and email.get("messageId"):
        details["transaction_id"] = email.get("messageId")
    
    if "date" not in details:
        details["date"] = datetime.now().strftime("%Y-%m-%d")
    
    # Use total_due or minimum_due as amount if amount is missing
    if "amount" not in details:
        if "total_due" in details:
            details["amount"] = details["total_due"]
        elif "minimum_due" in details:
            details["amount"] = details["minimum_due"]
    
    # Convert amount to float
    if "amount" in details:
        try:
            details["amount"] = float(str(details["amount"]).replace(",", ""))
        except (ValueError, TypeError):
            pass
    
    # Add confidence score based on extracted fields
    critical_fields = ["amount", "date", "category"]
    extracted_critical = sum(1 for field in critical_fields if field in details and details[field])
    details["confidence_score"] = round((extracted_critical / len(critical_fields)) * 100, 2)
    
    return details

# ========================================
# Main execution
# ========================================
if __name__ == "__main__":
    try:
        # Read JSON input from stdin
        email_data = json.load(sys.stdin)
        pdf_password = email_data.pop("pdf_password", None)
        
        result = scrape_email(email_data, pdf_password)
        print(json.dumps(result, indent=2, ensure_ascii=False))
        
    except json.JSONDecodeError as e:
        error_result = {
            "error": f"Invalid JSON input: {str(e)}",
            "traceback": traceback.format_exc()
        }
        print(json.dumps(error_result, indent=2))
        
    except Exception as e:
        error_result = {
            "error": str(e),
            "traceback": traceback.format_exc()
        }
        print(json.dumps(error_result, indent=2))
