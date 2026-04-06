import { Types, PipelineStage } from 'mongoose';
import type { IBankTransaction, MetricsSourceType } from '@/types/bank';
import BankTransaction from '@/models/transactions-automation/transaction';
import UserDailyMetrics from '@/models/transactions-automation/user-daily-metrics';
import logger from '@/utils/common/logger';

export type UserIdLike = string | Types.ObjectId;

const DAY_KEY_REGEX = /^\d{4}-\d{2}-\d{2}$/;

function toUtcDayStart(date: Date): Date {
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(), 0, 0, 0, 0));
}

function toUtcDayEnd(date: Date): Date {
  return new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(), 23, 59, 59, 999));
}

function dayKeyFromDate(date: Date): string {
  return date.toISOString().slice(0, 10);
}

function dayStartFromKey(dayKey: string): Date {
  if (!DAY_KEY_REGEX.test(dayKey)) {
    throw new Error(`Invalid day key: ${dayKey}`);
  }
  const [y, m, d] = dayKey.split('-').map((v) => Number(v));
  return new Date(Date.UTC(y, m - 1, d, 0, 0, 0, 0));
}

type ScopeKey = {
  dayKey: string;
  sourceType: MetricsSourceType;
  bankId: string | null;
  accountId: string | null;
};

function inferScope(tx: Partial<IBankTransaction>): ScopeKey | null {
  if (!tx?.transactionTimestamp) return null;
  const timestamp = new Date(tx.transactionTimestamp);
  if (Number.isNaN(timestamp.getTime())) return null;

  const dayStart = toUtcDayStart(timestamp);
  const dayKey = dayKeyFromDate(dayStart);

  const sourceType: MetricsSourceType = tx.manualTransaction ? 'MANUAL' : 'BANK';
  const bankId = sourceType === 'BANK' && tx.bankId ? String(tx.bankId) : null;
  const accountId = sourceType === 'BANK' && tx.accountId ? String(tx.accountId) : null;

  return { dayKey, sourceType, bankId, accountId };
}

async function computeScopeSnapshot(
  userId: UserIdLike,
  dayStart: Date,
  dayEnd: Date,
  sourceType: MetricsSourceType,
  bankId: string | null,
  accountId: string | null
) {
  const userObjectId = new Types.ObjectId(userId as string);
  const match: Record<string, any> = {
    userId: userObjectId,
    isExcluded: false,
    transactionTimestamp: { $gte: dayStart, $lte: dayEnd },
  };

  if (sourceType === 'MANUAL') {
    match.manualTransaction = true;
  } else {
    match.manualTransaction = { $ne: true };
    match.bankId = bankId ? new Types.ObjectId(bankId) : null;
    match.accountId = accountId ? new Types.ObjectId(accountId) : null;
  }

  const pipeline: PipelineStage[] = [
    { $match: match },
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
              cond: { $eq: ['$$split.userId', userObjectId] },
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
            cond: { $eq: ['$$ps.member', userObjectId] },
          },
        },
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
        subcategory: { $toLower: { $ifNull: ['$subcategory', 'untagged'] } },
      },
    },
    {
      $facet: {
        totals: [
          {
            $group: {
              _id: null,
              totalDebit: {
                $sum: { $cond: [{ $eq: ['$type', 'DEBIT'] }, '$computedAmount', 0] },
              },
              totalCredit: {
                $sum: { $cond: [{ $eq: ['$type', 'CREDIT'] }, '$computedAmount', 0] },
              },
              transactionCount: { $sum: 1 },
            },
          },
        ],
        subcategories: [
          {
            $group: {
              _id: { category: '$category', subcategory: '$subcategory' },
              debit: { $sum: { $cond: [{ $eq: ['$type', 'DEBIT'] }, '$computedAmount', 0] } },
              credit: { $sum: { $cond: [{ $eq: ['$type', 'CREDIT'] }, '$computedAmount', 0] } },
            },
          },
        ],
      },
    },
  ];

  const [aggregated] = await BankTransaction.aggregate(pipeline);
  const totals = aggregated?.totals?.[0];
  const subcategories = aggregated?.subcategories || [];

  return { totals, subcategories };
}

export async function recomputeDay(
  userId: UserIdLike,
  date: Date,
  sourceType: MetricsSourceType,
  bankId: string | Types.ObjectId | null = null,
  accountId: string | Types.ObjectId | null = null
) {
  try {
    const dayStart = toUtcDayStart(date);
    const dayEnd = toUtcDayEnd(date);
    const bankIdStr = bankId ? String(bankId) : null;
    const accountIdStr = accountId ? String(accountId) : null;
    const userObjectId = new Types.ObjectId(userId as string);

    const { totals, subcategories } = await computeScopeSnapshot(userId, dayStart, dayEnd, sourceType, bankIdStr, accountIdStr);

    if (!totals) {
      await UserDailyMetrics.deleteOne({
        userId: userObjectId,
        date: dayStart,
        sourceType,
        bankId: bankIdStr ? new Types.ObjectId(bankIdStr) : null,
        accountId: accountIdStr ? new Types.ObjectId(accountIdStr) : null,
      });
      return { updated: 0, deleted: 1 };
    }

    const subcategoryBreakdown = subcategories.map((row: any) => ({
      category: row._id?.category,
      subcategory: row._id?.subcategory,
      debit: row.debit || 0,
      credit: row.credit || 0,
    }));

    // derive category totals from subcategories to avoid double computation
    const categoryTotalsMap = new Map<string, { debit: number; credit: number }>();
    for (const row of subcategoryBreakdown) {
      const key = row.category || 'untagged';
      const cur = categoryTotalsMap.get(key) || { debit: 0, credit: 0 };
      cur.debit += row.debit || 0;
      cur.credit += row.credit || 0;
      categoryTotalsMap.set(key, cur);
    }
    const categoryBreakdown = Array.from(categoryTotalsMap.entries()).map(([category, totals]) => ({
      category,
      debit: totals.debit,
      credit: totals.credit,
    }));

    await UserDailyMetrics.updateOne(
      {
        userId: userObjectId,
        date: dayStart,
        sourceType,
        bankId: bankIdStr ? new Types.ObjectId(bankIdStr) : null,
        accountId: accountIdStr ? new Types.ObjectId(accountIdStr) : null,
      },
      {
        $set: {
          userId: userObjectId,
          date: dayStart,
          sourceType,
          bankId: bankIdStr ? new Types.ObjectId(bankIdStr) : null,
          accountId: accountIdStr ? new Types.ObjectId(accountIdStr) : null,
          totalDebit: totals.totalDebit || 0,
          totalCredit: totals.totalCredit || 0,
          transactionCount: totals.transactionCount || 0,
          categoryBreakdown,
          subcategoryBreakdown,
        },
      },
      { upsert: true }
    );

    return { updated: 1, deleted: 0 };
  } catch (error: any) {
    logger.error(`recomputeDay failed: ${error?.message || error}`);
    return { updated: 0, deleted: 0 };
  }
}

export async function updateDailyMetrics(transactions: Partial<IBankTransaction>[], userId: UserIdLike) {
  try {
    if (!transactions || transactions.length === 0) return { updated: 0, deleted: 0 };

    const normalizedTxs = [...transactions];
    const lookupIds: Types.ObjectId[] = [];
    for (const tx of normalizedTxs) {
      const hasId = tx?._id && Types.ObjectId.isValid(String(tx._id));
      const missingBank = tx?.manualTransaction !== true && !tx?.bankId;
      const missingAccount = tx?.manualTransaction !== true && !tx?.accountId;
      const missingManualFlag = tx?.manualTransaction === undefined;
      if (hasId && (missingBank || missingAccount || missingManualFlag)) {
        lookupIds.push(new Types.ObjectId(String(tx._id)));
      }
    }

    if (lookupIds.length > 0) {
      const existing = await BankTransaction.find({ _id: { $in: lookupIds } })
        .select('_id bankId accountId manualTransaction transactionTimestamp')
        .lean();

      const existingMap = new Map<string, any>(existing.map((e) => [String(e._id), e]));
      for (const tx of normalizedTxs) {
        if (!tx?._id) continue;
        const found = existingMap.get(String(tx._id));
        if (!found) continue;
        if (!tx.bankId && found.bankId) tx.bankId = found.bankId;
        if (!tx.accountId && found.accountId) tx.accountId = found.accountId;
        if (tx.manualTransaction === undefined && found.manualTransaction !== undefined) {
          tx.manualTransaction = found.manualTransaction;
        }
        if (!tx.transactionTimestamp && found.transactionTimestamp) {
          tx.transactionTimestamp = found.transactionTimestamp;
        }
      }
    }

    const scopes = new Map<string, ScopeKey>();
    for (const tx of normalizedTxs) {
      const scope = inferScope(tx);
      if (!scope) continue;
      const key = `${scope.dayKey}|${scope.sourceType}|${scope.bankId || 'null'}|${scope.accountId || 'null'}`;
      scopes.set(key, scope);
    }

    if (scopes.size === 0) return { updated: 0, deleted: 0 };

    let updated = 0;
    let deleted = 0;

    for (const scope of scopes.values()) {
      const dayStart = dayStartFromKey(scope.dayKey);
      const res = await recomputeDay(userId, dayStart, scope.sourceType, scope.bankId, scope.accountId);
      updated += res.updated;
      deleted += res.deleted;
    }

    return { updated, deleted };
  } catch (error: any) {
    logger.error(`updateDailyMetrics failed: ${error?.message || error}`);
    return { updated: 0, deleted: 0 };
  }
}

export const dailyMetricsHelpers = {
  toUtcDayStart,
  toUtcDayEnd,
};
