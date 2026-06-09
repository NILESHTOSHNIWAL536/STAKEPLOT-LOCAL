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
        # print(json.dumps({"error": pdf_password}))
        result = scrape_email(email_data, user_banks, pdf_password)
        print(json.dumps(result, indent=2, ensure_ascii=False))
    except json.JSONDecodeError as e:
        print(json.dumps({"error": f"Invalid JSON input: {e}", "type": "json_error"}))
        sys.exit(1)
    except Exception as e:
        print(json.dumps({"error": str(e), "traceback": traceback.format_exc(),
                          "type": "runtime_error"}))
        sys.exit(1)
# !/usr/bin/env python3
# """
# scrapemail.py
# =============
# Unified email + PDF transaction scraper. Called as a subprocess from extract.ts.

# Input (stdin JSON):
#     {
#       "subject": "...",
#       "body": "...",
#       "attachments": [
#         {"filename": "stmt.pdf", "content": "<base64 or base64url>", "contentType": "application/pdf"},
#         ...
#       ],
#       "messageId": "...",
#       "from": "...",
#       "user_bank": ["hdfc", ...],
#       "pdf_passwords": {
#         "stmt.pdf": ["MARU8465"],     # filename-keyed
#         "_default": ["fallback1", ...] # tried for any PDF
#       },
#       "password": "MARU8465"           # optional, single password applied to all PDFs
#     }

# Output (stdout JSON) — exactly two data payloads:
#     {
#       "transactions": [...],      # ALL transactions (email + every PDF), deduped
#       "transaction_count": N,
#       "statements": [             # one entry per PDF attachment ([] when no PDF)
#         {
#           "filename": "...",
#           "document_type": "statement" | "transaction_alert" | "unknown",
#           "card_number": "5268 73XX XXXX 8465",
#           "card_last4": "8465",
#           "statement_date": "2026-05-21",
#           "billing_period": {...},
#           "payment_due": {...},
#           "credit_limits": {...},
#           "billing_cycle": {...},
#           "summary_text": "==== CREDIT CARD STATEMENT SUMMARY ====\n...",
#           "transaction_count": N,         # txns this PDF contributed (txns live up top)
#           "password_required": false,
#           "error": "..."                  # present only on failure
#         }
#       ],
#       "messageId": "...",
#       "from": "...",
#       "subject": "..."
#     }

# Guarantees:
# - Gmail base64URL attachments are decoded correctly (fixes the previous
#   "Stream has ended unexpectedly" failure).
# - Email scraping happens first and is never lost to a bad/encrypted PDF.
# - A failed PDF becomes an `error` entry inside `statements`; it never crashes the run.
# - No transactions found anywhere -> "transactions": [].
# """

# import re
# import os
# import sys
# import json
# import base64
# import tempfile
# import traceback
# from datetime import datetime


# # ==========================================================================
# # DATE / TIME / AMOUNT HELPERS
# # ==========================================================================
# _DATE_PARSE_FORMATS = (
#     "%d/%m/%Y", "%d-%m-%Y", "%d.%m.%Y",
#     "%d %b %Y", "%d %B %Y", "%b %d %Y", "%B %d %Y",
#     "%d %b, %Y", "%d %B, %Y",
#     "%Y-%m-%d", "%Y/%m/%d",
# )


# def to_iso(value):
#     """Best-effort date -> ISO YYYY-MM-DD."""
#     if not value:
#         return None
#     s = re.sub(r"(\d{1,2})(?:st|nd|rd|th)\b", r"\1", str(value).strip(), flags=re.I)
#     candidates = [s, re.sub(r"\s+", " ", s.replace(",", " ")).strip()]
#     for cand in candidates:
#         for fmt in _DATE_PARSE_FORMATS:
#             try:
#                 return datetime.strptime(cand, fmt).strftime("%Y-%m-%d")
#             except ValueError:
#                 continue
#     try:
#         from dateutil import parser as _p
#         return _p.parse(candidates[-1], dayfirst=True).strftime("%Y-%m-%d")
#     except Exception:
#         return s


# def _parse_amount(s):
#     try:
#         return float(str(s).replace(",", "").strip())
#     except (ValueError, TypeError):
#         return None


# def money(pattern, text):
#     m = re.search(pattern, text, re.IGNORECASE)
#     return float(m.group(1).replace(",", "")) if m else None


# # ==========================================================================
# # FREE-FORM FIELD EXTRACTORS (date / time / merchant / ref / balance)
# # ==========================================================================
# _DATE_FIND = [
#     re.compile(r"(\d{1,2}(?:st|nd|rd|th)?[\s\-/.]+[A-Za-z]{3,9}\.?[\s\-/.,]+\d{2,4})"),
#     re.compile(r"([A-Za-z]{3,9}\.?[\s\-/.]+\d{1,2}(?:st|nd|rd|th)?[\s,\-/]+\d{2,4})"),
#     re.compile(r"(\d{4}[\-/]\d{1,2}[\-/]\d{1,2})"),
#     re.compile(r"(\d{1,2}[\-/.]\d{1,2}[\-/.]\d{2,4})"),
# ]


# def _find_date_iso(text):
#     for pat in _DATE_FIND:
#         m = pat.search(text)
#         if m:
#             iso = to_iso(m.group(1))
#             if iso and re.fullmatch(r"\d{4}-\d{2}-\d{2}", iso):
#                 return iso
#     return None


# def _find_time(text):
#     m = (re.search(r"\bat\s+(\d{1,2}:\d{2}(?::\d{2})?)", text, re.I)
#          or re.search(r"\b(\d{1,2}:\d{2}(?::\d{2})?)", text))
#     if not m:
#         return None
#     for fmt in ("%H:%M:%S", "%H:%M"):
#         try:
#             return datetime.strptime(m.group(1), fmt).strftime("%H:%M:%S")
#         except ValueError:
#             continue
#     return m.group(1)


# _MERCHANT_PATTERNS = [
#     re.compile(r"\b(?:towards|in favou?r of)\s+(.+?)\s+\bon\b", re.I),
#     re.compile(r"\b(?:spent\s+at|paid\s+(?:to|at)|charged\s+at|at)\s+(.+?)\s+\bon\b", re.I),
#     re.compile(r"\b(?:towards|in favou?r of|spent\s+at|paid\s+(?:to|at)|at|to)\s+(.+?)[.,]", re.I),
#     re.compile(r"\bInfo[:\-]\s*(.+?)[.,\n]", re.I),
#     re.compile(r"\b(?:merchant|payee|beneficiary)[:\s]+(.+?)[.,\n]", re.I),
# ]
# _STOP_NAMES = {"your", "the", "a", "an", "card", "know", "you", "bank"}


# def _clean_name(s):
#     s = re.sub(r"\s+", " ", s or "").strip(" .,:;-_'\"")
#     s = re.split(r"\b(?:on|at|using|via|ref|dated|towards)\b", s, maxsplit=1, flags=re.I)[0].strip()
#     if not s or len(s) < 2 or len(s) > 60 or s.lower() in _STOP_NAMES:
#         return None
#     return s


# def _find_merchant(text):
#     for pat in _MERCHANT_PATTERNS:
#         m = pat.search(text)
#         if m:
#             name = _clean_name(m.group(1))
#             if name:
#                 return name
#     return None


# _REF_RE = re.compile(
#     r"(?:ref(?:erence)?\s*(?:no\.?|number|id)?|txn\s*(?:id|no\.?)?|transaction\s*(?:id|ref))"
#     r"[:\s#]*([A-Za-z0-9]{6,})", re.I)
# _BAL_RE = re.compile(
#     r"(?:avl\.?\s*bal(?:ance)?|available\s+balance)[:\s]*(?:rs\.?|inr|\u20b9)?\s*([\d,]+(?:\.\d{1,2})?)", re.I)


# def _find_reference(text):
#     m = _REF_RE.search(text)
#     return m.group(1) if m else None


# def _find_balance(text):
#     m = _BAL_RE.search(text)
#     return _parse_amount(m.group(1)) if m else None


# def _norm_type(word):
#     return "CREDIT" if (word or "").lower() in ("credited", "received", "refunded") else "DEBIT"


# # ==========================================================================
# # CARD NUMBER (bank-agnostic)
# # ==========================================================================
# _MASKCLASS = r"0-9Xx*\u2022\u00b7\u25cf"


# def _format_card(token):
#     token = re.sub(r"[*\u2022\u00b7\u25cfx]", "X", token)
#     return " ".join(token[i:i + 4] for i in range(0, len(token), 4))


# def extract_card_number(text):
#     if not text:
#         return None
#     collapsed = re.sub(r"(?<=[" + _MASKCLASS + r"])[ \-](?=[" + _MASKCLASS + r"])", "", text)
#     token_re = re.compile(r"(?<![0-9A-Za-z])([" + _MASKCLASS + r"]{12,19})(?![0-9A-Za-z])")
#     for m in token_re.finditer(collapsed):
#         tok = m.group(1)
#         if len(re.findall(r"[Xx*\u2022\u00b7\u25cf]", tok)) >= 2 and re.search(r"\d{4}$", tok):
#             return _format_card(tok)
#     labeled = [
#         re.compile(r"ending\s+(?:in|with)?\s*[:#]?\s*(\d{4})\b", re.I),
#         re.compile(r"card\s*(?:no\.?|number)?\s*[:#]?\s*(?:[" + _MASKCLASS + r"\- ]{0,16}?)(\d{4})\b", re.I),
#         re.compile(r"(?:[Xx*\u2022\u00b7\u25cf]{2,}\s*)(\d{4})\b"),
#     ]
#     for pat in labeled:
#         m = pat.search(text)
#         if m:
#             return _format_card("XXXXXXXXXXXX" + m.group(1))
#     return None


# def _card_last4(card_number):
#     if not card_number:
#         return None
#     digits = re.findall(r"\d", card_number)
#     return "".join(digits[-4:]) if len(digits) >= 4 else None


# # ==========================================================================
# # TRANSACTION SHAPE + EXTRACTORS
# # ==========================================================================
# def _txn(date=None, time=None, ttype=None, amount=None, merchant=None,
#          description=None, reference_id=None, available_balance=None, source=None):
#     return {
#         "date": date, "time": time, "type": ttype, "amount": amount,
#         "merchant": merchant, "description": description,
#         "reference_id": reference_id, "available_balance": available_balance,
#         "source": source,
#     }


# # Statement tables: "27/04/2026 | 17:12 DESC +/- C 1,234.00"
# _TABULAR_RE = re.compile(
#     r"(\d{2}/\d{2}/\d{4})\s*\|\s*(\d{2}:\d{2})\s+(.+?)\s+(\+?)\s*C\s?([\d,]+\.\d{2})")

# # Prose alerts: "Rs.1114.00 is debited ..."
# _PROSE_RE = re.compile(
#     r"(?:rs\.?|inr|\u20b9)\s*([\d,]+(?:\.\d{1,2})?)\s+(?:is|was|has\s+been)?\s*"
#     r"(debited|credited|spent|charged|paid|deducted|withdrawn|received)", re.I)


# def parse_tabular(text, source="pdf"):
#     txns = []
#     for date, time, desc, sign, amount in _TABULAR_RE.findall(text):
#         txns.append(_txn(
#             date=to_iso(date), time=f"{time}:00",
#             ttype="CREDIT" if sign == "+" else "DEBIT",
#             amount=_parse_amount(amount),
#             description=" ".join(desc.split()),
#             source=source,
#         ))
#     return txns


# def parse_prose(text, source="email"):
#     txns = []
#     for m in _PROSE_RE.finditer(text):
#         amount = _parse_amount(m.group(1))
#         if amount is None:
#             continue
#         window = text[m.start():m.start() + 240]
#         merchant = _find_merchant(window) or _find_merchant(text)
#         txns.append(_txn(
#             date=_find_date_iso(window) or _find_date_iso(text),
#             time=_find_time(window) or _find_time(text),
#             ttype=_norm_type(m.group(2)),
#             amount=amount,
#             merchant=merchant,
#             description=merchant or m.group(2).upper(),
#             reference_id=_find_reference(window),
#             available_balance=_find_balance(window),
#             source=source,
#         ))
#     return txns


# def parse_transactions(text, source="pdf"):
#     """Tabular rows first; fall back to prose alerts."""
#     tab = parse_tabular(text, source=source)
#     if tab:
#         return tab
#     return parse_prose(text, source=source)


# # ==========================================================================
# # STATEMENT SUMMARY TEXT (the human-readable box)
# # ==========================================================================
# def _rupee(v):
#     if isinstance(v, (int, float)):
#         return f"\u20b9{v:,.2f}"
#     return "N/A"


# def format_statement_summary(card_number, total_due, min_due, due_date_raw,
#                              statement_date_raw, billing_start_raw, billing_end_raw,
#                              total_limit, avail_credit, avail_cash,
#                              credit_used, utilization,
#                              prev_dues, payments, purchases, finance, cashback):
#     L = []
#     L.append("=" * 52)
#     L.append("        CREDIT CARD STATEMENT SUMMARY")
#     L.append("=" * 52)
#     L.append("")
#     L.append("[ CARD ]")
#     L.append(f"  Card Number      : {card_number or 'N/A'}")
#     L.append("")
#     L.append("[ PAYMENT DUE ]")
#     L.append(f"  Total Amount Due : {_rupee(total_due)}")
#     L.append(f"  Minimum Due      : {_rupee(min_due)}")
#     L.append(f"  Due Date         : {due_date_raw or 'N/A'}")
#     L.append("")
#     L.append("[ STATEMENT PERIOD ]")
#     L.append(f"  Statement Date   : {statement_date_raw or 'N/A'}")
#     period = (f"{billing_start_raw} to {billing_end_raw}"
#               if (billing_start_raw and billing_end_raw) else "N/A")
#     L.append(f"  Billing Period   : {period}")
#     L.append("")
#     L.append("[ CREDIT LIMITS ]")
#     L.append(f"  Total Limit      : {_rupee(total_limit)}")
#     L.append(f"  Available Credit : {_rupee(avail_credit)}")
#     L.append(f"  Available Cash   : {_rupee(avail_cash)}")
#     used_line = _rupee(credit_used)
#     if utilization is not None:
#         used_line += f"  ({round(utilization)}% utilization)"
#     L.append(f"  Credit Used      : {used_line}")
#     L.append("")
#     L.append("[ THIS BILLING CYCLE ]")
#     L.append(f"  Previous Dues    : {_rupee(prev_dues)}")
#     L.append(f"  Payments/Credits : {_rupee(payments)}")
#     L.append(f"  Purchases/Debits : {_rupee(purchases)}")
#     L.append(f"  Finance Charges  : {_rupee(finance)}")
#     L.append(f"  Cashback Earned  : {_rupee(cashback)}")
#     L.append("")
#     return "\n".join(L)


# # ==========================================================================
# # STATEMENT BUILDER (PDF body -> structured summary, no transactions inside)
# # ==========================================================================
# def build_statement(text, source="pdf"):
#     card_number = extract_card_number(text)

#     total_due = money(r"TOTAL AMOUNT DUE\s+C?\s?([\d,]+\.\d{2})", text)
#     min_due = money(r"MINIMUM DUE\s+C?\s?([\d,]+\.\d{2})", text)
#     dd = re.search(r"DUE DATE\s+(\d{1,2} \w+,? \d{4})", text)
#     due_date_raw = dd.group(1) if dd else None

#     bp = re.search(
#         r"(\d{1,2} \w+,? \d{4})\s*(?:-|\u2013|to)\s*(\d{1,2} \w+,? \d{4})", text)
#     billing_start_raw = bp.group(1) if bp else None
#     billing_end_raw = bp.group(2) if bp else None
#     statement_date_raw = billing_end_raw

#     lim = re.search(r"AVAILABLE CASH LIMIT\s+C?\s?([\d,]+)\s+C?\s?([\d,]+)\s+C?\s?([\d,]+)", text)
#     total_limit = float(lim.group(1).replace(",", "")) if lim else None
#     avail_credit = float(lim.group(2).replace(",", "")) if lim else None
#     avail_cash = float(lim.group(3).replace(",", "")) if lim else None

#     credit_used = utilization = None
#     if total_limit and avail_credit is not None:
#         credit_used = round(total_limit - avail_credit, 2)
#         utilization = round(credit_used / total_limit * 100, 2)

#     bd = re.search(
#         r"FINANCE CHARGES\s+C?\s?([\d,]+\.\d{2})\s+C?\s?([\d,]+\.\d{2})\s+"
#         r"C?\s?([\d,]+\.\d{2})\s+C?\s?([\d,]+\.\d{2})", text)
#     prev_dues, payments, purchases, finance = (
#         [float(g.replace(",", "")) for g in bd.groups()] if bd else [None] * 4)

#     cashback = money(r"CashBack\s+C\s?([\d,]+\.\d{2})", text)

#     is_statement = any(v is not None for v in
#                        (total_due, min_due, due_date_raw, total_limit, billing_start_raw))
#     transactions = parse_transactions(text, source=source)
#     document_type = ("statement" if is_statement
#                      else "transaction_alert" if transactions
#                      else "unknown")

#     summary_text = format_statement_summary(
#         card_number, total_due, min_due, due_date_raw,
#         statement_date_raw, billing_start_raw, billing_end_raw,
#         total_limit, avail_credit, avail_cash, credit_used, utilization,
#         prev_dues, payments, purchases, finance, cashback,
#     )

#     statement = {
#         "document_type": document_type,
#         "card_number": card_number,
#         "card_last4": _card_last4(card_number),
#         "statement_date": to_iso(statement_date_raw),
#         "billing_period": {"start": to_iso(billing_start_raw), "end": to_iso(billing_end_raw)},
#         "payment_due": {
#             "total_amount_due": total_due,
#             "minimum_due": min_due,
#             "due_date": to_iso(due_date_raw),
#         },
#         "credit_limits": {
#             "total_limit": total_limit,
#             "available_credit": avail_credit,
#             "available_cash": avail_cash,
#             "credit_used": credit_used,
#             "utilization_percent": utilization,
#         },
#         "billing_cycle": {
#             "previous_dues": prev_dues,
#             "payments_credits": payments,
#             "purchases_debits": purchases,
#             "finance_charges": finance,
#             "cashback_earned": cashback,
#         },
#         "summary_text": summary_text,
#     }
#     # transactions returned separately so they can bubble up to the top level
#     return statement, transactions


# # ==========================================================================
# # ROBUST ATTACHMENT DECODING  (the real fix for the stream error)
# # ==========================================================================
# def _b64_variants(s):
#     """Yield candidate decoded byte strings, most-likely first."""
#     s = s.strip()
#     if s.startswith("data:"):
#         s = s.split(",", 1)[1] if "," in s else s
#     s = re.sub(r"\s+", "", s)

#     def _pad(x):
#         r = len(x) % 4
#         return x + ("=" * (4 - r)) if r else x

#     # 1) base64url -> standard alphabet (Gmail / most mail APIs use this)
#     url_to_std = s.replace("-", "+").replace("_", "/")
#     try:
#         yield base64.b64decode(_pad(url_to_std), validate=False)
#     except Exception:
#         pass
#     # 2) plain standard base64 (untranslated)
#     try:
#         yield base64.b64decode(_pad(s), validate=False)
#     except Exception:
#         pass
#     # 3) explicit urlsafe decoder
#     try:
#         yield base64.urlsafe_b64decode(_pad(s))
#     except Exception:
#         pass


# def _decode_attachment_bytes(content):
#     """Decode attachment content to raw bytes, handling base64 / base64url /
#     Node Buffer JSON. Prefers a result that looks like a real PDF (%PDF header)."""
#     if isinstance(content, dict) and isinstance(content.get("data"), list):
#         return bytes(content["data"])            # Node Buffer {"type":"Buffer","data":[...]}
#     if isinstance(content, (bytes, bytearray)):
#         return bytes(content)
#     if isinstance(content, list):
#         return bytes(content)
#     if not isinstance(content, str):
#         raise ValueError(f"unsupported attachment content type: {type(content).__name__}")

#     first = None
#     for candidate in _b64_variants(content):
#         if first is None:
#             first = candidate
#         if candidate[:5] == b"%PDF-":
#             return candidate          # definitely the right decoding
#     if first is None:
#         raise ValueError("attachment content could not be base64-decoded")
#     return first                      # let pypdf try its best


# def _materialize_attachment(att):
#     """Return (path, is_temp). Writes a temp file from decoded content if needed."""
#     if att.get("path") and os.path.exists(att["path"]):
#         return att["path"], False
#     content = att.get("content") or att.get("data")
#     if content is None:
#         raise ValueError("attachment has no path/content/data")
#     raw = _decode_attachment_bytes(content)
#     fd, tmp = tempfile.mkstemp(suffix=".pdf", prefix="scrapemail_")
#     with os.fdopen(fd, "wb") as f:
#         f.write(raw)
#     return tmp, True


# # ==========================================================================
# # PASSWORD HANDLING
# # ==========================================================================
# def _candidate_passwords(filename, pdf_passwords):
#     candidates = [""]
#     seen = {""}

#     def _add(items):
#         for p in items or []:
#             if p is None:
#                 continue
#             ps = str(p)
#             if ps not in seen:
#                 seen.add(ps)
#                 candidates.append(ps)

#     if not pdf_passwords:
#         return candidates
#     base = os.path.basename(filename or "")
#     if filename and filename in pdf_passwords:
#         v = pdf_passwords[filename]
#         _add(v if isinstance(v, list) else [v])
#     if base and base != filename and base in pdf_passwords:
#         v = pdf_passwords[base]
#         _add(v if isinstance(v, list) else [v])
#     _add(pdf_passwords.get("_default") or pdf_passwords.get("default"))
#     for k, v in pdf_passwords.items():
#         if k in (filename, base, "_default", "default"):
#             continue
#         _add(v if isinstance(v, list) else [v])
#     return candidates


# def extract_pdf_text(path, filename, pdf_passwords):
#     """Returns (text, info). Raises only for unreadable/corrupt PDFs."""
#     from pypdf import PdfReader
#     reader = PdfReader(path)
#     info = {"password_required": False, "password_used": None, "pages": None}

#     # Decrypt FIRST — touching reader.pages on an encrypted file before
#     # decryption raises "File has not been decrypted".
#     if reader.is_encrypted:
#         unlocked = False
#         for pwd in _candidate_passwords(filename, pdf_passwords):
#             try:
#                 if reader.decrypt(pwd) != 0:
#                     unlocked = True
#                     info["password_used"] = pwd if pwd else "(empty)"
#                     break
#             except Exception:
#                 continue
#         if not unlocked:
#             info["password_required"] = True
#             return "", info

#     info["pages"] = len(reader.pages)
#     text = "\n".join((p.extract_text() or "") for p in reader.pages)
#     return text, info


# def process_pdf_attachment(att, pdf_passwords):
#     """Always returns (statement_dict, transactions_list). Never raises."""
#     filename = att.get("filename") or "attachment.pdf"
#     tmp_path = None
#     is_temp = False
#     try:
#         tmp_path, is_temp = _materialize_attachment(att)
#         text, info = extract_pdf_text(tmp_path, filename, pdf_passwords)

#         if info["password_required"]:
#             return ({
#                 "filename": filename,
#                 "password_required": True,
#                 "error": "encrypted_pdf_no_valid_password",
#                 "summary_text": None,
#             }, [])
#         if not text.strip():
#             return ({
#                 "filename": filename,
#                 "error": "empty_pdf_text",
#                 "summary_text": None,
#             }, [])

#         statement, txns = build_statement(text, source="pdf")
#         statement["filename"] = filename
#         statement["password_required"] = False
#         statement["password_used"] = info.get("password_used")
#         statement["transaction_count"] = len(txns)
#         return statement, txns
#     except Exception as e:
#         return ({
#             "filename": filename,
#             "error": "pdf_processing_failed",
#             "detail": str(e),
#             "traceback": traceback.format_exc(),
#             "summary_text": None,
#         }, [])
#     finally:
#         if is_temp and tmp_path and os.path.exists(tmp_path):
#             try:
#                 os.remove(tmp_path)
#             except OSError:
#                 pass


# # ==========================================================================
# # DEDUPE
# # ==========================================================================
# def _txn_key(t):
#     return (t.get("date"), t.get("amount"), t.get("type"),
#             (t.get("description") or "").strip().lower()[:40])


# def merge_transactions(*lists):
#     seen, merged = set(), []
#     for lst in lists:
#         for t in lst or []:
#             k = _txn_key(t)
#             if k in seen:
#                 continue
#             seen.add(k)
#             merged.append(t)
#     return merged


# def _is_pdf_attachment(att):
#     name = (att.get("filename") or "").lower()
#     ctype = (att.get("contentType") or att.get("mimeType") or "").lower()
#     return name.endswith(".pdf") or "pdf" in ctype


# # ==========================================================================
# # ENTRY
# # ==========================================================================
# def run(payload):
#     subject = payload.get("subject") or ""
#     body = payload.get("body") or ""
#     attachments = payload.get("attachments") or []
#     pdf_passwords = dict(payload.get("pdf_passwords") or {})

#     # Optional single top-level password applied to every PDF.
#     top_pw = payload.get("password") or payload.get("pdf_password")
#     if top_pw:
#         existing = pdf_passwords.get("_default") or []
#         if not isinstance(existing, list):
#             existing = [existing]
#         pdf_passwords["_default"] = [top_pw] + existing + ['Nilesh9849', 'MARU8465']
   
#     # 1) Email body + subject (prose alerts).
#     email_text = (subject + "\n" + body).strip()
#     email_transactions = parse_prose(email_text, "email") if email_text else []

#     # 2) PDF attachments -> statements + their transactions.
#     statements = []
#     pdf_transactions = []
#     for att in attachments:
#         if not _is_pdf_attachment(att):
#             continue
#         statement, txns = process_pdf_attachment(att, pdf_passwords)
#         pdf_transactions.extend(txns)
#         statements.append(statement)

#     # 3) ALL transactions at the top (deduped); statements hold only summaries.
#     all_transactions = merge_transactions(email_transactions, pdf_transactions)

#     return {
#         "transactions": all_transactions,
#         "transaction_count": len(all_transactions),
#         "statements": statements,
#         "messageId": payload.get("messageId"),
#         "from": payload.get("from"),
#         "subject": subject,
#     }


# if __name__ == "__main__":
#     try:
#         raw = sys.stdin.read()
#         if not raw.strip():
#             print(json.dumps({"error": "empty_stdin",
#                               "transactions": [], "statements": []}))
#             sys.exit(1)
#         try:
#             payload = json.loads(raw)
#         except json.JSONDecodeError as e:
#             print(json.dumps({"error": "invalid_json", "detail": str(e),
#                               "transactions": [], "statements": []}))
#             sys.exit(1)
#         print(json.dumps(run(payload), indent=2, ensure_ascii=False))
#     except Exception as e:
#         print(json.dumps({
#             "error": "runtime_error",
#             "detail": str(e),
#             "traceback": traceback.format_exc(),
#             "transactions": [], "statements": [],
#         }))
#         sys.exit(1)

