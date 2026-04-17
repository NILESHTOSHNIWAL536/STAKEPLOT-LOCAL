import { Types } from 'mongoose';
import categories from '../../config/categories';
import { IBankTransaction } from '@/types/bank';
import { normalizeTransactionTimestamp } from '@/utils/time/normalize';

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

function categorizeTransactions(
  transactionsData: Partial<IBankTransaction>[],
  accountId: string | Types.ObjectId | null,
  userId: string | Types.ObjectId,
  bankId: string | Types.ObjectId | null,
  ruleMap: RuleMap,
  bankKey: string = 'UNKNOWN',
): Partial<IBankTransaction>[] {
  return transactionsData.map((transaction) => {
    const narration = transaction.narration ? transaction.narration.toLowerCase() : '';

    let matchedCategory = 'Untagged';
    let matchedSubcategory = '';
    let needsReview = false;

    // Step 1: Handle CREDIT
    if (transaction.type === 'CREDIT') {
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
      // Step 2: narrationPattern for rule lookup
      let narrationPattern = narration;

      if (narration.includes('/')) {
        const split = narration.split('/');
        if (split.length >= 5) {
          narrationPattern = `${split[3]}/${split[4]}`;
        }
      }

      // Step 3: Check ruleMap
      const ruleKey = `${narrationPattern}_${transaction.amount}`;
      const matchingRule = ruleMap.get(ruleKey);

      if (matchingRule) {
        matchedCategory = matchingRule.category || 'Untagged';
        matchedSubcategory = matchingRule.subcategory || '';
        needsReview = true;
      } else {
        // Step 4: Existing logic
        if (narration.startsWith('upi-cr') || narration.startsWith('upi cr')) {
          matchedCategory = 'Personal Transfer Received';
          const parts = transaction.narration?.split('-');
          if (parts && parts.length > 2) matchedSubcategory = parts[2].trim();
        } else if (narration.startsWith('pos') || narration.startsWith('cash wdl') || narration.startsWith('atm') || narration.startsWith('to:')) {
          matchedCategory = 'Personal Transfer';
        } else if (narration.startsWith('neft-cr') || narration.startsWith('neft cr')) {
          for (const keyword of categories['Income'] || []) {
            const regex = new RegExp(`\\b${keyword.toLowerCase()}\\b`, 'i');
            if (regex.test(narration)) {
              matchedCategory = 'Income';
              matchedSubcategory = keyword;
              break;
            }
          }
        } else {
          // Category keyword match
          for (const [category, keywords] of Object.entries(categories)) {
            for (const keyword of keywords) {
              const regex = new RegExp(`\\b${keyword.toLowerCase()}\\b`, 'i');
              if (regex.test(narration)) {
                matchedCategory = category;
                matchedSubcategory = keyword;
                break;
              }
            }
            if (matchedCategory !== 'Untagged') break;
          }
        }
      }
    }

    // Normalize current balance
    const rawBalance = transaction.transactionalBalance ?? transaction.currentBalance ?? 0;

    const currentBalance = typeof rawBalance === 'string' ? parseFloat(rawBalance.replace(/,/g, '')) : rawBalance;

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
    };
  });
}

export default categorizeTransactions;