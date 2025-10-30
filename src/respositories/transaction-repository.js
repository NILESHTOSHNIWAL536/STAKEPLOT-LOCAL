const { Transaction } = require("../models");
const CrudRepository = require("./crud-repository");
const mongoose = require("mongoose");
const AppError = require("../utils/errors/app-error");
const { StatusCodes } = require("http-status-codes");

class transactionRepository extends CrudRepository {
  constructor() {
    super(Transaction);
  }

  async updateTransactions(userId, transactionData) {
    const result = await Transaction.findOne({ userId: userId });
    if (result) {
      result.Transactions.push(transactionData);
      await result.save();
      return result;
    } else {
      throw new AppError(
        "No transactions found for this user",
        StatusCodes.NOT_FOUND
      );
    }
  }

  // async getLatestTransactions(data) {
  //   const lastTwoMonths = new Date().setMonth(new Date().getMonth() - 2);
  //   const transactions = await Transaction.find({
  //     userId: data.user._id,
  //     createdAt: { $gte: lastTwoMonths },
  //     $or: [{ room: { $exists: false } }, { room: null }],
  //   }).sort({ createdAt: -1 });
  //   return transactions;
  // }

  async dayWiseTransactions(user) {
    const query = { userId: user._id };
    const transactions = await Transaction.find(query)
      .sort({ createdAt: -1 })
      .limit(70);
    return transactions;
  }

  async expensesRecordedDays(user) {
    const query = [
      {
        $match: { userId: user._id },
      },
      {
        $group: {
          _id: {
            year: { $year: "$createdAt" },
            month: { $month: "$createdAt" },
            day: { $dayOfMonth: "$createdAt" },
          },
        },
      },
      {
        $count: "uniqueInsertDays",
      },
    ];
    const daysCount = await Transaction.aggregate(query);
    return daysCount.length > 0 ? daysCount[0].uniqueInsertDays : 0;
  }

  async totalMonthlyExpenses(user) {
    const now = new Date();
    const firstDayOfPreviousMonth = new Date(
      now.getFullYear(),
      now.getMonth() - 1,
      1
    );
    const lastDayOfPreviousMonth = new Date(
      now.getFullYear(),
      now.getMonth(),
      0,
      23,
      59,
      59,
      999
    );

    const query = [
      {
        $match: {
          userId: user._id,
          createdAt: {
            $gte: firstDayOfPreviousMonth,
            $lte: lastDayOfPreviousMonth,
          },
        },
      },
      {
        $group: {
          _id: null,
          totalAmount: { $sum: "$amount" },
        },
      },
    ];
    const result = await Transaction.aggregate(query);
    return result.length > 0 ? result[0].totalAmount : 0;
  }

  async countDocuments(user) {
    const query = { userId: user._id, isDebt: true };
    const count = await Transaction.countDocuments(query);
    return count;
  }

  async getRoomTransactions(roomId) {
    const transactions = await Transaction.find({
      "room.id": roomId,
      room: { $exists: true },
    }).sort({ createdAt: -1 });
    return transactions;
  }

  async getAllTransactions(userId) {
    try {
      const transactions = await Transaction.find({ userId: userId });
      return transactions;
    } catch (error) {
      throw new AppError(
        `Cannot get transaction Objects: ${error}`,
        StatusCodes.INTERNAL_SERVER_ERROR
      );
    }
  }

  async groupTransactions(userId) {
    const query = [
      {
        $match: { userId: new mongoose.Types.ObjectId(userId) },
      },
      {
        $sort: { createdAt: -1 },
      },
      {
        $group: {
          _id: { category: "$category" }, // Group by category
          totalTransactions: { $sum: 1 }, // Count total transactions in each category
          totalAmount: { $sum: "$amount" }, // Sum up the amounts in each category
          latestTransactionDate: { $first: "$createdAt" }, // Get the most recent transaction date in each category
        },
      },
      {
        $sort: { latestTransactionDate: -1 }, // Sort the grouped results by the latest transaction date in descending order
      },
    ];
    const transactions = await Transaction.aggregate(query);
    return transactions;
  }

  async deleteSpecificTransaction(userId, transactionId) {
    const result = await Transaction.updateOne(
      { userId: userId, "Transactions._id": transactionId },
      { $pull: { Transactions: { _id: transactionId } } }
    );

    if (result.modifiedCount === 0) {
      throw new AppError(
        "Transaction not found or does not belong to the user",
        StatusCodes.NOT_FOUND
      );
    }

    
    return { message: "Transaction deleted successfully" };
  }

  async updateGroupTransaction(userId, transactionId, body) {
    try {
      const result = await Transaction.updateOne(
        { userId: userId, _id: transactionId },
        {
          $set: {
            balanceOut: Math.abs(body.amount),
            isBalanceOut: true,
          },
        }
      );

      if (result.modifiedCount === 0) {
        return {
          success: false,
          message: "Transaction not found or already updated.",
        };
      }


      return { success: true, message: "Transaction updated successfully." };
    } catch (e) {
      console.error("Error updating group transaction:", e);
      return {
        success: false,
        message: "Something went wrong. Please try again later.",
      };
    }
  }
}

module.exports = transactionRepository;
