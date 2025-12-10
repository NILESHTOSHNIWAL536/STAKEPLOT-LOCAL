import type { PipelineStage } from 'mongoose';
import type { AggregationPipeline } from '@/types/bank/pipeline.types';

/**
 * Budget pipeline:
 * Groups transactions by formatted date and category for a given category set.
 * groupBy: 'monthly' | 'weekly' | 'yearly'
 *
 * For monthly/weekly we use '%Y-%m-%d' (day)
 * For yearly we return full month name using '%B'
 */
export const buildBudgetPipeline = (userId: any, startDate: Date, endDate: Date, categories: string[], groupBy: 'monthly' | 'weekly' | 'yearly'): AggregationPipeline => {
  let dateFormat = '%Y-%m-%d';
  if (groupBy === 'yearly') dateFormat = '%B';

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
        _id: {
          date: { $dateToString: { format: dateFormat, date: '$transactionTimestamp' } },
          type: '$type',
          category: '$category',
        },
        totalAmount: { $sum: '$amount' },
      },
    },
    {
      $group: {
        _id: '$_id.date',
        debit: {
          $push: {
            $cond: [{ $eq: ['$_id.type', 'DEBIT'] }, { k: '$_id.category', v: '$totalAmount' }, '$$REMOVE'],
          },
        },
        credit: {
          $push: {
            $cond: [{ $eq: ['$_id.type', 'CREDIT'] }, { k: '$_id.category', v: '$totalAmount' }, '$$REMOVE'],
          },
        },
        debitTotalAmount: { $sum: { $cond: [{ $eq: ['$_id.type', 'DEBIT'] }, '$totalAmount', 0] } },
        creditTotalAmount: { $sum: { $cond: [{ $eq: ['$_id.type', 'CREDIT'] }, '$totalAmount', 0] } },
      },
    },
    {
      $project: {
        _id: 1,
        debit: { $arrayToObject: '$debit' },
        credit: { $arrayToObject: '$credit' },
        debitTotalAmount: 1,
        creditTotalAmount: 1,
      },
    },
    { $sort: { _id: 1 } },
  ];
};
