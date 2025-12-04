const { StatusCodes } = require("http-status-codes");
const { TransactionService } = require("../services");
const { SuccessResponse, ErrorResponse } = require("../utils/common");
// const AppError = require("../utils/errors/app-error");
const headsUpMessages = require("../utils/common/money-map");
const moneyMapMessages = require("../utils/common/money-map");
const moment = require('moment-timezone');
// const { TransactionRepository } = require("../repositories");
// const logger = require("../utils/common/logger");


// function findIndexByName(name, keys) {
//   return keys.findIndex((obj) => obj.name === name);
// }


async function enterTransaction(req, res) {
  try {
    const userId = req.user._id;
    const response = await TransactionService.enterTransaction({ ...req.body, userId });
    SuccessResponse.data = [response];
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    return res.status(error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR).json(ErrorResponse);
  }
}

function filterAndAddTotalByDate(data) {
  return data.reduce((result, item) => {
    const date = moment(item.transactionTimestamp).tz('Asia/Kolkata').format('YYYY-MM-DD');
    const existingDate = result.find(entry => entry.date === date);

    if (existingDate) {
      existingDate.total += item.amount;
      existingDate.transactions.push({
        name: item.narration,
        amount: item.amount,
        category: item.category || 'Untagged',
        subcategory: item.subcategory || 'Untagged',
        mode: item.mode,
        type: item.type
      });
    } else {
      result.push({
        date,
        total: item.amount,
        transactions: [{
          name: item.narration,
          amount: item.amount,
          category: item.category || 'Untagged',
          subcategory: item.subcategory || 'Untagged',
          mode: item.mode,
          type: item.type
        }]
      });
    }
    return result;
  }, []);
}

async function getRoomHistory(req, res) {
  try {
    const transactions = await TransactionService.getRoomHistory(req.params.roomId)
    const filteredData = filterAndAddTotalByDate(transactions)
    SuccessResponse.data = filteredData;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR; // Ensure a valid status code
    return res.status(statusCode).json(ErrorResponse);
  }
}

async function getBudgetHistory(req, res) {
  try {
    
    const transactions = await TransactionService.getBudgetHistory(req.user, req.params.budgetId)
    const filteredData = filterAndAddTotalByDate(transactions);
    SuccessResponse.data = filteredData;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    return res.status(error.statusCode).json(ErrorResponse);
  }
}

async function getAllTransactions(req, res) {
  try {
    
    const transactions = await TransactionService.getAllTransactions(req.user._id);
    const filteredData =filterAndAddTotalByDate(transactions);
    SuccessResponse.data = filteredData;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  } 
}

async function groupTransactions(req, res) {
  try {
    const groupedTransactions = await TransactionService.groupTransactions(req.user._id)
    SuccessResponse.data = groupedTransactions;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
}




async function deleteSpecificTransaction(req, res) {
  try {
    const transactionId = req.params.id;
    const userId = req.user._id;
    const response = TransactionService.deleteSpecificTransaction(userId, transactionId);
    //logger.debug("response: ", response)
    SuccessResponse.data = response
    return res.status(StatusCodes.OK).json(SuccessResponse)
  } catch (error) {
    ErrorResponse.error = error;
    return res.status(error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR).json(ErrorResponse);
  }
}

async function updateMoneymapHeadsUp(req, res) {
  try {
    const userId = req.user._id;
    await headsUpMessages(userId);
    await moneyMapMessages(userId);
    SuccessResponse.data = { message: "Moneymap Heads Up Updated Successfully" }
    return res.status(StatusCodes.OK).json(SuccessResponse)
  } catch (error) {
    ErrorResponse.error = error;
    return res.status(error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR).json(ErrorResponse);
  }
}

async function updateGroupTransaction(req, res) {
  try {
    const transactionId = req.params.id;
    const userId = req.user._id;
    var body=req.body;
    const response = TransactionService.updateGroupTransaction(userId, transactionId,body);
    SuccessResponse.data = response
    return res.status(StatusCodes.OK).json(SuccessResponse)
  } catch (error) {
    ErrorResponse.error = error;
    return res.status(error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR).json(ErrorResponse);
  }
}


module.exports = {
  enterTransaction,
  getRoomHistory,
  getAllTransactions,
  getBudgetHistory,
  groupTransactions,
  deleteSpecificTransaction,
  updateGroupTransaction,
  updateMoneymapHeadsUp
};