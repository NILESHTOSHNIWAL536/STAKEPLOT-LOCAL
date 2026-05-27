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
): Promise<Partial<IBankTransaction>[]> {
  // Layer 3 — MERCHANT DIRECTORY: single batch query for the whole ingest batch.
  const directoryMap = await buildDirectoryMap(transactionsData);

  return Promise.all(transactionsData.map(async (transaction) => {
    const narration = transaction.narration ? transaction.narration.toLowerCase() : '';

    // Layer 1 — PARSE: extract structured fields from the raw narration string.
    const parsed = parseNarration(transaction.narration);

    let matchedCategory = 'Untagged';
    let matchedSubcategory = '';
    let needsReview = false;

    if (transaction.type === 'CREDIT') {
      // All credits default to Income; try to extract a subcategory label.
      matchedCategory = 'Income';
      const narrationParts = transaction.narration?.split(/[-/]/);
      if (narrationParts) {
        for (const part of narrationParts) {
          const trimmed = part.trim();
          if (trimmed && trimmed !== 'UPI' && trimmed !== 'CR' && !/^\d+$/.test(trimmed)) {
            matchedSubcategory = trimmed;
            break;
          }
        }
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

      if (counterpartyClass === 'P2P') {
        matchedCategory = 'Transfers';
        matchedSubcategory = 'Sent'; // we are in the DEBIT/TDS branch
      }

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
          if (narration.startsWith('upi-cr') || narration.startsWith('upi cr')) {
            matchedCategory = 'Personal Transfer Received';
            const parts = transaction.narration?.split('-');
            if (parts && parts.length > 2) matchedSubcategory = parts[2].trim();
          } else if (
            narration.startsWith('pos') ||
            narration.startsWith('cash wdl') ||
            narration.startsWith('atm') ||
            narration.startsWith('to:')
          ) {
            matchedCategory = 'Personal Transfer';
          } else if (narration.startsWith('neft-cr') || narration.startsWith('neft cr')) {
            // NEFT credits on a debit (e.g. reversals) — try Income keywords first.
            const incomeSubcats = categories['Income'] as Record<string, string[]> | undefined;
            if (incomeSubcats) {
              outer: for (const [subKey, keywords] of Object.entries(incomeSubcats)) {
                for (const keyword of keywords) {
                  const regex = new RegExp(`\\b${keyword.toLowerCase()}\\b`, 'i');
                  if (regex.test(narration)) {
                    matchedCategory = 'Income';
                    matchedSubcategory = subKey;
                    break outer;
                  }
                }
              }
            }
            if (matchedCategory === 'Untagged') matchedCategory = 'Income';
          } else {
            // categories is nested: { Category: { Subcategory: [keywords] } }
            outer: for (const [category, subcategories] of Object.entries(categories)) {
              for (const [subKey, keywords] of Object.entries(
                subcategories as Record<string, string[]>,
              )) {
                for (const keyword of keywords) {
                  const regex = new RegExp(`\\b${keyword.toLowerCase()}\\b`, 'i');
                  if (regex.test(narration)) {
                    matchedCategory = category;
                    matchedSubcategory = subKey;
                    break outer;
                  }
                }
              }
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
          if (key) {
            upsertMerchantDirectory(key, llmResult.category, llmResult.subcategory, 'llm', llmResult.confidence).catch(() => {});
          }
        } else {
          needsReview = true;
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
      subcategory: transaction.subcategory || matchedSubcategory,
      manualTransaction: transaction.manualTransaction !== undefined ? transaction.manualTransaction : false,
      accountId,
      userId,
      bankId,
      needsReview,
      // Structured narration fields extracted by the parser layer (PR2).
      // Stored on the document for analytics, write-back, and future ML training.
      counterpartyName: parsed?.counterpartyName ?? '',
      counterpartyVPA: parsed?.counterpartyVPA ?? '',
      counterpartyBankHandle: parsed?.bankHandle ?? '',
    };
  }));
}

export default categorizeTransactions;
