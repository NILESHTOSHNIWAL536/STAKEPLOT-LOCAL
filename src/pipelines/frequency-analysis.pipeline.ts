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
