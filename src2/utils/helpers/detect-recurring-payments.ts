import mongoose, { Types } from 'mongoose';
import autoPayMerchants from '../../config/autoPayMerchants';
import { Transaction, RecurringPayment } from '../../models/index';

// ----------------------------
// Types
// ----------------------------

export type Frequency = 'daily' | 'weekly' | 'monthly' | 'quarterly' | 'biannual';

export interface MerchantRule {
  name: string;
  regex: RegExp;
  excludeIf?: (txn: any) => boolean;
}

export interface DetectRecurringOptions {
  fromDate?: string | Date;
  timeWindowMonths?: number;
}

// Each transaction we process
export interface TxnObj {
  _id: Types.ObjectId;
  narration: string;
  amount: number;
  transactionTimestamp: string | Date;
  type: string;
  category?: string;
  accountId?: Types.ObjectId;
  userId?: Types.ObjectId;
  merchant?: string;
  [key: string]: any;
}

// Final autopay object before DB insert
export interface AutoPayInfo {
  recentMostTransactionId: Types.ObjectId;
  merchant: string;
  frequency: Frequency;
  amount: number;
  recentMostTransactionTimestamp: Date | string;
  narration: string;
  source: 'merchantMatch' | 'patternMatch';
  recentMostTwoOccurrences: (string | Date)[];
  occurrencesCount: number;
  nextReminderAt: Date;
}

// ----------------------------
// Global Exclusion Rules
// ----------------------------
export function globalExcludeIf(txn: TxnObj): boolean {
  return /zomato|swiggy|food|eat|meals/i.test(txn.narration || '') || txn.category?.toLowerCase() === 'food';
}

// ----------------------------
// Normalize narration → extract keywords
// ----------------------------
export function normalizeNarration(narration: string): string {
  return (narration || '')
    .toUpperCase()
    .replace(/[^A-Z0-9 ]+/g, ' ')
    .replace(/\b\d+\b/g, '')
    .replace(/\b(UPI|IMPS|NEFT|RTGS|TO|FROM|REF|TXN)\b/g, '')
    .replace(/\s+/g, ' ')
    .trim()
    .split(' ')
    .filter((word) => word.length > 3)
    .slice(0, 2)
    .join('_');
}

// ----------------------------
// Infer frequency: daily, weekly, monthly, etc.
// ----------------------------
export function inferFrequency(transactions: TxnObj[]): Frequency | null {
  if (transactions.length < 2) return null;

  const intervals: number[] = [];

  for (let i = 1; i < transactions.length; i++) {
    const diff = (new Date(transactions[i].transactionTimestamp).getTime() - new Date(transactions[i - 1].transactionTimestamp).getTime()) / (1000 * 60 * 60 * 24);

    intervals.push(diff);
  }

  const avg = intervals.reduce((a, b) => a + b, 0) / intervals.length;

  if (Math.abs(avg - 1) <= 0.5) return 'daily';
  if (Math.abs(avg - 7) <= 2) return 'weekly';
  if (Math.abs(avg - 30) <= 5) return 'monthly';
  if (Math.abs(avg - 90) <= 10) return 'quarterly';
  if (Math.abs(avg - 180) <= 15) return 'biannual';

  return null;
}

// ----------------------------
// Calculate next reminder date
// ----------------------------
export function calculateNextReminder(input: { recentMostTransactionTimestamp: string | Date; frequency: Frequency }): Date {
  const { recentMostTransactionTimestamp, frequency } = input;
  const msInDay = 24 * 60 * 60 * 1000;

  const now = new Date();
  let base = new Date(recentMostTransactionTimestamp);

  if (isNaN(base.getTime())) {
    throw new Error(`Invalid date: ${recentMostTransactionTimestamp}`);
  }

  const next = new Date(base);

  const advance = (d: Date) => {
    switch (frequency) {
      case 'daily':
        d.setUTCDate(d.getUTCDate() + 1);
        break;
      case 'weekly':
        d.setUTCDate(d.getUTCDate() + 7);
        break;
      case 'monthly':
        d.setUTCMonth(d.getUTCMonth() + 1);
        break;
      case 'quarterly':
        d.setUTCMonth(d.getUTCMonth() + 3);
        break;
      case 'biannual':
        d.setUTCMonth(d.getUTCMonth() + 6);
        break;
    }
  };

  while (next.getTime() <= now.getTime()) {
    advance(next);
  }

  let reminder = new Date(next.getTime() - 2 * msInDay);
  if (reminder.getTime() <= now.getTime()) {
    reminder = now;
  }

  reminder.setUTCHours(9, 0, 0, 0);
  return reminder;
}

// ----------------------------
// Main: detect recurring payments
// ----------------------------
export async function detectRecurringPayments(userId: string | Types.ObjectId, options: DetectRecurringOptions = {}): Promise<AutoPayInfo[]> {
  const { fromDate, timeWindowMonths = 4 } = options;

  let cutoffDate: Date;

  if (fromDate) {
    cutoffDate = new Date(fromDate);
  } else {
    cutoffDate = new Date();
    cutoffDate.setMonth(cutoffDate.getMonth() - timeWindowMonths);
  }

  const transactions: TxnObj[] = await Transaction.find({
    userId: new mongoose.Types.ObjectId(userId),
    transactionTimestamp: { $gte: cutoffDate },
    type: 'DEBIT',
  });

  const merchantGrouped: Record<string, TxnObj[]> = {};
  const genericGrouped: Record<string, TxnObj[]> = {};

  // ----------------------------
  // Group by known merchants & generic keyword patterns
  // ----------------------------
  for (const txn of transactions) {
    const matched = (autoPayMerchants as MerchantRule[]).find((m) => m.regex.test(txn.narration) && !globalExcludeIf(txn) && !m.excludeIf?.(txn));

    const roundedAmount = Math.round(txn.amount / 10) * 10;

    if (matched) {
      const key = `${matched.name}_${roundedAmount}`;
      if (!merchantGrouped[key]) merchantGrouped[key] = [];
      merchantGrouped[key].push({ ...txn, merchant: matched.name });
    } else {
      const keyword = normalizeNarration(txn.narration);
      const key = `${keyword}_${roundedAmount}`;
      if (!genericGrouped[key]) genericGrouped[key] = [];
      genericGrouped[key].push({ ...txn, merchant: keyword });
    }
  }

  const autoPays: AutoPayInfo[] = [];

  // ----------------------------
  // Process groups → detect frequency
  // ----------------------------
  function processGroups(groups: Record<string, TxnObj[]>, isKnown: boolean) {
    for (const txns of Object.values(groups)) {
      if (txns.length < 2) continue;

      txns.sort((a, b) => new Date(a.transactionTimestamp).getTime() - new Date(b.transactionTimestamp).getTime());

      const frequency = inferFrequency(txns);
      if (!frequency) continue;

      const mostRecent = txns[txns.length - 1];

      autoPays.push({
        recentMostTransactionId: mostRecent._id,
        merchant: mostRecent.merchant!,
        frequency,
        amount: mostRecent.amount,
        recentMostTransactionTimestamp: mostRecent.transactionTimestamp,
        narration: mostRecent.narration,
        source: isKnown ? 'merchantMatch' : 'patternMatch',
        recentMostTwoOccurrences: txns.slice(-2).map((t) => t.transactionTimestamp),
        occurrencesCount: txns.length,
        nextReminderAt: calculateNextReminder({
          recentMostTransactionTimestamp: mostRecent.transactionTimestamp,
          frequency,
        }),
      });
    }
  }

  processGroups(merchantGrouped, true);
  processGroups(genericGrouped, false);

  // Insert into DB
  const docs = autoPays.map((a) => ({ ...a, userId }));
  await RecurringPayment.insertMany(docs);

  return autoPays;
}

export default detectRecurringPayments;
