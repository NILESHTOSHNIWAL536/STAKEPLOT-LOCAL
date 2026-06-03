import re
import sys
import json
import base64
import traceback
from io import BytesIO
from datetime import datetime

# --------------------------------------------------------------------------
# Optional dependencies (graceful degradation)
# --------------------------------------------------------------------------
try:
    from pypdf import PdfReader
except ImportError:
    try:
        from PyPDF2 import PdfReader  # type: ignore
    except ImportError:
        PdfReader = None

try:
    from dateutil import parser as _dateutil_parser
except Exception:
    _dateutil_parser = None

# spaCy is used ONLY as a fallback for merchant detection. Loading is lazy so
# a missing model never crashes the script (the old code raised on import).
_NLP = None
_NLP_TRIED = False


def _get_nlp():
    global _NLP, _NLP_TRIED
    if _NLP_TRIED:
        return _NLP
    _NLP_TRIED = True
    try:
        import spacy
        _NLP = spacy.load("en_core_web_sm")
    except Exception:
        _NLP = None  # regex carries the load on its own
    return _NLP


# ==========================================================================
# CONFIG
# ==========================================================================
BANK_IDENTIFIERS = {
    'HDFC':  {'keywords': ['hdfc', 'hdfcbank'],          'exclude': ['slice']},
    'ICICI': {'keywords': ['icici', 'icicibank'],        'exclude': []},
    'Axis':  {'keywords': ['axis', 'axisbank'],          'exclude': []},
    'SBI':   {'keywords': ['sbi', 'state bank', 'sbicard'], 'exclude': []},
    'Slice': {'keywords': ['slice', 'sliceit'],          'exclude': []},
    'Kotak': {'keywords': ['kotak'],                     'exclude': []},
    'IDFC':  {'keywords': ['idfc'],                      'exclude': []},
    'IndusInd': {'keywords': ['indusind'],               'exclude': []},
}

BANK_NAME_MAP = {
    'hdfc': 'HDFC', 'hdfc bank': 'HDFC',
    'icici': 'ICICI', 'icici bank': 'ICICI',
    'axis': 'Axis', 'axis bank': 'Axis',
    'sbi': 'SBI', 'sbi card': 'SBI', 'state bank': 'SBI',
    'slice': 'Slice', 'slicebank': 'Slice',
    'kotak': 'Kotak', 'idfc': 'IDFC', 'indusind': 'IndusInd',
}

TRANSACTION_KEYWORDS = {
    'debit':     ['debited', 'charged', 'deducted', 'withdrawn', 'spent', 'paid', 'purchase', 'txn alert'],
    'credit':    ['credited', 'received', 'added', 'deposited', 'salary', 'refund', 'cashback'],
    'statement': ['statement', 'bill generated', 'outstanding', 'amount due', 'total due', 'summary'],
    'loan':      ['loan', 'emi', 'disbursed', 'sanctioned'],
    'reward':    ['reward', 'cashback', 'points', 'bonus'],
}


# ==========================================================================
# TEXT NORMALISATION
# ==========================================================================
_MOJIBAKE = {
    'â‚¹': 'Rs ', 'Ã¢â€šÂ¹': 'Rs ', 'â€™': "'", 'â€“': '-', 'â€”': '-',
    'â€˜': "'", 'â€œ': '"', 'â€\x9d': '"', 'Â ': ' ', 'Â': '',
}


def sanitize_text(text):
    """Normalise encoding artefacts, strip HTML, collapse whitespace."""
    if not text:
        return ""
    for bad, good in _MOJIBAKE.items():
        text = text.replace(bad, good)
    # Real rupee sign and currency words -> a single canonical token "Rs".
    text = text.replace('\u20b9', ' Rs ')
    # Strip HTML (bank emails are frequently HTML) and common entities.
    text = re.sub(r'<(script|style)[^>]*>.*?</\1>', ' ', text, flags=re.I | re.S)
    text = re.sub(r'<[^>]+>', ' ', text)
    text = re.sub(r'&nbsp;', ' ', text, flags=re.I)
    text = re.sub(r'&amp;', '&', text, flags=re.I)
    text = re.sub(r'&(?:lt|gt|quot|#\d+);', ' ', text, flags=re.I)
    # Remove zero-width / invisible characters.
    text = re.sub(r'[\u200b\u200c\u200d\ufeff]', '', text)
    text = text.encode("utf-8", "ignore").decode("utf-8", "ignore")
    # Normalise whitespace but keep newlines (they help merchant boundaries).
    text = re.sub(r'[ \t]+', ' ', text)
    text = re.sub(r'\n{2,}', '\n', text)
    return text.strip()


def normalize_bank_name(bank_name):
    return BANK_NAME_MAP.get(str(bank_name).lower().strip(), str(bank_name).upper())


def belongs_to_any_bank(text, target_banks):
    """Return (matched_bank, belongs). Empty target list => accept all."""
    if not target_banks:
        return (None, True)
    low = text.lower()
    for bank in target_banks:
        cfg = BANK_IDENTIFIERS.get(normalize_bank_name(bank), {})
        if any(k in low for k in cfg.get('exclude', [])):
            continue
        kws = cfg.get('keywords', [])
        if not kws or any(k in low for k in kws):
            return (normalize_bank_name(bank), True)
    return (None, False)


def classify_transaction(text):
    low = text.lower()
    if any(k in low for k in ["repayment", "emi paid", "installment paid", "loan closed", "payment successful"]):
        return "Repayment"
    if any(k in low for k in TRANSACTION_KEYWORDS['debit']):
        return "Debit"
    if any(k in low for k in TRANSACTION_KEYWORDS['credit']):
        return "Credit"
    if any(k in low for k in TRANSACTION_KEYWORDS['statement']):
        return "Statement"
    if any(k in low for k in TRANSACTION_KEYWORDS['loan']):
        return "Borrow"
    if any(k in low for k in TRANSACTION_KEYWORDS['reward']):
        return "Reward"
    return "Other"


def is_financial_email(text):
    kws = ['bank', 'credit card', 'debit', 'credited', 'debited', 'transaction',
           'payment', 'amount', 'rs', 'rupees', 'inr', 'loan', 'emi', 'statement',
           'bill', 'alert', 'charged', 'spent', 'transferred', 'upi']
    low = text.lower()
    return sum(1 for k in kws if k in low) >= 2


# ==========================================================================
# DATE + TIME  (the main bug area)
# ==========================================================================
_ORDINAL = re.compile(r'(\d{1,2})(?:st|nd|rd|th)\b', re.I)

# Ordered most-specific first. Alpha-month forms come before numeric so that
# "14 Apr, 2026" is never mis-read by the numeric DD/MM pattern.
_DATE_PATTERNS = [
    # 14 Apr, 2026 | 14 April 2026 | 14-Apr-2026 | 14th Apr 2026
    re.compile(r'(\d{1,2}(?:st|nd|rd|th)?[\s\-/.]+[A-Za-z]{3,9}\.?[\s\-/.,]+\d{2,4})'),
    # Apr 14, 2026 | April 14 2026 | Apr-14-2026
    re.compile(r'([A-Za-z]{3,9}\.?[\s\-/.]+\d{1,2}(?:st|nd|rd|th)?[\s,\-/]+\d{2,4})'),
    # 2026-04-14 | 2026/04/14
    re.compile(r'(\d{4}[\-/]\d{1,2}[\-/]\d{1,2})'),
    # 14/04/2026 | 14-04-2026 | 14.04.26
    re.compile(r'(\d{1,2}[\-/.]\d{1,2}[\-/.]\d{2,4})'),
]

_STRPTIME_FORMATS = [
    "%d %b %Y", "%d %B %Y", "%d %b %y", "%d %B %y",
    "%b %d %Y", "%B %d %Y", "%b %d, %Y", "%B %d, %Y",
    "%d-%m-%Y", "%d/%m/%Y", "%d.%m.%Y",
    "%d-%m-%y", "%d/%m/%y", "%d.%m.%y",
    "%Y-%m-%d", "%Y/%m/%d",
]

# Prefer a time that follows "at"; otherwise accept a standalone HH:MM[:SS].
_TIME_AT = re.compile(r'\bat\s+(\d{1,2}:\d{2}(?::\d{2})?)\s*([AaPp]\.?[Mm]\.?)?', re.I)
_TIME_ANY = re.compile(r'\b(\d{1,2}:\d{2}(?::\d{2})?)\s*([AaPp]\.?[Mm]\.?)?')
_TIME_FORMATS = ["%H:%M:%S", "%H:%M", "%I:%M:%S %p", "%I:%M %p", "%I:%M%p"]


def _parse_date_token(token):
    """Turn a captured date string into a datetime, or None."""
    token = _ORDINAL.sub(r'\1', token).replace(',', ' ')
    token = re.sub(r'\s+', ' ', token).strip()
    # "14-Apr-2026" -> "14 Apr 2026" so strptime month parsing works.
    norm = re.sub(r'(?<=\d)[\-/.](?=[A-Za-z])', ' ', token)
    norm = re.sub(r'(?<=[A-Za-z])[\-/.](?=\d)', ' ', norm)
    norm = re.sub(r'\s+', ' ', norm).strip()
    for cand in (token, norm):
        for fmt in _STRPTIME_FORMATS:
            try:
                return datetime.strptime(cand, fmt)
            except ValueError:
                continue
    if _dateutil_parser is not None:  # last-resort robust parser (dayfirst = Indian)
        for cand in (token, norm):
            try:
                return _dateutil_parser.parse(cand, dayfirst=True, fuzzy=False)
            except Exception:
                continue
    return None


def extract_datetime(text):
    """Return (date_obj | None, time_obj | None), preferring dates after 'on'."""
    best, best_pref = None, False
    for pat in _DATE_PATTERNS:
        for m in pat.finditer(text):
            dt = _parse_date_token(m.group(1))
            if not dt:
                continue
            preceded = text[max(0, m.start() - 8):m.start()].lower()
            preferred = ('on ' in preceded) or ('dated' in preceded)
            if best is None or (preferred and not best_pref):
                best, best_pref = dt, preferred
            if best_pref:
                break
        if best_pref:
            break

    time_obj = None
    tm = _TIME_AT.search(text) or _TIME_ANY.search(text)
    if tm:
        raw = tm.group(1)
        ampm = (tm.group(2) or '').replace('.', '').upper()
        candidate = (raw + (' ' + ampm if ampm else '')).strip()
        for fmt in _TIME_FORMATS:
            try:
                time_obj = datetime.strptime(candidate, fmt).time()
                break
            except ValueError:
                continue
    return best, time_obj


# ==========================================================================
# AMOUNT
# ==========================================================================
# A money token: supports Indian grouping (1,23,456) and decimals.
_AMOUNT_TOKEN = r'(\d{1,3}(?:[,\s]\d{2,3})+(?:\.\d{1,2})?|\d+(?:\.\d{1,2})?)'
_CUR = r'(?:rs\.?|inr|rupees)'
_AMOUNT_PATTERNS = [
    re.compile(_CUR + r'\s*' + _AMOUNT_TOKEN, re.I),       # Rs 1,660.00
    re.compile(_AMOUNT_TOKEN + r'\s*' + _CUR, re.I),       # 1,660.00 Rs
]
_ACTION_NEAR = re.compile(
    r'(debit|credit|spent|paid|charged|transferr|withdraw|due|received|disbursed|purchase)',
    re.I,
)


def _to_float(s):
    try:
        return float(s.replace(',', '').replace(' ', ''))
    except ValueError:
        return None


def extract_primary_amount(text):
    """Pick the transaction amount, favouring one next to an action verb."""
    candidates = []  # (value, position, near_action)
    for pat in _AMOUNT_PATTERNS:
        for m in pat.finditer(text):
            val = _to_float(m.group(1))
            if val is None or not (1 <= val <= 1e8):
                continue
            window = text[max(0, m.start() - 30):m.end() + 30]
            candidates.append((val, m.start(), bool(_ACTION_NEAR.search(window))))
    if not candidates:
        return ""
    near = [c for c in candidates if c[2]]
    pool = sorted(near or candidates, key=lambda c: c[1])
    val = pool[0][0]
    return str(int(val)) if val == int(val) else f"{val:.2f}"


# ==========================================================================
# MERCHANT  (entirely new)
# ==========================================================================
_MERCHANT_STOP = {
    'the', 'your', 'a', 'an', 'rs', 'inr', 'rupees', 'account', 'acct', 'a/c',
    'card', 'bank', 'upi', 'imps', 'neft', 'rtgs', 'ref', 'reference', 'txn',
    'transaction', 'avl', 'available', 'balance', 'bal', 'info', 'dear',
    'customer', 'user', 'on', 'via', 'using', 'for', 'with', 'no', 'number',
    'id', 'date', 'dated', 'you', 'was', 'is', 'has', 'been', 'to', 'at',
    'from', 'of', 'and', 'payment', 'amount',
}
_BANK_WORDS = {'hdfc', 'icici', 'axis', 'sbi', 'slice', 'kotak', 'citi', 'yes',
               'idfc', 'indusind', 'state', 'rbl'}

_MERCHANT_PATTERNS = [
    # UPI VPA, e.g. "VPA swiggy@okhdfcbank"
    re.compile(r'\bVPA[:\s]+([\w.\-]{2,}@[\w.\-]+)', re.I),
    re.compile(r'\b([\w.\-]{2,}@(?:ok\w+|ybl|axl|paytm|ibl|apl|upi|hdfcbank|icici|sbi|axis))\b', re.I),
    # "...spent/paid/charged ... at MERCHANT (on|via|.|,|end)"
    re.compile(r'\b(?:spent|paid|purchase\w*|charged|debited)[\w\s]*?\bat\s+(.+?)\s*(?:\bon\b|\bvia\b|\busing\b|\bdated\b|\bref\b|\bwith\b|[.,]|$)', re.I),
    # generic "at MERCHANT on/via/using/dated/ref"
    re.compile(r'\bat\s+([A-Za-z0-9][\w&.\-\' ]{1,45}?)\s+(?:on|via|using|dated|ref|with)\b', re.I),
    # transfers / payees: "to / towards / trf to MERCHANT ..."
    re.compile(r'\b(?:towards|trf to|transferred to|sent to|paid to|in favou?r of|to)\s+([A-Za-z0-9][\w&.\-\' ]{1,45}?)\s*(?:\bon\b|\bvia\b|\bref\b|\bupi\b|a/c|account|[.,]|$)', re.I),
    # explicit labels
    re.compile(r'\bInfo[:\-]\s*([A-Za-z0-9][\w&.\-\'/ ]{1,45})', re.I),
    re.compile(r'\b(?:merchant|payee|beneficiary|biller)[:\s]+([A-Za-z0-9][\w&.\-\' ]{1,45})', re.I),
]


def _clean_merchant(name):
    if not name:
        return ""
    name = re.sub(r'\s+', ' ', name).strip(" .,:;-_/\t\n\"'")
    # Drop trailing tails the regex may have over-captured.
    name = re.sub(r'\s+(?:on|dated|via|using|ref\b.*|txn\b.*)$', '', name, flags=re.I).strip()
    if not name or len(name) < 2 or len(name) > 60:
        return ""
    toks = [t for t in name.split() if t]
    if not toks or all(t.lower() in _MERCHANT_STOP for t in toks):
        return ""
    if name.lower() in _BANK_WORDS:
        return ""
    if re.fullmatch(r'[\d\W]+', name):  # only digits / punctuation
        return ""
    return name


def _vpa_to_name(vpa):
    handle = vpa.split('@', 1)[0]
    handle = re.sub(r'[._\-]+', ' ', handle)
    handle = re.sub(r'\d{3,}', '', handle).strip()
    cleaned = _clean_merchant(handle) or _clean_merchant(vpa.split('@', 1)[0])
    if cleaned and cleaned.islower():
        return cleaned.title()
    return cleaned


def extract_merchant(text):
    for pat in _MERCHANT_PATTERNS:
        m = pat.search(text)
        if not m:
            continue
        raw = m.group(1)
        result = _vpa_to_name(raw) if '@' in raw else _clean_merchant(raw)
        if result:
            return result
    # Fallback: spaCy named entities (only if the model is installed).
    nlp = _get_nlp()
    if nlp is not None:
        try:
            for ent in nlp(text[:1000]).ents:
                if ent.label_ in ("ORG", "PERSON", "FAC", "PRODUCT"):
                    cand = _clean_merchant(ent.text)
                    if cand and cand.lower() not in _BANK_WORDS:
                        return cand
        except Exception:
            pass
    return ""


# ==========================================================================
# OTHER FIELDS
# ==========================================================================
_CARD_PATTERNS = [
    re.compile(r'ending\s+(?:in|with)?\s*[:#]?\s*(\d{4})\b', re.I),
    re.compile(r'(?:card|a/c|acct|account)\s*(?:no\.?|number)?\s*[:#]?\s*(?:[xX*]{2,}[xX*\s\-]*)(\d{4})\b', re.I),
    re.compile(r'(?:[xX*]{2,}|\*\*)\s*(\d{4})\b'),
]


def extract_card_number(text):
    for pat in _CARD_PATTERNS:
        m = pat.search(text)
        if m:
            return m.group(1)
    return ""


_ORDER_PATTERNS = [
    re.compile(r'(?:order\s+id|order\s+no)[:\s]+([A-Za-z0-9]{6,})', re.I),
    re.compile(r'(?:txn(?:\s+ref)?|transaction\s+(?:id|ref)|reference\s+(?:no|number)|upi\s+ref(?:\s+no)?)[:\s]+([A-Za-z0-9\-]{6,})', re.I),
    re.compile(r'\b(BW[A-Za-z0-9]{15,})\b'),
    re.compile(r'\b(RID-[A-Za-z0-9\-]{6,})\b'),
]


def extract_order_id(text):
    for pat in _ORDER_PATTERNS:
        m = pat.search(text)
        if m:
            val = m.group(1)
            if val.lower() not in {"is", "no", "transaction", "reference", "purposes"}:
                return val
    return ""


_MODE_RE = re.compile(
    r'\b(UPI|IMPS|NEFT|RTGS|Net\s*Banking|Wallet|Credit\s*Card|Debit\s*Card|ATM|'
    r'Auto\s*Debit|E?-?Mandate|Standing\s*Instruction|POS|EMI|Cheque|Bank\s*Transfer|'
    r'PhonePe|Google\s*Pay|GPay|Paytm|Amazon\s*Pay)\b',
    re.I,
)


def extract_mode(text):
    m = _MODE_RE.search(text)
    return m.group(0).replace(" ", "").upper() if m else ""


# ==========================================================================
# PDF ATTACHMENTS  (kept, with the same external contract)
# ==========================================================================
def _decode_attachment_data(data):
    if not data:
        return b""
    padded = data + "=" * (-len(data) % 4)
    try:
        return base64.urlsafe_b64decode(padded)
    except Exception:
        try:
            return base64.b64decode(padded)
        except Exception:
            return b""


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

    seen, unique = set(), []
    for pw in candidates:
        if pw and pw not in seen:
            seen.add(pw)
            unique.append(pw)
    return unique


def _extract_pdf_text(attachment, password_candidates):
    filename = attachment.get("filename") or attachment.get("name") or "statement.pdf"
    mime = (attachment.get("mimeType") or attachment.get("mime") or "").lower()
    if not (filename.lower().endswith(".pdf") or mime == "application/pdf"):
        return {"text": "", "processed": False}

    if PdfReader is None:
        return {"text": "", "processed": True, "needs_password": True,
                "password_error": "pdf_reader_unavailable", "password_file": filename}

    raw = _decode_attachment_data(attachment.get("data") or "")
    if not raw:
        return {"text": "", "processed": True}

    try:
        reader = PdfReader(BytesIO(raw))
        if getattr(reader, "is_encrypted", False):
            if not password_candidates:
                return {"text": "", "processed": True, "needs_password": True,
                        "password_error": "password_required", "password_file": filename}
            if not any(_safe_decrypt(reader, pw) for pw in password_candidates):
                return {"text": "", "processed": True, "needs_password": True,
                        "password_error": "invalid_password", "password_file": filename}
        text = "\n".join((page.extract_text() or "") for page in reader.pages)
        return {"text": text, "processed": True}
    except Exception as exc:
        msg = str(exc).lower()
        needs = any(w in msg for w in ("password", "decrypt", "encrypted"))
        return {"text": "", "processed": True, "needs_password": needs,
                "password_error": "password_required" if needs else "pdf_parse_failed",
                "password_file": filename}


def _safe_decrypt(reader, password):
    try:
        return bool(reader.decrypt(password))
    except Exception:
        return False


# ==========================================================================
# ORCHESTRATION
# ==========================================================================
def extract_details(text, user_banks=None, detection_text=None):
    details = {}
    clean = sanitize_text(text)

    if user_banks is None:
        user_banks = []
    elif isinstance(user_banks, str):
        user_banks = [user_banks]

    # Bank membership is decided on subject + sender + body, because many banks
    # only identify themselves in the From address (e.g. alerts@hdfcbank.net).
    detect = sanitize_text(detection_text) if detection_text else clean
    matched_bank, belongs = belongs_to_any_bank(detect, user_banks)
    if user_banks and not belongs:
        return {"category": "Other", "banks_checked": user_banks, "matched_bank": None,
                "date": datetime.now().strftime("%Y-%m-%d"), "confidence_score": 0,
                "skipped": True, "reason": "Email does not belong to any selected bank"}

    if not is_financial_email(clean):
        return {"category": "Other", "banks_checked": user_banks,
                "matched_bank": matched_bank, "date": datetime.now().strftime("%Y-%m-%d"),
                "confidence_score": 0}

    details["category"] = classify_transaction(clean)
    details["banks_checked"] = user_banks
    details["matched_bank"] = matched_bank or "unknown"

    amount = extract_primary_amount(clean)
    if amount:
        details["amount"] = amount

    date_obj, time_obj = extract_datetime(clean)
    if date_obj:
        details["date"] = date_obj.strftime("%Y-%m-%d")
    if time_obj:
        details["time"] = time_obj.strftime("%H:%M:%S")
        if date_obj:
            details["datetime"] = f"{date_obj.strftime('%Y-%m-%d')}T{time_obj.strftime('%H:%M:%S')}"

    merchant = extract_merchant(clean)
    if merchant:
        details["merchant"] = merchant

    card = extract_card_number(clean)
    if card:
        details["card_number"] = card

    oid = extract_order_id(clean)
    if oid:
        details["transaction_id"] = oid

    mode = extract_mode(clean)
    if mode:
        details["mode"] = mode

    return details


def scrape_email(email, user_banks=None, pdf_passwords=None):
    subject = email.get("subject", "") or ""
    body = email.get("body", "") or ""
    sender = email.get("from", "") or ""

    if user_banks is None:
        user_banks = []
    elif isinstance(user_banks, str):
        user_banks = [user_banks]

    attachments = email.get("attachments") or []
    password_candidates = _password_candidates(pdf_passwords, user_banks)
    attachment_text_parts = []
    attachment_status = {"attachments_processed": 0, "needs_password": False,
                         "password_error": None, "password_file": None}

    for attachment in attachments:
        pdf_result = _extract_pdf_text(attachment, password_candidates)
        if not pdf_result.get("processed"):
            continue
        attachment_status["attachments_processed"] += 1
        if pdf_result.get("text"):
            attachment_text_parts.append(pdf_result["text"])
        if pdf_result.get("needs_password"):
            attachment_status.update(needs_password=True,
                                      password_error=pdf_result.get("password_error"),
                                      password_file=pdf_result.get("password_file"))
            break
        elif pdf_result.get("password_error"):
            attachment_status["password_error"] = pdf_result.get("password_error")

    # Sender is included for bank detection but kept out of field extraction.
    detection_text = f"{subject}\n{sender}\n{body}"
    full_text = f"{subject}\n\n{body}\n\n{chr(10).join(attachment_text_parts)}".strip()

    if attachment_status["needs_password"]:
        matched_bank, _ = belongs_to_any_bank(detection_text, user_banks)
        return {"category": "Other", "banks_checked": user_banks,
                "matched_bank": matched_bank or (user_banks[0] if user_banks else "unknown"),
                "date": datetime.now().strftime("%Y-%m-%d"), "confidence_score": 0,
                "message_id": email.get("messageId", ""),
                "sources_processed": {"subject": bool(subject), "body": bool(body), **attachment_status}}

    if not full_text or len(full_text) < 10:
        return {"category": "Other", "banks_checked": user_banks, "matched_bank": "unknown",
                "date": datetime.now().strftime("%Y-%m-%d"), "confidence_score": 0,
                "sources_processed": {"subject": bool(subject), "body": bool(body), **attachment_status}}

    # Detect the bank from subject+sender+body, then extract from full text.
    details = extract_details(full_text, user_banks, detection_text=detection_text)

    if details.get("skipped"):
        return details

    details["sources_processed"] = {"subject": bool(subject), "body": bool(body), **attachment_status}
    details["message_id"] = email.get("messageId", "")
    details.setdefault("matched_bank", "unknown")
    details.setdefault("date", datetime.now().strftime("%Y-%m-%d"))

    if "amount" in details:
        try:
            details["amount"] = float(str(details["amount"]).replace(",", ""))
        except (ValueError, TypeError):
            details.pop("amount", None)

    scored = ["amount", "date", "merchant", "category"]
    got = sum(1 for k in scored if details.get(k) and details.get(k) != "Other")
    details["confidence_score"] = round(got / len(scored) * 100, 2)
    return details


# ==========================================================================
# ENTRY POINT  (stdin JSON -> stdout JSON; unchanged contract for the TS side)
# ==========================================================================
if __name__ == "__main__":
    try:
        email_data = json.load(sys.stdin)
        user_banks = email_data.pop("user_bank", None)
        pdf_password = email_data.pop("pdf_passwords", None) or email_data.pop("pdf_password", None)
        result = scrape_email(email_data, user_banks, pdf_password)
        print(json.dumps(result, indent=2, ensure_ascii=False))
    except json.JSONDecodeError as e:
        print(json.dumps({"error": f"Invalid JSON input: {e}", "type": "json_error"}))
        sys.exit(1)
    except Exception as e:
        print(json.dumps({"error": str(e), "traceback": traceback.format_exc(),
                          "type": "runtime_error"}))
        sys.exit(1)


# import re
# import json
# from datetime import datetime
# import spacy
# import sys
# import traceback
# import base64
# from io import BytesIO

# try:
#     from pypdf import PdfReader
# except ImportError:
#     try:
#         from PyPDF2 import PdfReader
#     except ImportError:
#         PdfReader = None

# try:
#     nlp = spacy.load("en_core_web_sm")
# except OSError:
#     raise OSError("spaCy model 'en_core_web_sm' not found. Run: python -m spacy download en_core_web_sm")

# # ========================================
# # BANK IDENTIFIERS (for filtering emails)
# # ========================================
# BANK_IDENTIFIERS = {
#     'HDFC': {
#         'keywords': ['hdfc', 'hdfcbank', 'alerts@hdfcbank'],
#         'exclude_keywords': ['slice', 'axis', 'icici', 'sbi', 'citi']
#     },
#     'ICICI': {
#         'keywords': ['icici', 'icicibank'],
#         'exclude_keywords': ['hdfc', 'slice', 'axis', 'sbi']
#     },
#     'Axis': {
#         'keywords': ['axis', 'axisbank'],
#         'exclude_keywords': ['hdfc', 'slice', 'icici', 'sbi']
#     },
#     'SBI': {
#         'keywords': ['sbi', 'state bank'],
#         'exclude_keywords': ['hdfc', 'slice', 'axis', 'icici']
#     },
#     'Slice': {
#         'keywords': ['slice', 'sliceit', 'slicebank'],
#         'exclude_keywords': ['hdfc', 'axis', 'icici', 'sbi']
#     },
# }

# # ========================================
# # TRANSACTION TYPE KEYWORDS
# # ========================================
# TRANSACTION_KEYWORDS = {
#     'debit': ['debited', 'charged', 'deducted', 'withdrawn', 'spent', 'paid', 'transaction alert'],
#     'credit': ['credited', 'received', 'added', 'deposited', 'salary', 'refund', 'cashback'],
#     'statement': ['statement', 'bill generated', 'outstanding', 'due', 'summary'],
#     'loan': ['loan', 'borrow', 'emi', 'disbursed', 'sanctioned', 'transferred'],
#     'reward': ['reward', 'cashback', 'points', 'bonus', 'offer']
# }

# def sanitize_text(text: str) -> str:
#     """Clean and normalize text"""
#     if not text:
#         return ""
#     # Replace all variants of rupee symbols
#     text = text.replace('â‚¹', 'Rs').replace('Ã¢â€šÂ¹', 'Rs').replace('Rs.', 'Rs')
#     # Remove zero-width spaces and other hidden Unicode
#     text = re.sub(r'[\u200b\u200c\u200d\ufeff]', '', text)
#     # Decode and clean
#     return text.encode("utf-8", "ignore").decode("utf-8", "ignore").strip()

# def normalize_bank_name(bank_name: str) -> str:
#     """Normalize bank name to match BANK_IDENTIFIERS keys"""
#     bank_lower = bank_name.lower().strip()
    
#     # Map common variations to standardized names
#     bank_map = {
#         'hdfc bank': 'HDFC',
#         'hdfc': 'HDFC',
#         'icici bank': 'ICICI',
#         'icici': 'ICICI',
#         'axis bank': 'Axis',
#         'axis': 'Axis',
#         'sbi': 'SBI',
#         'sbi card': 'SBI',
#         'state bank': 'SBI',
#         'slice': 'Slice',
#         'slicebank': 'Slice',
#     }
    
#     return bank_map.get(bank_lower, bank_name.upper())

# def belongs_to_any_bank(text: str, target_banks: list) -> tuple:
#     """
#     Check if email belongs to any of the target banks.
#     Returns (matched_bank, belongs) tuple
#     """
#     if not target_banks:
#         return (None, True)
    
#     text_lower = text.lower()
    
#     for bank in target_banks:
#         normalized_bank = normalize_bank_name(bank)
#         bank_config = BANK_IDENTIFIERS.get(normalized_bank, {})
        
#         # Check for excluding keywords first (stronger negative signal)
#         exclude_keywords = bank_config.get('exclude_keywords', [])
#         exclude_match = any(keyword in text_lower for keyword in exclude_keywords)
        
#         # Check for include keywords
#         keywords = bank_config.get('keywords', [])
#         if keywords:
#             include_match = any(keyword in text_lower for keyword in keywords)
#         else:
#             include_match = True
        
#         # If this bank matches and no exclude keywords found, return it
#         if include_match and not exclude_match:
#             return (normalized_bank, True)
    
#     return (None, False)

# def classify_transaction(text: str) -> str:
#     """Classify transaction type"""
#     clean = text.lower()
    
#     if any(k in clean for k in ["repayment", "emi paid", "installment paid", "loan closed", "payment successful"]):
#         return "Repayment"
#     elif any(k in clean for k in TRANSACTION_KEYWORDS['debit']):
#         return "Debit"
#     elif any(k in clean for k in TRANSACTION_KEYWORDS['credit']):
#         return "Credit"
#     elif any(k in clean for k in TRANSACTION_KEYWORDS['statement']):
#         return "Statement"
#     elif any(k in clean for k in TRANSACTION_KEYWORDS['loan']):
#         return "Borrow"
#     elif any(k in clean for k in TRANSACTION_KEYWORDS['reward']):
#         return "Reward"
#     else:
#         return "Other"

# def extract_date(text: str) -> str:
#     """Extract and normalize date from text"""
#     patterns = [
#         r"\b(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})\b",
#         r"([A-Za-z]{3,9}\s+\d{1,2}(?:st|nd|rd|th)?,?\s+\d{2,4})",
#         r"\b(\d{1,2}\s+[A-Za-z]{3,9}\s+\d{4})\b",
#         r"\b(\d{4}[-/]\d{1,2}[-/]\d{1,2})\b",
#     ]
    
#     for pattern in patterns:
#         match = re.search(pattern, text, re.IGNORECASE)
#         if match:
#             date_str = match.group(1).replace("st", "").replace("nd", "").replace("rd", "").replace("th", "").replace(",", "").strip()
            
#             date_formats = [
#                 "%d-%m-%Y", "%d/%m/%Y", "%d %m %Y",
#                 "%d-%m-%y", "%d/%m/%y",
#                 "%d %B %Y", "%d %b %Y", "%B %d %Y", "%b %d %Y",
#                 "%Y-%m-%d", "%Y/%m/%d", "%b %d, %Y"
#             ]
            
#             for fmt in date_formats:
#                 try:
#                     parsed_date = datetime.strptime(date_str, fmt)
#                     return parsed_date.strftime("%Y-%m-%d")
#                 except ValueError:
#                     continue
            
#             return date_str
    
#     return None

# def extract_primary_amount(text: str, category: str) -> str:
#     """
#     Extract PRIMARY transaction amount.
#     Handles amounts with formatting issues (commas, spaces, etc.)
#     """
#     # Clean text first - remove all hidden chars and normalize spaces
#     clean_text = re.sub(r'\s+', ' ', text)
    
#     # Patterns for finding amounts with robust matching
#     patterns = [
#         # Pattern 1: "transferred â‚¹1,660" or "transferred Rs 1660"
#         r'(?:transferred|disbursed|credited)\s+(?:Rs|rupees|â‚¹)\s*[\s,]*(\d+)(?:[,\s]*(\d{3}))*(?:[.,](\d{2}))?',
        
#         # Pattern 2: "Rs.1,660 debited/credited"
#         r'(?:Rs|rupees|â‚¹)\s*[\s,]*(\d+)(?:[,\s]*(\d{3}))*(?:[.,](\d{2}))?\s+(?:is\s+)?(?:debited|credited|charged|transferred)',
        
#         # Pattern 3: "Amount: Rs 1660" or "Amount: Rs.1,660"
#         r'(?:amount|total)[:\s]+(?:Rs|rupees|â‚¹)[\s,]*(\d+)(?:[,\s]*(\d{3}))*(?:[.,](\d{2}))?',
        
#         # Pattern 4: Generic number after Rs/rupees
#         r'(?:Rs|rupees|â‚¹)[\s,]*(\d+)(?:[,\s]*(\d{3}))*(?:[.,](\d{2}))?',
        
#         r'(?:Rs|rupees|â‚¹|INR)[\s,]*(\d+)(?:[,\s]*(\d{3}))*(?:[.,](\d{2}))?',
#     ]
    
#     for pattern in patterns:
#         matches = re.finditer(pattern, clean_text, re.IGNORECASE)
#         for match in matches:
#             # Reconstruct the number from groups
#             groups = match.groups()
            
#             if groups[0]:  # Main amount
#                 main = groups[0]
                
#                 # Handle thousands
#                 thousands = groups[1] if len(groups) > 1 and groups[1] else ''
                
#                 # Handle decimals
#                 decimals = groups[2] if len(groups) > 2 and groups[2] else ''
                
#                 if thousands:
#                     amount_str = main + thousands
#                 else:
#                     amount_str = main
                
#                 if decimals:
#                     amount_str = amount_str + '.' + decimals
                
#                 try:
#                     amount_val = float(amount_str)
#                     # Reasonable range for transactions
#                     if 1 <= amount_val <= 100000000:
#                         return amount_str
#                 except ValueError:
#                     continue
    
#     return ""

# def extract_card_number(text: str) -> str:
#     """Extract card number (usually last 4 digits)"""
#     patterns = [
#         r"(?:ending\s+(?:in|with)[:\s]*)(\d{4})",
#         r"(?:\*{2,}|\*\*)\s*(\d{4})",
#         r"(?:\*{4}[-\s]?){3}(\d{4})",
#     ]
    
#     for pattern in patterns:
#         match = re.search(pattern, text, re.IGNORECASE)
#         if match:
#             return match.group(1)
    
#     return ""

# def extract_order_id(text: str) -> str:
#     """Extract Order ID, Txn ID, Reference ID"""
#     patterns = [
#         r"(?:order\s+id|order\s+no)[:\s]+([A-Za-z0-9]{6,})",
#         r"(?:txn(?:\s+ref)?|transaction\s+(?:id|ref)|reference\s+(?:no|number))[:\s]+([A-Za-z0-9\-]{6,})",
#         r"\b(BW[A-Za-z0-9]{15,})\b",
#         r"\b(RID-[A-Za-z0-9\-]{6,})\b",
#     ]
    
#     for pattern in patterns:
#         match = re.search(pattern, text, re.IGNORECASE)
#         if match:
#             val = match.group(1)
#             if val.lower() not in ["is", "no", "transaction", "reference", "purposes"]:
#                 return val
    
#     return ""

# def extract_mode(text: str) -> str:
#     """Extract payment mode"""
#     pattern = r"\b(UPI|IMPS|NEFT|RTGS|Net\s*Banking|Wallet|Credit\s*Card|Debit\s*Card|ATM|Auto\s*Debit|Cheque|Bank\s*Transfer|PhonePe|Google\s*Pay|Paytm|Amazon\s*Pay)\b"
#     match = re.search(pattern, text, re.IGNORECASE)
#     if match:
#         return match.group(0).replace(" ", "").upper()
#     return ""

# def is_financial_email(text: str) -> bool:
#     """Check if email is actually financial/banking related"""
#     financial_keywords = [
#         'bank', 'credit card', 'debit', 'credited', 'debited', 
#         'transaction', 'payment', 'amount', 'rs', 'rupees',
#         'loan', 'emi', 'statement', 'bill', 'alert', 'charged',
#         'borrow', 'transferred'
#     ]
    
#     text_lower = text.lower()
#     count = sum(1 for keyword in financial_keywords if keyword in text_lower)
#     return count >= 2

# def extract_details(text: str, user_banks: list = None):
#     """Extract transaction details from email text for multiple banks"""
#     details = {}
#     clean_text = sanitize_text(text)
    
#     # Normalize user_banks to handle various input formats
#     if user_banks is None:
#         user_banks = []
#     elif isinstance(user_banks, str):
#         user_banks = [user_banks]
    
#     # Check if email belongs to any target bank
#     matched_bank, belongs = belongs_to_any_bank(clean_text, user_banks)
    
#     if user_banks and not belongs:
#         return {
#             "category": "Other",
#             "banks_checked": user_banks,
#             "matched_bank": None,
#             "date": datetime.now().strftime("%Y-%m-%d"),
#             "confidence_score": 0,
#             "skipped": True,
#             "reason": "Email does not belong to any selected bank"
#         }
    
#     # Check if it's a financial email
#     if not is_financial_email(clean_text):
#         return {
#             "category": "Other",
#             "banks_checked": user_banks,
#             "matched_bank": matched_bank,
#             "date": datetime.now().strftime("%Y-%m-%d"),
#             "confidence_score": 0,
#         }
    
#     # Classify transaction
#     category = classify_transaction(clean_text)
#     details["category"] = category
#     details["banks_checked"] = user_banks
#     details["matched_bank"] = matched_bank if matched_bank else "unknown"
    
#     # ========================================
#     # AMOUNT EXTRACTION
#     # ========================================
#     amount = extract_primary_amount(clean_text, category)
#     if amount:
#         details["amount"] = amount
    
#     # ========================================
#     # DATE EXTRACTION
#     # ========================================
#     date_result = extract_date(clean_text)
#     if date_result:
#         details["date"] = date_result
    
#     # ========================================
#     # CARD NUMBER EXTRACTION
#     # ========================================
#     card_number = extract_card_number(clean_text)
#     if card_number:
#         details["card_number"] = card_number
    
#     # ========================================
#     # ORDER/TRANSACTION ID EXTRACTION
#     # ========================================
#     order_id = extract_order_id(clean_text)
#     if order_id:
#         details["transaction_id"] = order_id
    
#     # ========================================
#     # PAYMENT MODE EXTRACTION
#     # ========================================
#     mode = extract_mode(clean_text)
#     if mode:
#         details["mode"] = mode
    
#     return details

# def _decode_attachment_data(data: str) -> bytes:
#     if not data:
#         return b""

#     padded = data + "=" * (-len(data) % 4)
#     try:
#         return base64.urlsafe_b64decode(padded)
#     except Exception:
#         return base64.b64decode(padded)

# def _password_candidates(pdf_passwords, user_banks):
#     candidates = []

#     if isinstance(pdf_passwords, str):
#         candidates.append(pdf_passwords)
#     elif isinstance(pdf_passwords, list):
#         candidates.extend(pdf_passwords)
#     elif isinstance(pdf_passwords, dict):
#         for bank in user_banks or []:
#             values = pdf_passwords.get(bank) or pdf_passwords.get(str(bank).lower())
#             if isinstance(values, str):
#                 candidates.append(values)
#             elif isinstance(values, list):
#                 candidates.extend(values)
#         for values in pdf_passwords.values():
#             if isinstance(values, str):
#                 candidates.append(values)
#             elif isinstance(values, list):
#                 candidates.extend(values)

#     seen = set()
#     unique = []
#     for password in candidates:
#         if not password or password in seen:
#             continue
#         seen.add(password)
#         unique.append(password)
#     return unique

# def _extract_pdf_text(attachment, password_candidates):
#     filename = attachment.get("filename") or attachment.get("name") or "statement.pdf"
#     mime_type = attachment.get("mimeType") or attachment.get("mime") or ""
#     is_pdf = filename.lower().endswith(".pdf") or mime_type.lower() == "application/pdf"

#     if not is_pdf:
#         return {"text": "", "processed": False}

#     if PdfReader is None:
#         return {
#             "text": "",
#             "processed": True,
#             "needs_password": True,
#             "password_error": "pdf_reader_unavailable",
#             "password_file": filename,
#         }

#     raw = _decode_attachment_data(attachment.get("data") or "")
#     if not raw:
#         return {"text": "", "processed": True}

#     try:
#         reader = PdfReader(BytesIO(raw))
#         if getattr(reader, "is_encrypted", False):
#             if not password_candidates:
#                 return {
#                     "text": "",
#                     "processed": True,
#                     "needs_password": True,
#                     "password_error": "password_required",
#                     "password_file": filename,
#                 }

#             decrypted = False
#             for password in password_candidates:
#                 try:
#                     decrypt_result = reader.decrypt(password)
#                     if decrypt_result != 0:
#                         decrypted = True
#                         break
#                 except Exception:
#                     continue

#             if not decrypted:
#                 return {
#                     "text": "",
#                     "processed": True,
#                     "needs_password": True,
#                     "password_error": "invalid_password",
#                     "password_file": filename,
#                 }

#         text_parts = []
#         for page_number, page in enumerate(reader.pages, start=1):
#             page_text = page.extract_text() or ""
#             if page_text:
#                 text_parts.append(page_text)

#         text = "\n".join(text_parts)
#         return {"text": text, "processed": True}
#     except Exception as exc:
#         message = str(exc).lower()
#         if "password" in message or "decrypt" in message or "encrypted" in message:
#             return {
#                 "text": "",
#                 "processed": True,
#                 "needs_password": True,
#                 "password_error": "password_required",
#                 "password_file": filename,
#             }

#         return {
#             "text": "",
#             "processed": True,
#             "needs_password": False,
#             "password_error": "pdf_parse_failed",
#             "password_file": filename,
#         }

# def scrape_email(email, user_banks=None, pdf_passwords=None):
#     """Main email scraping function supporting multiple banks"""
#     subject = email.get("subject", "") or ""
#     body = email.get("body", "") or ""
    
#     # Normalize user_banks to handle various input formats
#     if user_banks is None:
#         user_banks = []
#     elif isinstance(user_banks, str):
#         user_banks = [user_banks]

#     attachments = email.get("attachments") or []
#     password_candidates = _password_candidates(pdf_passwords, user_banks)
#     attachment_text_parts = []
#     attachment_status = {
#         "attachments_processed": 0,
#         "needs_password": False,
#         "password_error": None,
#         "password_file": None,
#     }

#     for attachment in attachments:
#         pdf_result = _extract_pdf_text(attachment, password_candidates)
#         if not pdf_result.get("processed"):
#             continue

#         attachment_status["attachments_processed"] += 1
#         if pdf_result.get("text"):
#             attachment_text_parts.append(pdf_result["text"])

#         if pdf_result.get("needs_password"):
#             attachment_status["needs_password"] = True
#             attachment_status["password_error"] = pdf_result.get("password_error")
#             attachment_status["password_file"] = pdf_result.get("password_file")
#             break
#         elif pdf_result.get("password_error"):
#             attachment_status["password_error"] = pdf_result.get("password_error")

#     # Combine all text
#     full_text = f"{subject}\n\n{body}\n\n{chr(10).join(attachment_text_parts)}".strip()

#     if attachment_status["needs_password"]:
#         matched_bank, _ = belongs_to_any_bank(f"{subject}\n{body}", user_banks)
#         return {
#             "category": "Other",
#             "banks_checked": user_banks,
#             "matched_bank": matched_bank or (user_banks[0] if user_banks else "unknown"),
#             "date": datetime.now().strftime("%Y-%m-%d"),
#             "confidence_score": 0,
#             "message_id": email.get("messageId", ""),
#             "sources_processed": {
#                 "subject": bool(subject),
#                 "body": bool(body),
#                 **attachment_status,
#             }
#         }
    
#     # If no text, return empty result
#     if not full_text or len(full_text) < 10:
#         return {
#             "category": "Other",
#             "banks_checked": user_banks,
#             "matched_bank": "unknown",
#             "date": datetime.now().strftime("%Y-%m-%d"),
#             "confidence_score": 0,
#             "sources_processed": {
#                 "subject": bool(subject),
#                 "body": bool(body),
#                 **attachment_status,
#             }
#         }
    
#     # Extract details
#     details = extract_details(full_text, user_banks)
    
#     # Skip if email doesn't belong to any bank
#     if details.get("skipped"):
#         return details
    
#     # Add metadata
#     details["sources_processed"] = {
#         "subject": bool(subject),
#         "body": bool(body),
#         **attachment_status,
#     }
#     details["message_id"] = email.get("messageId", "")
    
#     # Set matched_bank if not found
#     if "matched_bank" not in details or details["matched_bank"] == "unknown":
#         details["matched_bank"] = details.get("matched_bank", "unknown")
    
#     # Set date if not found
#     if "date" not in details:
#         details["date"] = datetime.now().strftime("%Y-%m-%d")
    
#     # Convert amount to numeric
#     if "amount" in details:
#         try:
#             details["amount"] = float(str(details["amount"]).replace(",", ""))
#         except (ValueError, TypeError):
#             details.pop("amount", None)
    
#     # Confidence score
#     extracted_fields = sum(1 for k in ["amount", "date", "category"] if k in details and details[k])
#     details["confidence_score"] = round((extracted_fields / 3) * 100, 2)
    
#     return details

# # ========================================
# # MAIN EXECUTION
# # ========================================
# if __name__ == "__main__":
#     try:
#         email_data = json.load(sys.stdin)
#         user_banks = email_data.pop("user_bank", None)
#         pdf_password = email_data.pop("pdf_passwords", None) or email_data.pop("pdf_password", None)
        
#         result = scrape_email(email_data, user_banks, pdf_password)
#         print(json.dumps(result, indent=2, ensure_ascii=False))
        
#     except json.JSONDecodeError as e:
#         error_result = {
#             "error": f"Invalid JSON input: {str(e)}",
#             "type": "json_error"
#         }
#         print(json.dumps(error_result, indent=2))
#         sys.exit(1)
#     except Exception as e:
#         error_result = {
#             "error": str(e),
#             "traceback": traceback.format_exc(),
#             "type": "runtime_error"
#         }
#         print(json.dumps(error_result, indent=2))
#         sys.exit(1)
