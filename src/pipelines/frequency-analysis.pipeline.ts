import type { PipelineStage } from 'mongoose';
import type { AggregationPipeline } from '@/types/bank/pipeline.types';
import { Types } from 'mongoose';

/**
 * Frequency analysis pipeline:
 * - Finds top repeating payees / probable names for DEBIT transactions in a date range.
 * - Returns top 4 frequent payments with counts and total amounts.
 */
export const buildFrequencyAnalysisPipeline = (userId: Types.ObjectId, fromDate: Date, toDate: Date, limit = 4): AggregationPipeline => {
  return [
    {
      $match: {
        userId,
        transactionTimestamp: { $gte: fromDate, $lte: toDate },
        type: 'DEBIT',
        narration: { $ne: null },
        manualTransaction: { $ne: true },
      },
    },
    {
      $addFields: {
        splitByDash: { $split: ['$narration', '-'] },
        splitBySlash: { $split: ['$narration', '/'] },
        splitByPlus: { $split: ['$narration', '+'] },
        splitBySpace: { $split: ['$narration', ' '] },
      },
    },
    {
      $addFields: {
        chosenSplit: {
          $cond: [
            { $gt: [{ $size: '$splitByDash' }, 1] },
            '$splitByDash',
            {
              $cond: [
                { $gt: [{ $size: '$splitBySlash' }, 1] },
                '$splitBySlash',
                {
                  $cond: [{ $gt: [{ $size: '$splitByPlus' }, 1] }, '$splitByPlus', '$splitBySpace'],
                },
              ],
            },
          ],
        },
      },
    },
    {
      $addFields: {
        trimmedParts: {
          $map: {
            input: '$chosenSplit',
            as: 'part',
            in: { $trim: { input: '$$part' } },
          },
        },
      },
    },
    {
      $addFields: {
        probableName: {
          $cond: [
            { $gte: [{ $size: '$trimmedParts' }, 4] },
            {
              $concat: [{ $arrayElemAt: ['$trimmedParts', 2] }, ' ', { $arrayElemAt: ['$trimmedParts', 3] }],
            },
            {
              $cond: [
                { $gte: [{ $size: '$trimmedParts' }, 3] },
                { $arrayElemAt: ['$trimmedParts', 2] },
                {
                  $cond: [{ $gte: [{ $size: '$trimmedParts' }, 2] }, { $arrayElemAt: ['$trimmedParts', 1] }, { $arrayElemAt: ['$trimmedParts', 0] }],
                },
              ],
            },
          ],
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
            else: '$amount',
          },
        },
      },
    },
    {
      $group: {
        _id: '$probableName',
        count: { $sum: 1 },
        totalAmount: { $sum: '$computedAmount' },
        narrations: { $addToSet: '$narration' },
      },
    },
    {
      $sort: { count: -1, totalAmount: -1 },
    },
    { $limit: limit },
    {
      $project: {
        _id: 0,
        name: '$_id',
        count: 1,
        totalAmount: 1,
        narrations: 1,
      },
    },
  ];
};
export const buildMostSpentDayPipeline = (
  userId: Types.ObjectId,
  fromDate: Date,
  toDate: Date
): AggregationPipeline => {
  return [
    {
      $match: {
        userId,
        type: 'DEBIT',
        isExcluded: false,
        transactionTimestamp: { $gte: fromDate, $lte: toDate },
      },
    },
    {
      $group: {
        _id: {
          day: {
            $dateToString: {
              format: '%Y-%m-%d',
              date: '$transactionTimestamp',
            },
          },
        },
        totalAmount: { $sum: '$amount' },
      },
    },
    { $sort: { totalAmount: -1 } },
    { $limit: 1 },
    {
      $project: {
        _id: 0,
        date: '$_id.day',
        amount: '$totalAmount',
      },
    },
  ];
};


export const buildMostSpentCategoriesPipeline = (
  userId: Types.ObjectId,
  fromDate: Date,
  toDate: Date
): AggregationPipeline => [
    {
      $match: {
        userId,
        type: 'DEBIT',
        isExcluded: false,
        transactionTimestamp: { $gte: fromDate, $lte: toDate },
      },
    },
    {
      $addFields: {
        computedAmount: {
          $cond: {
            if: {
              $and: [
                { $eq: [{ $ifNull: ['$isBalanceOut', false] }, true] },
                { $ne: [{ $ifNull: ['$balanceOut', -1] }, -1] },
              ],
            },
            then: '$balanceOut',
            else: '$amount',
          },
        },
        category: { $toLower: { $ifNull: ['$category', 'untagged'] } },
      },
    },
    {
      $group: {
        _id: '$category',
        totalAmount: { $sum: '$computedAmount' },
      },
    },
    {
      $sort: { totalAmount: -1 },
    },
    {
      $facet: {
        topCategories: [
          { $limit: 2 },
        ],
        totalSpend: [
          {
            $group: {
              _id: null,
              total: { $sum: '$totalAmount' },
            },
          },
        ],
      },
    },
    {
      $project: {
        topCategories: 1,
        totalSpend: { $arrayElemAt: ['$totalSpend.total', 0] },
      },
    },
    {
      $unwind: '$topCategories',
    },
    {
      $project: {
        category: '$topCategories._id',
        amount: '$topCategories.totalAmount',
        percentage: {
          $cond: [
            { $gt: ['$totalSpend', 0] },
            {
              $round: [
                {
                  $multiply: [
                    { $divide: ['$topCategories.totalAmount', '$totalSpend'] },
                    100,
                  ],
                },
                2,
              ],
            },
            0,
          ],
        },
      },
    },
  ];

export function calculatePercentageChange(
  current: number,
  previous: number
): number {
  if (previous === 0) return current > 0 ? 100 : 0;
  return Number((((current - previous) / previous) * 100).toFixed(2));
}

export const buildWeeklyTotalSpendPipeline = (
  userId: Types.ObjectId,
  fromDate: Date,
  toDate: Date
): AggregationPipeline => [
    {
      $match: {
        userId,
        type: 'DEBIT',
        isExcluded: false,
        transactionTimestamp: { $gte: fromDate, $lte: toDate },
      },
    },
    {
      $addFields: {
        computedAmount: {
          $cond: {
            if: {
              $and: [
                { $eq: [{ $ifNull: ['$isBalanceOut', false] }, true] },
                { $ne: [{ $ifNull: ['$balanceOut', -1] }, -1] },
              ],
            },
            then: '$balanceOut',
            else: '$amount',
          },
        },
      },
    },
    {
      $group: {
        _id: null,
        totalSpend: { $sum: '$computedAmount' },
      },
    },
    {
      $project: {
        _id: 0,
        totalSpend: 1,
      },
    },
  ];

export function getCurrentWeekRangeUTC() {
  const now = new Date();
  const day = now.getUTCDay(); // 0 = Sunday

  // Sunday 00:00:00
  const weekStart = new Date(
    Date.UTC(
      now.getUTCFullYear(),
      now.getUTCMonth(),
      now.getUTCDate() - day,
      0, 0, 0, 0
    )
  );

  // Saturday 23:59:59.999
  const fullWeekEnd = new Date(
    Date.UTC(
      weekStart.getUTCFullYear(),
      weekStart.getUTCMonth(),
      weekStart.getUTCDate() + 6,
      23, 59, 59, 999
    )
  );

  // 🔥 IMPORTANT PART
  // If week is still running → take NOW
  // If week completed → take Saturday end
  const weekEnd = now < fullWeekEnd ? now : fullWeekEnd;

  return { weekStart, weekEnd };
}
export function getLastWeekRangeUTC() {
  const { weekStart } = getCurrentWeekRangeUTC();

  const lastWeekStart = new Date(
    Date.UTC(
      weekStart.getUTCFullYear(),
      weekStart.getUTCMonth(),
      weekStart.getUTCDate() - 7,
      0, 0, 0, 0
    )
  );

  const lastWeekEnd = new Date(
    Date.UTC(
      lastWeekStart.getUTCFullYear(),
      lastWeekStart.getUTCMonth(),
      lastWeekStart.getUTCDate() + 6,
      23, 59, 59, 999
    )
  );

  return { lastWeekStart, lastWeekEnd };
}