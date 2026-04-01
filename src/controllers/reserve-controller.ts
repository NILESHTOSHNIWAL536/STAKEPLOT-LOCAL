import { Request, Response } from "express";
import { StatusCodes } from "http-status-codes";
import AppError from "../utils/errors/app-error";
import logger from "../utils/common/logger";
import { ReserveService } from "../services/reserve-service";
const categoryMapping: Record<string, string> = {
  "Transport": "travel",
  "Dining out": "food",
  "Shopping": "shopping",
  "Groceries": "groceries",
  "Overall spend": "all",
};
export class ReserveController {
  // 🔥 CREATE
  static async createReserve(req: Request, res: Response) {

    try {
      const userId = req.user!._id;

      const { startDate, endDate } = req.body;

      if (!startDate || !endDate) {
             throw new AppError("Start and End dates required", 400);
      }

      // 🔥 VALIDATE RANGE
      const start = new Date(startDate);
      const end = new Date(endDate);

      const diff =
        (end.getTime() - start.getTime()) /
        (1000 * 60 * 60 * 24) +
        1;

      if (diff > 7) {
        throw new AppError("Max 7 days allowed", 400);
      }

      // 🔥 CATEGORY TRANSFORM (your previous logic)
      const transformedCategories = req.body.categories.map((cat: string) => {
        return categoryMapping[cat] || cat.toLowerCase();
      });

      const reserve = await ReserveService.createReserve({
        ...req.body,
        categories: transformedCategories,
        userId,
        startDate: start,
        endDate: end,
      });

      return res.status(201).json({
        success: true,
        data: reserve,
      });
    } catch (error: any) {
      return ReserveController.handleError(res, error);
    }
  }

  // 🔥 GET ALL
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

  // 🔥 GET BY ID
  static async getReserveById(req: Request, res: Response) {
    try {
      const reserve = await ReserveService.getReserveById(
        req.user!._id.toString(),
        req.params.rid
      );

      return res.status(StatusCodes.OK).json({
        success: true,
        data: reserve,
      });
    } catch (error: any) {
      return ReserveController.handleError(res, error);
    }
  }

  // 🔥 DELETE
  static async deleteReserve(req: Request, res: Response) {
    try {
      const data = await ReserveService.deleteReserve(
        req.user!._id.toString(),
        req.params.rid
      );

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
      message: error?.message || "Internal server error",
    });
  }
}