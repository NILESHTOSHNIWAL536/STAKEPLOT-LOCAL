import { StatusCodes } from 'http-status-codes';
import AppError from '@/utils/errors/app-error';
import { redisClient } from '@/config';
import logger from '../utils/common/logger';
import { incrementScore, handleDailyCounter } from '@/utils/helpers/increment_score';
import { scoreToAdd, scoreToGetReward } from '@/utils/common/enums';
import { TransactionRepository, AutoTransactionRepository } from '@/repositories';

// Initialize repositories
const autoTransactionRepository = new AutoTransactionRepository();
const transactionRepository = new TransactionRepository();

// Example transaction input interface (customize if needed)
export interface EnterTransactionInput {
  userId: string;
  amount: number;
  label: string;
  category: string;
  merchantId?: string;
  remainderId?: string;
  isDebit: boolean;
  isDebt?: boolean;
  isBill?: boolean;
  isSplit?: boolean;
}

export async function enterTransaction(data: EnterTransactionInput) {
  try {
    if (!data) {
      throw new AppError('No transaction data provided', StatusCodes.BAD_REQUEST);
    }

    const id = data.userId;

    await handleDailyCounter(id, 'dailyTransaction', 1, '', scoreToAdd.Transaction, scoreToGetReward.Transaction);

    const transactionData = {
      transactions: [
        {
          type: data.isDebit ? 'DEBIT' : 'CREDIT',
          mode: 'CASH',
          amount: data.amount,
          transactionalBalance: '0',
          transactionTimestamp: new Date(),
          valueDate: new Date(),
          txnId: data.merchantId || '',
          narration: data.label,
          category: data.category,
          subcategory: data.label,
          reference: data.remainderId || '',
          manualTransaction: true,
          isDebt: data.isDebt ?? false,
          isBill: data.isBill ?? false,
          isSplit: data.isSplit ?? false,
          userId: data.userId,
        },
      ],
      userId: data.userId,
    };

    const response = await autoTransactionRepository.createTransaction(transactionData.transactions, null, data.userId);

    await redisClient.del(`categorizedTransactions:${data.userId}`);
    await redisClient.del(`all-budgets-${data.userId}`);

    return response;
  } catch (error: any) {
    logger.error(`[ERROR] enterTransaction() failed: ${error.stack || error}`);
    throw new AppError('Cannot add a new transaction Object', StatusCodes.INTERNAL_SERVER_ERROR);
  }
}

export async function getAllTransactions(data: any) {
  try {
    const response = await transactionRepository.getAllTransactions(data);
    return response;
  } catch (error) {
    logger.debug(`error from getAllTransactions: ${error}`);
    throw new AppError('Cannot get transaction Objects', StatusCodes.INTERNAL_SERVER_ERROR);
  }
}

export async function deleteSpecificTransaction(userId: string, transactionId: string) {
  try {
    const response = await transactionRepository.deleteSpecificTransaction(userId, transactionId);

    return response;
  } catch (error) {
    logger.debug(`error from deleteSpecificTransaction: ${error}`);
    throw new AppError('Cannot get transaction Objects', StatusCodes.INTERNAL_SERVER_ERROR);
  }
}

export async function updateGroupTransaction(userId: string, transactionId: string, body: any) {
  try {
    const response = await transactionRepository.updateGroupTransaction(userId, transactionId, body);

    return response;
  } catch (error) {
    logger.debug(`error from updateGroupTransaction: ${error}`);
    throw new AppError('Cannot get transaction Objects', StatusCodes.INTERNAL_SERVER_ERROR);
  }
}

// Export all functions
export default {
  enterTransaction,
  getAllTransactions,
  deleteSpecificTransaction,
  updateGroupTransaction,
};
