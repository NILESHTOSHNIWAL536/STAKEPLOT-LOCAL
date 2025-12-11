import type { PipelineStage } from 'mongoose';
import type { AggregationPipeline } from '@/types/bank/pipeline.types';
import { Types } from 'mongoose';

/**
 * Group similar (untagged) transactions by a computed narrationPattern + amount.
 * Returns grouped documents with transactions array, count, latestTimestamp, etc.
 */
export const groupSimilarTransactionsPipeline = (userId: Types.ObjectId): AggregationPipeline => {
  return [
    {
      $match: {
        userId,
        category: 'Untagged',
      },
    },
    {
      $addFields: {
        narrationPattern: {
          $let: {
            vars: {
              splitSlash: { $split: ['$narration', '/'] },
              splitDash: { $split: ['$narration', '-'] },
            },
            in: {
              $trim: {
                input: {
                  $cond: [
                    { $gte: [{ $size: '$$splitSlash' }, 5] },
                    { $concat: [{ $arrayElemAt: ['$$splitSlash', 3] }, '/', { $arrayElemAt: ['$$splitSlash', 4] }] },
                    {
                      $cond: [
                        { $gte: [{ $size: '$$splitDash' }, 4] },
                        { $concat: [{ $arrayElemAt: ['$$splitDash', 2] }, '-', { $arrayElemAt: ['$$splitDash', 3] }] },
                        '$narration',
                      ],
                    },
                  ],
                },
              },
            },
          },
        },
      },
    },
    {
      $group: {
        _id: { narrationPattern: '$narrationPattern', amount: '$amount' },
        transactions: { $push: '$_id' },
        totalAmount: { $sum: '$amount' },
        count: { $sum: 1 },
        narrationPattern: { $first: '$narrationPattern' },
        latestTimestamp: { $max: '$transactionTimestamp' },
        suggestedCategory: { $first: '$category' },
      },
    },
    {
      $match: { count: { $gt: 3 } },
    },
    {
      $sort: { latestTimestamp: -1 },
    },
  ];
};
