import { Request, Response } from 'express';
import { StatusCodes } from 'http-status-codes';
import * as Common from '@/utils/common';
import * as BankService from '../../services/bank-service';
import monthNames from '@/config/monthNames';
import { Transaction } from '@/models';
import { Types as MongooseTypes, ObjectId as MongooseObjectId } from 'mongoose';
import { getDateRange, initializeResults, fillTransactionData } from '../../utils/helpers/dateUtils';
import { AccountRepository, FipRepository } from '@/repositories';
import logger from '@/utils/common/logger';
import moment from 'moment';
import mongoose from 'mongoose';

/**
 * NOTE:
 * - Replace `any` types for services/repositories with concrete interfaces from your project where available.
 * - Common.SuccessResponse and Common.ErrorResponse are treated as mutable objects (same as original).
 */

/* ---------------------------
   Types
   --------------------------- */

interface UserPayload {
  _id: string | MongooseTypes.ObjectId;
  name?: string;
  email?: string;
  role?: string;
  [key: string]: any;
}

/* Helpers to avoid TS complaints about common responses being mutated */
const SuccessResponse: any = (Common as any).SuccessResponse;
const ErrorResponse: any = (Common as any).ErrorResponse;

/* ---------------------------
   Non-controller exports (business helpers)
   --------------------------- */

export const createBankDetails = async (details: any[], consentHandleId: string, userId: string): Promise<any> => {
  try {
    for (const bankData of details) {
      // BankService.createBankDetails may be typed in your codebase; this is any to match original behavior.
      // eslint-disable-next-line @typescript-eslint/ban-ts-comment
      // @ts-ignore
      await (BankService as any).createBankDetails(bankData, consentHandleId, userId);
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
      await (BankService as any).updateBankDetails(bankData, consentHandleId, userId);
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

export const getMap = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    // AccountRepository typing left as any
    const response = await new (AccountRepository as any)().getMap(userId);
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
    const response = await (BankService as any).getUserDetails(userId);

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
    const response = await (BankService as any).getBanksLinkedAndAccounts(userId);
    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const getAllTransactions = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const { page } = req.params;
    const pageNum = page ? Number(page) : 1;
    const response = await (BankService as any).getAllTransactions(userId, pageNum);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const getMonthlyTransactionsHistory = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const { type, page } = req.params;
    const pageNum = page ? Number(page) : 1;
    const response = await (BankService as any).getMonthlyTransactionsHistory(userId, type, pageNum);
    SuccessResponse.data = response;
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
    const response = await (BankService as any).getAllTransactionsOfUser(userId);
    return res.status(StatusCodes.OK).json(response);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const getAllTransactionsForAccount = async (req: Request, res: Response): Promise<Response> => {
  try {
    const { accountId, page } = req.params;
    const userId = req.user!._id;
    const pageNum = page ? Number(page) : 1;
    const response = await (BankService as any).getAllTransactionsForAccount(userId, accountId, pageNum);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const getHideTransactions = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const response = await (BankService as any).getHideTransactions(userId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    // original code returned res.status(500) with message; preserve that behavior
    return res.status(500).json({
      success: false,
      error: (error as Error).message,
    });
  }
};

export const categorizeTransactions = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const response = await (BankService as any).categorizeTransactions(userId);

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
    const response = await (BankService as any).createTransaction(userId, transactions);

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
    const response = await (BankService as any).getTopFiveCategories(userId);

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
    const { categoryNames = '', startDate, endDate } = req.query;
    const categoryNamesArray = typeof categoryNames === 'string' && categoryNames.length ? categoryNames.split(',') : [];

    const response = await (BankService as any).categoryWiseSpendings(userId, categoryNamesArray, startDate as string, endDate as string);

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
    const { categoryNames = '', groupBy, startDate, endDate } = req.query;
    const categoryNamesArray = typeof categoryNames === 'string' && categoryNames.length ? categoryNames.split(',') : [];

    const response = await (BankService as any).getBudgetTransactions(userId, startDate as string, endDate as string, categoryNamesArray, groupBy as string);

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
    const { categoryNames = '', startDate, endDate } = req.query;
    const categoryNamesArray = typeof categoryNames === 'string' && categoryNames.length ? categoryNames.split(',') : [];

    const response = await (BankService as any).getBudgetSpents(userId, startDate as string, endDate as string, categoryNamesArray);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const updateUserDetails = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const data = req.body;
    const response = await (BankService as any).updateUserDetails(userId, data);

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
    const response = await (BankService as any).updateTransaction(updateData, userId, transactionId);

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
    const accountId = req.params.accountId;
    const response = await (BankService as any).getPreviousTransactions(userId, date, accountId);
    SuccessResponse.data = response;
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
    const response = await (BankService as any).getGroupedTransactions(userId);

    SuccessResponse.data = response;
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

    const response = await (BankService as any).categorizeGroupedTransaction(userId, groupId, category, subcategory, removedTransactions);

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
    const response = await (BankService as any).getPendingForReviewTransactions(userId);

    SuccessResponse.data = response;
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
    const response = await (BankService as any).verifyPendingTransaction(userId, transactionId, isCorrect);

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
    let prevStartDate: Date | undefined, prevEndDate: Date | undefined;
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

    // 1. Fetch current period transactions
    const response = await (BankService as any).getAllTransactionsByTimeLine(userId, accountIdObj, startDate, endDate, groupBy);
    const transactionData = fillTransactionData(response, result, type as RangeType, monthNames);

    // 2. Fetch previous period lastTimePeriodDebit
    const getLastPeriodDebit = await (BankService as any).getLastPeriodDebit(userId, accountIdObj, prevStartDate, prevEndDate, groupBy);
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

    const response = await (BankService as any).getAllTransactionsForMainGraph(userId, startDate, endDate, groupBy);

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
    const response = await (BankService as any).getTopThreeTransactionsOfWeek(userId);

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
    const response = await (BankService as any).getIncomeAndCategorySpent(userId);

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
    const response = await (BankService as any).getLoanCalculation(data);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const getSearchedTransactions = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const { page, search, isBankAccount } = req.params;

    const response = await (BankService as any).getSearchedTransactions(userId, page, search, isBankAccount, req.query);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error?.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

export const getDayWiseTransactionsSummary = async (req: Request, res: Response): Promise<Response> => {
  try {
    const userId = req.user!._id;
    const response = await (BankService as any).getDayWiseTransactionsSummary(userId);

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

    const response = await (BankService as any).getTransactionsByDate(userId, date);

    SuccessResponse.data = response;
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
    const response = await (BankService as any).getRecurringPayments(userId, type);

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
    const response = await (BankService as any).updateRecurringPayment(recurringPaymentId, userId, data);

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
    const response = await (BankService as any).deleteRecurringPayment(recurringPaymentId);

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

    const sanitizedIds = transactionIds.filter((id: any) => mongoose.Types.ObjectId.isValid(id)).map((id: any) => new mongoose.Types.ObjectId(id));

    await Transaction.deleteMany({ _id: { $in: sanitizedIds }, manualTransaction: true, userId: new mongoose.Types.ObjectId(userId) });

    SuccessResponse.data = `${sanitizedIds.length} transaction(s) deleted successfully`;

    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    logger.error(`Error from deleteBankAccount, transaction-controller ${error}`);
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
    await (BankService as any).deleteBankAccount(userId, bankId, accountId);

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
    SuccessResponse.data = await (BankService as any).getUserSpending(userId);
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    return res.status(500).json({ message: 'Internal server error' });
  }
};
