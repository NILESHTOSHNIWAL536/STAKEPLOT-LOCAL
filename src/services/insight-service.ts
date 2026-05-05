import { PipelineStage, Types } from 'mongoose';
import { RecurringPayment, Transaction } from '@/models';

const TIMEZONE = 'Asia/Kolkata';
const DEFAULT_DAYS = 30;
const DEFAULT_LIMIT = 10;

type DateRange = {
  startDate: Date;
  endDate: Date;
};

type InsightQuery = {
  startDate?: string;
  endDate?: string;
  days?: string | number;
  limit?: string | number;
  type?: string;
};

const insightCatalog = [
  {
    key: 'spend_overview',
    title: 'Spend overview',
    description: 'Total spend, income, net cash flow, transaction count, and comparison with the previous period.',
  },
  {
    key: 'most_frequent_payment',
    title: 'Most frequent payment',
    description: 'Merchant or payee where the user pays most often.',
  },
  {
    key: 'highest_payment_date',
    title: 'Highest payment date',
    description: 'The day where user spent the highest amount.',
  },
  {
    key: 'top_categories',
    title: 'Top spending categories',
    description: 'Categories taking the largest share of user spend.',
  },
  {
    key: 'category_growth',
    title: 'Category growth vs previous period',
    description: 'Categories where spend has increased or reduced compared with the previous period.',
  },
  {
    key: 'top_merchants',
    title: 'Top merchants/payees',
    description: 'Highest spend and highest frequency merchants or payees.',
  },
  {
    key: 'income_sources',
    title: 'Income sources',
    description: 'Frequent credit sources and largest incoming credits.',
  },
  {
    key: 'cash_vs_bank',
    title: 'Cash vs bank/UPI usage',
    description: 'Manual cash transactions compared with bank/UPI transactions.',
  },
  {
    key: 'payment_mode_mix',
    title: 'Payment mode mix',
    description: 'Spend split by UPI, card, cash, ATM, transfer, and other modes.',
  },
  {
    key: 'weekday_pattern',
    title: 'Weekday spending pattern',
    description: 'Days of week where user spends most.',
  },
  {
    key: 'hourly_pattern',
    title: 'Time of day spending pattern',
    description: 'Morning, afternoon, evening, and night spend behavior.',
  },
  {
    key: 'recurring_payments',
    title: 'Recurring payments',
    description: 'Upcoming active recurring payments and subscription-like debits.',
  },
  {
    key: 'bill_and_autopay',
    title: 'Bills and autopay',
    description: 'Bills, autopay debits, and expected upcoming money outflow.',
  },
  {
    key: 'anomalies',
    title: 'Unusual high spends',
    description: 'Transactions much higher than the user usually pays in that category or merchant.',
  },
  {
    key: 'review_needed',
    title: 'Transactions needing review',
    description: 'Untagged or pending-review transactions that need user confirmation.',
  },
  {
    key: 'savings_opportunity',
    title: 'Savings opportunities',
    description: 'Categories or merchants where spend grew fast and may be reduced.',
  },
  {
    key: 'daily_trend',
    title: 'Daily spend trend',
    description: 'Day-by-day debit and credit movement for charts.',
  },
  {
    key: 'largest_transactions',
    title: 'Largest transactions',
    description: 'Biggest debits or credits in the selected period.',
  },
  {
    key: 'balance_trend',
    title: 'Balance trend',
    description: 'Available transaction balance movement from bank transactions.',
  },
  {
    key: 'spend_velocity',
    title: 'Spend velocity',
    description: 'Current daily spend pace, projected period spend, and remaining safe daily spend.',
  },
  {
    key: 'category_health',
    title: 'Category health',
    description: 'Category share, comparison, and risk level for overspending.',
  },
];

const parseNumber = (value: string | number | undefined, fallback: number) => {
  const parsed = Number(value);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
};

const getDateRange = (query: InsightQuery = {}): DateRange => {
  const endDate = query.endDate ? new Date(query.endDate) : new Date();
  const startDate = query.startDate ? new Date(query.startDate) : new Date(endDate);

  if (!query.startDate) {
    startDate.setDate(endDate.getDate() - parseNumber(query.days, DEFAULT_DAYS) + 1);
  }

  startDate.setHours(0, 0, 0, 0);
  endDate.setHours(23, 59, 59, 999);

  if (Number.isNaN(startDate.getTime()) || Number.isNaN(endDate.getTime())) {
    throw new Error('Invalid date range');
  }

  return { startDate, endDate };
};

const getPreviousRange = ({ startDate, endDate }: DateRange): DateRange => {
  const duration = endDate.getTime() - startDate.getTime() + 1;
  const previousEnd = new Date(startDate.getTime() - 1);
  const previousStart = new Date(previousEnd.getTime() - duration + 1);
  return { startDate: previousStart, endDate: previousEnd };
};

const percentageChange = (current = 0, previous = 0) => {
  if (!previous && !current) return 0;
  if (!previous) return 100;
  return Number((((current - previous) / previous) * 100).toFixed(2));
};

const baseMatch = (userId: string | Types.ObjectId, range?: DateRange, extra: Record<string, unknown> = {}) => {
  const match: Record<string, unknown> = {
    userId: new Types.ObjectId(userId),
    Hidden: { $ne: true },
    isExcluded: { $ne: true },
    ...extra,
  };

  if (range) {
    match.transactionTimestamp = { $gte: range.startDate, $lte: range.endDate };
  }

  return match;
};

const txNameExpression = {
  $ifNull: [
    {
      $cond: [{ $ne: ['$merchant', ''] }, '$merchant', null],
    },
    {
      $ifNull: [
        {
          $cond: [{ $ne: ['$name', ''] }, '$name', null],
        },
        '$narration',
      ],
    },
  ],
};

const getTotals = async (userId: string | Types.ObjectId, range: DateRange) => {
  const [totals] = await Transaction.aggregate([
    { $match: baseMatch(userId, range) },
    {
      $group: {
        _id: null,
        totalDebit: { $sum: { $cond: [{ $eq: ['$type', 'DEBIT'] }, '$amount', 0] } },
        totalCredit: { $sum: { $cond: [{ $eq: ['$type', 'CREDIT'] }, '$amount', 0] } },
        transactionCount: { $sum: 1 },
        debitCount: { $sum: { $cond: [{ $eq: ['$type', 'DEBIT'] }, 1, 0] } },
        creditCount: { $sum: { $cond: [{ $eq: ['$type', 'CREDIT'] }, 1, 0] } },
        averageDebit: { $avg: { $cond: [{ $eq: ['$type', 'DEBIT'] }, '$amount', null] } },
        biggestDebit: { $max: { $cond: [{ $eq: ['$type', 'DEBIT'] }, '$amount', 0] } },
        biggestCredit: { $max: { $cond: [{ $eq: ['$type', 'CREDIT'] }, '$amount', 0] } },
      },
    },
  ]);

  return {
    totalDebit: totals?.totalDebit || 0,
    totalCredit: totals?.totalCredit || 0,
    netCashFlow: (totals?.totalCredit || 0) - (totals?.totalDebit || 0),
    transactionCount: totals?.transactionCount || 0,
    debitCount: totals?.debitCount || 0,
    creditCount: totals?.creditCount || 0,
    averageDebit: Number((totals?.averageDebit || 0).toFixed(2)),
    biggestDebit: totals?.biggestDebit || 0,
    biggestCredit: totals?.biggestCredit || 0,
  };
};

export const getInsightCatalog = async () => insightCatalog;

export const getSummaryInsights = async (userId: string | Types.ObjectId, query: InsightQuery = {}) => {
  const range = getDateRange(query);
  const previousRange = getPreviousRange(range);

  const [current, previous, highestPaymentDate, mostFrequentPayment, topCategory] = await Promise.all([
    getTotals(userId, range),
    getTotals(userId, previousRange),
    Transaction.aggregate([
      { $match: baseMatch(userId, range, { type: 'DEBIT' }) },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$transactionTimestamp', timezone: TIMEZONE } },
          amount: { $sum: '$amount' },
          count: { $sum: 1 },
        },
      },
      { $sort: { amount: -1 } },
      { $limit: 1 },
    ]),
    Transaction.aggregate([
      { $match: baseMatch(userId, range, { type: 'DEBIT' }) },
      { $group: { _id: txNameExpression, amount: { $sum: '$amount' }, count: { $sum: 1 } } },
      { $sort: { count: -1, amount: -1 } },
      { $limit: 1 },
    ]),
    Transaction.aggregate([
      { $match: baseMatch(userId, range, { type: 'DEBIT' }) },
      { $group: { _id: '$category', amount: { $sum: '$amount' }, count: { $sum: 1 } } },
      { $sort: { amount: -1 } },
      { $limit: 1 },
    ]),
  ]);

  return {
    range,
    current,
    previous,
    comparison: {
      debitChangePercentage: percentageChange(current.totalDebit, previous.totalDebit),
      creditChangePercentage: percentageChange(current.totalCredit, previous.totalCredit),
      transactionCountChangePercentage: percentageChange(current.transactionCount, previous.transactionCount),
    },
    highlights: {
      highestPaymentDate: highestPaymentDate[0] || null,
      mostFrequentPayment: mostFrequentPayment[0] || null,
      topCategory: topCategory[0] || null,
    },
  };
};

export const getCategoryInsights = async (userId: string | Types.ObjectId, query: InsightQuery = {}) => {
  const range = getDateRange(query);
  const previousRange = getPreviousRange(range);
  const limit = parseNumber(query.limit, DEFAULT_LIMIT);

  const [current, previous] = await Promise.all([
    Transaction.aggregate([
      { $match: baseMatch(userId, range, { type: 'DEBIT' }) },
      { $group: { _id: '$category', amount: { $sum: '$amount' }, count: { $sum: 1 }, average: { $avg: '$amount' } } },
      { $sort: { amount: -1 } },
      { $limit: limit },
    ]),
    Transaction.aggregate([
      { $match: baseMatch(userId, previousRange, { type: 'DEBIT' }) },
      { $group: { _id: '$category', amount: { $sum: '$amount' }, count: { $sum: 1 } } },
    ]),
  ]);

  const previousMap = new Map(previous.map((item) => [item._id, item]));

  return current.map((item) => {
    const previousItem = previousMap.get(item._id);
    return {
      category: item._id || 'Uncategorized',
      amount: item.amount,
      count: item.count,
      average: Number((item.average || 0).toFixed(2)),
      previousAmount: previousItem?.amount || 0,
      changePercentage: percentageChange(item.amount, previousItem?.amount || 0),
    };
  });
};

export const getMerchantInsights = async (userId: string | Types.ObjectId, query: InsightQuery = {}) => {
  const range = getDateRange(query);
  const limit = parseNumber(query.limit, DEFAULT_LIMIT);
  const type = query.type === 'CREDIT' ? 'CREDIT' : 'DEBIT';

  return Transaction.aggregate([
    { $match: baseMatch(userId, range, { type }) },
    {
      $group: {
        _id: txNameExpression,
        amount: { $sum: '$amount' },
        count: { $sum: 1 },
        average: { $avg: '$amount' },
        latestTransactionAt: { $max: '$transactionTimestamp' },
      },
    },
    { $match: { _id: { $nin: [null, ''] } } },
    { $sort: { amount: -1, count: -1 } },
    { $limit: limit },
    {
      $project: {
        _id: 0,
        name: '$_id',
        amount: 1,
        count: 1,
        average: { $round: ['$average', 2] },
        latestTransactionAt: 1,
      },
    },
  ]);
};

export const getTimePatternInsights = async (userId: string | Types.ObjectId, query: InsightQuery = {}) => {
  const range = getDateRange(query);
  const match = { $match: baseMatch(userId, range, { type: 'DEBIT' }) };

  const [weekday, hourly, highestDates] = await Promise.all([
    Transaction.aggregate([
      match,
      {
        $group: {
          _id: { $dayOfWeek: { date: '$transactionTimestamp', timezone: TIMEZONE } },
          amount: { $sum: '$amount' },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ] as PipelineStage[]),
    Transaction.aggregate([
      match,
      {
        $group: {
          _id: { $hour: { date: '$transactionTimestamp', timezone: TIMEZONE } },
          amount: { $sum: '$amount' },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ] as PipelineStage[]),
    Transaction.aggregate([
      match,
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$transactionTimestamp', timezone: TIMEZONE } },
          amount: { $sum: '$amount' },
          count: { $sum: 1 },
        },
      },
      { $sort: { amount: -1 } },
      { $limit: 5 },
    ] as PipelineStage[]),
  ]);

  return { weekday, hourly, highestDates };
};

export const getPaymentModeInsights = async (userId: string | Types.ObjectId, query: InsightQuery = {}) => {
  const range = getDateRange(query);

  return Transaction.aggregate([
    { $match: baseMatch(userId, range, { type: 'DEBIT' }) },
    {
      $group: {
        _id: '$mode',
        amount: { $sum: '$amount' },
        count: { $sum: 1 },
        average: { $avg: '$amount' },
      },
    },
    { $sort: { amount: -1 } },
    {
      $project: {
        _id: 0,
        mode: { $ifNull: ['$_id', 'UNKNOWN'] },
        amount: 1,
        count: 1,
        average: { $round: ['$average', 2] },
      },
    },
  ]);
};

export const getCashVsBankInsights = async (userId: string | Types.ObjectId, query: InsightQuery = {}) => {
  const range = getDateRange(query);

  return Transaction.aggregate([
    { $match: baseMatch(userId, range) },
    {
      $group: {
        _id: {
          source: { $cond: [{ $eq: ['$manualTransaction', true] }, 'CASH_MANUAL', 'BANK_UPI'] },
          type: '$type',
        },
        amount: { $sum: '$amount' },
        count: { $sum: 1 },
      },
    },
    { $sort: { '_id.source': 1, '_id.type': 1 } },
    {
      $project: {
        _id: 0,
        source: '$_id.source',
        type: '$_id.type',
        amount: 1,
        count: 1,
      },
    },
  ]);
};

export const getRecurringInsights = async (userId: string | Types.ObjectId, query: InsightQuery = {}) => {
  const limit = parseNumber(query.limit, DEFAULT_LIMIT);

  return RecurringPayment.find({
    userId: new Types.ObjectId(userId),
    isActive: true,
  })
    .sort({ nextReminderAt: 1 })
    .limit(limit)
    .lean();
};

export const getAnomalyInsights = async (userId: string | Types.ObjectId, query: InsightQuery = {}) => {
  const range = getDateRange({ days: query.days || 90, endDate: query.endDate });
  const limit = parseNumber(query.limit, DEFAULT_LIMIT);

  return Transaction.aggregate([
    { $match: baseMatch(userId, range, { type: 'DEBIT' }) },
    {
      $setWindowFields: {
        partitionBy: '$category',
        output: {
          categoryAverage: { $avg: '$amount', window: { documents: ['unbounded', 'unbounded'] } },
          categoryStdDev: { $stdDevPop: '$amount', window: { documents: ['unbounded', 'unbounded'] } },
        },
      },
    },
    {
      $addFields: {
        anomalyScore: {
          $cond: [
            { $gt: ['$categoryStdDev', 0] },
            { $divide: [{ $subtract: ['$amount', '$categoryAverage'] }, '$categoryStdDev'] },
            0,
          ],
        },
      },
    },
    { $match: { anomalyScore: { $gte: 2 } } },
    { $sort: { anomalyScore: -1, amount: -1 } },
    { $limit: limit },
    {
      $project: {
        _id: 1,
        type: 1,
        mode: 1,
        name: 1,
        merchant: 1,
        amount: 1,
        category: 1,
        subcategory: 1,
        narration: 1,
        transactionTimestamp: 1,
        categoryAverage: { $round: ['$categoryAverage', 2] },
        anomalyScore: { $round: ['$anomalyScore', 2] },
      },
    },
  ]);
};

export const getActionItemInsights = async (userId: string | Types.ObjectId) => {
  const [needsReviewCount, untaggedCount, activeRecurringCount, hiddenCount] = await Promise.all([
    Transaction.countDocuments(baseMatch(userId, undefined, { needsReview: true })),
    Transaction.countDocuments(baseMatch(userId, undefined, { category: { $in: ['Untagged', 'Uncategorized', '', null] } })),
    RecurringPayment.countDocuments({ userId: new Types.ObjectId(userId), isActive: true }),
    Transaction.countDocuments({ userId: new Types.ObjectId(userId), Hidden: true }),
  ]);

  return {
    needsReviewCount,
    untaggedCount,
    activeRecurringCount,
    hiddenCount,
  };
};

export const getDailyTrendInsights = async (userId: string | Types.ObjectId, query: InsightQuery = {}) => {
  const range = getDateRange(query);

  return Transaction.aggregate([
    { $match: baseMatch(userId, range) },
    {
      $group: {
        _id: { $dateToString: { format: '%Y-%m-%d', date: '$transactionTimestamp', timezone: TIMEZONE } },
        debit: { $sum: { $cond: [{ $eq: ['$type', 'DEBIT'] }, '$amount', 0] } },
        credit: { $sum: { $cond: [{ $eq: ['$type', 'CREDIT'] }, '$amount', 0] } },
        count: { $sum: 1 },
      },
    },
    { $sort: { _id: 1 } },
    {
      $project: {
        _id: 0,
        date: '$_id',
        debit: 1,
        credit: 1,
        net: { $subtract: ['$credit', '$debit'] },
        count: 1,
      },
    },
  ]);
};

export const getLargestTransactionInsights = async (userId: string | Types.ObjectId, query: InsightQuery = {}) => {
  const range = getDateRange(query);
  const limit = parseNumber(query.limit, DEFAULT_LIMIT);
  const type = query.type === 'CREDIT' ? 'CREDIT' : 'DEBIT';

  return Transaction.find(baseMatch(userId, range, { type }))
    .select('type mode name merchant amount category subcategory narration transactionTimestamp manualTransaction transactionalBalance')
    .sort({ amount: -1 })
    .limit(limit)
    .lean();
};

export const getBalanceTrendInsights = async (userId: string | Types.ObjectId, query: InsightQuery = {}) => {
  const range = getDateRange(query);

  return Transaction.aggregate([
    {
      $match: baseMatch(userId, range, {
        manualTransaction: { $ne: true },
        transactionalBalance: { $gt: 0 },
      }),
    },
    { $sort: { transactionTimestamp: 1 } },
    {
      $group: {
        _id: { $dateToString: { format: '%Y-%m-%d', date: '$transactionTimestamp', timezone: TIMEZONE } },
        closingBalance: { $last: '$transactionalBalance' },
        lowestBalance: { $min: '$transactionalBalance' },
        highestBalance: { $max: '$transactionalBalance' },
        count: { $sum: 1 },
      },
    },
    { $sort: { _id: 1 } },
    {
      $project: {
        _id: 0,
        date: '$_id',
        closingBalance: 1,
        lowestBalance: 1,
        highestBalance: 1,
        count: 1,
      },
    },
  ]);
};

export const getSpendVelocityInsights = async (userId: string | Types.ObjectId, query: InsightQuery = {}) => {
  const range = getDateRange(query);
  const previousRange = getPreviousRange(range);
  const [current, previous] = await Promise.all([getTotals(userId, range), getTotals(userId, previousRange)]);

  const totalDays = Math.max(1, Math.ceil((range.endDate.getTime() - range.startDate.getTime()) / (1000 * 60 * 60 * 24)));
  const elapsedDays = Math.min(totalDays, Math.max(1, Math.ceil((Date.now() - range.startDate.getTime()) / (1000 * 60 * 60 * 24))));
  const dailyAverageSpend = Number((current.totalDebit / elapsedDays).toFixed(2));
  const projectedSpend = Number((dailyAverageSpend * totalDays).toFixed(2));
  const previousDailyAverageSpend = Number((previous.totalDebit / totalDays).toFixed(2));
  const suggestedDailySpend = previous.totalDebit ? Number((previous.totalDebit / totalDays).toFixed(2)) : dailyAverageSpend;
  const remainingDays = Math.max(0, totalDays - elapsedDays);
  const remainingSpendToMatchPrevious = Math.max(0, previous.totalDebit - current.totalDebit);

  return {
    range,
    totalDays,
    elapsedDays,
    remainingDays,
    dailyAverageSpend,
    previousDailyAverageSpend,
    projectedSpend,
    previousPeriodSpend: previous.totalDebit,
    spendPaceChangePercentage: percentageChange(dailyAverageSpend, previousDailyAverageSpend),
    safeDailySpendForRemainingDays: remainingDays ? Number((remainingSpendToMatchPrevious / remainingDays).toFixed(2)) : 0,
  };
};

export const getCategoryHealthInsights = async (userId: string | Types.ObjectId, query: InsightQuery = {}) => {
  const categories = await getCategoryInsights(userId, { ...query, limit: query.limit || 12 });
  const totalAmount = categories.reduce((sum, item) => sum + (item.amount || 0), 0);

  return categories.map((item) => {
    const sharePercentage = totalAmount ? Number(((item.amount / totalAmount) * 100).toFixed(2)) : 0;
    const riskLevel = item.changePercentage >= 50 || sharePercentage >= 35 ? 'HIGH' : item.changePercentage >= 20 || sharePercentage >= 20 ? 'MEDIUM' : 'LOW';

    return {
      ...item,
      sharePercentage,
      riskLevel,
      savingOpportunityAmount: item.changePercentage > 0 ? Math.max(0, item.amount - item.previousAmount) : 0,
    };
  });
};

export const getIncomeSourceInsights = async (userId: string | Types.ObjectId, query: InsightQuery = {}) => {
  return getMerchantInsights(userId, { ...query, type: 'CREDIT' });
};
