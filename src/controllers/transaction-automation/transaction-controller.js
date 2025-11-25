const { StatusCodes } = require('http-status-codes');
const { SuccessResponse, ErrorResponse } = require('../../utils/common');
const BankService = require('../../services/bank-service');
const { monthNames } = require('../../config/monthNames');
const { Transaction } = require('../../models');
const { ObjectId } = require('mongoose').Types;
const { getDateRange, initializeResults, fillTransactionData } = require('../../utils/helpers/dateUtils');
const { AccountRepository, FipRepository } = require('../../respositories');
const headsUpMessages = require('../../utils/common/headsup-messages');
const moneyMapMessages = require('../../utils/common/money-map');

const logger = require('../../utils/common/logger');
const moment = require('moment');
const mongoose = require('mongoose');

exports.createUserDetails = async (details, consenthandleid, userId) => {
  try {
    const existingBanks = await new FipRepository().getBankDetailsMap(userId);
    const existingBankAccounts = await new AccountRepository().getMap(userId);
    const responses = [];

    const noExistingAccounts =
      !existingBankAccounts || existingBankAccounts.size === 0;

    // If user has no accounts → create everything directly
    if (noExistingAccounts) {
      const createPromises = details.map((data) =>
        BankService.createUserDetails(data, consenthandleid, userId)
      );
      responses.push(...(await Promise.all(createPromises)));
      return responses;
    }

    // Process each FIP / bank
    for (const bank of details) {
      const bankExists = existingBanks.has(bank.fipId);

      // Iterate through each account in the bank
      for (const acct of bank.fiAccountInfo) {
        const { linkRefNo, accountRefNo } = acct;

        // Check if account already exists (via linkRefNo or accountRefNo)
        const matchedKey =
          (linkRefNo && existingBankAccounts.has(linkRefNo) && linkRefNo) ||
          (accountRefNo &&
            existingBankAccounts.has(accountRefNo) &&
            accountRefNo) ||
          null;

        if (matchedKey) {
          // Account exists → perform UPDATE
          const accountId = existingBankAccounts.get(matchedKey);

          // Find matching fiObject for this specific account
          const fiObject = bank.fiObjects.find(
            (fi) =>
              fi.linkedAccRef === linkRefNo ||
              fi.linkedAccRef === accountRefNo
          );

          if (!fiObject) {
            console.warn(
              `No matching fiObject found for accountRef/linkRef ${matchedKey}`
            );
            continue;
          }

          const payload = {
            ...bank,
            fiObjects: [fiObject],
          };

          const result = await BankService.updateUserDetails(
            payload,
            consenthandleid,
            userId,
            accountId
          );

          responses.push(result);
        } else {
          // Account does not exist → CREATE new one
          const fiObject = bank.fiObjects.find(
            (fi) =>
              fi.linkedAccRef === linkRefNo ||
              fi.linkedAccRef === accountRefNo
          );

          const payload = {
            ...bank,
            fiObjects: fiObject ? [fiObject] : [],
            fiAccountInfo: [acct], // only create the specific account
          };

          const result = await BankService.createUserDetails(
            payload,
            consenthandleid,
            userId
          );

          responses.push(result);
        }
      }
    }

    return responses;
  } catch (error) {
    ErrorResponse.error = error;
    logger.debug(`Error from createUserDetails: ${error}`);
    return error;
  }
};

exports.getMap = async (req, res) => {
  try {
    const userId = req.user._id;
    const response = await new AccountRepository().getMap(userId);

    return res.status(200).json(response);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.getUser = async (req, res) => {
  try {
    const userId = req.user._id;
    const response = await BankService.getUserDetails(userId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.getBanksLinkedAndAccounts = async (req, res) => {
  try {
    const userId = req.user._id;
    const response = await BankService.getBanksLinkedAndAccounts(userId);
    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.getAllTransactions = async (req, res) => {
  try {
    const userId = req.user._id;
    const { page } = req.params;
    const response = await BankService.getAllTransactions(userId, page);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.getMonthlyTransactionsHistory = async (req, res) => {
  try {
    const userId = req.user._id;
    const { type, page } = req.params;
    const response = await BankService.getMonthlyTransactionsHistory(userId, type, page);
    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.getAllTransactionsOfUser = async (req, res) => {
  try {
    const userId = req.user._id;
    const response = await BankService.getAllTransactionsOfUser(userId);
    return res.status(StatusCodes.OK).json(response);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.getAllTransactionsForAccount = async (req, res) => {
  try {
    const { accountId, page } = req.params;
    const userId = req.user._id;
    const response = await BankService.getAllTransactionsForAccount(userId, accountId, page);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.getHideTransactions = async (req, res) => {
  try {
    const userId = req.user._id;
    const response = await BankService.getHideTransactions(userId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
};

exports.categorizeTransactions = async (req, res) => {
  try {
    const userId = req.user._id;
    const response = await BankService.categorizeTransactions(userId);

    console.log("response from the API: ", response);
    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.createTransaction = async (req, res) => {
  try {
    const userId = req.user._id;
    const { transactions } = req.body;
    const response = await BankService.createTransaction(userId, transactions);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.getTopFiveCategories = async (req, res) => {
  try {
    const userId = req.user._id;
    const response = await BankService.getTopFiveCategories(userId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.getCategoryWiseSpendings = async (req, res) => {
  try {
    const userId = req.user._id;
    const { categoryNames, startDate, endDate } = req.query;
    const categoryNamesArray = categoryNames.split(',');

    const response = await BankService.categoryWiseSpendings(userId, categoryNamesArray, startDate, endDate);
    
    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    console.log('error:', error);
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
}

exports.getBudgetTransactions = async (req, res) => {
  try {
    const userId = req.user._id;
    const { categoryNames, groupBy, startDate, endDate } = req.query;
    const categoryNamesArray = categoryNames.split(',');

    const response = await BankService.getBudgetTransactions(userId, startDate, endDate, categoryNamesArray, groupBy);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
}

exports.getBudgetSpents = async (req, res) => {
  try {
    const userId = req.user._id;
    const { categoryNames, startDate, endDate } = req.query;
    const categoryNamesArray = categoryNames.split(',');

    const response = await BankService.getBudgetSpents(userId, startDate, endDate, categoryNamesArray);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.updateUserDetails = async (req, res) => {
  try {
    const userId = req.user._id;
    const data = req.body;
    const response = await BankService.updateUserDetails(userId, data);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.updateTransaction = async (req, res) => {
  try {
    const userId = req.user._id;
    const { transactionId } = req.params;
    const updateData = req.body;
    const response = await BankService.updateTransaction(updateData, userId, transactionId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

exports.getPreviousTransactions = async (req, res) => {
  try {
    const userId = req.user._id;
    const date = req.params.date;
    const accountId = req.params.accountId;
    const response = await BankService.getPreviousTransactions(userId, date, accountId);
    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

// These functions are related to groupingTransactions, auto-categorize transactions
// 1. get grouped transactions
exports.getGroupedTransactions = async (req, res) => {
  try {
    const userId = req.user._id;
    const response = await BankService.getGroupedTransactions(userId);

    SuccessResponse.data = response;
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    logger.error(`error from getGroupedTransactions, transaction-controller ${error}`);
    res.status(500).json({ message: 'Server error' });
  }
};

// 2. categorize grouped transaction
exports.categorizeGroupedTransaction = async (req, res) => {
  try {
    const userId = req.user._id;
    const groupId = req.params.groupId;
    const { category, subcategory, removedTransactions = [] } = req.body;
    if (!category || !subcategory) {
      return res.status(StatusCodes.BAD_REQUEST).json({ message: 'Category and subcategory are required' });
    }

    const response = await BankService.categorizeGroupedTransaction(userId, groupId, category, subcategory, removedTransactions);

    SuccessResponse.data = response;
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    logger.error(`error from categorizedGroupedTransactions, transaction-controller: ${error}`);
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// 3. get pending transaction which needs for review
exports.getPendingForReviewTransactions = async (req, res) => {
  try {
    const userId = req.user._id;
    const response = await BankService.getPendingForReviewTransactions(userId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

// 4. verify, pending transction
exports.verifyPendingTransaction = async (req, res) => {
  try {
    const userId = req.user._id;
    // const {category, subcategory} = req.body;
    const { transactionId, isCorrect } = req.params;
    const response = await BankService.verifyPendingTransaction(userId, transactionId, isCorrect);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    logger.debug(`Error from verifyPendingTransaction, transaction-controller ${error}`);
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

// These functions are related to Graphs
// 1. Get all transactions for a specific account
exports.getAllCustomTransactions = async (req, res) => {
  try {
    const { type, value, accountId } = req.params;
    const accountIdObj = new ObjectId(accountId);
    const userId = req.user._id;

    const { startDate, endDate, groupBy } = getDateRange(type, value);
    const result = initializeResults(type, new Date(startDate), new Date(endDate), monthNames);

    // Get previous period's start and end date
    let prevStartDate, prevEndDate;
    if (type === 'month') {
      // Get the previous month
      const prevMonth = new Date(Date.UTC(startDate.getUTCFullYear(), startDate.getUTCMonth() - 1, 1, 0, 0, 0, 0));
      prevStartDate = prevMonth; // Already in UTC

      // Get the last day of the previous month
      prevEndDate = new Date(Date.UTC(startDate.getUTCFullYear(), startDate.getUTCMonth(), 0, 23, 59, 59, 999));
    } else if (type === 'week') {
      prevStartDate = new Date(startDate);
      prevStartDate.setUTCDate(prevStartDate.getUTCDate() - 7);
      prevStartDate.setUTCHours(0, 0, 0, 0); // Force UTC midnight

      prevEndDate = new Date(endDate);
      prevEndDate.setUTCDate(prevEndDate.getUTCDate() - 7);
      prevEndDate.setUTCHours(23, 59, 59, 999); // Force UTC end-of-day
    }

    // 1. Fetch current period transactions
    const response = await BankService.getAllTransactionsByTimeLine(userId, accountIdObj, startDate, endDate, groupBy);
    const transactionData = fillTransactionData(response, result, type, monthNames);

    // 2. Fetch previous period lastTimePeriodDebit
    const getLastPeriodDebit = await BankService.getLastPeriodDebit(userId, accountIdObj, prevStartDate, prevEndDate, groupBy);
    const lastTimePeriodDebit = getLastPeriodDebit[0]?.totalDebit || 0;

    // Calculate percentage change
    const currentTotalDebit = transactionData.totalDebit;
    const debitChangePercentage = ((currentTotalDebit - lastTimePeriodDebit) / lastTimePeriodDebit) * 100;

    SuccessResponse.data = { ...transactionData, debitChangePercentage };

    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
};

// 2. Get all transactions for all accounts including manual transactions
exports.getWholeTransactionsGraph = async (req, res) => {
  try {
    const { type, value } = req.params;
    const userId = req.user._id;

    const { startDate, endDate, groupBy } = getDateRange(type, value);
    const result = initializeResults(type, new Date(startDate), new Date(endDate), monthNames);

    const response = await BankService.getAllTransactionsForMainGraph(userId, startDate, endDate, groupBy);

    const transactionData = fillTransactionData(response, result, type, monthNames);

    SuccessResponse.data = transactionData;

    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
};

exports.getHeadsUpMessages = async (req, res) => {
  try {
    const userId = req.user._id;
    const response = await BankService.getHeadsUpMessages(userId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.getMoneyMapMessages = async (req, res) => {
  try {
    const userId = req.user._id;
    const response = await BankService.getMoneyMapMessages(userId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.getTopThreeTransactionsOfWeek = async (req, res) => {
  try {
    const userId = req.user._id;
    const response = await BankService.getTopThreeTransactionsOfWeek(userId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.getIncomeAndCategorySpent = async (req, res) => {
  try {
    const userId = req.user._id;
    const response = await BankService.getIncomeAndCategorySpent(userId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.getLoanCalculation = async (req, res) => {
  try {
    const data = req.body;
    const response = await BankService.getLoanCalculation(data);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.getSearchedTransactions = async (req, res) => {
  try {
    const userId = req.user._id;
    const { page, search, isBankAccount } = req.params;

    const response = await BankService.getSearchedTransactions(userId, page, search, isBankAccount, req.query);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.getDayWiseTransactionsSummary = async (req, res) => {
  try {
    const userId = req.user._id;
    // const {page} = req.params;

    const response = await BankService.getDayWiseTransactionsSummary(userId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json(ErrorResponse);
  }
};

exports.getTransactionsByDate = async (req, res) => {
  try {
    const userId = req.user._id;
    const { date } = req.params;

    const response = await BankService.getTransactionsByDate(userId, date);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json(ErrorResponse);
  }
};

exports.getRecurringPayments = async (req, res) => {
  try {
    const userId = req.user._id;
    const type = req.params.isActive;
    const response = await BankService.getRecurringPayments(userId, type);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.updateRecurringPayment = async (req, res) => {
  try {
    const userId = req.user._id;
    const recurringPaymentId = new ObjectId(req.params.id);
    const data = req.body;
    const response = await BankService.updateRecurringPayment(recurringPaymentId, userId, data);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.deleteRecurringPayment = async (req, res) => {
  try {
    const recurringPaymentId = new ObjectId(req.params.id);
    const response = await BankService.deleteRecurringPayment(recurringPaymentId);

    SuccessResponse.data = response;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.deleteTransactions = async (req, res) => {
  try {
    const { transactionIds } = req.body;
    const userId = req.user._id;
    if (!Array.isArray(transactionIds) || transactionIds.length === 0) {
      return res.status(StatusCodes.BAD_REQUEST).json({ ...ErrorResponse, error: 'transactionIds must be a non-empty array.' });
    }

    const sanitizedIds = transactionIds.filter((id) => mongoose.Types.ObjectId.isValid(id)).map((id) => new mongoose.Types.ObjectId(id));

    await Transaction.deleteMany({ _id: { $in: sanitizedIds }, manualTransaction: true, userId: new mongoose.Types.ObjectId(userId) });

    SuccessResponse.data = `${sanitizedIds.length} transaction(s) deleted successfully`;

    try {
      await headsUpMessages(userId);
      await moneyMapMessages(userId);
    } catch (e) {
      console.log(e);
    }

    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    logger.error(`Error from deleteBankAccount, transaction-controller ${error}`);
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.deleteBankAccount = async (req, res) => {
  try {
    const userId = req.user._id;
    const { bankId, accountId } = req.params;

    // delete bank account
    await BankService.deleteBankAccount(userId, bankId, accountId);

    SuccessResponse.data = 'Bank data deleted successfully';
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    logger.error(`Error from deleteBankAccount, transaction-controller ${error}`);
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

exports.getUserMonthlySpending = async (req, res) => {
  try {
    const userId = req.user._id;
    SuccessResponse.data = await BankService.getUserSpending(userId);
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    res.status(500).json({ message: 'Internal server error' });
  }
};
