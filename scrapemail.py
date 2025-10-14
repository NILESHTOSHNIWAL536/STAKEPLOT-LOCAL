import re
import json
from datetime import datetime
import spacy
import sys

# Load spaCy model
try:
    nlp = spacy.load("en_core_web_sm")
except OSError:
    raise OSError("⚠️ spaCy model 'en_core_web_sm' not found. Run: python -m spacy download en_core_web_sm")

# Unicode Sanitizer
def sanitize_text(text: str) -> str:
    if not text:
        return ""
    return text.encode("utf-8", "ignore").decode("utf-8", "ignore")

# Transaction Classifier (broad pattern matching)
def classify_transaction(text: str):
    clean = text.lower()
    if any(k in clean for k in ["debited", "withdrawn", "spent", "paid", "purchase", "atm", "transaction alert", "debit alert", "charged"]):
        return "Debit"
    elif any(k in clean for k in ["credited", "received", "salary", "refund", "cashback", "credit alert", "deposit", "added"]):
        return "Credit"
    elif any(k in clean for k in ["loan disbursed", "borrowed", "sanctioned", "approved", "disbursal", "borrow order confirmed", "transferred to your bank", "borrow confirmation"]):
        return "Borrow"
    elif any(k in clean for k in ["repayment successful", "emi paid", "installment paid", "loan closed", "bill paid", "payment successful", "repaid"]):
        return "Repayment"
    elif any(k in clean for k in ["outstanding", "due", "minimum due", "bill generated", "statement", "monthly statement", "bill summary", "borrow statement"]):
        return "Statement"
    else:
        return "Other"

# Extraction Logic (flexible for varied patterns)
def extract_details(text: str):
    details = {}
    clean_text = " ".join(sanitize_text(text).split())

    # Category
    details["category"] = classify_transaction(clean_text)

    # Amount (support multiple currency formats and decimals)
    amt_match = re.search(r"(?:Rs\.?|INR|₹|Amount|Rs|INR\s|₹\s)?\s?([\d,]+\.?\d{0,2})", clean_text, re.IGNORECASE)
    if amt_match:
        details["amount"] = amt_match.group(1).replace(",", "")

    # Date (support multiple date formats)
    date_match = re.search(r"\b(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})\b|([A-Za-z]{3,9}\s?\d{1,2}(?:st|nd|rd|th)?,?\s?\d{2,4})|\b(\d{1,2}\s[A-Za-z]{3,9}\s\d{4})\b", clean_text, re.IGNORECASE)
    if date_match:
        date_str = date_match.group(0).replace("st,", "").replace("nd,", "").replace("rd,", "").replace("th,", "")
        try:
            parsed_date = datetime.strptime(date_str, "%B %d %Y") if "," in date_str else datetime.strptime(date_str, "%d %B %Y")
            details["date"] = parsed_date.strftime("%Y-%m-%d")
        except ValueError:
            try:
                parsed_date = datetime.strptime(date_str, "%d-%m-%Y") or datetime.strptime(date_str, "%d/%m/%Y")
                details["date"] = parsed_date.strftime("%Y-%m-%d")
            except ValueError:
                details["date"] = date_str  # Keep raw date if parsing fails

    # Due Date (specific for statements or repayments)
    due_date_match = re.search(r"(?:Due Date|Payment Due|Repay By)[:\- ]?\s?(\d{1,2}[-/]\d{1,2}[-/]\d{2,4}|[A-Za-z]{3,9}\s?\d{1,2}(?:st|nd|rd|th)?,?\s?\d{2,4})", clean_text, re.IGNORECASE)
    if due_date_match:
        due_date_str = due_date_match.group(1).replace("st,", "").replace("nd,", "").replace("rd,", "").replace("th,", "")
        try:
            parsed_date = datetime.strptime(due_date_str, "%B %d %Y") if "," in due_date_str else datetime.strptime(due_date_str, "%d %B %Y")
            details["due_date"] = parsed_date.strftime("%Y-%m-%d")
        except ValueError:
            try:
                parsed_date = datetime.strptime(due_date_str, "%d-%m-%Y") or datetime.strptime(due_date_str, "%d/%m/%Y")
                details["due_date"] = parsed_date.strftime("%Y-%m-%d")
            except ValueError:
                details["due_date"] = due_date_str

    # Card Number (last 4 digits, flexible patterns)
    card_match = re.search(r"(?:xx|xxxx|x{2,}|ending in|Card\s*No\.?|card\s*ending|last\s*4\s*digits|card)[:\- ]?\s*(\d{4})", clean_text, re.IGNORECASE)
    if card_match:
        details["card_number"] = card_match.group(1)

    # Transaction ID (support UUIDs, order IDs, etc.)
    txn_match = re.search(r"(?:Txn(?: Ref)?|Transaction ID|RID|Reference|Transaction Reference Number|Order ID|BW|RID-)[:\- ]+([\w\-]{6,})", clean_text, re.IGNORECASE)
    if txn_match:
        val = txn_match.group(1)
        if val.lower() not in ["is", "no"]:
            details["transaction_id"] = val

    # Loan ID
    loan_match = re.search(r"(?:Loan ID|Loan Number|Borrow ID)[:\- ]+([A-Za-z0-9\-]{4,})", clean_text, re.IGNORECASE)
    if loan_match:
        details["loan_id"] = loan_match.group(1)

    # Total Due (for statements)
    total_due_match = re.search(r"(?:Total Due|Outstanding Balance|Amt Due|Amount Due|Statement Balance)[:\- ]?\s?(?:Rs\.?|INR|₹)?\s?([\d,]+\.?\d*)", clean_text, re.IGNORECASE)
    if total_due_match:
        details["total_due"] = total_due_match.group(1).replace(",", "")

    # Minimum Due
    min_due_match = re.search(r"(?:Min(?:imum)? Due|Minimum Amount Due)[:\- ]?\s?(?:Rs\.?|INR|₹)?\s?([\d,]+\.?\d*)", clean_text, re.IGNORECASE)
    if min_due_match:
        details["minimum_due"] = min_due_match.group(1).replace(",", "")

    # Mode (expanded payment modes)
    mode_match = re.search(r"(UPI|IMPS|NEFT|RTGS|Netbanking|Wallet|Credit Card|Debit Card|ATM|Auto Debit|Cheque|slice borrow|Bank Transfer)", clean_text, re.IGNORECASE)
    if mode_match:
        details["mode"] = mode_match.group(0).upper()

    # User ID (from greeting)
    user_match = re.search(r"Hi (\w+),|Dear (\w+),", clean_text, re.IGNORECASE)
    if user_match:
        details["user_id"] = user_match.group(1) or user_match.group(2)

    # Bank (dynamic extraction)
    bank_match = re.search(r"\b([A-Z][A-Za-z0-9& ]{2,}(?:Bank|Credit Card|Debit Card|Finance|Services|slice))", clean_text)
    if bank_match and len(bank_match.group(0)) > 5:
        details["bank"] = bank_match.group(0)

    # NLP Fallback (extract missing fields)
    try:
        doc = nlp(clean_text)
        if "bank" not in details:
            for ent in doc.ents:
                if ent.label_ == "ORG" and len(ent.text) > 3:
                    details["bank"] = ent.text
                    break
        if "amount" not in details:
            for ent in doc.ents:
                if ent.label_ == "MONEY":
                    details["amount"] = ent.text.replace(",", "").replace("Rs.", "").replace("INR", "").replace("₹", "").strip()
                    break
        if "date" not in details:
            for ent in doc.ents:
                if ent.label_ == "DATE":
                    details["date"] = ent.text
                    try:
                        parsed_date = datetime.strptime(ent.text, "%B %d %Y") if "," in ent.text else datetime.strptime(ent.text, "%d %B %Y")
                        details["date"] = parsed_date.strftime("%Y-%m-%d")
                    except ValueError:
                        try:
                            parsed_date = datetime.strptime(ent.text, "%d-%m-%Y") or datetime.strptime(ent.text, "%d/%m/%Y")
                            details["date"] = parsed_date.strftime("%Y-%m-%d")
                        except ValueError:
                            pass
                    break
        if "user_id" not in details:
            for ent in doc.ents:
                if ent.label_ == "PERSON":
                    details["user_id"] = ent.text
                    break
    except Exception as e:
        details["nlp_error"] = str(e)

    return details

def scrape_email(email):
    # Combine subject and body for extraction
    subject = email.get("subject", "")
    body = email.get("body", "")
    full_text = subject + " " + body

    # Extract details
    details = extract_details(full_text)

    # Ensure default bank
    if "bank" not in details:
        details["bank"] = "slice small finance bank"

    # Ensure transaction_id includes messageId if available
    if "transaction_id" not in details and email.get("messageId"):
        details["transaction_id"] = email.get("messageId")

    # Set date to current date if not found
    if "date" not in details:
        details["date"] = datetime.now().strftime("%Y-%m-%d")

    # If total_due or minimum_due exists but not amount, use it
    if "amount" not in details and "total_due" in details:
        details["amount"] = details["total_due"]
    elif "amount" not in details and "minimum_due" in details:
        details["amount"] = details["minimum_due"]

    # Convert amount to float if possible
    if "amount" in details:
        try:
            details["amount"] = float(details["amount"])
        except (ValueError, TypeError):
            pass  # Keep as string if conversion fails

    return details

# Main execution for Node.js integration
if __name__ == "__main__":
    try:
        # Read JSON input from stdin (sent by Node.js)
        email_data = json.load(sys.stdin)
        result = scrape_email(email_data)
        print(json.dumps(result, indent=2, ensure_ascii=False))
    except json.JSONDecodeError as e:
        print(json.dumps({"error": f"Invalid JSON input: {str(e)}"}, indent=2))
    except Exception as e:
        print(json.dumps({"error": str(e)}, indent=2))