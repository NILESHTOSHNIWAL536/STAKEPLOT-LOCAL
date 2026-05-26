import { Request, Response } from 'express';
import { StatusCodes } from 'http-status-codes';
import * as Common from '@/utils/common';
import { toISTArray } from '@/utils/time/formatResponse';
import * as BankService from '../../services/bank-service';
import StridesService from '@/services/strides-service';
import monthNames from '@/config/monthNames';
import { Transaction } from '@/models';
import { Types as MongooseTypes, ObjectId as MongooseObjectId, Types } from 'mongoose';
import { getDateRange, initializeResults, fillTransactionData } from '../../utils/helpers/dateUtils';
import { AccountRepository, FipRepository } from '@/repositories';
import logger from '@/utils/common/logger';
import moment from 'moment';
import mongoose from 'mongoose';
import CollectionTransaction from '@/models/collections/collection-transaction.model';
import Collection from '@/models/collections/collection.model';
import Split from '@/models/collections/split.model';
import SplitPayment from '@/models/collections/split-payment.model';
import { runInTransaction } from '@/utils/run-in-transaction';
import { createRecurringPaymentFromTransaction, detectAndStoreAutoPays } from '@/services/auto-service';

/**
 * NOTE:
 * - Replace `any` types for services/repositories with concrete interfaces from your project where available.
 * - Common.SuccessResponse and Common.ErrorResponse are treated as mutable objects (same as original).
 */

/* Helpers to avoid TS complaints about common responses being mutated */
const SuccessResponse: any = (Common as any).SuccessResponse;
const ErrorResponse: any = (Common as any).ErrorResponse;
type GroupBy = 'day' | 'week' | 'month';

/* ---------------------------
   Non-controller exports (business helpers)
   --------------------------- */

export const createBankDetails = async (details: any[], consentHandleId: string, userId: string): Promise<any> => {
  try {
    for (const bankData of details) {
      // BankService.createBankDetails may be typed in your codebase; this is any to match original behavior.
      // eslint-disable-next-line @typescript-eslint/ban-ts-comment
      // @ts-ignore
      await BankService.createBankDetails(bankData, consentHandleId, userId);
    }
    return { success: true };
  } catch (error: any) {
    ErrorResponse.error = error;
    logger.debug(`Error from createUserDetails: ${error}`);
    return error;
  }
};

export const updateBankDetails = async (details: any[], consentHandleId: string, userId: string): Promise<any> => {
  try {
    for (const bankData of details) {
      // eslint-disable-next-line @typescript-eslint/ban-ts-comment
      // @ts-ignore
      await BankService.updateBankDetails(bankData, consentHandleId, userId);
    }
    return { success: true };
  } catch (error: any) {
    ErrorResponse.error = error;
    // Throw so caller (controller) can decide how to respond
    throw error;
  }
};

/* ---------------------------
   Controllers
   --------------------------- */

export const getAutoPays = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    // AccountRepository typing left as any
    const response = await detectAndStoreAutoPays(userId);
    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const createRecurringPaymentFromTransactionController = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const { transactionId } = req.params;
    const dueDay = req.body?.dueDay ? Number(req.body.dueDay) : undefined;
    const response = await createRecurringPaymentFromTransaction(userId, transactionId, dueDay);
    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    console.log(error);
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const getMap = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    // AccountRepository typing left as any
     const response = await BankService.getUserDetails(userId);
    return res.status(StatusCodes.OK).json(response);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const getUser = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const response = await BankService.getUserDetails(userId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const getBanksLinkedAndAccounts = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const response = await BankService.getBanksLinkedAndAccounts(userId);
    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const getBankBalanceAndDebitSummary = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = new Types.ObjectId(req.user!._id);

    const { view = "monthly", month, year } = req.query;

    if (!year) {
      return res.status(StatusCodes.BAD_REQUEST).json({
        success: false,
        message: "year is required",
      });
    }

    if (view === "monthly" && !month) {
      return res.status(StatusCodes.BAD_REQUEST).json({
        success: false,
        message: "month is required for monthly view",
      });
    }

    const response =
      await BankService.getBankBalanceAndDebitSummary({
        userId,
        view: view as "monthly" | "yearly",
        month: month ? Number(month) : undefined,
        year: Number(year),
      });

    return res.status(StatusCodes.OK).json({
      success: true,
      data: response,
    });
  } catch (error: any) {
    return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json({
      success: false,
      message: error?.message || "Internal server error",
    });
  }
};


export const getMonthlyTransactionsHistory = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const { type, page } = req.params;
    const pageNum = page ? Number(page) : 1;
    const response = await BankService.getMonthlyTransactionsHistory(userId, type, pageNum);
    SuccessResponse.data = toISTArray(response);
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const getAllTransactionsOfUser = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const response = await BankService.getAllTransactionsOfUser(userId);
    return res.status(StatusCodes.OK).json(toISTArray(response));
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const categorizeTransactions = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const response = await BankService.categorizeTransactions(userId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const createTransaction = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const { transactions } = req.body;
    const response = await BankService.createTransaction(userId, transactions);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const getTopFiveCategories = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const response = await BankService.getTopFiveCategories(userId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const getCategoryWiseSpendings = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const { categoryNames = '', groupBy } = req.query;
    const startDate = req.query.startDate as string | undefined;
    const endDate = req.query.endDate as string | undefined;

    // Enforce required query params
    if (!startDate || !endDate) {
      return res.status(StatusCodes.BAD_REQUEST).json({
        error: 'startDate and endDate are required',
      });
    }

    // Convert safely
    const modifiedStartDate = new Date(startDate);
    const modifiedEndDate = new Date(endDate);

    // Validate converted dates
    if (isNaN(modifiedStartDate.getTime()) || isNaN(modifiedEndDate.getTime())) {
      return res.status(StatusCodes.BAD_REQUEST).json({
        error: 'Invalid date format for startDate or endDate',
      });
    }

    const categoryNamesArray = typeof categoryNames === 'string' && categoryNames.length ? categoryNames.split(',') : [];

    const response = await BankService.categoryWiseSpendings(userId, categoryNamesArray, modifiedStartDate, modifiedEndDate);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    console.log('error:', error);
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const getBudgetTransactions = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const { categoryNames = '', groupBy } = req.query;
    const startDate = req.query.startDate as string | undefined;
    const endDate = req.query.endDate as string | undefined;

    // Enforce required query params
    if (!startDate || !endDate) {
      return res.status(StatusCodes.BAD_REQUEST).json({
        error: 'startDate and endDate are required',
      });
    }

    // Convert safely
    const modifiedStartDate = new Date(startDate);
    const modifiedEndDate = new Date(endDate);

    // Validate converted dates
    if (isNaN(modifiedStartDate.getTime()) || isNaN(modifiedEndDate.getTime())) {
      return res.status(StatusCodes.BAD_REQUEST).json({
        error: 'Invalid date format for startDate or endDate',
      });
    }

    const categoryNamesArray = typeof categoryNames === 'string' && categoryNames.length ? categoryNames.split(',') : [];

    const response = await BankService.getBudgetTransactions(userId, modifiedStartDate, modifiedEndDate, categoryNamesArray, groupBy as GroupBy);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const getBudgetSpents = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const { categoryNames = '' } = req.query;

    const startDate = req.query.startDate as string | undefined;
    const endDate = req.query.endDate as string | undefined;

    // Enforce required query params
    if (!startDate || !endDate) {
      return res.status(StatusCodes.BAD_REQUEST).json({
        error: 'startDate and endDate are required',
      });
    }

    // Convert safely
    const modifiedStartDate = new Date(startDate);
    const modifiedEndDate = new Date(endDate);

    // Validate converted dates
    if (isNaN(modifiedStartDate.getTime()) || isNaN(modifiedEndDate.getTime())) {
      return res.status(StatusCodes.BAD_REQUEST).json({
        error: 'Invalid date format for startDate or endDate',
      });
    }

    const categoryNamesArray = typeof categoryNames === 'string' && categoryNames.length ? categoryNames.split(',') : [];

    const response = await BankService.getBudgetSpents(userId, modifiedStartDate, modifiedEndDate, categoryNamesArray);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const updateTransaction = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const { transactionId } = req.params;
    const updateData = req.body;
    const response = await BankService.updateTransaction(updateData, userId, transactionId);
    if (response?.data?.wasTaggedFromUntagged) {
      await StridesService.recordTaggedTransaction(userId, transactionId);
    }

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    return res.status(500).json({ success: false, error: (error as Error).message });
  }
};

export const getPreviousTransactions = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const date = req.params.date;
    const modifiedDate = new Date(date);

    if (isNaN(modifiedDate.getTime())) {
      return res.status(StatusCodes.BAD_REQUEST).json({
        error: 'Invalid date format for startDate or endDate',
      });
    }

    const accountId = req.params.accountId;
    const response = await BankService.getPreviousTransactions(userId, modifiedDate, accountId);
    // response = { transactions: [...], profile, summary, account, ... }
    SuccessResponse.data = {
      ...response,
      transactions: toISTArray(response?.transactions),
    };
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    return res.status(500).json({ success: false, error: (error as Error).message });
  }
};

/* Grouping & Auto-categorize */

// 1. get grouped transactions
export const getGroupedTransactions = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const response = await BankService.getGroupedTransactions(userId);

    SuccessResponse.data = toISTArray(response);
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    logger.error(`error from getGroupedTransactions, transaction-controller ${error}`);
    return res.status(500).json({ message: 'Server error' });
  }
};

// 2. categorize grouped transaction
export const categorizeGroupedTransaction = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const groupId = req.params.groupId;
    const { category, subcategory, removedTransactions = [] } = req.body;
    if (!category || !subcategory) {
      return res.status(StatusCodes.BAD_REQUEST).json({ message: 'Category and subcategory are required' });
    }

    const modifiedGroupId = new MongooseTypes.ObjectId(groupId);

    const response = await BankService.categorizeGroupedTransaction(userId, modifiedGroupId, category, subcategory, removedTransactions);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    logger.error(`error from categorizedGroupedTransactions, transaction-controller: ${error}`);
    console.error(error);
    return res.status(500).json({ message: 'Server error' });
  }
};

// 3. get pending transaction which needs for review
export const getPendingForReviewTransactions = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const response = await BankService.getPendingForReviewTransactions(userId);

    SuccessResponse.data = toISTArray(response);
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

// 4. verify pending transaction
export const verifyPendingTransaction = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const { transactionId, isCorrect } = req.params;

    // Convert string → boolean
    const parsedIsCorrect = isCorrect === 'true' ? true : isCorrect === 'false' ? false : null;

    if (parsedIsCorrect === null) {
      return res.status(StatusCodes.BAD_REQUEST).json({
        error: "isCorrect must be 'true' or 'false'",
      });
    }
    const response = await BankService.verifyPendingTransaction(userId, transactionId, parsedIsCorrect);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    logger.debug(`Error from verifyPendingTransaction, transaction-controller ${error}`);
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

/* Graphs */

// 1. Get all transactions for a specific account (custom range)
export const getAllCustomTransactions = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { type, value, accountId } = req.params;
    const accountIdObj = new MongooseTypes.ObjectId(accountId);
    const userId = req.user!._id;

    type RangeType = 'month' | 'week' | 'custom' | 'year';

    const { startDate, endDate, groupBy } = getDateRange(type as RangeType, value);
    const result = initializeResults(type as RangeType, new Date(startDate), new Date(endDate), monthNames);

    // Get previous period's start and end date
    let prevStartDate: Date | null = null;
    let prevEndDate: Date | null = null;

    if (type === 'month') {
      const prevMonth = new Date(Date.UTC(startDate.getUTCFullYear(), startDate.getUTCMonth() - 1, 1, 0, 0, 0, 0));
      prevStartDate = prevMonth;
      prevEndDate = new Date(Date.UTC(startDate.getUTCFullYear(), startDate.getUTCMonth(), 0, 23, 59, 59, 999));
    } else if (type === 'week') {
      prevStartDate = new Date(startDate);
      prevStartDate.setUTCDate(prevStartDate.getUTCDate() - 7);
      prevStartDate.setUTCHours(0, 0, 0, 0);

      prevEndDate = new Date(endDate);
      prevEndDate.setUTCDate(prevEndDate.getUTCDate() - 7);
      prevEndDate.setUTCHours(23, 59, 59, 999);
    }

    //  BEFORE calling the service → Validate
    if (!prevStartDate || !prevEndDate) {
      return res.status(StatusCodes.BAD_REQUEST).json({
        error: `Previous period is not defined for range type '${type}'`,
      });
    }

    // 1. Fetch current period transactions
    const response = await BankService.getAllTransactionsByTimeLine(userId, accountIdObj, startDate, endDate, groupBy);
    const transactionData = fillTransactionData(response, result, type as RangeType, monthNames);

    // 2. Fetch previous period lastTimePeriodDebit
    const getLastPeriodDebit = await BankService.getLastPeriodDebit(userId, accountIdObj, prevStartDate, prevEndDate);
    const lastTimePeriodDebit = getLastPeriodDebit?.[0]?.totalDebit || 0;

    // Calculate percentage change (protect against divide by zero)
    const currentTotalDebit = transactionData.totalDebit || 0;
    let debitChangePercentage = 0;
    if (lastTimePeriodDebit === 0 && currentTotalDebit === 0) {
      debitChangePercentage = 0;
    } else if (lastTimePeriodDebit === 0) {
      debitChangePercentage = 100;
    } else {
      debitChangePercentage = ((currentTotalDebit - lastTimePeriodDebit) / lastTimePeriodDebit) * 100;
    }

    SuccessResponse.data = { ...transactionData, debitChangePercentage };

    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      error: (error as Error).message,
    });
  }
};

// 2. Get all transactions for all accounts including manual transactions
export const getWholeTransactionsGraph = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { type, value } = req.params;
    const userId = req.user!._id;
    type RangeType = 'month' | 'week' | 'custom' | 'year';

    const { startDate, endDate, groupBy } = getDateRange(type as RangeType, value);
    const result = initializeResults(type as RangeType, new Date(startDate), new Date(endDate), monthNames);

    const response = await BankService.getAllTransactionsForMainGraph(userId, startDate, endDate, groupBy);

    const transactionData = fillTransactionData(response, result, type as RangeType, monthNames);

    SuccessResponse.data = transactionData;

    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    return res.status(500).json({
      success: false,
      error: (error as Error).message,
    });
  }
};

export const getTopThreeTransactionsOfWeek = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const response = await BankService.getTopThreeTransactionsOfWeek(userId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const getIncomeAndCategorySpent = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const response = await BankService.getIncomeAndCategorySpent(userId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const getLoanCalculation = async (req: Request, res: Response): Promise<Response> => {
  try {
    const data = req.body;
    const response = await BankService.getLoanCalculation(data);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const getSearchedTransactions = async (req: Request, res: Response) => {
  try {
    const userId = req.user._id;
    const page = Number(req.params.page);

    if (!page || page < 1) return res.status(400).json({ error: 'Page must be >= 1' });

    const { search = '', type, manualTransaction, isHidden, accountId, minAmount, maxAmount, startDate, endDate } = req.query;

    const response = await BankService.getSearchedTransactions({
      userId,
      page,
      Hidden: isHidden === 'true',
      search: String(search),
      type: type ? String(type) : undefined,
      manualTransaction: manualTransaction === 'true',
      accountId, // single or multiple (string or array)
      minAmount: minAmount ? Number(minAmount) : undefined,
      maxAmount: maxAmount ? Number(maxAmount) : undefined,
      startDate: startDate ? new Date(startDate as string) : undefined,
      endDate: endDate ? new Date(endDate as string) : undefined,
    });

    return res.json({
      data: {
        ...response,
        transactions: toISTArray(response?.transactions),
      },
    });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e });
  }
};

export const getDayWiseTransactionsSummary = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const response = await BankService.getDayWiseTransactionsSummary(userId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json(ErrorResponse);
  }
};

export const getTransactionsByDate = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const { date } = req.params;

    const response = await BankService.getTransactionsByDate(userId, date);

    SuccessResponse.data = toISTArray(response);
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json(ErrorResponse);
  }
};

export const getRecurringPayments = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const type = req.params.isActive;
    const boolIsActive = type === 'true' ? true : false;
    const response = await BankService.getRecurringPayments(userId, boolIsActive);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const updateRecurringPayment = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const recurringPaymentId = new MongooseTypes.ObjectId(req.params.id);
    const data = req.body;
    const response = await BankService.updateRecurringPayment(recurringPaymentId, userId, data);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const deleteRecurringPayment = async (req: Request, res: Response): Promise<Response> => {
  try {
    const recurringPaymentId = new MongooseTypes.ObjectId(req.params.id);
    const response = await BankService.deleteRecurringPayment(recurringPaymentId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const deleteTransactions = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { transactionIds } = req.body;
    const userId = req.user!._id;
    if (!Array.isArray(transactionIds) || transactionIds.length === 0) {
      return res.status(StatusCodes.BAD_REQUEST).json({ ...ErrorResponse, error: 'transactionIds must be a non-empty array.' });
    }

    const sanitizedIds = transactionIds
      .filter((id: any) => mongoose.Types.ObjectId.isValid(id))
      .map((id: any) => new mongoose.Types.ObjectId(id));

    // Resolve the actual IDs that will be deleted (must be manual and belong to this user)
    const toDelete = await Transaction.find(
      { _id: { $in: sanitizedIds }, manualTransaction: true, userId: new mongoose.Types.ObjectId(userId) },
      { _id: 1 }
    ).lean();
    const confirmedIds = toDelete.map((t) => t._id);

    if (confirmedIds.length === 0) {
      SuccessResponse.data = '0 transaction(s) deleted successfully';
      return res.status(StatusCodes.OK).json(SuccessResponse);
    }

    // Snapshot reads before the atomic section
    const affectedCollectionTxns = await CollectionTransaction.find({ transactionId: { $in: confirmedIds } }).lean();

    const collectionDeductMap = new Map<string, number>();
    for (const ct of affectedCollectionTxns) {
      const key = ct.collectionId.toString();
      collectionDeductMap.set(key, (collectionDeductMap.get(key) ?? 0) + ct.amount);
    }

    const affectedSplitIds = await Split.find({ transactionIds: { $in: confirmedIds } }).distinct('_id');

    await runInTransaction(async (session) => {
      // Adjust collection totals for the removed transactions
      for (const [colId, amount] of collectionDeductMap) {
        await Collection.findByIdAndUpdate(colId, { $inc: { totalAmount: -amount } }, { session });
      }

      if (affectedSplitIds.length > 0) {
        await SplitPayment.deleteMany({ splitId: { $in: affectedSplitIds } }).session(session);
        await Split.deleteMany({ _id: { $in: affectedSplitIds } }).session(session);
      }

      await CollectionTransaction.deleteMany({ transactionId: { $in: confirmedIds } }).session(session);
      await Transaction.deleteMany({ _id: { $in: confirmedIds } }).session(session);
    });

    SuccessResponse.data = `${confirmedIds.length} transaction(s) deleted successfully`;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    logger.error(`Error from deleteTransactions, transaction-controller ${error}`);
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const deleteBankAccount = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const { bankId, accountId } = req.params;

    // delete bank account
    await BankService.deleteBankAccount(userId, bankId, accountId);
    await StridesService.add(userId, -2, 'BANK_ACCOUNT_REMOVED', accountId);

    SuccessResponse.data = 'Bank data deleted successfully';
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    logger.error(`Error from deleteBankAccount, transaction-controller ${error}`);
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const getUserMonthlySpending = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    SuccessResponse.data = await BankService.getUserSpending(userId);
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    return res.status(500).json({ message: 'Internal server error' });
  }
};
