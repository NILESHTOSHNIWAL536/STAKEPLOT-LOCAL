import { Types } from 'mongoose';
import categories from '../../config/categories';
import { IBankTransaction } from '@/types/bank';
import { normalizeTransactionTimestamp } from '@/utils/time/normalize';
import { parseNarration } from '@/utils/narration/parseNarration';
import { classifyCounterparty } from '@/utils/narration/classifyCounterparty';
import MerchantDirectory from '@/models/transactions-automation/merchantDirectory';
import { normalizeMerchantKey, upsertMerchantDirectory } from '@/utils/narration/merchantDirectoryLookup';
import { enrichWithLLM } from '@/utils/narration/enrichWithLLM';

export interface TransactionInput {
  narration: string;
  type: string; // e.g., "CREDIT" | "DEBIT"
  amount: number;
  transactionalBalance?: number | string;
  currentBalance?: number | string;
  transactionTimestamp?: string | Date | null;
  valueDate?: string | Date | null;
  subcategory?: string;
  manualTransaction?: boolean;
  [key: string]: any; // fallback for extra fields
}

export interface TransactionRule {
  category?: string;
  subcategory?: string;
}

type RuleMap = Map<string, TransactionRule>;
type DirectoryMap = Map<string, { category: string; subcategory: string }>;
type ParsedNarration = ReturnType<typeof parseNarration>;

interface CategorizeOptions {
  persistMerchantDirectory?: boolean;
  preserveExistingSubcategory?: boolean;
  useMerchantDirectory?: boolean;
}

interface CategoryMatch {
  category: string;
  subcategory: string;
  keyword: string;
  score: number;
  order: number;
}

export interface CategorizationPreviewResult {
  narration: string;
  currentCategory: string;
  currentSubcategory: string;
  updatedCategory: string;
  updatedSubcategory: string;
}

const DEFAULT_CATEGORIZE_OPTIONS: Required<CategorizeOptions> = {
  persistMerchantDirectory: true,
  preserveExistingSubcategory: true,
  useMerchantDirectory: true,
};

const TRANSFER_ONLY_CATEGORY_KEYS = new Set(['PersonalTransfer', 'PersonalTransferReceived']);
const NARRATION_NOISE_TOKENS = new Set([
  'upi',
  'neft',
  'imps',
  'rtgs',
  'ach',
  'nach',
  'cms',
  'by',
  'cr',
  'dr',
  'credit',
  'txn',
  'utr',
  'sal',
  'salary',
  'payroll',
  'transaction',
  'payment',
  'transfer',
  'from',
  'to',
  'ref',
  'via',
]);

const normalizeForSearch = (value: string): string =>
  value
    .toLowerCase()
    .replace(/[_+@.]/g, ' ')
    .replace(/[^a-z0-9]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

const compactForSearch = (value: string): string =>
  value.toLowerCase().replace(/[^a-z0-9]+/g, '');

const escapeRegex = (value: string): string => value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

function titleCase(value: string): string {
  return value
    .toLowerCase()
    .replace(/\b[a-z0-9]/g, (char) => char.toUpperCase())
    .replace(/\b(Pvt|Ltd|Llp|LlP)\b/g, (word) => word.toUpperCase());
}

function normalizeSourceKey(value: string): string {
  return (value || '')
    .toUpperCase()
    .replace(/[^A-Z0-9 ]+/g, ' ')
    .replace(/\b(NEFT|IMPS|RTGS|UPI|ACH|NACH|CMS|BY|FROM|CR|DR|CREDIT|REF|TXN|UTR|SAL|SALARY|PAYROLL|PAYMENT|TRANSFER)\b/g, ' ')
    .replace(/\b[A-Z]{2,}\d+[A-Z0-9]*\b/g, ' ')
    .replace(/\b\d+\b/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .split(' ')
    .filter((token) => token.length > 2)
    .slice(0, 6)
    .join('_');
}

function titleCaseFromKey(key: string): string {
  return titleCase(key.replace(/_/g, ' '));
}

function isBankOrReferenceSegment(segment: string): boolean {
  const value = segment.trim().toUpperCase();
  if (!value) return true;
  if (NARRATION_NOISE_TOKENS.has(value.toLowerCase())) return true;
  if (/^(HDFC|ICIC|ICICI|SBI|SBIN|AXIS|KOTAK|YESB|IDFC|FDRL|FEDERAL|CNRB|BOFA)$/.test(value)) return true;
  if (/^\d+$/.test(value)) return true;
  if (/^[A-Z]{2,}\d+[A-Z0-9]*$/.test(value)) return true;
  if (/^[A-Z]{3,6}$/.test(value)) return true;
  return false;
}

function extractStructuredTransferSource(narration: string): string {
  const parts = narration
    .toUpperCase()
    .split(/[-/|]/)
    .map((part) => part.trim())
    .filter(Boolean);

  if (parts.length < 2) return '';

  const firstToken = parts[0].split(/\s+/)[0];
  if (!/^(NEFT|IMPS|RTGS|UPI|ACH|NACH|CMS)$/.test(firstToken)) return '';

  const sourcePart = parts.find((part, index) => {
    if (index === 0) return false;
    return /[A-Z]{3,}/.test(part) && !isBankOrReferenceSegment(part);
  });

  const key = normalizeSourceKey(sourcePart || '');
  return key ? titleCaseFromKey(key) : '';
}

function buildSearchText(transaction: Partial<IBankTransaction>, parsed: ParsedNarration): string {
  return [
    transaction.narration,
    transaction.merchant,
    parsed?.counterpartyName,
    parsed?.counterpartyVPA,
    parsed?.remark,
  ]
    .filter((part): part is string => typeof part === 'string' && part.trim().length > 0)
    .join(' ');
}

function keywordMatches(searchText: string, keyword: string): boolean {
  const normalizedKeyword = normalizeForSearch(keyword);
  if (!normalizedKeyword) return false;

  const normalizedText = normalizeForSearch(searchText);
  const compactText = compactForSearch(searchText);
  const compactKeyword = compactForSearch(keyword);
  const isShortKeyword = compactKeyword.length <= 3;
  const hasMultipleWords = normalizedKeyword.includes(' ');

  if (hasMultipleWords) {
    return normalizedText.includes(normalizedKeyword) || compactText.includes(compactKeyword);
  }

  const tokenRegex = new RegExp(`(^|\\s)${escapeRegex(normalizedKeyword)}(\\s|$)`, 'i');
  if (tokenRegex.test(normalizedText)) return true;

  if (isShortKeyword) return false;

  return compactText.includes(compactKeyword);
}

function findCategoryMatch(searchText: string): CategoryMatch | null {
  let bestMatch: CategoryMatch | null = null;
  let order = 0;

  for (const [category, subcategories] of Object.entries(categories)) {
    if (TRANSFER_ONLY_CATEGORY_KEYS.has(category)) continue;

    for (const [subKey, keywords] of Object.entries(
      subcategories as Record<string, string[]>,
    )) {
      for (const keyword of keywords) {
        const currentOrder = order++;
        if (!keywordMatches(searchText, keyword)) continue;

        const compactKeywordLength = compactForSearch(keyword).length;
        const score = compactKeywordLength * 10 + (keyword.trim().includes(' ') ? 25 : 0);
        if (
          !bestMatch ||
          score > bestMatch.score ||
          (score === bestMatch.score && currentOrder < bestMatch.order)
        ) {
          bestMatch = {
            category,
            subcategory: subKey,
            keyword,
            score,
            order: currentOrder,
          };
        }
      }
    }
  }

  return bestMatch;
}

function getCounterpartyName(
  transaction: Partial<IBankTransaction>,
  parsed: ParsedNarration,
): string {
  return (
    parsed?.counterpartyName ||
    transaction.merchant ||
    transaction.name ||
    parsed?.counterpartyVPA ||
    ''
  ).trim();
}

function cleanCounterpartyLabel(value: string): string {
  const cleaned = value
    .replace(/\s{2,}/g, ' ')
    .replace(/\b(?:a\/c|acct|account)\b.*$/i, '')
    .trim()
    .replace(/^[^a-z0-9]+|[^a-z0-9]+$/gi, '');

  return cleaned === cleaned.toUpperCase() ? titleCase(cleaned) : cleaned;
}

function isUsefulCounterpartyLabel(value: string): boolean {
  const normalized = normalizeForSearch(value);
  const compact = compactForSearch(value);

  if (!normalized || compact.length < 3) return false;
  if (/^\d+$/.test(compact)) return false;
  if (/^[A-Z]{3,6}$/.test(value.trim())) return false;
  if (NARRATION_NOISE_TOKENS.has(normalized)) return false;

  return /[a-z]/i.test(value);
}

function extractFallbackCounterpartyName(rawNarration: string): string {
  if (!rawNarration || typeof rawNarration !== 'string') return '';

  const structuredSource = extractStructuredTransferSource(rawNarration);
  if (structuredSource) return structuredSource;

  const parts = rawNarration
    .split(/[-/|:]+/)
    .map(cleanCounterpartyLabel)
    .filter(isUsefulCounterpartyLabel);

  return parts.find((part) => hasCompanySuffix(part)) || parts[0] || '';
}

function getBestCounterpartyName(transaction: Partial<IBankTransaction>, parsed: ParsedNarration): string {
  const structuredSource = extractStructuredTransferSource(transaction.narration ?? '');

  return cleanCounterpartyLabel(
    getCounterpartyName(transaction, parsed) ||
      structuredSource ||
      extractFallbackCounterpartyName(transaction.narration ?? ''),
  );
}

function getP2PTransferCategory(transaction: Partial<IBankTransaction>, parsed: ParsedNarration): string {
  if (parsed?.direction === 'CR' || transaction.type === 'CREDIT') return 'Received';
  return 'Transfers';
}

function isMerchantQrPayment(searchText: string): boolean {
  return /paytmqr|paytm-|bharatpe|gpay-|okbiz|rzp|freecharge|q\d{6,}|pinelabs|billdesk/i.test(searchText);
}

function isHandleOnlyUpiTransfer(rawNarration: string, parsed: ParsedNarration): boolean {
  return parsed?.format === 'UPI_SLASH_REF_TIME_VPA' && /^UPI\//i.test(rawNarration);
}

function isIncomeCreditSignal(searchText: string): boolean {
  return /salary|payout|neft\s*cr|credit interest|interest capitalised|cash deposit|refund|reversal|rev-upi|sweepin|intpd/i.test(searchText);
}

function hasCompanySuffix(value: string): boolean {
  return /\b(pvt\.?\s*ltd\.?|private\s+limited|ltd\.?|limited|llp|solutions|technologies|systems|services|consulting)\b/i.test(value);
}

function isFinancialInstitutionName(value: string): boolean {
  return /\b(bank|finance|financial|finserv|capital|credit|loan|loans|nbfc|insurance|securities|mutual\s*fund|asset\s+management|lending)\b/i.test(value);
}

function isSalaryCredit(transaction: Partial<IBankTransaction>, parsed: ParsedNarration, searchText: string): boolean {
  const counterpartyName = getBestCounterpartyName(transaction, parsed);
  const isCredit = transaction.type === 'CREDIT' || parsed?.direction === 'CR';
  const isNeftCredit = parsed?.format === 'NEFT_DASH' && parsed.direction === 'CR';

  if (!isCredit) return false;
  if (/\bsalary\b/i.test(searchText)) return true;
  if (/\b(princ|int)\s+payout\b/i.test(searchText)) return true;
  if (!isNeftCredit || !counterpartyName) return false;
  if (isFinancialInstitutionName(counterpartyName)) return false;

  return hasCompanySuffix(counterpartyName);
}

function getSalarySubcategory(transaction: Partial<IBankTransaction>, parsed: ParsedNarration): string {
  const counterpartyName = getBestCounterpartyName(transaction, parsed);
  return counterpartyName && !/\bsalary\b/i.test(counterpartyName) ? counterpartyName : 'SalaryAndPayouts';
}

function getIncomeCreditSubcategory(
  transaction: Partial<IBankTransaction>,
  parsed: ParsedNarration,
  incomeMatch: CategoryMatch | null,
): string {
  const counterpartyName = getBestCounterpartyName(transaction, parsed);
  if (counterpartyName && !/^bankcredits$/i.test(counterpartyName)) return counterpartyName;
  return incomeMatch?.subcategory || 'BankCredits';
}

function getDebitFallbackCategory(
  transaction: Partial<IBankTransaction>,
  parsed: ParsedNarration,
  counterpartyClass: string,
): { category: string; subcategory: string; needsReview: boolean } | null {
  const counterpartyName = getBestCounterpartyName(transaction, parsed);
  if (!counterpartyName) return null;

  if (counterpartyClass === 'P2P') {
    return {
      category: getP2PTransferCategory(transaction, parsed),
      subcategory: counterpartyName,
      needsReview: false,
    };
  }

  if (counterpartyClass === 'P2M' || hasCompanySuffix(counterpartyName) || transaction.merchant) {
    return {
      category: 'Services',
      subcategory: counterpartyName,
      needsReview: true,
    };
  }

  return {
    category: 'Personal Transfer',
    subcategory: counterpartyName,
    needsReview: true,
  };
}


/**
 * Pre-fetches all relevant MerchantDirectory entries for the given transaction
 * batch in a single DB query, returning an in-memory key → category map.
 */
async function buildDirectoryMap(
  transactionsData: Partial<IBankTransaction>[],
): Promise<DirectoryMap> {
  const keys = new Set<string>();

  for (const txn of transactionsData) {
    const parsed = parseNarration(txn.narration);
    if (!parsed) continue;
    if (parsed.counterpartyVPA && !/^\d+$/.test(parsed.counterpartyVPA)) {
      keys.add(normalizeMerchantKey(parsed.counterpartyVPA));
    }
    if (parsed.counterpartyName) {
      keys.add(normalizeMerchantKey(parsed.counterpartyName));
    }
  }

  if (keys.size === 0) return new Map();

  const entries = await MerchantDirectory.find({ key: { $in: Array.from(keys) } })
    .select('key category subcategory')
    .lean();

  const map: DirectoryMap = new Map();
  for (const e of entries) {
    map.set(e.key, { category: e.category, subcategory: e.subcategory });
  }
  return map;
}

/**
 * Looks up a parsed narration in the pre-fetched directory map.
 * Resolution order: VPA (primary) → normalized counterparty name (secondary).
 */
function directoryHit(
  parsed: ReturnType<typeof parseNarration>,
  directoryMap: DirectoryMap,
): { category: string; subcategory: string } | null {
  if (!parsed) return null;

  if (parsed.counterpartyVPA && !/^\d+$/.test(parsed.counterpartyVPA)) {
    const hit = directoryMap.get(normalizeMerchantKey(parsed.counterpartyVPA));
    if (hit) return hit;
  }

  if (parsed.counterpartyName) {
    const hit = directoryMap.get(normalizeMerchantKey(parsed.counterpartyName));
    if (hit) return hit;
  }

  return null;
}

async function categorizeTransactions(
  transactionsData: Partial<IBankTransaction>[],
  accountId: string | Types.ObjectId | null,
  userId: string | Types.ObjectId,
  bankId: string | Types.ObjectId | null,
  ruleMap: RuleMap,
  bankKey: string = 'UNKNOWN',
  options: CategorizeOptions = {},
): Promise<Partial<IBankTransaction>[]> {
  const categorizeOptions = { ...DEFAULT_CATEGORIZE_OPTIONS, ...options };
  // Layer 3 — MERCHANT DIRECTORY: single batch query for the whole ingest batch.
  const directoryMap = categorizeOptions.useMerchantDirectory
    ? await buildDirectoryMap(transactionsData)
    : new Map();

  return Promise.all(transactionsData.map(async (transaction) => {
    const rawNarration = typeof transaction.narration === 'string' ? transaction.narration : '';
    const narration = rawNarration.toLowerCase();

    // Layer 1 — PARSE: extract structured fields from the raw narration string.
    const parsed = parseNarration(transaction.narration);
    const searchText = buildSearchText(transaction, parsed);

    let matchedCategory = 'Untagged';
    let matchedSubcategory = '';
    let needsReview = false;

    if (transaction.type === 'CREDIT') {
      const categoryMatch = findCategoryMatch(searchText);
      const incomeMatch = categoryMatch?.category === 'Income' ? categoryMatch : null;

      if (isSalaryCredit(transaction, parsed, searchText)) {
        matchedCategory = 'Income';
        matchedSubcategory = getSalarySubcategory(transaction, parsed);
      } else if (incomeMatch && isIncomeCreditSignal(searchText)) {
        matchedCategory = 'Income';
        matchedSubcategory = getIncomeCreditSubcategory(transaction, parsed, incomeMatch);
      } else if (narration.startsWith('upi-cr') || narration.includes('/cr/')) {
        matchedCategory = 'Received';
        matchedSubcategory = getBestCounterpartyName(transaction, parsed);
      } else {
        matchedCategory = 'Income';
        matchedSubcategory = getIncomeCreditSubcategory(transaction, parsed, incomeMatch);
      }
    } else {
      // Build narration pattern for ruleMap lookup (legacy key format).
      let narrationPattern = narration;
      if (narration.includes('/')) {
        const split = narration.split('/');
        if (split.length >= 5) {
          narrationPattern = `${split[3]}/${split[4]}`;
        }
      }

      // Layer 2 — P2P / P2M GATE:
      // P2P transactions are routed to Transfers and skip all spend categorization.
      const counterpartyClass = classifyCounterparty(
        parsed,
        transaction.merchant,
        transaction.isAutoPay,
      );

      if (matchedCategory === 'Untagged') {
        // Layer 3 — MERCHANT DIRECTORY (cross-user, VPA-keyed):
        const dirEntry = directoryHit(parsed, directoryMap);
        if (dirEntry) {
          matchedCategory = dirEntry.category;
          matchedSubcategory = dirEntry.subcategory;
        }
      }

      if (matchedCategory === 'Untagged') {
        // Layer 4 — RULE MAP (per-user learned rules):
        const ruleKey = `${narrationPattern}_${transaction.amount}`;
        const matchingRule = ruleMap.get(ruleKey);

        if (matchingRule) {
          matchedCategory = matchingRule.category || 'Untagged';
          matchedSubcategory = matchingRule.subcategory || '';
          needsReview = true;
        } else {
          // Layer 5 — KEYWORD CONFIG (fixed for nested structure):
          if (
            narration.startsWith('pos') ||
            narration.startsWith('cash wdl') ||
            narration.startsWith('atm') ||
            narration.startsWith('to:') ||
            narration.startsWith('chq paid') ||
            (narration.startsWith('imps') && narration.includes('normal transfer'))
          ) {
            matchedCategory = 'Personal Transfer';
          } else if (narration.startsWith('neft-cr') || narration.startsWith('neft cr')) {
            // NEFT credits on a debit (e.g. reversals) — try Income keywords first.
            const incomeMatch = findCategoryMatch(searchText);
            if (incomeMatch?.category === 'Income') {
              matchedCategory = 'Income';
              matchedSubcategory = incomeMatch.subcategory;
            }
            if (matchedCategory === 'Untagged') matchedCategory = 'Income';
          } else {
            const categoryMatch = findCategoryMatch(searchText);
            if (categoryMatch) {
              matchedCategory = categoryMatch.category;
              matchedSubcategory = categoryMatch.subcategory;
            } else if (isMerchantQrPayment(searchText)) {
              matchedCategory = 'Shopping';
              matchedSubcategory = 'RetailStores';
              needsReview = true;
            } else if (isHandleOnlyUpiTransfer(rawNarration, parsed)) {
              matchedCategory = getP2PTransferCategory(transaction, parsed);
              matchedSubcategory = getBestCounterpartyName(transaction, parsed);
            } else if (counterpartyClass === 'P2P') {
              matchedCategory = getP2PTransferCategory(transaction, parsed);
              matchedSubcategory = getBestCounterpartyName(transaction, parsed);
            } else if (narration.startsWith('upi-cr') || narration.startsWith('upi cr')) {
              matchedCategory = 'Personal Transfer Received';
              const parts = transaction.narration?.split('-');
              if (parts && parts.length > 2) matchedSubcategory = cleanCounterpartyLabel(parts[2]);
            }
          }
        }
      }

      // Layer 6 — LLM / ENRICHMENT FALLBACK:
      // Only called for confirmed P2M merchants that all previous layers missed.
      // enrichWithLLM is a documented stub — replace its body to activate.
      if (matchedCategory === 'Untagged' && counterpartyClass === 'P2M') {
        const llmResult = await enrichWithLLM({
          counterpartyName: parsed?.counterpartyName,
          counterpartyVPA: parsed?.counterpartyVPA,
          remark: parsed?.remark,
          narration: transaction.narration ?? '',
        });

        if (llmResult) {
          matchedCategory = llmResult.category;
          matchedSubcategory = llmResult.subcategory;
          // Persist so subsequent users with the same merchant skip the LLM call.
          const key =
            parsed?.counterpartyVPA && !/^\d+$/.test(parsed.counterpartyVPA)
              ? normalizeMerchantKey(parsed.counterpartyVPA)
              : parsed?.counterpartyName
              ? normalizeMerchantKey(parsed.counterpartyName)
              : null;
          if (key && categorizeOptions.persistMerchantDirectory) {
            upsertMerchantDirectory(key, llmResult.category, llmResult.subcategory, 'llm', llmResult.confidence).catch(() => {});
          }
        } else {
          needsReview = true;
        }
      }

      if (matchedCategory === 'Untagged') {
        const fallbackResult = getDebitFallbackCategory(transaction, parsed, counterpartyClass);
        if (fallbackResult) {
          matchedCategory = fallbackResult.category;
          matchedSubcategory = fallbackResult.subcategory;
          needsReview = fallbackResult.needsReview;
        }
      }
    }

    const rawBalance = transaction.transactionalBalance ?? transaction.currentBalance ?? 0;
    const currentBalance =
      typeof rawBalance === 'string' ? parseFloat(rawBalance.replace(/,/g, '')) : rawBalance;

    return {
      ...transaction,
      currentBalance,
      transactionTimestamp: normalizeTransactionTimestamp(transaction.transactionTimestamp, bankKey),
      valueDate: normalizeTransactionTimestamp(transaction.valueDate, bankKey),
      category: matchedCategory,
      subcategory: categorizeOptions.preserveExistingSubcategory
        ? transaction.subcategory || matchedSubcategory
        : matchedSubcategory,
      manualTransaction: transaction.manualTransaction !== undefined ? transaction.manualTransaction : false,
      accountId,
      userId,
      bankId,
      needsReview,
      // Structured narration fields extracted by the parser layer (PR2).
      // Stored on the document for analytics, write-back, and future ML training.
      counterpartyName: getBestCounterpartyName(transaction, parsed),
      counterpartyVPA: parsed?.counterpartyVPA ?? '',
      counterpartyBankHandle: parsed?.bankHandle ?? '',
    };
  }));
}

export async function previewTransactionCategories(
  transactionsData: Partial<IBankTransaction>[],
  bankKey: string = 'UNKNOWN',
): Promise<CategorizationPreviewResult[]> {
  const categorizedTransactions = await categorizeTransactions(
    transactionsData,
    null,
    'dummy-preview-user',
    null,
    new Map(),
    bankKey,
    {
      persistMerchantDirectory: false,
      preserveExistingSubcategory: false,
      useMerchantDirectory: false,
    },
  );

  return categorizedTransactions.map((transaction, index) => {
    const original = transactionsData[index];
    return {
      narration: original?.narration ?? '',
      currentCategory: original?.category ?? '',
      currentSubcategory: original?.subcategory ?? '',
      updatedCategory: transaction.category ?? 'Untagged',
      updatedSubcategory: transaction.subcategory ?? '',
    };
  });
}

export default categorizeTransactions;
