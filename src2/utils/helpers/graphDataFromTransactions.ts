import { IBankTransaction } from '@/types/bank';
import { Model, Types } from "mongoose";

type GroupBy = "day" | "week" | "month";

export async function getTransactions(
  model: Model<IBankTransaction>,
  userId: string | Types.ObjectId,
  startDate: string | Date,
  endDate: string | Date,
  groupBy: GroupBy = "day",
  accountId: string | Types.ObjectId | null = null
) {
  const dateFormat = groupBy === "month" ? "%Y-%m" : "%Y-%m-%d";

  const matchCondition: any = {
    userId,
    transactionTimestamp: {
      $gte: new Date(startDate),
      $lte: new Date(endDate),
    },
    isExcluded: false,
  };

  if (accountId) {
    matchCondition.accountId = accountId;
  }

  const response = await model.aggregate([
    { $match: matchCondition },
    {
      $group: {
        _id: {
          date: {
            $dateToString: {
              format: dateFormat,
              date: "$transactionTimestamp",
            },
          },
        },
        debit: {
          $sum: { $cond: [{ $eq: ["$type", "DEBIT"] }, "$amount", 0] },
        },
        credit: {
          $sum: { $cond: [{ $eq: ["$type", "CREDIT"] }, "$amount", 0] },
        },
      },
    },
    { $sort: { "_id.date": 1 } },
  ]);

  return response;
}
