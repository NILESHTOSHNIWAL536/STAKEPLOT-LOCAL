import { Request, Response } from 'express';
import { StatusCodes } from 'http-status-codes';
import * as InsightService from '@/services/insight-service';

const handleInsightRequest = async (req: Request, res: Response, handler: () => Promise<unknown>) => {
  try {
    const data = await handler();
    return res.status(StatusCodes.OK).json({
      success: true,
      message: 'Insights fetched successfully',
      data,
      error: {},
    });
  } catch (error: any) {
    return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({
      success: false,
      message: error?.message || 'Unable to fetch insights',
      data: {},
      error,
    });
  }
};

export const getCatalog = async (_req: Request, res: Response) => {
  return handleInsightRequest(_req, res, () => InsightService.getInsightCatalog());
};

export const getSummary = async (req: Request, res: Response) => {
  const userId = req.user!._id;
  return handleInsightRequest(req, res, () => InsightService.getSummaryInsights(userId, req.query));
};

export const getCategories = async (req: Request, res: Response) => {
  const userId = req.user!._id;
  return handleInsightRequest(req, res, () => InsightService.getCategoryInsights(userId, req.query));
};

export const getMerchants = async (req: Request, res: Response) => {
  const userId = req.user!._id;
  return handleInsightRequest(req, res, () => InsightService.getMerchantInsights(userId, req.query));
};

export const getTimePatterns = async (req: Request, res: Response) => {
  const userId = req.user!._id;
  return handleInsightRequest(req, res, () => InsightService.getTimePatternInsights(userId, req.query));
};

export const getPaymentModes = async (req: Request, res: Response) => {
  const userId = req.user!._id;
  return handleInsightRequest(req, res, () => InsightService.getPaymentModeInsights(userId, req.query));
};

export const getCashVsBank = async (req: Request, res: Response) => {
  const userId = req.user!._id;
  return handleInsightRequest(req, res, () => InsightService.getCashVsBankInsights(userId, req.query));
};

export const getRecurring = async (req: Request, res: Response) => {
  const userId = req.user!._id;
  return handleInsightRequest(req, res, () => InsightService.getRecurringInsights(userId, req.query));
};

export const getAnomalies = async (req: Request, res: Response) => {
  const userId = req.user!._id;
  return handleInsightRequest(req, res, () => InsightService.getAnomalyInsights(userId, req.query));
};

export const getActionItems = async (req: Request, res: Response) => {
  const userId = req.user!._id;
  return handleInsightRequest(req, res, () => InsightService.getActionItemInsights(userId));
};

export const getDailyTrend = async (req: Request, res: Response) => {
  const userId = req.user!._id;
  return handleInsightRequest(req, res, () => InsightService.getDailyTrendInsights(userId, req.query));
};

export const getLargestTransactions = async (req: Request, res: Response) => {
  const userId = req.user!._id;
  return handleInsightRequest(req, res, () => InsightService.getLargestTransactionInsights(userId, req.query));
};

export const getBalanceTrend = async (req: Request, res: Response) => {
  const userId = req.user!._id;
  return handleInsightRequest(req, res, () => InsightService.getBalanceTrendInsights(userId, req.query));
};

export const getSpendVelocityInsight = async (req: Request, res: Response) => {
  const userId = req.user!._id;
  try {
    const data = await InsightService.getSpendVelocityInsights(userId, req.query);
    return res.status(StatusCodes.OK).json(data);
  } catch (error: any) {
    return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({
      message: error?.message || 'Unable to fetch spend velocity',
      error,
    });
  }
};

export const getSpendVelocity = getSpendVelocityInsight;

export const getCategoryHealth = async (req: Request, res: Response) => {
  const userId = req.user!._id;
  return handleInsightRequest(req, res, () => InsightService.getCategoryHealthInsights(userId, req.query));
};

export const getIncomeSources = async (req: Request, res: Response) => {
  const userId = req.user!._id;
  return handleInsightRequest(req, res, () => InsightService.getIncomeSourceInsights(userId, req.query));
};

export const getUpcomingExpensePrediction = async (req: Request, res: Response) => {
  const userId = req.user!._id;
  return handleInsightRequest(req, res, () => InsightService.getUpcomingExpensePredictionInsights(userId, req.query));
};
