const { TransactionRepository, AutoTransactionRepository } = require('../respositories/index');
const { StatusCodes } = require('http-status-codes');
const AppError = require('../utils/errors/app-error');
const redisClient = require('../config/redis-config');
const logger = require('../utils/common/logger');
const headsUpMessages = require('../utils/common/headsup-messages');
const moneyMapMessages = require('../utils/common/money-map');
const { incrementScore, handleDailyCounter } = require('../utils/helpers/increment_score');
const { scoreToAdd, scoreToGetReward } = require('../utils/common/enums');
//Intialize the classes to fetch the data
const autoTransactionRepository = new AutoTransactionRepository();
const transactionRepository = new TransactionRepository();

async function enterTransaction(data) {
  try {
    if (!data) {
      throw new AppError('No transaction data provided', StatusCodes.BAD_REQUEST);
    }

    const transaction = data;
    const id = data.userId;

    await handleDailyCounter(id, 'dailyTransaction', 1, '', scoreToAdd.Transaction, scoreToGetReward.Transaction);

    // prepare transactionData
    const transactionData = {
      transactions: [
        {
          type: transaction.isDebit ? 'DEBIT' : 'CREDIT',
          mode: 'CASH',
          amount: transaction.amount,
          transactionalBalance: '0',
          transactionTimestamp: new Date(),
          valueDate: new Date(),
          txnId: transaction.merchantId || '',
          narration: transaction.label,
          category: transaction.category,
          subcategory: transaction.label,
          reference: transaction.remainderId || '',
          manualTransaction: true,
          isDebt: transaction.isDebt ?? false,
          isBill: transaction.isBill ?? false,
          isSplit: transaction.isSplit ?? false,
          userId: data.userId,
        },
      ],
      userId: data.userId,
    };

    const response = await autoTransactionRepository.createTransaction(transactionData.transactions, null, data.userId);

    if (response) {
      // Redis cleanup
      const cacheKey = `categorizedTransactions:${data.userId}`;
      const cachedData = await redisClient.del(cacheKey);

      const budgetKey = `all-budgets-${data.userId}`;
      const budgetCachedData = await redisClient.del(budgetKey);

      // headsUp and moneyMap
      await headsUpMessages(data.userId);

      await moneyMapMessages(data.userId);
    }

    return response;
  } catch (error) {
    logger.error(`[ERROR] enterTransaction() failed: ${error.stack || error}`);
    throw new AppError('Cannot add a new transaction Object', StatusCodes.INTERNAL_SERVER_ERROR);
  }
}

// async function transactionHistory(data) {
//   try {
//     const response = await transactionRepository.getLatestTransactions(data);

//     return response;
//   } catch (error) {
//     logger.error(`error from the transactionHistory: ${error}`);
//     throw new AppError("Cannot get transaction Objects",StatusCodes.INTERNAL_SERVER_ERROR);
//   }
// }

async function getAllTransactions(data) {
  try {
    const response = await transactionRepository.getAllTransactions(data);
    return response;
  } catch (error) {
    logger.debug(`error from the getAllTransactions: ${error}`);
    throw new AppError('Cannot get transaction Objects', StatusCodes.INTERNAL_SERVER_ERROR);
  }
}

async function deleteSpecificTransaction(userId, transactionId) {
  try {
    const response = await transactionRepository.deleteSpecificTransaction(userId, transactionId);

    try {
      await headsUpMessages(userId);
      await moneyMapMessages(userId);
    } catch (e) {
      console.log(e);
    }

    return response;
  } catch (error) {
    logger.debug(`error from deleteSpecificTransaction: ${error}`);
    throw new AppError('Cannot get transaction Objects', StatusCodes.INTERNAL_SERVER_ERROR);
  }
}
async function updateGroupTransaction(userId, transactionId, body) {
  try {
    const response = await transactionRepository.updateGroupTransaction(userId, transactionId, body);
    try {
      await headsUpMessages(userId);
      await moneyMapMessages(userId);
    } catch (e) {}
    return response;
  } catch (error) {
    logger.debug(`error from deleteSpecificTransaction: ${error}`);
    throw new AppError('Cannot get transaction Objects', StatusCodes.INTERNAL_SERVER_ERROR);
  }
}

module.exports = {
  enterTransaction,
  // transactionHistory,
  getAllTransactions,
  deleteSpecificTransaction,
  updateGroupTransaction,
};
