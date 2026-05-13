// ─── Types ────────────────────────────────────────────────────────────────────
import { PendingTransaction, GroupedTransaction, Transaction } from '@/models';
import { IBankTransaction } from '@/types/bank';


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
  detectionMethod: 'keyword_match' | 'merchant_name' | 'bbps' | 'amount_pattern';
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
  /nach\s?debit/i,
  /ecs\s?debit/i,
  /autopay\s?debit/i,
  /standing\s?instruction/i,
  /si\s?debit/i,
];

// ─── Frequency Windows (in days) ─────────────────────────────────────────────
const FREQUENCY_WINDOWS: Record<Frequency, { min: number; max: number; label: string }> = {
  monthly:   { min: 25,  max: 35,  label: 'Monthly' },
  quarterly: { min: 80,  max: 100, label: 'Quarterly' },
  biannual:  { min: 170, max: 200, label: 'Bi-Annual' },
  annual:    { min: 340, max: 390, label: 'Annual' },
};

// Amount tolerance: transactions are grouped if amounts are within ±15%
const AMOUNT_TOLERANCE = 0.15;

// Minimum occurrences to confirm recurring
const MIN_OCCURRENCES = 2;

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
    .map((token) => token.replace(/^(paytm|phonepe|gpay|googlepay|bhim)/, ''))
    .filter((token) => !isNoiseToken(token));
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

  return null;
}

// ─── Grouping Key ─────────────────────────────────────────────────────────────
// Two transactions belong to the same autopay group if:
//   (a) same canonical merchant name
//   (b) amount within ±AMOUNT_TOLERANCE of each other

function amountBucket(amount: number): string {
  // Round to nearest 5 for loose bucketing
  return String(Math.round(amount / 5) * 5);
}

export function groupingKey(canonicalName: string, amount: number): string {
  return `${canonicalName}::${amountBucket(amount)}`;
}

// ─── Main Detection Function ──────────────────────────────────────────────────

export async function detectAutoPays(userId): Promise<DetectedAutoPay[] | null> {
  // Only look at DEBIT transactions
  const debits = await Transaction.find({ userId, type: 'DEBIT', }).lean();

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

    const match = matchMerchant(txn.narration);
    if (match) {
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

  // Step 2: Group candidates by (canonicalName + amount bucket)
  const groups = new Map<string, Candidate[]>();
  for (const c of candidates) {
    const key = groupingKey(c.match.fingerprint.canonicalName, c.txn.amount);
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key)!.push(c);
  }

  const results: DetectedAutoPay[] = [];

  // Step 3: Analyze each group for recurring pattern
  for (const [, groupCandidates] of groups) {
    if (groupCandidates.length < MIN_OCCURRENCES) continue;

    // Sort by timestamp ascending
    const sorted = [...groupCandidates].sort((a, b) => a.ts.getTime() - b.ts.getTime());

    // Compute intervals between consecutive occurrences
    const intervals: number[] = [];
    for (let i = 1; i < sorted.length; i++) {
      intervals.push(daysBetween(sorted[i - 1].ts, sorted[i].ts));
    }

    // Use minimum interval for frequency detection.
    // Rationale: a subscription is monthly if it ever recurred monthly.
    // Larger gaps happen when users temporarily cancel or when data window is incomplete.
    const minInterval = Math.min(...intervals);
    const frequency = detectFrequency(minInterval);

    if (!frequency) continue; // Not a recognized recurring interval

    // Compute amount stats
    const amounts = sorted.map((c) => c.txn.amount);
    const avgAmount = amounts.reduce((a, b) => a + b, 0) / amounts.length;
    const amountVariance =
      amounts.length > 1
        ? (Math.max(...amounts) - Math.min(...amounts)) / avgAmount
        : 0;

    // Consistency score
    const consistency = intervalConsistencyScore(intervals);

    // Confidence: combine consistency + occurrence count + amount stability
    const occurrenceBonus = Math.min(sorted.length / 6, 0.3); // up to 0.3 bonus for many hits
    const amountBonus = 1 - amountVariance; // 1.0 = exact same amount
    const rawConfidence = consistency * 0.5 + amountBonus * 0.3 + occurrenceBonus;
    const confidenceScore = Math.min(1, rawConfidence);
    const confidenceLabel: DetectedAutoPay['confidenceLabel'] =
      confidenceScore >= 0.7 ? 'high' : confidenceScore >= 0.45 ? 'medium' : 'low';

    // Only emit high/medium confidence detections
    if (confidenceLabel === 'low') continue;

    const mostRecent = sorted[sorted.length - 1];
    const recentTwo = sorted.slice(-2).map((c) => c.ts);

    results.push({
      transactionIds: sorted.map((c) => c.txn._id.toString()),
      recentMostTransactionId: mostRecent.txn._id.toString(),
      transactions: sorted.map((c) => c.txn),
      recentMostTransaction: mostRecent.txn,
      userId: mostRecent.txn.userId,
      merchant: mostRecent.match.fingerprint.canonicalName,
      merchantCategory: mostRecent.match.fingerprint.category,
      normalizedMerchantKey: groupingKey(
        mostRecent.match.fingerprint.canonicalName,
        mostRecent.txn.amount
      ),
      amount: avgAmount,
      amountVariance: Math.round(amountVariance * 10000) / 100, // as %
      currency: 'INR',
      frequency,
      averageIntervalDays: Math.round(intervals.reduce((a,b) => a+b, 0) / intervals.length),
      intervalConsistencyScore: Math.round(consistency * 100) / 100,
      recentMostTransactionTimestamp: mostRecent.ts,
      nextReminderAt: nextReminderDate(mostRecent.ts, frequency),
      recentMostTwoOccurrences: recentTwo,
      occurrencesCount: sorted.length,
      isActive: isActive(mostRecent.ts, frequency),
      confidenceScore: Math.round(confidenceScore * 100) / 100,
      confidenceLabel,
      matchedNarrations: sorted.map((c) => c.txn.narration),
      detectionMethod: mostRecent.match.method,
    });
  }

  // Sort by confidence desc, then amount desc
  return results.sort((a, b) => {
    if (b.confidenceScore !== a.confidenceScore) return b.confidenceScore - a.confidenceScore;
    return b.amount - a.amount;
  });

}
