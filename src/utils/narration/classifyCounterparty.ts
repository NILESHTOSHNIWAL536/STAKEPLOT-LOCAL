import { ParsedNarration } from './types';

export type CounterpartyClass = 'P2M' | 'P2P' | 'unknown';

/**
 * Tokens that indicate the counterparty is a registered business / merchant.
 * Config-driven so new suffixes are added here without touching logic.
 */
const COMPANY_SUFFIX_TOKENS: string[] = [
  'PRIVATE LIMITED',
  'PVT LTD',
  'PVT. LTD',
  'LIMITED',
  'LLP',
  'LTD',
  'ENTERPRISES',
  'ENTERPRISE',
  'TRADERS',
  'TRADING',
  'FOODS',
  'FOOD',
  'MART',
  'RETAIL',
  'STORE',
  'STORES',
  'TECHNOLOGIES',
  'TECHNOLOGY',
  'TECH',
  'SOLUTIONS',
  'SOLUTION',
  'SERVICES',
  'SERVICE',
  'INDUSTRIES',
  'INDUSTRY',
  'CORPORATION',
  'CORP',
  'ASSOCIATES',
  'ASSOCIATION',
  'AGENCY',
  'VENTURES',
  'HOLDINGS',
  'GROUP',
  'INTERNATIONAL',
  'GLOBAL',
  'EXPORTS',
  'IMPORTS',
  'DISTRIBUTORS',
  'SUPPLIERS',
  'MANUFACTURER',
  'FABRICATORS',
  'INFRASTRUCTURE',
  'CONSTRUCTIONS',
  'BUILDERS',
  'DEVELOPERS',
  'COMMUNICATIONS',
  'MEDIA',
  'NETWORKS',
  'LOGISTICS',
  'CONSULTANCY',
  'CONSULTING',
];

/**
 * VPA patterns associated with merchant QR codes / payment aggregators.
 * These appear in the counterpartyVPA field.
 */
const MERCHANT_VPA_PATTERNS: RegExp[] = [
  /paytmqr/i,
  /paytm-/i,
  /bharatpe/i,
  /BBPSBP/i,
  /pinelabs/i,
  /razorpay/i,
  /cashfree/i,
  /payu/i,
  /billdesk/i,
  /amazonpay/i,
  /phonepe\.merchant/i,
  /gpay\.merchant/i,
  /gpay-/i,
  /okbiz/i,
  /rzp/i,
  /freecharge/i,
  /Q\d+/i,
];

/**
 * Heuristic: a P2P person name is typically two short (≤20 char) all-alpha tokens.
 * This is intentionally conservative — we'd rather call 'unknown' than mis-route
 * a merchant to Transfers.
 */
function looksLikePersonName(name: string): boolean {
  const tokens = name.trim().split(/\s+/);
  if (tokens.length < 2 || tokens.length > 4) return false;
  return tokens.every((t) => /^[A-Za-z]{2,20}$/.test(t));
}

function containsCompanySuffix(name: string): boolean {
  const upper = name.toUpperCase();
  return COMPANY_SUFFIX_TOKENS.some((suffix) => upper.includes(suffix));
}

function vpaIsmerchant(vpa: string): boolean {
  return MERCHANT_VPA_PATTERNS.some((re) => re.test(vpa));
}

/**
 * Classifies the counterparty of a transaction as P2M (merchant), P2P (person),
 * or unknown (insufficient signal).
 *
 * Inputs:
 *   parsed   — structured narration from parseNarration(); may be null
 *   merchant — the `merchant` field on the transaction document (if populated)
 *   isAutoPay — true when the recurring-payment detector flagged this transaction
 *
 * Resolution order (first conclusive signal wins):
 *   1. `merchant` field non-empty                     → P2M
 *   2. `isAutoPay` flag set                           → P2M
 *   3. counterpartyVPA matches a known merchant VPA pattern → P2M
 *   4. counterpartyName contains a company-suffix token → P2M
 *   5. counterpartyName looks like a person name      → P2P
 *   6. No conclusive signal                           → unknown
 */
export function classifyCounterparty(
  parsed: ParsedNarration | null,
  merchant: string | undefined,
  isAutoPay: boolean | undefined,
): CounterpartyClass {
  // Signal 1: merchant field already populated by enrichment
  if (merchant && merchant.trim().length > 0) return 'P2M';

  // Signal 2: recurring payment flag
  if (isAutoPay) return 'P2M';

  if (!parsed) return 'unknown';

  const { counterpartyVPA, counterpartyName } = parsed;

  // Signal 3: VPA pattern matches a known merchant aggregator
  if (counterpartyVPA && vpaIsmerchant(counterpartyVPA)) return 'P2M';

  if (!counterpartyName) return 'unknown';

  // Signal 4: company-suffix tokens in the name
  if (containsCompanySuffix(counterpartyName)) return 'P2M';

  // Signal 5: name looks like a person
  if (looksLikePersonName(counterpartyName)) return 'P2P';

  return 'unknown';
}
