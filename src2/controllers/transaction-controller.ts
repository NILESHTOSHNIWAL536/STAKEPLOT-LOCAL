import moment from 'moment-timezone';
import { Request, Response } from 'express';
import { StatusCodes } from 'http-status-codes';
import { TransactionService } from '@/services';
import { SuccessResponse, ErrorResponse } from '@/utils/common';
import { IBankTransaction } from '@/types/bank';

function filterAndAddTotalByDate(data: IBankTransaction[]) {
  return data.reduce((result: any[], item) => {
    const date = moment(item.transactionTimestamp).tz('Asia/Kolkata').format('YYYY-MM-DD');

    const existingDate = result.find((entry) => entry.date === date);

    const transaction = {
      name: item.narration,
      amount: item.amount,
      category: item.category || 'Untagged',
      subcategory: item.subcategory || 'Untagged',
      mode: item.mode,
      type: item.type,
    };

    if (existingDate) {
      existingDate.total += item.amount;
      existingDate.transactions.push(transaction);
    } else {
      result.push({
        date,
        total: item.amount,
        transactions: [transaction],
      });
    }

    return result;
  }, []);
}

export async function enterTransaction(req: Request, res: Response) {
  try {
    const userId = req.user!._id;
    const response = await TransactionService.enterTransaction({
      ...req.body,
      userId,
    });

    SuccessResponse.data = [response];
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    return res.status(error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR).json(ErrorResponse);
  }
}

export async function getAllTransactions(req: Request, res: Response) {
  try {
    const userId = req.user!._id;
    const transactions = await TransactionService.getAllTransactions(userId);
    const filteredData = filterAndAddTotalByDate(transactions);

    SuccessResponse.data = filteredData;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    return res.status(error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR).json(ErrorResponse);
  }
}

export async function deleteSpecificTransaction(req: Request, res: Response) {
  try {
    const transactionId = req.params.id;
    const userId = req.user!._id;

    const response = await TransactionService.deleteSpecificTransaction(userId, transactionId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    return res.status(error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR).json(ErrorResponse);
  }
}

export async function updateGroupTransaction(req: Request, res: Response) {
  try {
    const transactionId = req.params.id;
    const userId = req.user!._id;
    const body = req.body;

    const response = await TransactionService.updateGroupTransaction(userId, transactionId, body);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    return res.status(error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR).json(ErrorResponse);
  }
}

export default {
  enterTransaction,
  getAllTransactions,
  deleteSpecificTransaction,
  updateGroupTransaction,
};
