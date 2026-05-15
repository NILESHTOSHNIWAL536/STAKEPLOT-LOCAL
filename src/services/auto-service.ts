// ─── Types ────────────────────────────────────────────────────────────────────
import { RecurringPayment, Transaction } from '@/models';
import { IBankTransaction } from '@/types/bank';
import { Types } from 'mongoose';


export type Frequency = 'monthly' | 'quarterly' | 'biannual' | 'annual';

// export interface RawTransaction {
//   _id: string;
//   type: 'DEBIT' | 'CREDIT';
//   mode: string;
//   amount: number;
//   transactionTimestamp: string | Date;
//   narration: string;
//   category?: string;
//   subcategory?: string;
//   isAutoPay?: boolean;
//   autoPayId?: string;
//   merchant?: string;
//   expectedFrequency?: string;
//   userId: string;
//   accountId: string;
// }

export interface DetectedAutoPay {
  // Matched transaction IDs (most recent first)
  transactionIds: string[];
  recentMostTransactionId: string;
  transactions: IBankTransaction[];
  recentMostTransaction: IBankTransaction;
  userId: string | object;

  // Merchant info
  merchant: string;
  merchantCategory: MerchantCategory;
  normalizedMerchantKey: string; // for dedup / grouping

  // Payment info
  amount: number;
  amountVariance: number; // % variance across occurrences (0 = exact)
  currency: string;

  // Frequency
  frequency: Frequency;
  averageIntervalDays: number;
  intervalConsistencyScore: number; // 0–1, higher = more regular

  // Timestamps
  recentMostTransactionTimestamp: Date;
  nextReminderAt: Date;
  recentMostTwoOccurrences: Date[];

  occurrencesCount: number;
  isActive: boolean; // false if last payment > 1.5× expected interval ago

  // Confidence
  confidenceScore: number; // 0–1
  confidenceLabel: 'high' | 'medium' | 'low';

  // Source narrations used for detection
  matchedNarrations: string[];
  detectionMethod: 'keyword_match' | 'merchant_name' | 'bbps' | 'amount_pattern' | 'manual';
}

export type MerchantCategory =
  | 'streaming'
  | 'telecom'
  | 'internet'
  | 'utility'
  | 'music'
  | 'gaming'
  | 'cloud'
  | 'insurance'
  | 'emi'
  | 'subscription_other';

// ─── Merchant Fingerprint Dictionary ─────────────────────────────────────────
// Each entry: { keywords[], category, canonicalName }
// keywords are matched against the FULL narration (case-insensitive)

interface MerchantFingerprint {
  keywords: string[];
  category: MerchantCategory;
  canonicalName: string;
  /** Typical amounts in INR — used as soft hint, not hard filter */
  typicalAmounts?: number[];
}

export const MERCHANT_FINGERPRINTS: MerchantFingerprint[] = [
  // ── Streaming ──────────────────────────────────────────────────────────────
  {
    canonicalName: 'Netflix',
    category: 'streaming',
    keywords: ['netflix'],
    typicalAmounts: [149, 199, 499, 649, 799],
  },
  {
    canonicalName: 'Disney+ Hotstar',
    category: 'streaming',
    keywords: ['hotstar', 'disneyplus', 'disney+', 'disney plus'],
    typicalAmounts: [299, 499, 899, 1499],
  },
  {
    canonicalName: 'Amazon Prime Video',
    category: 'streaming',
    keywords: ['primevideo', 'prime video', 'amazonprime', 'amazon prime', 'primemembership'],
    typicalAmounts: [179, 299, 1499],
  },
  {
    canonicalName: 'Sony LIV',
    category: 'streaming',
    keywords: ['sonyliv', 'sony liv'],
    typicalAmounts: [299, 599, 999],
  },
  {
    canonicalName: 'Zee5',
    category: 'streaming',
    keywords: ['zee5', 'zee 5'],
    typicalAmounts: [99, 365, 999],
  },
  {
    canonicalName: 'JioCinema',
    category: 'streaming',
    keywords: ['jiocinema', 'jio cinema'],
    typicalAmounts: [29, 99, 999],
  },
  {
    canonicalName: 'MX Player',
    category: 'streaming',
    keywords: ['mxplayer', 'mx player'],
  },
  {
    canonicalName: 'ALTBalaji',
    category: 'streaming',
    keywords: ['altbalaji', 'alt balaji'],
  },
  {
    canonicalName: 'Voot',
    category: 'streaming',
    keywords: ['voot'],
  },

  // ── Music ──────────────────────────────────────────────────────────────────
  {
    canonicalName: 'Spotify',
    category: 'music',
    keywords: ['spotify'],
    typicalAmounts: [7, 59, 119, 189],
  },
  {
    canonicalName: 'Apple Music',
    category: 'music',
    keywords: ['apple music', 'applemusic'],
    typicalAmounts: [99, 149],
  },
  {
    canonicalName: 'YouTube Premium',
    category: 'music',
    keywords: ['youtube premium', 'youtubepremium', 'ytpremium'],
    typicalAmounts: [129, 189],
  },
  {
    canonicalName: 'JioSaavn',
    category: 'music',
    keywords: ['jiosaavn', 'jio saavn', 'saavn'],
  },
  {
    canonicalName: 'Gaana',
    category: 'music',
    keywords: ['gaana'],
  },

  // ── Telecom ─────────────────────────────────────────────────────────────────
  {
    canonicalName: 'Airtel',
    category: 'telecom',
    keywords: [
      'airtel',
      'airtelpay',
      'airtelmobile',
      'airtelbroadband',
      'airtelfiber',
      'airtelbillpay',
      'airtelprepaid',
      'airtelpostpaid',
      'airtelbroadbandbillpayment',
      'airtelpayuaxisban',
    ],
    typicalAmounts: [199, 299, 399, 455, 500, 588, 599, 699, 799, 999],
  },
  {
    canonicalName: 'Jio',
    category: 'telecom',
    keywords: ['jio recharge', 'jiomoney', 'jio prepaid', 'jio postpaid', 'jio bill', 'jiobillpay'],
    typicalAmounts: [149, 179, 209, 299, 395, 479, 666, 719],
  },
  {
    canonicalName: 'Vi (Vodafone Idea)',
    category: 'telecom',
    keywords: ['vodafone', 'idea cellular', 'vi mobile', 'vimobile', 'vibillpay'],
    typicalAmounts: [149, 249, 299, 401, 449, 599],
  },
  {
    canonicalName: 'BSNL',
    category: 'telecom',
    keywords: ['bsnl'],
  },
  {
    canonicalName: 'MTNL',
    category: 'telecom',
    keywords: ['mtnl'],
  },

  // ── Internet / Broadband ───────────────────────────────────────────────────
  {
    canonicalName: 'ACT Fibernet',
    category: 'internet',
    keywords: ['act fibernet', 'actfibernet', 'act fiber', 'act broadband', 'actbroadband'],
    typicalAmounts: [399, 499, 599, 699, 799, 999, 1099],
  },
  {
    canonicalName: 'Hathway',
    category: 'internet',
    keywords: ['hathway'],
  },
  {
    canonicalName: 'BSNL Broadband',
    category: 'internet',
    keywords: ['bsnl broadband', 'bsnlbroadband'],
  },
  {
    canonicalName: 'JioFiber',
    category: 'internet',
    keywords: ['jiofiber', 'jio fiber', 'reliance jio fiber'],
    typicalAmounts: [399, 599, 899, 1199, 1499],
  },
  {
    canonicalName: 'Excitel',
    category: 'internet',
    keywords: ['excitel'],
  },
  {
    canonicalName: 'Tikona',
    category: 'internet',
    keywords: ['tikona'],
  },
  {
    canonicalName: 'Spectra',
    category: 'internet',
    keywords: ['spectranet', 'spectra broadband'],
  },

  // ── Utilities ─────────────────────────────────────────────────────────────
  {
    canonicalName: 'BESCOM (Electricity)',
    category: 'utility',
    keywords: ['bescom'],
  },
    {
    canonicalName: 'TSSPDCL (Electricity)',
    category: 'utility',
    keywords: ['tsspdcl', 'tspdcl', 'southerndiscoms'],
  },
  {
    canonicalName: 'TSNPDCL (Electricity)',
    category: 'utility',
    keywords: ['tsnpdcl'],
  },
  {
    canonicalName: 'MSEDCL (Electricity)',
    category: 'utility',
    keywords: ['msedcl', 'mahadiscom', 'mseb'],
  },
  {
    canonicalName: 'Adani Electricity',
    category: 'utility',
    keywords: ['adani electricity', 'adanielec'],
  },
  {
    canonicalName: 'CESC Electricity',
    category: 'utility',
    keywords: ['cesc'],
  },
  {
    canonicalName: 'BWSSB (Water)',
    category: 'utility',
    keywords: ['bwssb'],
  },
  {
    canonicalName: 'Piped Gas / IGL',
    category: 'utility',
    keywords: ['igl gas', 'indraprastha gas', 'mgl gas', 'mahanagar gas', 'gas bill'],
  },
  {
    canonicalName: 'BBPS Bill Payment',
    category: 'utility',
    keywords: ['bbps', 'bbpsbpaxl', 'bbpsbillpay', 'bbpsb'],
  },

  // ── Gaming / Cloud ─────────────────────────────────────────────────────────
  {
    canonicalName: 'Google Play / Google One',
    category: 'cloud',
    keywords: ['google play', 'googleplay', 'google one', 'googleone'],
  },
  {
    canonicalName: 'Apple iCloud / App Store',
    category: 'cloud',
    keywords: ['apple.com', 'itunes', 'icloud', 'appstore', 'app store'],
  },
  {
    canonicalName: 'Microsoft / Xbox',
    category: 'cloud',
    keywords: ['microsoft', 'xbox', 'office365', 'microsoft365'],
  },

  // ── Insurance ─────────────────────────────────────────────────────────────
  {
    canonicalName: 'LIC Premium',
    category: 'insurance',
    keywords: ['lic premium', 'licpremium', 'life insurance corporation'],
  },
  {
    canonicalName: 'Health Insurance',
    category: 'insurance',
    keywords: ['health insurance', 'healthinsurance', 'star health', 'starhealth', 'niva bupa', 'nivabupa'],
  },
  {
    canonicalName: 'Vehicle Insurance',
    category: 'insurance',
    keywords: ['vehicle insurance', 'car insurance', 'two wheeler insurance', 'bike insurance'],
  },

  // ── Generic BBPS / ECS / NACH (catch-all for autopay debits) ─────────────
  {
    canonicalName: 'ECS / NACH Autopay',
    category: 'subscription_other',
    keywords: ['nach debit', 'ecs debit', 'autopay debit', 'si debit', 'standing instruction'],
  },
];

// ─── BBPS Patterns ───────────────────────────────────────────────────────────
// BBPS transactions are almost always recurring bill payments
const BBPS_PATTERNS = [
  /bbps/i,
  /bbpsbpaxl/i,
  /bill\s?pay/i,
  /billpayment/i,
  /bill\s?desk/i,
  /utility\s?bill/i,
  /electricity\s?bill/i,
  /water\s?bill/i,
  /gas\s?bill/i,
  /mobile\s?bill/i,
  /postpaid/i,
  /nach\s?debit/i,
  /ecs\s?debit/i,
  /autopay\s?debit/i,
  /auto\s?pay/i,
  /mandate/i,
  /upi\s?mandate/i,
  /recurring/i,
  /standing\s?instruction/i,
  /si\s?debit/i,
];

const GENERIC_RECURRING_FINGERPRINTS: Array<{
  canonicalName: string;
  category: MerchantCategory;
  patterns: RegExp[];
}> = [
  {
    canonicalName: 'Room Rent',
    category: 'subscription_other',
    patterns: [
      /\broom\s*rent\b/i,
      /\bhou?se\s*rent\b/i,
      /\bflat\s*rent\b/i,
      /\bhome\s*rent\b/i,
      /\bapartment\s*rent\b/i,
      /\bpg\s*rent\b/i,
      /\boffice\s*rent\b/i,
      /\brent\s*(paid|payment|transfer|to|for)?\b/i,
      /\brent\b/i,
    ],
  },
  {
    canonicalName: 'Wifi / Broadband',
    category: 'internet',
    patterns: [
      /\bwifi\b/i,
      /\bwi-fi\b/i,
      /\bwi\s*fi\b/i,
      /\bbroadband\b/i,
      /\binternet\b/i,
      /\bfibernet\b/i,
      /\bfiber\b/i,
      /\bfibre\b/i,
      /\bisp\b/i,
    ],
  },
  {
    canonicalName: 'Utility Bill',
    category: 'utility',
    patterns: [
      /\bbill\s*pay(ment)?\b/i,
      /\butility\s*bill\b/i,
      /\belectricity\b/i,
      /\bpower\s*bill\b/i,
      /\bwater\s*bill\b/i,
      /\bgas\s*bill\b/i,
      /\bpostpaid\b/i,
      /\bmobile\s*bill\b/i,
      /\bdth\b/i,
      /\bcable\b/i,
      /\brecharge\b/i,
    ],
  },
  {
    canonicalName: 'Autopay Mandate',
    category: 'subscription_other',
    patterns: [
      /\bauto\s*pay\b/i,
      /\bautopay\b/i,
      /\bmandate\b/i,
      /\bnach\b/i,
      /\becs\b/i,
      /\bstanding\s*instruction\b/i,
      /\bsi\s*debit\b/i,
      /\bsubscription\b/i,
      /\brecurring\b/i,
    ],
  },
  {
    canonicalName: 'Recurring Transfer',
    category: 'subscription_other',
    patterns: [
      /\brtgs\b/i,
      /\bneft\b/i,
      /\bimps\b/i,
      /\bupi\b/i,
      /\bbank\s*transfer\b/i,
      /\btransfer\s*to\b/i,
    ],
  },
  {
    canonicalName: 'Maintenance',
    category: 'utility',
    patterns: [
      /\bmaintenance\b/i,
      /\bsociety\s*maintenance\b/i,
      /\bapartment\s*maintenance\b/i,
    ],
  },
  {
    canonicalName: 'Maid / Domestic Help',
    category: 'subscription_other',
    patterns: [
      /\bmaid\b/i,
      /\bdomestic\s*help\b/i,
      /\bhouse\s*help\b/i,
    ],
  },
  {
    canonicalName: 'Tuition / Classes',
    category: 'subscription_other',
    patterns: [
      /\btuition\b/i,
      /\bclass(es)?\b/i,
      /\bcoaching\b/i,
    ],
  },
];

// ─── Frequency Windows (in days) ─────────────────────────────────────────────
const FREQUENCY_WINDOWS: Record<Frequency, { min: number; max: number; label: string }> = {
  monthly:   { min: 23,  max: 38,  label: 'Monthly' },
  quarterly: { min: 80,  max: 100, label: 'Quarterly' },
  biannual:  { min: 170, max: 200, label: 'Bi-Annual' },
  annual:    { min: 340, max: 390, label: 'Annual' },
};

const DETECTION_WINDOW_MONTHS = 12;
const MIN_OCCURRENCES = 3;
const MONTHLY_MIN_COVERAGE = 3;
const AMOUNT_VARIANCE_SOFT_LIMIT = 0.45;
const NARRATION_MERCHANT_CATEGORIES = new Set([
  'Room Rent',
  'Wifi / Broadband',
  'Utility Bill',
  'Autopay Mandate',
  'Recurring Transfer',
  'Maintenance',
  'Maid / Domestic Help',
  'Tuition / Classes',
]);
const MANUAL_MATCH_AMOUNT_TOLERANCE = 0.08;
const MANUAL_MATCH_LOOKBACK_MONTHS = 18;
const RECURRING_CONTEXT_STOP_WORDS = new Set([
  'rent',
  'room',
  'house',
  'home',
  'flat',
  'apartment',
  'pg',
  'bill',
  'bills',
  'wifi',
  'broadband',
  'internet',
  'fiber',
  'fibre',
  'recharge',
  'utility',
  'electricity',
  'water',
  'gas',
  'maintenance',
  'subscription',
  'autopay',
  'mandate',
  'monthly',
]);

// ─── Helpers ─────────────────────────────────────────────────────────────────

function normalizeNarration(narration: string): string {
  return (narration || '').toLowerCase().replace(/[^a-z0-9\s]/g, ' ').replace(/\s+/g, ' ').trim();
}

const GENERIC_NARRATION_STOP_WORDS = new Set([
  'upi',
  'dr',
  'cr',
  'debit',
  'credit',
  'pay',
  'paid',
  'payment',
  'payments',
  'bank',
  'limited',
  'ltd',
  'pvt',
  'private',
  'india',
  'bharat',
  'merchant',
  'transfer',
  'transferred',
  'bill',
  'txn',
  'txnid',
  'ref',
  'reference',
  'imps',
  'neft',
  'rtgs',
  'nach',
  'ecs',
  'si',
  'to',
  'from',
  'by',
  'via',
  'upiid',
  'vpa',
  'axis',
  'utib',
  'hdfc',
  'icic',
  'icici',
  'sbin',
  'yesb',
  'indb',
  'idfb',
  'kotak',
  'kkbk',
  'barb',
  'cnrb',
  'punb',
  'paytm',
  'phonepe',
  'gpay',
  'googlepay',
  'bhim',
]);

function isNoiseToken(token: string): boolean {
  if (!token || token.length < 3) return true;
  if (GENERIC_NARRATION_STOP_WORDS.has(token)) return true;
  if (/^\d+$/.test(token)) return true;
  if (/\d{5,}/.test(token)) return true;

  const digitCount = (token.match(/\d/g) || []).length;
  return digitCount > 0 && digitCount / token.length > 0.4;
}

function titleCase(value: string): string {
  return value
    .split(' ')
    .filter(Boolean)
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');
}

function cleanedNarrationTokens(value: string): string[] {
  return normalizeNarration(value)
    .split(' ')
    .flatMap((token) => token.split(/(?=rent|wifi|broadband|internet|maintenance)/i))
    .map((token) => token.replace(/^(paytm|phonepe|gpay|googlepay|bhim)/, ''))
    .filter((token) => !isNoiseToken(token));
}

function significantNarrationTokens(value: string): string[] {
  return cleanedNarrationTokens(value).filter((token) => !RECURRING_CONTEXT_STOP_WORDS.has(token));
}

function manualMerchantName(txn: IBankTransaction): string {
  const tokens = significantNarrationTokens(`${txn.merchant || ''} ${txn.name || ''} ${txn.narration || ''}`);
  if (tokens.length > 0) return titleCase(tokens.slice(0, 4).join(' '));

  return extractGenericMerchantName(txn) || 'Recurring Payment';
}

function tokenOverlapScore(a: string[], b: string[]): number {
  if (a.length === 0 || b.length === 0) return 0;

  const bSet = new Set(b);
  const matched = new Set(a.filter((token) => bSet.has(token)));
  return matched.size / Math.min(a.length, b.length);
}

function isAmountClose(a: number, b: number, tolerance = MANUAL_MATCH_AMOUNT_TOLERANCE): boolean {
  if (!a || !b) return false;
  const baseline = Math.max(Math.abs(a), Math.abs(b), 1);
  return Math.abs(a - b) / baseline <= tolerance;
}

function amountGroupKey(amount: number): string {
  return `amount_${Math.round(amount)}`;
}

function sharedNameFromTransactions(transactions: IBankTransaction[]): string | null {
  if (transactions.length === 0) return null;

  const tokenLists = transactions.map((txn) =>
    significantNarrationTokens(`${txn.merchant || ''} ${txn.name || ''} ${txn.narration || ''}`)
  );
  const firstTokens = tokenLists[0] || [];
  const shared = firstTokens.filter((token) =>
    tokenLists.every((tokens) => tokens.includes(token))
  );

  return shared.length > 0 ? titleCase(shared.slice(0, 4).join(' ')) : null;
}

function phraseFromNarrationPart(value: string): string | null {
  const tokens = cleanedNarrationTokens(value);
  if (tokens.length === 0) return null;

  return tokens.slice(0, 4).join(' ');
}

function scoreMerchantPhrase(phrase: string): number {
  const tokens = phrase.split(' ').filter(Boolean);
  if (tokens.length === 0) return 0;

  const joined = tokens.join('');
  const uniqueChars = new Set(joined.split('')).size;
  const lengthScore = Math.min(joined.length, 24);
  const tokenScore = Math.min(tokens.length, 3) * 4;

  return uniqueChars + lengthScore + tokenScore;
}

function narrationPatternMerchantName(narration: string): string | null {
  if (!narration) return null;

  const rawParts = narration
    .split(/[-/|:]+/)
    .map((part) => part.trim())
    .filter(Boolean);

  const scoredParts = rawParts
    .map((part) => phraseFromNarrationPart(part))
    .filter((part): part is string => Boolean(part))
    .map((part) => ({ part, score: scoreMerchantPhrase(part) }))
    .sort((a, b) => b.score - a.score);

  if (scoredParts.length > 0) {
    return titleCase(scoredParts[0].part);
  }

  const fullNarrationPattern = phraseFromNarrationPart(narration);
  return fullNarrationPattern ? titleCase(fullNarrationPattern) : null;
}

function extractGenericMerchantName(txn: IBankTransaction): string | null {
  const explicitMerchant = txn.merchant || txn.name;
  const explicitMerchantKey = phraseFromNarrationPart(explicitMerchant || '');
  if (explicitMerchantKey) {
    return titleCase(explicitMerchantKey);
  }

  const narrationMerchant = narrationPatternMerchantName(txn.narration || '');
  if (narrationMerchant) return narrationMerchant;

  const tokens = cleanedNarrationTokens(txn.narration || '');
  if (tokens.length === 0) return null;

  return titleCase(tokens.slice(0, 3).join(' '));
}

function daysBetween(a: Date, b: Date): number {
  return Math.abs((b.getTime() - a.getTime()) / (1000 * 60 * 60 * 24));
}

function detectFrequency(intervalDays: number): Frequency | null {
  for (const [freq, { min, max }] of Object.entries(FREQUENCY_WINDOWS) as [Frequency, { min: number; max: number }][]) {
    if (intervalDays >= min && intervalDays <= max) return freq;
  }
  return null;
}

function nextReminderDate(lastDate: Date, frequency: Frequency): Date {
  const d = new Date(lastDate);
  switch (frequency) {
    case 'monthly':   d.setMonth(d.getMonth() + 1); break;
    case 'quarterly': d.setMonth(d.getMonth() + 3); break;
    case 'biannual':  d.setMonth(d.getMonth() + 6); break;
    case 'annual':    d.setFullYear(d.getFullYear() + 1); break;
  }
  // Remind 3 days before
  d.setDate(d.getDate() - 3);
  return d;
}

function intervalConsistencyScore(intervals: number[]): number {
  if (intervals.length < 1) return 0;
  const mean = intervals.reduce((a, b) => a + b, 0) / intervals.length;
  const variance = intervals.reduce((sum, v) => sum + (v - mean) ** 2, 0) / intervals.length;
  const cv = Math.sqrt(variance) / mean; // coefficient of variation
  // Score: 1 = perfectly regular, approaches 0 as variance grows
  return Math.max(0, 1 - cv);
}

function isActive(lastTransactionDate: Date, frequency: Frequency): boolean {
  const expectedIntervalDays = {
    monthly: 30,
    quarterly: 91,
    biannual: 183,
    annual: 365,
  }[frequency];
  const daysSinceLast = daysBetween(lastTransactionDate, new Date());
  return daysSinceLast <= expectedIntervalDays * 1.5;
}

// ─── Core Matcher ─────────────────────────────────────────────────────────────

interface MatchResult {
  fingerprint: MerchantFingerprint;
  method: DetectedAutoPay['detectionMethod'];
}

export function matchMerchant(narration: string): MatchResult | null {
  const norm = normalizeNarration(narration);

  // 1. Check BBPS patterns first — these are guaranteed bill payments
  for (const pattern of BBPS_PATTERNS) {
    if (pattern.test(norm)) {
      // Try to identify which merchant from narration
      for (const fp of MERCHANT_FINGERPRINTS) {
        if (fp.keywords.some((kw) => norm.includes(kw.toLowerCase()))) {
          return { fingerprint: fp, method: 'bbps' };
        }
      }
      // Unknown BBPS merchant — use generic
      return {
        fingerprint: {
          canonicalName: 'BBPS Bill Payment',
          category: 'utility',
          keywords: ['bbps'],
        },
        method: 'bbps',
      };
    }
  }

  // 2. Keyword match against all merchant fingerprints
  for (const fp of MERCHANT_FINGERPRINTS) {
    if (fp.keywords.some((kw) => norm.includes(kw.toLowerCase()))) {
      return { fingerprint: fp, method: 'keyword_match' };
    }
  }

  for (const fp of GENERIC_RECURRING_FINGERPRINTS) {
    if (fp.patterns.some((pattern) => pattern.test(norm))) {
      return {
        fingerprint: {
          canonicalName: fp.canonicalName,
          category: fp.category,
          keywords: [fp.canonicalName],
        },
        method: 'keyword_match',
      };
    }
  }

  return null;
}

// ─── Grouping Key ─────────────────────────────────────────────────────────────
// Two transactions belong to the same autopay group if:
//   (a) same canonical merchant name
//   (b) amount within ±AMOUNT_TOLERANCE of each other

function merchantKey(canonicalName: string): string {
  return normalizeNarration(canonicalName).replace(/\s+/g, '_');
}

export function groupingKey(canonicalName: string, amount?: number): string {
  return merchantKey(canonicalName);
}

function detectionCutoff(months = DETECTION_WINDOW_MONTHS): Date {
  const cutoff = new Date();
  cutoff.setMonth(cutoff.getMonth() - months);
  cutoff.setHours(0, 0, 0, 0);
  return cutoff;
}

function uniqueMonthCount(dates: Date[]): number {
  return new Set(dates.map((date) => `${date.getUTCFullYear()}-${date.getUTCMonth()}`)).size;
}

function median(values: number[]): number {
  if (!values.length) return 0;
  const sorted = [...values].sort((a, b) => a - b);
  const mid = Math.floor(sorted.length / 2);
  return sorted.length % 2 === 0 ? (sorted[mid - 1] + sorted[mid]) / 2 : sorted[mid];
}

function inferFrequencyFromTransactions(transactions: IBankTransaction[], fallback: Frequency = 'monthly'): Frequency {
  const sorted = [...transactions]
    .map((txn) => new Date(txn.transactionTimestamp))
    .filter((date) => !Number.isNaN(date.getTime()))
    .sort((a, b) => a.getTime() - b.getTime());

  if (sorted.length < 2) return fallback;

  const intervals: number[] = [];
  for (let i = 1; i < sorted.length; i++) {
    intervals.push(daysBetween(sorted[i - 1], sorted[i]));
  }

  return detectFrequency(median(intervals)) || fallback;
}

function amountVariancePercent(amounts: number[]): number {
  if (amounts.length < 2) return 0;

  const avgAmount = amounts.reduce((sum, amount) => sum + amount, 0) / amounts.length;
  if (!avgAmount) return 0;

  return Math.round(((Math.max(...amounts) - Math.min(...amounts)) / avgAmount) * 10000) / 100;
}

function buildRecurringDoc(detected: DetectedAutoPay, existing?: any) {
  const recent = detected.recentMostTransaction;

  return {
    recentMostTransactionId: new Types.ObjectId(detected.recentMostTransactionId),
    userId: new Types.ObjectId(String(detected.userId)),
    merchant: detected.merchant,
    frequency: detected.frequency,
    amount: Math.round(detected.amount * 100) / 100,
    recentMostTransactionTimestamp: detected.recentMostTransactionTimestamp,
    nextReminderAt: existing?.isActive && existing?.nextReminderAt ? existing.nextReminderAt : detected.nextReminderAt,
    narration: recent?.narration || detected.matchedNarrations[detected.matchedNarrations.length - 1] || '',
    source: detected.detectionMethod,
    recentMostTwoOccurrences: detected.recentMostTwoOccurrences,
    occurrencesCount: detected.occurrencesCount,
    isActive: existing?.isActive ?? detected.isActive,
    isDaily: existing?.isDaily ?? false,
    normalizedMerchantKey: detected.normalizedMerchantKey,
    transactionIds: detected.transactionIds.map((id) => new Types.ObjectId(id)),
    amountVariance: detected.amountVariance,
    currency: detected.currency,
    confidenceScore: detected.confidenceScore,
    confidenceLabel: detected.confidenceLabel,
    detectionMethod: detected.detectionMethod,
    merchantCategory: detected.merchantCategory,
    matchedNarrations: detected.matchedNarrations,
    isUserDefined: existing?.isUserDefined ?? false,
  };
}

export async function persistDetectedAutoPays(userId: string | Types.ObjectId, detected: DetectedAutoPay[]): Promise<any[]> {
  const saved: any[] = [];

  for (const autoPay of detected) {
    if (autoPay.occurrencesCount < MIN_OCCURRENCES) continue;

    const filter = {
      userId: new Types.ObjectId(String(userId)),
      normalizedMerchantKey: autoPay.normalizedMerchantKey,
    };
    const existing = await RecurringPayment.findOne(filter).lean();
    const doc = buildRecurringDoc(autoPay, existing);
    const savedAutoPay = await RecurringPayment.findOneAndUpdate(filter, { $set: doc }, { new: true, upsert: true, setDefaultsOnInsert: true });

    if (savedAutoPay) {
      saved.push(savedAutoPay);
      await Transaction.updateMany(
        { _id: { $in: autoPay.transactionIds }, userId },
        {
          $set: {
            isAutoPay: true,
            autoPayId: savedAutoPay._id.toString(),
            merchant: autoPay.merchant,
            expectedFrequency: autoPay.frequency,
          },
        }
      );
    }
  }

  return saved.sort((a, b) => {
    const activeDiff = Number(b.isActive) - Number(a.isActive);
    if (activeDiff !== 0) return activeDiff;
    return new Date(a.nextReminderAt).getTime() - new Date(b.nextReminderAt).getTime();
  });
}

// ─── Main Detection Function ──────────────────────────────────────────────────

export async function detectAutoPays(userId, options: { persist?: boolean; months?: number } = {}): Promise<DetectedAutoPay[] | null> {
  const { persist = true, months = DETECTION_WINDOW_MONTHS } = options;
  const cutoff = detectionCutoff(months);

  const debits = await Transaction.find({
    userId,
    type: 'DEBIT',
    Hidden: { $ne: true },
    isExcluded: { $ne: true },
    transactionTimestamp: { $gte: cutoff },
  }).lean();

  if(!debits || debits.length === 0) return null;
  
  // const debits = transactions.filter((t) => t.type === 'DEBIT');

  // Step 1: Match each transaction to a merchant fingerprint
  interface Candidate {
    txn: IBankTransaction;
    match: MatchResult;
    ts: Date;
  }

  const candidates: Candidate[] = [];
  for (const txn of debits) {
    const ts = new Date(txn.transactionTimestamp);
    if (Number.isNaN(ts.getTime())) continue;

    let match = matchMerchant(txn.narration);
    if (match) {
      const narrationMerchant = extractGenericMerchantName(txn);
      if (
        narrationMerchant &&
        NARRATION_MERCHANT_CATEGORIES.has(match.fingerprint.canonicalName)
      ) {
        match = {
          ...match,
          fingerprint: {
            ...match.fingerprint,
            canonicalName: narrationMerchant,
          },
        };
      }
      candidates.push({ txn, match, ts });
      continue;
    }

    const genericMerchantName = extractGenericMerchantName(txn);
    if (!genericMerchantName) continue;

    candidates.push({
      txn,
      ts,
      match: {
        fingerprint: {
          canonicalName: genericMerchantName,
          category: 'subscription_other',
          keywords: [genericMerchantName],
        },
        method: 'amount_pattern',
      },
    });
  }

  // Step 2: Group candidates by merchant/narration fingerprint. Amount is
  // scored later, not used as the grouping gate, so variable bills still match.
  const groups = new Map<string, { candidates: Candidate[]; isAmountFallback: boolean }>();
  for (const c of candidates) {
    const merchantGroupKey = `merchant:${groupingKey(c.match.fingerprint.canonicalName)}`;
    const amountKey = amountGroupKey(c.txn.amount);
    const amountFallbackKey = `amount:${amountKey}`;

    if (!groups.has(merchantGroupKey)) {
      groups.set(merchantGroupKey, { candidates: [], isAmountFallback: false });
    }
    groups.get(merchantGroupKey)!.candidates.push(c);

    if (!groups.has(amountFallbackKey)) {
      groups.set(amountFallbackKey, { candidates: [], isAmountFallback: true });
    }
    groups.get(amountFallbackKey)!.candidates.push(c);
  }

  const results: DetectedAutoPay[] = [];

  // Step 3: Analyze each group for recurring pattern
  for (const [groupKey, group] of groups) {
    const groupCandidates = group.candidates;
    if (groupCandidates.length < MIN_OCCURRENCES) continue;

    // Sort by timestamp ascending
    const sorted = [...groupCandidates].sort((a, b) => a.ts.getTime() - b.ts.getTime());

    if (sorted.length < MIN_OCCURRENCES) continue;

    const intervals: number[] = [];
    for (let i = 1; i < sorted.length; i++) {
      intervals.push(daysBetween(sorted[i - 1].ts, sorted[i].ts));
    }

    const averageInterval = intervals.reduce((a, b) => a + b, 0) / intervals.length;
    const medianInterval = median(intervals);
    const frequency = detectFrequency(medianInterval) || detectFrequency(averageInterval);

    if (!frequency) continue; // Not a recognized recurring interval
    if (frequency === 'monthly' && uniqueMonthCount(sorted.map((c) => c.ts)) < MONTHLY_MIN_COVERAGE) continue;

    // Compute amount stats
    const amounts = sorted.map((c) => c.txn.amount);
    const avgAmount = amounts.reduce((a, b) => a + b, 0) / amounts.length;
    const amountVariance =
      amounts.length > 1
        ? (Math.max(...amounts) - Math.min(...amounts)) / avgAmount
        : 0;

    // Consistency score
    const consistency = intervalConsistencyScore(intervals);

    const amountBonus = Math.max(0, 1 - Math.min(amountVariance, AMOUNT_VARIANCE_SOFT_LIMIT) / AMOUNT_VARIANCE_SOFT_LIMIT);
    const occurrenceBonus = Math.min(sorted.length / 6, 0.25);
    const methodBonus = sorted.some((c) => c.match.method === 'keyword_match' || c.match.method === 'bbps') ? 0.15 : 0;
    const rawConfidence = consistency * 0.45 + amountBonus * 0.2 + occurrenceBonus + methodBonus;
    const confidenceScore = Math.min(1, rawConfidence);
    const confidenceLabel: DetectedAutoPay['confidenceLabel'] =
      confidenceScore >= 0.7 ? 'high' : confidenceScore >= 0.45 ? 'medium' : 'low';

    // Only emit high/medium confidence detections
    if (confidenceLabel === 'low') continue;

    const mostRecent = sorted[sorted.length - 1];
    const recentTwo = sorted.slice(-2).map((c) => c.ts);
    const avgRounded = Math.round(avgAmount);
    const fallbackName =
      sharedNameFromTransactions(sorted.map((c) => c.txn)) ||
      extractGenericMerchantName(mostRecent.txn) ||
      `Recurring ${avgRounded}`;
    const merchant = group.isAmountFallback
      ? fallbackName
      : mostRecent.match.fingerprint.canonicalName;
    const normalizedMerchantKey = group.isAmountFallback
      ? groupKey.replace(':', '_')
      : groupingKey(merchant);

    results.push({
      transactionIds: sorted.map((c) => c.txn._id.toString()),
      recentMostTransactionId: mostRecent.txn._id.toString(),
      transactions: sorted.map((c) => c.txn),
      recentMostTransaction: mostRecent.txn,
      userId: mostRecent.txn.userId,
      merchant,
      merchantCategory: mostRecent.match.fingerprint.category,
      normalizedMerchantKey,
      amount: avgAmount,
      amountVariance: Math.round(amountVariance * 10000) / 100, // as %
      currency: 'INR',
      frequency,
      averageIntervalDays: Math.round(averageInterval),
      intervalConsistencyScore: Math.round(consistency * 100) / 100,
      recentMostTransactionTimestamp: mostRecent.ts,
      nextReminderAt: nextReminderDate(mostRecent.ts, frequency),
      recentMostTwoOccurrences: recentTwo,
      occurrencesCount: sorted.length,
      isActive: isActive(mostRecent.ts, frequency),
      confidenceScore: Math.round(confidenceScore * 100) / 100,
      confidenceLabel,
      matchedNarrations: sorted.map((c) => c.txn.narration),
      detectionMethod: group.isAmountFallback ? 'amount_pattern' : mostRecent.match.method,
    });
  }

  const sortedResults = results.sort((a, b) => {
    if (b.confidenceScore !== a.confidenceScore) return b.confidenceScore - a.confidenceScore;
    return b.amount - a.amount;
  }).reduce<DetectedAutoPay[]>((unique, item) => {
    const ids = new Set(item.transactionIds);
    const duplicate = unique.some((existing) => {
      const existingIds = new Set(existing.transactionIds);
      const overlap = [...ids].filter((id) => existingIds.has(id)).length;
      return overlap / Math.min(ids.size, existingIds.size) >= 0.8;
    });

    if (!duplicate) unique.push(item);
    return unique;
  }, []);

  if (persist) await persistDetectedAutoPays(userId, sortedResults);
  return sortedResults;

}

export async function detectAndStoreAutoPays(userId: string | Types.ObjectId): Promise<any[]> {
  const detected = (await detectAutoPays(userId, { persist: false })) || [];
  await persistDetectedAutoPays(userId, detected);
  return RecurringPayment.find({
    userId,
    $or: [
      { occurrencesCount: { $gte: MIN_OCCURRENCES } },
      { isUserDefined: true },
      { isDaily: true },
    ],
  })
    .populate('transactionIds')
    .sort({ isActive: -1, nextReminderAt: 1, confidenceScore: -1 })
    .lean();
}

async function findManualRecurringTransactions(userId: string | Types.ObjectId, selectedTxn: IBankTransaction): Promise<IBankTransaction[]> {
  const selectedTokens = significantNarrationTokens(
    `${selectedTxn.merchant || ''} ${selectedTxn.name || ''} ${selectedTxn.narration || ''}`
  );
  const selectedMerchantKey = merchantKey(manualMerchantName(selectedTxn));
  const cutoff = detectionCutoff(MANUAL_MATCH_LOOKBACK_MONTHS);

  const candidates = await Transaction.find({
    userId,
    // type: 'DEBIT',
    Hidden: { $ne: true },
    isExcluded: { $ne: true },
    transactionTimestamp: { $gte: cutoff },
  }).lean();

  const matched: IBankTransaction[] = candidates.filter((candidate) => {
    const candidateId = candidate._id?.toString();
    if (candidateId && candidateId === selectedTxn._id?.toString()) return true;
    if (!isAmountClose(candidate.amount, selectedTxn.amount)) return false;

    const candidateTokens = significantNarrationTokens(
      `${candidate.merchant || ''} ${candidate.name || ''} ${candidate.narration || ''}`
    );
    const candidateMerchantKey = merchantKey(manualMerchantName(candidate));

    if (selectedMerchantKey && candidateMerchantKey === selectedMerchantKey) return true;

    const overlap = tokenOverlapScore(selectedTokens, candidateTokens);
    if (selectedTokens.length >= 2) return overlap >= 0.5;

    return overlap >= 1;
  });

  const selectedId = selectedTxn._id?.toString();
  if (selectedId && !matched.some((candidate) => candidate._id?.toString() === selectedId)) {
    matched.push(selectedTxn);
  }

  return matched.sort(
    (a, b) =>
      new Date(a.transactionTimestamp).getTime() -
      new Date(b.transactionTimestamp).getTime()
  );
}

export async function createRecurringPaymentFromTransaction(
  userId: string | Types.ObjectId,
  transactionId: string | Types.ObjectId,
  dueDay?: number
): Promise<any> {
  const txn = await Transaction.findOne({ _id: transactionId, userId }).lean();
  if (!txn) throw new Error('Transaction not found');

  const matched = matchMerchant(txn.narration || '');
  const recurringTransactions = await findManualRecurringTransactions(userId, txn);
  const mostRecentTxn = recurringTransactions[recurringTransactions.length - 1] || txn;
  const merchant = manualMerchantName(txn);
  const frequency = inferFrequencyFromTransactions(recurringTransactions, 'monthly');
  const transactionDate = new Date(mostRecentTxn.transactionTimestamp);
  const nextReminderAt = nextReminderDate(transactionDate, frequency);
  const transactionIds = recurringTransactions.map((transaction) => transaction._id);
  const amounts = recurringTransactions.map((transaction) => transaction.amount);
  const avgAmount = amounts.length
    ? Math.round((amounts.reduce((sum, amount) => sum + amount, 0) / amounts.length) * 100) / 100
    : txn.amount;
  const recentMostTwoOccurrences = recurringTransactions
    .slice(-2)
    .map((transaction) => new Date(transaction.transactionTimestamp));

  if (dueDay && dueDay >= 1 && dueDay <= 31) {
    const now = new Date();
    const year = now.getUTCFullYear();
    const month = now.getUTCMonth();
    const day = Math.min(dueDay, new Date(Date.UTC(year, month + 1, 0)).getUTCDate());
    nextReminderAt.setUTCFullYear(year, month, day);
    nextReminderAt.setUTCHours(9, 0, 0, 0);
    if (nextReminderAt.getTime() <= now.getTime()) {
      nextReminderAt.setUTCMonth(nextReminderAt.getUTCMonth() + 1);
    }
  }

  const normalizedMerchantKey = groupingKey(merchant);
  const saved = await RecurringPayment.findOneAndUpdate(
    { userId: new Types.ObjectId(String(userId)), normalizedMerchantKey },
    {
      $set: {
        recentMostTransactionId: txn._id,
        userId,
        merchant,
        frequency,
        amount: avgAmount,
        recentMostTransactionTimestamp: transactionDate,
        nextReminderAt,
        narration: mostRecentTxn.narration || txn.narration || '',
        source: 'manual',
        recentMostTwoOccurrences,
        occurrencesCount: recurringTransactions.length,
        isActive: true,
        isDaily: false,
        normalizedMerchantKey,
        transactionIds,
        amountVariance: amountVariancePercent(amounts),
        currency: 'INR',
        confidenceScore: 1,
        confidenceLabel: 'high',
        detectionMethod: 'manual',
        merchantCategory: matched?.fingerprint.category || 'subscription_other',
        matchedNarrations: recurringTransactions.map((transaction) => transaction.narration || ''),
        isUserDefined: true,
      },
    },
    { new: true, upsert: true, setDefaultsOnInsert: true }
  );

  await Transaction.updateMany(
    { _id: { $in: transactionIds }, userId },
    { $set: { isAutoPay: true, autoPayId: saved!._id.toString(), merchant, expectedFrequency: frequency } }
  );

  return RecurringPayment.findById(saved!._id).populate('transactionIds').lean();
}
