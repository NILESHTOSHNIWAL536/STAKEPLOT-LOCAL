import type { AggregationPipeline } from '@/types/bank/pipeline.types';

/**
 * Spending pipeline: returns spent totals per category and breakdown by subcategory
 */
export const buildSpendingPipeline = (userId: any, startDate: Date, endDate: Date, categories: string[]): AggregationPipeline => {
  return [
    {
      $match: {
        userId,
        transactionTimestamp: { $gte: startDate, $lte: endDate },
        category: { $in: categories },
      },
    },
    {
      $group: {
        _id: { category: '$category', subcategory: '$subcategory' },
        totalAmount: { $sum: '$amount' },
      },
    },
    {
      $group: {
        _id: '$_id.category',
        totalSpent: { $sum: '$totalAmount' },
        breakdown: {
          $push: {
            name: '$_id.subcategory',
            amount: '$totalAmount',
          },
        },
      },
    },
    {
      $project: {
        _id: 0,
        category: '$_id',
        totalSpent: 1,
        breakdown: 1,
      },
    },
  ];
};
