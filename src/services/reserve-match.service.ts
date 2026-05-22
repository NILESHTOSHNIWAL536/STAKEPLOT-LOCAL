import { Types } from 'mongoose';
import UserDailyMetrics from '@/models/transactions-automation/user-daily-metrics';
import BankTransaction from '@/models/transactions-automation/transaction';
import { Reserve } from '@/models/reserve-model';
import { DEFAULT_TZ, getEndOfDay, getLast7DaysRange, getLastNDaysRange, getMonthToDateRatio, getStartOfDay } from '@/utils/time';

type GoalType = 'reserve' | 'saving' | 'debt' | null;

const spendBuckets = [0, 5000, 10000, 20000, Number.POSITIVE_INFINITY];
const spendBucketLabels = ['₹0–5K', '₹5–10K', '₹10–20K', '₹20K+'];
const ticketBuckets = [0, 150, 300, 700, Number.POSITIVE_INFINITY];
const ticketBucketLabels = ['₹0–150', '₹150–300', '₹300–700', '₹700+'];

export type SpendProfile = {
  userId: Types.ObjectId;
  monthlySpend: number;
  spendBucket: number;
  spendBucketLabel: string;
  topCategories: string[];
  weeklyFrequency: number;
  medianTicket: number;
  medianTicketBucket: number;
  medianTicketLabel: string;
  foodDeliveryRatio: number;
  earlyMonthSpend: number;
  lateMonthSpend: number;
  avgTimeBetweenSpendsDays: number | null;
  goalActive: boolean;
  goalType: GoalType;
};

export type SimilarityComponents = {
  spend_match: number;
  category_match: number;
  frequency_match: number;
  ticket_match: number;
  behavior_state: number;
};

export type SimilarityResult = {
  score: number;
  components: SimilarityComponents;
};

function bucketIndex(buckets: number[], value: number): number {
  for (let i = 0; i < buckets.length - 1; i++) {
    if (value >= buckets[i] && value < buckets[i + 1]) return i;
  }
  return buckets.length - 2;
}

function jaccard(a: string[], b: string[]): number {
  const setA = new Set(a);
  const setB = new Set(b);
  if (setA.size === 0 && setB.size === 0) return 1;
  const intersection = [...setA].filter((x) => setB.has(x)).length;
  const union = new Set([...a, ...b]).size;
  return union === 0 ? 0 : intersection / union;
}

function median(values: number[]): number {
  if (!values.length) return 0;
  const mid = Math.floor(values.length / 2);
  return values.length % 2 === 0 ? (values[mid - 1] + values[mid]) / 2 : values[mid];
}

export async function getUserSpendProfile(userId: string | Types.ObjectId, now = new Date(), tz: string = DEFAULT_TZ): Promise<SpendProfile> {
  const userObjectId = new Types.ObjectId(userId as any);
  const { start: start30, end } = getLastNDaysRange(30, now, tz);
  const { start: start7 } = getLast7DaysRange(end, tz);
  const nowDay = getStartOfDay(now, tz);
  const monthStart = getStartOfDay(new Date(Date.UTC(nowDay.getUTCFullYear(), nowDay.getUTCMonth(), 1)), tz);
  const earlyEnd = getEndOfDay(new Date(monthStart.getTime() + 9 * 24 * 60 * 60 * 1000), tz);
  const lateStart = getStartOfDay(new Date(monthStart.getTime() + 19 * 24 * 60 * 60 * 1000), tz);
  const lateEnd = getEndOfDay(new Date(monthStart.getTime() + 29 * 24 * 60 * 60 * 1000), tz);

  const [totals] = await UserDailyMetrics.aggregate([
    { $match: { userId: userObjectId, date: { $gte: start30, $lte: end } } },
    {
      $group: {
        _id: null,
        totalDebit: { $sum: '$totalDebit' },
        totalTxns: { $sum: '$transactionCount' },
      },
    },
  ]);

  const categoriesAgg = await UserDailyMetrics.aggregate([
    { $match: { userId: userObjectId, date: { $gte: start30, $lte: end } } },
    { $unwind: '$categoryBreakdown' },
    {
      $group: {
        _id: '$categoryBreakdown.category',
        debit: { $sum: '$categoryBreakdown.debit' },
      },
    },
    { $sort: { debit: -1 } },
    { $limit: 5 },
  ]);

  const [last7] = await UserDailyMetrics.aggregate([
    { $match: { userId: userObjectId, date: { $gte: start7, $lte: end } } },
    { $group: { _id: null, txns: { $sum: '$transactionCount' } } },
  ]);

  const [early] = await UserDailyMetrics.aggregate([
    { $match: { userId: userObjectId, date: { $gte: monthStart, $lte: earlyEnd } } },
    { $group: { _id: null, debit: { $sum: '$totalDebit' } } },
  ]);

  const [late] = await UserDailyMetrics.aggregate([
    { $match: { userId: userObjectId, date: { $gte: lateStart, $lte: lateEnd } } },
    { $group: { _id: null, debit: { $sum: '$totalDebit' } } },
  ]);

  const [food] = await UserDailyMetrics.aggregate([
    { $match: { userId: userObjectId, date: { $gte: start30, $lte: end } } },
    { $unwind: '$categoryBreakdown' },
    { $match: { 'categoryBreakdown.category': { $in: ['food', 'restaurant'] } } },
    { $group: { _id: null, debit: { $sum: '$categoryBreakdown.debit' } } },
  ]);

  const txns = await BankTransaction.find(
    {
      userId: userObjectId,
      type: 'DEBIT',
      isExcluded: { $ne: true },
      transactionTimestamp: { $gte: start30, $lte: end },
    },
    { amount: 1, transactionTimestamp: 1 }
  )
    .sort({ transactionTimestamp: 1 })
    .lean();

  const amounts = txns.map((t) => t.amount || 0).sort((a, b) => a - b);
  const medianTicket = median(amounts);
  const medianTicketBucket = bucketIndex(ticketBuckets, medianTicket);

  let avgGapDays: number | null = null;
  if (txns.length > 1) {
    let totalGapMs = 0;
    for (let i = 1; i < txns.length; i++) {
      totalGapMs += new Date(txns[i].transactionTimestamp!).getTime() - new Date(txns[i - 1].transactionTimestamp!).getTime();
    }
    avgGapDays = totalGapMs / (txns.length - 1) / (1000 * 60 * 60 * 24);
  }

  const monthlySpend = totals?.totalDebit || 0;
  const spendBucket = bucketIndex(spendBuckets, monthlySpend);
  const topCategories = categoriesAgg.map((c) => c._id as string);
  const weeklyFrequency = last7?.txns || 0;
  const foodRatio = monthlySpend > 0 ? (food?.debit || 0) / monthlySpend : 0;

  // treat having any reserve as an active financial goal
  const goalActive = true;
  const goalType: GoalType = 'reserve';

  return {
    userId: userObjectId,
    monthlySpend,
    spendBucket,
    spendBucketLabel: spendBucketLabels[spendBucket],
    topCategories,
    weeklyFrequency,
    medianTicket,
    medianTicketBucket,
    medianTicketLabel: ticketBucketLabels[medianTicketBucket],
    foodDeliveryRatio: foodRatio,
    earlyMonthSpend: early?.debit || 0,
    lateMonthSpend: late?.debit || 0,
    avgTimeBetweenSpendsDays: avgGapDays,
    goalActive,
    goalType,
  };
}

export function computeSimilarity(viewer: SpendProfile, other: SpendProfile): SimilarityResult {
  const spendGap = Math.abs(viewer.spendBucket - other.spendBucket);
  const spend_match = spendGap === 0 ? 1 : spendGap === 1 ? 0.5 : 0;

  const category_match = jaccard(viewer.topCategories, other.topCategories);

  const freqDiff = Math.abs((viewer.weeklyFrequency || 0) - (other.weeklyFrequency || 0));
  const frequency_match = Math.max(0, 1 - freqDiff / 10);

  const ticketGap = Math.abs(viewer.medianTicketBucket - other.medianTicketBucket);
  const ticket_match = ticketGap === 0 ? 1 : ticketGap === 1 ? 0.5 : 0;

  const frontLoaded = (profile: SpendProfile) => profile.earlyMonthSpend > profile.lateMonthSpend * 1.1;
  const backLoaded = (profile: SpendProfile) => profile.lateMonthSpend > profile.earlyMonthSpend * 1.1;
  const pattern = (p: SpendProfile) => (frontLoaded(p) ? 'front' : backLoaded(p) ? 'back' : 'balanced');
  const patternScore = pattern(viewer) === pattern(other) ? 1 : 0;

  const foodScore = 1 - Math.min(1, Math.abs(viewer.foodDeliveryRatio - other.foodDeliveryRatio));

  const goalScore = (() => {
    if (viewer.goalActive && other.goalActive) {
      return viewer.goalType === other.goalType ? 1 : 0.5;
    }
    if (!viewer.goalActive && !other.goalActive) return 0.5;
    return 0;
  })();

  const behavior_state = (patternScore + foodScore + goalScore) / 3;

  const score = 0.25 * spend_match + 0.3 * category_match + 0.2 * frequency_match + 0.1 * ticket_match + 0.15 * behavior_state;

  return { score, components: { spend_match, category_match, frequency_match, ticket_match, behavior_state } };
}

function scoreToLabel(score: number): { label: string; color: string } {
  if (score >= 0.75) return { label: 'High match', color: '#22c55e' };
  if (score >= 0.5) return { label: 'Good match', color: '#f59e0b' };
  return { label: 'Low match', color: '#ef4444' };
}

export async function getSharedReservesFeed(viewerId: string | Types.ObjectId, page = 1, limit = 10, tz: string = DEFAULT_TZ) {
  const viewerProfile = await getUserSpendProfile(viewerId, new Date(), tz);
  const skip = (page - 1) * limit;

  const reserves = await Reserve.find({
    share_with_community: true,
    achieved: true,
    status: 'COMPLETED',
    userId: { $ne: new Types.ObjectId(viewerId as any) },
  })
    .sort({ updatedAt: -1 })
    .skip(skip)
    .limit(limit)
    .lean();

  const profileCache = new Map<string, SpendProfile>();
  const items = [] as any[];

  for (const res of reserves) {
    const uid = (res.userId as any).toString();
    let posterProfile = profileCache.get(uid);
    if (!posterProfile) {
      posterProfile = await getUserSpendProfile(uid);
      profileCache.set(uid, posterProfile);
    }

    const { score, components } = computeSimilarity(viewerProfile, posterProfile);
    const { label, color } = scoreToLabel(score);

    items.push({
      reserve: res,
      similarity_score: score,
      similarity_label: label,
      similarity_color: color,
      components,
      posterProfile,
    });
  }

  return {
    page,
    pageSize: limit,
    items,
  };
}

export default {
  getUserSpendProfile,
  computeSimilarity,
  getSharedReservesFeed,
};
