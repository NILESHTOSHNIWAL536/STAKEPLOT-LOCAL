// src2/helpers/transaction-create.helper.ts

import type { Model } from 'mongoose';
import { Types } from 'mongoose';
import type { IBankTransaction } from '@/types/bank';
import type { ITransactionRule } from '@/models/transactions-automation/transactionRule';

import deduplicateTransactions from '@/utils/helpers/de-duplicate-transactions';
import categorizeTransactions from '@/utils/helpers/categorizeTransactions';
import deduplicateAllTransactions from '@/utils/helpers/delete-transactions-from-db';

interface CreateTxInput {
  transactions: Partial<IBankTransaction>[];
  accountId: string | Types.ObjectId | null;
  userId: string | Types.ObjectId;
  bankId: string | Types.ObjectId | null;
  bankKey?: string;
  Transaction: Model<IBankTransaction>;
  TransactionRule: Model<ITransactionRule>;
}

export const createTransactionsBulk = async ({ transactions, accountId, userId, bankId, bankKey = 'UNKNOWN', Transaction, TransactionRule }: CreateTxInput) => {
  // 1. Manual transaction (shortcut path)
  if (transactions[0]?.manualTransaction) {
    const created = await Transaction.create(transactions[0]);
    return { data: created, categorizedTransactions: [created] };
  }

  // 2. Fetch rules (used for auto-tagging)
  const rules = await TransactionRule.find({ userId }).lean();
  const ruleMap = new Map(rules.map((r) => [`${r.narrationPattern}_${r.amount}`, r]));

  // 3. Deduplicate batch
  const uniqueTransactions = deduplicateTransactions(transactions);

  // 4. Categorize using your helper
  const categorized = categorizeTransactions(uniqueTransactions, accountId, userId, bankId, ruleMap, bankKey);

  // 5. Insert
  try {
    const insertResult = await Transaction.insertMany(categorized, {
      ordered: false,
    });

    // 6. Cleanup DB-level duplicates
    await deduplicateAllTransactions(userId);

    return {
      insertedCount: insertResult.length,
      message: 'Transactions inserted',
      categorizedTransactions: categorized,
    };
  } catch (error: any) {
    if (error.code === 11000) {
      return {
        insertedCount: error.result?.insertedCount || 0,
        message: 'Some transactions were duplicates',
        categorizedTransactions: categorized,
      };
    }
    throw error;
  }
};
