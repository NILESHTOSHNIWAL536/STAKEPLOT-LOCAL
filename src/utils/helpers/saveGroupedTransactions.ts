import mongoose from 'mongoose';
import { GroupedTransaction } from '@/models';
import { AutoTransactionRepository } from '@/repositories';
import { Types } from 'mongoose';

// ---- Interfaces to type group data ---- //
interface IGroupedTransactionItem {
  _id: {
    narrationPattern: string;
    amount: number;
  };
  transactions: any[]; // You may replace with a specific interface
  totalAmount: number;
  count: number;
  suggestedCategory?: string;
}

async function saveGroupedTransactions(userId: string | Types.ObjectId): Promise<void> {
  const repo = new AutoTransactionRepository();

  const groups = (await repo.groupSimilarTransactions(userId)) as IGroupedTransactionItem[];

  for (const group of groups) {
    const groupKey = `${group._id.narrationPattern}_${group._id.amount}`;

    await GroupedTransaction.findOneAndUpdate(
      {
        userId: new mongoose.Types.ObjectId(userId),
        groupKey,
      },
      {
        $set: {
          userId: new mongoose.Types.ObjectId(userId),
          groupKey,
          transactions: group.transactions,
          narrationPattern: group._id.narrationPattern,
          totalAmount: group.totalAmount,
          count: group.count,
          suggestedCategory: group.suggestedCategory ?? 'Untagged',
        },
      },
      { upsert: true, new: true }
    );
  }
}

export default saveGroupedTransactions;
