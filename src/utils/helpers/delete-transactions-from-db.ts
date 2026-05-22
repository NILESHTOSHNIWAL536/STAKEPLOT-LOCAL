import mongoose, { Types } from 'mongoose';
import { Transaction } from '../../models';

interface DuplicateAggregationResult {
  duplicateIds: Types.ObjectId[];
}

export async function deduplicateAllTransactions(userId: string | Types.ObjectId): Promise<void> {
  try {
    // -------------------------------
    // Step 1: Find duplicate _ids
    // -------------------------------
    const duplicates = await Transaction.aggregate<DuplicateAggregationResult>([
      {
        $match: {
          userId: new mongoose.Types.ObjectId(userId),
        },
      },
      {
        $group: {
          _id: {
            narration: { $trim: { input: '$narration' } },
            transactionTimestamp: '$transactionTimestamp',
            amount: '$amount',
            accountId: '$accountId',
          },
          ids: { $push: '$_id' },
          count: { $sum: 1 },
        },
      },
      {
        $match: { count: { $gt: 1 } }, // Only groups with duplicates
      },
      {
        $project: {
          _id: 0,
          duplicateIds: { $slice: ['$ids', 1, { $subtract: ['$count', 1] }] }, // Keep all except first
        },
      },
    ]);

    const duplicateIds = duplicates.flatMap((d) => d.duplicateIds);

    // -------------------------------
    // Step 2: Delete duplicates
    // -------------------------------
    if (duplicateIds.length > 0) {
      const result = await Transaction.deleteMany({
        _id: { $in: duplicateIds },
      });

    } else {
      console.log('✅ No duplicates found for user.');
    }
  } catch (error) {
    console.error('❌ Error deduplicating transactions:', error);
  }
}

export default deduplicateAllTransactions;
