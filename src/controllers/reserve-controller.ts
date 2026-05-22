import { Request, Response } from 'express';
import { StatusCodes } from 'http-status-codes';
import AppError from '../utils/errors/app-error';
import logger from '../utils/common/logger';
import { ReserveService } from '../services/reserve-service';
import reserveEngine from '../services/reserve-engine';
import { scheduleReserveReminder, removeReserveReminder } from '../services/bull-queue-service/reserve-reminder-queue';
import { getStartOfDay, getEndOfDay } from '../utils/time';
import StridesService from '../services/strides-service';
const categoryMapping: Record<string, string> = {
  Transport: 'travel',
  'Dining out': 'food',
  Shopping: 'shopping',
  Groceries: 'groceries',
  'Overall spend': 'overall',
};
export class ReserveController {
  static async suggest(req: Request, res: Response) {
    try {
      const userId = req.user!._id;
      const { durationDays = 7 } = req.body;

      const suggestion = await reserveEngine.computeSuggestion({
        userId,
        durationDays,
      });

      return res.status(StatusCodes.OK).json({ success: true, data: suggestion });
    } catch (error: any) {
      return ReserveController.handleError(res, error);
    }
  }

  // CREATE
  static async createReserve(req: Request, res: Response) {
    try {
      const userId = req.user!._id;

      const { startDate, endDate } = req.body;

      if (!startDate || !endDate) {
        throw new AppError('Start and End dates required', 400);
      }

      // Normalize to IST-midnight-UTC so stored dates align with snapshot dates and sweep queries.
      // e.g. frontend "2026-04-16" → 2026-04-16T00:00Z (UTC midnight = IST 5:30 AM) becomes
      //      2026-04-15T18:30:00Z (IST midnight), matching getStartOfDay used everywhere else.
      const start = getStartOfDay(new Date(startDate));
      const end = getStartOfDay(new Date(endDate));

      const diff = Math.round((end.getTime() - start.getTime()) / (24 * 60 * 60 * 1000)) + 1;

      if (diff > 7) {
        throw new AppError('Max 7 days allowed', 400);
      }

      // CATEGORY TRANSFORM (your previous logic)
      const transformedCategories = req.body.categories.map((cat: string) => {
        return categoryMapping[cat] || cat.toLowerCase();
      });

      // CREATE SUGGESTED AMOUNT, daily_baseline, recommended_spend accoriding the ALGO
      const suggestion = await reserveEngine.computeSuggestion({
        userId,
        categories: transformedCategories,
        durationDays: diff,
      });

      // CREATE RESERVE
      const reserve = await ReserveService.createReserve({
        ...req.body,
        categories: transformedCategories,
        userId,
        startDate: start,
        endDate: end,
        duration_days: diff,
        ...suggestion,
      });

      // Build flat initial snapshots based on the user's chosen amount, then set status.
      // We do NOT call evaluateReserve here — that runs recomputeReserveProgress which
      // produces inflated future-day recommendedDaily values when there is no spend yet.
      // The full recompute happens naturally on the first getReserveById call.
      const snapshots = await reserveEngine.buildSnapshots(reserve as any);
      reserve.set('snapshots', snapshots as any);

      const todayDate = getStartOfDay(new Date());
      const startOfStart = getStartOfDay(start);
      const endOfEnd = getEndOfDay(end);
      if (todayDate.getTime() >= startOfStart.getTime() && todayDate.getTime() <= endOfEnd.getTime()) {
        reserve.status = 'ACTIVE';
      } else if (todayDate.getTime() < startOfStart.getTime()) {
        reserve.status = 'UPCOMING';
      }
      await reserve.save();
      await scheduleReserveReminder(reserve.id, userId.toString(), start, end, req.body.reminder_time);

      return res.status(201).json({
        success: true,
        data: reserve,
      });
    } catch (error: any) {
      return ReserveController.handleError(res, error);
    }
  }

  // GET ALL
  static async getReserves(req: Request, res: Response) {
    try {
      const userId = req.user!._id;

      const reserves = await ReserveService.getReserves(userId.toString());

      return res.status(StatusCodes.OK).json({
        success: true,
        data: reserves,
      });
    } catch (error: any) {
      return ReserveController.handleError(res, error);
    }
  }

  // GET BY ID
  static async getReserveById(req: Request, res: Response) {
    try {
      const reserve = await ReserveService.getReserveById(req.user!._id.toString(), req.params.rid);

      if (reserve) {
        await reserveEngine.evaluateReserve(reserve as any);
        await reserve.save();
        if ((reserve as any).achieved) {
          await StridesService.addOnce(req.user!._id, 5, 'RESERVE_FOLLOWED', `reserve-followed:${req.params.rid}`, req.params.rid);
        }
      }

      return res.status(StatusCodes.OK).json({
        success: true,
        data: reserve,
      });
    } catch (error: any) {
      return ReserveController.handleError(res, error);
    }
  }

  // TOGGLE SHARE WITH COMMUNITY
  static async toggleShare(req: Request, res: Response) {
    try {
      const userId = req.user!._id.toString();
      const { share_with_community = true } = req.body;
      const rid = req.params.rid;

      const reserve = await ReserveService.getReserveById(userId, rid);
      if (!reserve) throw new AppError('Reserve not found', StatusCodes.NOT_FOUND);

      if (share_with_community && !reserve.achieved) {
        throw new AppError('Reserve must be achieved before sharing', StatusCodes.BAD_REQUEST);
      }

      const updated = await ReserveService.updateShareFlag(userId, rid, !!share_with_community);

      return res.status(StatusCodes.OK).json({
        success: true,
        data: updated,
      });
    } catch (error: any) {
      return ReserveController.handleError(res, error);
    }
  }

  // DELETE
  static async deleteReserve(req: Request, res: Response) {
    try {
      const data = await ReserveService.deleteReserve(req.user!._id.toString(), req.params.rid);
      await removeReserveReminder(req.params.rid);

      return res.status(StatusCodes.OK).json({
        success: true,
        data,
      });
    } catch (error: any) {
      return ReserveController.handleError(res, error);
    }
  }

  private static handleError(res: Response, error: any) {
    const status = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    logger.error(error?.message);

    return res.status(status).json({
      success: false,
      message: error?.message || 'Internal server error',
    });
  }
}
