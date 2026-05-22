import mongoose from 'mongoose';
import { Transaction } from '../../models';

export async function getOldestTransactionMonthYear(userId: string): Promise<Date | ''> {
  const result = await Transaction.findOne({
    userId: new mongoose.Types.ObjectId(userId),
  })
    .sort({ transactionTimestamp: 1 })
    .select({ transactionTimestamp: 1 })
    .lean<{ transactionTimestamp: Date } | null>();

  if (!result) {
    return '';
  }

  const date = new Date(result.transactionTimestamp);
  const firstOfMonth = new Date(date.getFullYear(), date.getMonth(), 1);

  return firstOfMonth;
}
