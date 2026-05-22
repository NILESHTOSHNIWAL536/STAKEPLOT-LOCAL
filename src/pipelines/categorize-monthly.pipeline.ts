import type { PipelineStage } from 'mongoose';
import type { AggregationPipeline } from '@/types/bank/pipeline.types';
import { Types } from 'mongoose';

/**
 * Build pipeline for monthly categorization of transactions.
 * Accepts user ObjectId (Types.ObjectId) and date range.
 */
export const buildMonthlyCategorizationPipeline = (userId: Types.ObjectId, fromDate: Date, toDate: Date): AggregationPipeline => {
  return [
    {
      $match: {
        userId,
        transactionTimestamp: { $gte: fromDate, $lte: toDate },
        isExcluded: false,
      },
    },
    {
      $lookup: {
        from: 'splits',
        localField: '_id',
        foreignField: 'transactionId',
        as: 'splitData',
      },
    },
    {
      $addFields: {
        userSplit: {
          $first: {
            $filter: {
              input: '$splitData',
              as: 'split',
              cond: { $eq: ['$$split.userId', userId] },
            },
          },
        },
      },
    },
    {
      $addFields: {
        userPaymentStatus: {
          $filter: {
            input: { $ifNull: ['$userSplit.paymentStatus', []] },
            as: 'ps',
            cond: { $eq: ['$$ps.member', userId] },
          },
        },
      },
    },
    {
      $addFields: {
        computedAmount: {
          $cond: {
            if: {
              $and: [{ $eq: [{ $ifNull: ['$isBalanceOut', false] }, true] }, { $ne: [{ $ifNull: ['$balanceOut', -1] }, -1] }],
            },
            then: '$balanceOut',
            else: {
              $cond: [
                { $gt: [{ $size: '$userPaymentStatus' }, 0] },
                {
                  $sum: {
                    $map: {
                      input: '$userPaymentStatus',
                      as: 's',
                      in: { $ifNull: ['$$s.amount', 0] },
                    },
                  },
                },
                '$amount',
              ],
            },
          },
        },
        category: { $toLower: { $ifNull: ['$category', 'untagged'] } },
      },
    },
    {
      $group: {
        _id: '$category',
        total_debit: {
          $sum: {
            $cond: [{ $eq: ['$type', 'DEBIT'] }, '$computedAmount', 0],
          },
        },
        total_credit: {
          $sum: {
            $cond: [{ $eq: ['$type', 'CREDIT'] }, '$computedAmount', 0],
          },
        },
      },
    },
    {
      $project: {
        _id: 0,
        category: '$_id',
        total_debit: 1,
        total_credit: 1,
      },
    },
  ];
};
