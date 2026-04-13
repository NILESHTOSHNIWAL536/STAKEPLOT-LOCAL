import moment from 'moment-timezone';
import ReserveRepository from '../repositories/reserve-repository';
import UserDailyMetrics from '@/models/transactions-automation/user-daily-metrics';
import { ReserveSnapshot, ReserveDocument } from '@/models/reserve-model';
import { Types, PipelineStage } from 'mongoose';
import { getDeviceIdsByUserId } from '@/utils/helpers/getDeviceIds';
import pushNotificationService from './notification-service';
import logger from '@/utils/common/logger';
import { scheduleReserveReminder } from './bull-queue-service/reserve-reminder-queue';

const reserveRepo = new ReserveRepository();

type SuggestionInput = {
  userId: string | Types.ObjectId;
  categories?: string[];
  durationDays: number;
  now?: Date;
};

export async function computeSuggestion({ userId, durationDays, now = new Date() }: SuggestionInput) {
  // Suggestion is based on overall spend, ignoring selected categories
  const end = moment(now).utc().endOf('day').toDate();
  const start = moment(end).subtract(70, 'days').startOf('day').toDate();

  const pipeline: PipelineStage[] = [];
  pipeline.push({
    $match: {
      userId: new Types.ObjectId(userId as string),
      date: { $gte: start, $lte: end },
    },
  } as PipelineStage.Match);
  pipeline.push({
    $group: {
      _id: null,
      debit: { $sum: '$totalDebit' },
      days: { $addToSet: '$date' },
    },
  } as PipelineStage.Group);

  const agg = await UserDailyMetrics.aggregate(pipeline);
  const debit = agg?.[0]?.debit || 0;
  const dayCount = (agg?.[0]?.days || []).length || 1;
  const dailyBaseline = debit / 70;

  // momentum: last 7 days vs baseline
  const last7End = end;
  const last7Start = moment(end).subtract(6, 'days').startOf('day').toDate();
  const last7Pipeline: PipelineStage[] = [];
  last7Pipeline.push({
    $match: {
      userId: new Types.ObjectId(userId as string),
      date: { $gte: last7Start, $lte: last7End },
    },
  } as PipelineStage.Match);
  last7Pipeline.push({
    $group: {
      _id: null,
      debit: { $sum: '$totalDebit' },
    },
  } as PipelineStage.Group);

  const last7Agg = await UserDailyMetrics.aggregate(last7Pipeline);
  const last7 = last7Agg?.[0]?.debit || 0;
  const momentum = dailyBaseline > 0 ? last7 / (dailyBaseline * 7) : 1;

  const today = moment(now).tz('Asia/Kolkata');
  const mtdPressure = today.date() / today.daysInMonth();

  const base = 1;
  const momentumAdjustment = Math.min(Math.max(momentum, 0.5), 1.5);
  const mtdAdjustment = Math.min(Math.max(mtdPressure, 0.5), 1.5);
  const adjustmentFactor = base * momentumAdjustment * mtdAdjustment;

  const suggestedLimit = dailyBaseline * durationDays * adjustmentFactor;
  const plannedDaily = suggestedLimit / durationDays;

  return {
    suggested_limit: suggestedLimit,
    daily_baseline: dailyBaseline,
    momentum,
    mtd_pressure: mtdPressure,
    adjustment_factor: adjustmentFactor,
    planned_daily: plannedDaily,
  };
}

export async function buildSnapshots(reserve: ReserveDocument, now = new Date()): Promise<ReserveSnapshot[]> {
  const days: ReserveSnapshot[] = [];
  const start = moment(reserve.startDate).startOf('day');
  const end = moment(reserve.endDate).endOf('day');
  const duration = end.diff(start, 'days') + 1;

  for (let i = 0; i < duration; i++) {
    const day = moment(start).add(i, 'days');
    const remainingDays = Math.max(0, end.diff(day, 'days')) + 1;
    const remaining = reserve.amount;
    const daily = reserve.planned_daily || reserve.amount / duration;
    days.push({
      date: day.toDate(),
      spend: 0,
      projectedTotal: 0,
      percentUsed: 0,
      remaining,
      remainingDays,
      recommendedDaily: daily,
      recoveryTarget: 0,
      alertSent: false,
      overspendNotified: false,
    });
  }

  return days;
}

export async function recomputeReserveProgress(reserve: ReserveDocument) {
  const start = moment(reserve.startDate).startOf('day');
  const end = moment(reserve.endDate).endOf('day');
  const duration = end.diff(start, 'days') + 1;
  const useAllCategories = reserve.categories.includes('overall');
  const today = moment().startOf('day');
  const userObjectId = new Types.ObjectId(reserve.userId as any);

  // fetch spend in window for categories
  const pipeline: PipelineStage[] = [];
  pipeline.push({
    $match: {
      userId: userObjectId,
      date: { $gte: start.toDate(), $lte: end.toDate() },
      ...(useAllCategories ? {} : { 'categoryBreakdown.category': { $in: reserve.categories } }),
    },
  } as PipelineStage.Match);
  pipeline.push({ $unwind: '$categoryBreakdown' } as PipelineStage.Unwind);
  if (!useAllCategories) {
    pipeline.push({ $match: { 'categoryBreakdown.category': { $in: reserve.categories } } } as PipelineStage.Match);
  }
  pipeline.push({
    $group: {
      _id: '$date',
      debit: { $sum: '$categoryBreakdown.debit' },
    },
  } as PipelineStage.Group);
  pipeline.push({ $sort: { _id: 1 } } as PipelineStage.Sort);

  const rows = await UserDailyMetrics.aggregate(pipeline);
  const snapshots: ReserveSnapshot[] = [];
  let cumulative = 0;
  if (today.isBetween(start, end, 'day', '[]')) {
    reserve.status = reserve.status === 'OVERSPENT' ? 'OVERSPENT' : 'ACTIVE';
  } else if (today.isBefore(start)) {
    reserve.status = 'UPCOMING';
  }

  for (let i = 0; i < duration; i++) {
    const day = moment(start).add(i, 'days');
    const row = rows.find((r) => moment(r._id).isSame(day, 'day'));
    const spend = row?.debit || 0;
    cumulative += spend;
    const percentUsed = (cumulative / reserve.amount) * 100;
    const remaining = Math.max(reserve.amount - cumulative, 0);
    const remainingDays = Math.max(end.diff(day, 'days') + 1, 0);
    const recommendedDaily = remainingDays > 0 ? remaining / remainingDays : 0;
    const overspend = Math.max(cumulative - reserve.amount, 0);
    const recoveryTarget = remainingDays > 0 ? overspend / remainingDays : 0;

    snapshots.push({
      date: day.toDate(),
      spend,
      projectedTotal: cumulative,
      percentUsed,
      remaining,
      remainingDays,
      recommendedDaily,
      recoveryTarget,
      alertSent: percentUsed >= reserve.notify_at_percent,
      overspendNotified: overspend > 0,
    });
  }

  return { snapshots, cumulative };
}

export async function notifyIfNeeded(reserve: ReserveDocument, snapshots: ReserveSnapshot[]) {
  const last = snapshots[snapshots.length - 1];
  if (!last) return;

  const deviceIds = await getDeviceIdsByUserId(reserve.userId!);
  if (!deviceIds.length) return;

  // pre-alert when approaching 90% (or user threshold)
  if (!reserve.pre_alert_sent && last.percentUsed >= reserve.notify_at_percent - 10) {
    const msg = `Heads up! You've used ${last.percentUsed.toFixed(0)}% of your reserve. Remaining ₹${last.remaining.toFixed(0)} over ${last.remainingDays} days.`;
    await pushNotificationService.SendNotificationToDeviceSpecific(reserve.userId!, msg, deviceIds, '/reserve', 'Reserve update');
    reserve.pre_alert_sent = true;
  }

  // exact threshold
  if (last.percentUsed >= reserve.notify_at_percent && reserve.last_notified_percent < reserve.notify_at_percent) {
    const msg = `Reserve reached ${reserve.notify_at_percent}% spent. Try to stay within ₹${last.recommendedDaily.toFixed(0)} per day.`;
    await pushNotificationService.SendNotificationToDeviceSpecific(reserve.userId!, msg, deviceIds, '/reserve', 'Reserve alert');
    reserve.last_notified_percent = reserve.notify_at_percent;
  }

  // overspend recovery
  if (last.projectedTotal > reserve.amount && !reserve.recovery_notified) {
    const msg = `You've overspent reserve by ₹${(last.projectedTotal - reserve.amount).toFixed(0)}. Target ₹${last.recommendedDaily.toFixed(0)} per day to recover.`;
    await pushNotificationService.SendNotificationToDeviceSpecific(reserve.userId!, msg, deviceIds, '/reserve', 'Recovery mode');
    reserve.recovery_notified = true;
    reserve.status = 'OVERSPENT';
  }

  // completion
  if (last.projectedTotal <= reserve.amount && last.remainingDays === 0) {
    reserve.status = 'COMPLETED';
  }
}

export async function evaluateReserve(reserve: ReserveDocument) {
  const { snapshots } = await recomputeReserveProgress(reserve);
  reserve.set('snapshots', snapshots as any);
  await notifyIfNeeded(reserve, snapshots);
  return reserve;
}

export async function runDailyReserveSweep() {
  const today = moment().startOf('day').toDate();
  const active = await reserveRepo.get({ startDate: { $lte: today }, endDate: { $gte: today } });

  for (const res of active as ReserveDocument[]) {
    try {
      await evaluateReserve(res as ReserveDocument);
      await res.save();
    } catch (err: any) {
      logger.error(`Reserve sweep failed for ${res.id}: ${err.message}`);
    }
  }
}

export async function scheduleExistingReserves() {
  const today = moment().startOf('day').toDate();
  const active = await reserveRepo.get({ startDate: { $lte: today }, endDate: { $gte: today } });
  for (const res of active as ReserveDocument[]) {
    try {
      const userIdStr = typeof res.userId === 'string' ? res.userId : res.userId?.toString();
      if (!userIdStr) continue;
      await scheduleReserveReminder(res.id, userIdStr, res.startDate, res.endDate, res.reminder_time as any);
    } catch (err: any) {
      logger.error(`Failed to schedule reserve reminder ${res.id}: ${err.message}`);
    }
  }
}

export default {
  computeSuggestion,
  buildSnapshots,
  recomputeReserveProgress,
  notifyIfNeeded,
  evaluateReserve,
  runDailyReserveSweep,
  scheduleExistingReserves,
};
