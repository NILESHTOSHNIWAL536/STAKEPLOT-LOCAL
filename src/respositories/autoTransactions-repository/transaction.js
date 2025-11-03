const { Transaction, GroupedTransaction, BankLogo, TransactionRule, HeadsUp, MoneyMap, PredictedCategories, RecurringPayment } = require('../../models/index');
const { categorizeTransactions } = require('../../utils/helpers/categorizeTransactions');
const { getTransactions } = require('../../utils/helpers/graphDataFromTransactions');
const mongoose = require('mongoose');
const CrudRepository = require('../crud-repository');
const calculatePercentageChange = require('../../utils/helpers/comparePersentage');
const FipRepository  = require('../autoTransactions-repository/bank');
const { buildSearchFilter, getMatchedKeywords } = require('../../utils/helpers/transactionSearchFilter');
const { enrichTransactionWithBankDetails } = require('../../utils/helpers/transactionBankLogo');
const extractNarrationPattern = require('../../utils/helpers/extractNarrationPattern');
const logger = require('../../utils/common/logger');
const { deduplicateTransactions } = require('../../utils/helpers/de-duplicate-transactions');
const deduplicateAllTransactions = require('../../utils/helpers/delete-transactions-from-db');
const AppError = require('../../utils/errors/app-error');
const { StatusCodes } = require('http-status-codes');
const transactionWithPredictions = require('../../utils/helpers/transaction-category-prediction');
const { handleDailyCounter, incrementScore, getCurrentDate } = require('../../utils/helpers/increment_score');
const { scoreToAdd, scoreToGetReward } = require('../../utils/common/enums');
const axios = require('axios');
const dotenv = require('dotenv');
const { startOfWeek, endOfWeek, subDays, startOfMonth, endOfMonth } = require('date-fns');
const { calculateLoanEligibility } = require('../../utils/common/loanCalculator');

dotenv.config();

const PREDICT_URL = process.env.PREDICT_URL;

class AutoTransactionRepository extends CrudRepository {
  constructor() {
    super(Transaction);
  }

  async createTransaction(transactionsData, accountId, userId, bankId) {
    try {
      // 1. Check if transactionsData's manualTransaction is true, then there will only we one transaction, directly create it.
      if (transactionsData[0]?.manualTransaction) {
        const response = await this.model.create(transactionsData[0]);
        return { data: response };
      }

      // 2. Fetch rules for auto-categorization, and create a ruleMap out of it
      const rules = await TransactionRule.find({ userId }).lean();
      const ruleMap = new Map(rules.map((r) => [`${r.narrationPattern}_${r.amount}`, r]));

      // 3. Remove the duplicate transactions from the fetched transactions
      const uniqueTransactions = deduplicateTransactions(transactionsData);

      // 4. Categorize transactions for category, subcategory
      const categorizedTransactions = categorizeTransactions(uniqueTransactions, accountId, userId, bankId, ruleMap);

      // 5. Insert transactions in bulk with error tolerance
      const responses = await this.model.insertMany(categorizedTransactions, {
        ordered: false,
        rawResult: true,
      });

      // 6. Call the function to remove duplicates from the DB If found
      await deduplicateAllTransactions(userId);

      return {
        insertedCount: responses.insertedCount,
        insertedIds: responses.insertedIds,
        message: 'Transactions inserted, grouping queued if needed',
      };
    } catch (error) {
      console.error('Error inserting transactions:', error);

      if (error.code === 11000) {
        console.warn('Duplicate transactions detected:', error);
        return {
          message: 'Some transactions were duplicates',
          insertedCount: error.result?.insertedCount || 0,
        };
      }

      throw error;
    }
  }

  async getTransactions(userId, page) {
    try {
      const limit = 20;
      const skip = (page - 1) * limit;

      // 1. pull the page of transactions (already sorted newest-first)
      const transactions = await this.model.find({ userId, Hidden: false }).sort({ transactionTimestamp: -1 }).skip(skip).limit(limit).populate('accountId', 'bankId');

      // 2. enrich with bank details
      const banks = await new FipRepository().getBank(userId);
      const txWithBank = await enrichTransactionWithBankDetails(transactions, banks);

      // 3. add predictions **in place**, preserving order
      const txWithPredictions = await transactionWithPredictions(txWithBank);

      return txWithPredictions;
    } catch (err) {
      logger.error(`Error fetching transactions: ${err.stack}`);
      throw new AppError('Failed to fetch transactions', StatusCodes.INTERNAL_SERVER_ERROR);
    }
  }

  async getSearchedTransactions(userId, page, search, isBankAccount, query) {
    try {
      const limit = 20;
      const skip = (page - 1) * limit;
      const searchFilter = isBankAccount == 'Cash' ? [] : buildSearchFilter(search);
      const objectUserId = new mongoose.Types.ObjectId(userId);
      const objectAccountId = isBankAccount !== '' && isBankAccount != 'Cash' && isBankAccount !== '-' ? new mongoose.Types.ObjectId(isBankAccount) : undefined;

      const minAmount = query.minAmount ? Number(query.minAmount) : null;
      const maxAmount = query.maxAmount ? Number(query.maxAmount) : null;

      const startDate = query.startDate ? new Date(query.startDate.replace(/\//g, '-')) : null;
      const endDate = query.endDate ? new Date(query.endDate.replace(/\//g, '-')) : null;

      const baseQuery = {
        userId: objectUserId,
        Hidden: false,
        ...(isBankAccount === 'Cash' ? { manualTransaction: true } : {}),
        ...(searchFilter.length > 0 ? { $or: searchFilter } : {}),
        ...(isBankAccount !== '' && isBankAccount !== '-' && isBankAccount !== 'Credit' && isBankAccount !== 'Debit' && isBankAccount != 'Cash'
          ? { accountId: objectAccountId }
          : {}),
        ...(minAmount !== null || maxAmount !== null
          ? {
              amount: {
                ...(minAmount !== null ? { $gte: minAmount } : {}),
                ...(maxAmount !== null ? { $lte: maxAmount } : {}),
              },
            }
          : {}),
        ...(startDate || endDate
          ? {
              transactionTimestamp: {
                ...(startDate ? { $gte: startDate } : {}),
                ...(endDate ? { $lte: endDate } : {}),
              },
            }
          : {}),
      };

      // const amountQuery = {
      //       userId: objectUserId,
      //       Hidden: false,
      //       ...(minAmount !== undefined ? { amount: { $gte: minAmount } } : {}),
      //       ...(maxAmount !== undefined
      //         ? {
      //             amount: {
      //               ...(amountQuery.amount || {}),
      //               $lte: maxAmount,
      //             },
      //           }
      //         : {}),
      //     };

      const now = new Date();

      // Last Week Range (previous full week, e.g., Mon-Sun)
      const lastWeekStart = startOfWeek(subDays(now, 7), { weekStartsOn: 1 });
      const lastWeekEnd = endOfWeek(subDays(now, 7), { weekStartsOn: 1 });

      // Last Month Range
      const currentMonthStart = startOfMonth(now);
      const currentMonthEnd = endOfMonth(now);

      // Function to get totals for a period
      const getTotals = async (start, end) => {
        const match = {
          ...baseQuery,
          transactionTimestamp: { $gte: start, $lte: end },
        };

        const result = await this.model.aggregate([
          { $match: match },
          {
            $group: {
              _id: '$type',
              total: { $sum: '$amount' },
            },
          },
        ]);

        const totals = { credit: 0, debit: 0 };
        result.forEach((r) => {
          if (r._id === 'CREDIT') totals.credit = Math.round(r.total);
          if (r._id === 'DEBIT') totals.debit = Math.round(r.total);
        });
        return totals;
      };

      // Get last week/month totals
      const lastWeekTotals = await getTotals(lastWeekStart, lastWeekEnd);
      const currentMonthTotals = await getTotals(currentMonthStart, currentMonthEnd);

      // Fetch paginated transactions
      const transactions = await this.model.find(baseQuery).sort({ transactionTimestamp: -1 }).skip(skip).limit(limit).populate('accountId', 'bankId');

      // Add Bank Logo's to the transactions
      const banks = await new FipRepository().getBank(userId);
      const txWithBank = await enrichTransactionWithBankDetails(
        transactions,

        banks
      );
      const txWithPredictions = await transactionWithPredictions(txWithBank);

      const matchedKeywords = await getMatchedKeywords(userId, search);

      return {
        transactions: txWithPredictions,
        lastWeek: lastWeekTotals,
        lastMonth: currentMonthTotals,
        matchedKeywords,
      };
    } catch (error) {
      logger.error(`Error from getSearchedTransactions: ${error}`);
      throw new AppError('Failed to fetch searched transactions', StatusCodes.INTERNAL_SERVER_ERROR);
    }
  }

  async getTransactionsOfUser(userId) {
    const response = await this.model.find({ userId: userId, Hidden: false });
    return response;
  }

  async getTransactionsForAccount(userId, accountId, page) {
    const limit = 20; // Number of records per page
    const skip = (page - 1) * limit; // Calculate how many to skip
    const response = await this.model
      .find({ userId: userId, accountId: accountId, Hidden: false })
      .sort({ transactionTimestamp: -1 })
      .skip(skip) // Skip previous records
      .limit(limit); // Limit the number of records

    return response;
  }

  async getRecurringPayments(userId, type) {
    try {
      const response = await RecurringPayment.find({
        userId,
        isActive: type,
      }).lean();
      return response;
    } catch (error) {
      logger.error(`error from the getRecurringPayments from the repository: ${error}`);
      return error;
    }
  }

  async updateRecurringPayment(recurringPaymentId, userId, data) {
    const response = await RecurringPayment.findOneAndUpdate({ _id: recurringPaymentId, userId }, { $set: data }, { new: true, upsert: true });
    return response;
  }

  async deleteRecurringPayment(recurringPaymentId) {
    const response = await RecurringPayment.deleteOne({
      _id: recurringPaymentId,
    });
    return response;
  }

  async getGroupedTransactions(userId) {
    try {
      const response = await GroupedTransaction.find({ userId }).populate('transactions').sort({ count: -1 });
      return response;
    } catch (error) {
      logger.error(`error from getGroupedTransactions, respositories: ${error}`);
      throw error;
    }
  }

  async categorizeGroupedTransaction(userId, groupId, category, subcategory, removedTransactions) {
    const group = await GroupedTransaction.findOne({ _id: groupId, userId });
    if (!group) return { message: 'Group not found' };

    // Extract all transaction IDs from the group
    const transactionIds = group.transactions.map((txn) => txn._id.toString());

    // Filter out removed transactions
    const filteredIds = transactionIds.filter((id) => !removedTransactions.includes(id));

    // Only update the filtered transactions
    if (filteredIds.length > 0) {
      await Transaction.updateMany({ _id: { $in: filteredIds } }, { $set: { category, subcategory } });
    }

    // update the TransactionRule, for future transactions categorization
    // if (group.suggestedCategory && group.suggestedCategory !== 'Untagged') {
    await TransactionRule.findOneAndUpdate(
      {
        userId,
        narrationPattern: group.narrationPattern.toLowerCase(),
        amount: group.amount,
      },
      {
        userId,
        narrationPattern: group.narrationPattern.toLowerCase(),
        amount: group.totalAmount / group.count,
        category: category,
        subcategory: subcategory,
        source: 'group',
      },
      { upsert: true }
    );
    // }

    // Delete the grouped transaction regardless
    await GroupedTransaction.deleteOne({ _id: groupId });
  }

  async getPendingForReviewTransactions(userId) {
    try {
      const response = await this.model.find({ userId, needsReview: true }).sort({ transactionTimestamp: -1 });
      return response;
    } catch (error) {
      logger.debug(`response from the transactions repository: ${error}`);
      throw error;
    }
  }

  async verifyPendingTransaction(userId, transactionId, isCorrect) {
    try {
      const transaction = await Transaction.findOne({
        _id: transactionId,
        userId,
      });
      if (!transaction) return { message: 'Transaction not found' };

      isCorrect = String(isCorrect).toLowerCase() === 'true';
      const narrationPattern = extractNarrationPattern(transaction.narration).toLowerCase();

      if (isCorrect) {
        transaction.needsReview = false;
        await transaction.save();

        await TransactionRule.findOneAndUpdate(
          {
            userId,
            narrationPattern,
            amount: transaction.amount,
          },
          {
            userId,
            narrationPattern,
            amount: transaction.amount,
            category: transaction.category,
            subcategory: transaction.subcategory || '',
            source: 'manual',
          },
          { upsert: true }
        );
      } else {
        transaction.category = 'Untagged';
        transaction.subcategory = '';
        transaction.needsReview = false;
        await transaction.save();

        await TransactionRule.deleteOne({
          userId,
          narrationPattern,
          amount: transaction.amount,
        });
      }

      return { message: 'Transaction categorized successfully' };
    } catch (error) {
      logger.error(`response from the transactions repository: ${error}`);
      throw error;
    }
  }

  async getMonthlyTransactionsHistory(userId, type, page) {
    const limit = 20;
    const skip = (page - 1) * limit;

    let startDate, endDate;

    if (/^\d{4}$/.test(type)) {
      // Year
      const y = parseInt(type, 10);
      startDate = new Date(Date.UTC(y, 0, 1, 18, 30, 0, 0)); // 1 Jan 00:00 IST
      endDate = new Date(Date.UTC(y, 11, 31, 18, 29, 59, 999)); // 31 Dec 23:59 IST
    } else if (/^\d{4}-\d{2}$/.test(type)) {
      // Month
      const [year, month] = type.split('-');
      const y = parseInt(year, 10);
      const m = parseInt(month, 10) - 1;

      startDate = new Date(Date.UTC(y, m, 1, 18, 30, 0, 0)); // 1st day 00:00 IST
      endDate = new Date(Date.UTC(y, m + 1, 0, 18, 29, 59, 999)); // Last day 23:59 IST
    } else {
      throw new Error("Invalid date format. Use 'YYYY' or 'YYYY-MM'.");
    }

    const transactions = await this.model
      .find({
        userId: userId,
        Hidden: false,
        transactionTimestamp: { $gte: startDate, $lte: endDate },
      })
      .sort({ transactionTimestamp: -1 })
      .skip(skip)
      .limit(limit);

    const banks = await new FipRepository().getBank(userId);
    const txWithBank = await enrichTransactionWithBankDetails(transactions, banks);

    // 3. add predictions **in place**, preserving order
    const txWithPredictions = await transactionWithPredictions(txWithBank);

    return { transactions: txWithPredictions };
  }

  async getDayWiseTransactionsSummary(userId) {
    const pipeline = [
      {
        $match: {
          userId: userId,
        },
      },
      {
        $group: {
          _id: {
            $dateToString: {
              format: '%Y-%m-%d',
              date: '$transactionTimestamp',
            },
          },
          count: { $sum: 1 },
          creditAmount: {
            $sum: {
              $cond: [{ $eq: ['$type', 'CREDIT'] }, '$amount', 0],
            },
          },
          debitAmount: {
            $sum: {
              $cond: [{ $eq: ['$type', 'DEBIT'] }, '$amount', 0],
            },
          },
        },
      },
      { $sort: { _id: -1 } },
      {
        $project: {
          _id: 0,
          date: '$_id',
          count: 1,
          creditAmount: 1,
          debitAmount: 1,
        },
      },
    ];
    const response = await this.model.aggregate(pipeline);
    return response;
  }

  async getTransactionsByDate(userId, date) {
    const start = new Date(date);
    const end = new Date(date);
    end.setDate(start.getDate() + 1);

    const query = {
      userId: userId,
      transactionTimestamp: {
        $gte: start,
        $lt: end,
      },
    };
    const options = { transactionTimestamp: -1 };

    const transactions = await this.get(query, options);

    const banks = await new FipRepository().getBank(userId);
    const txWithBank = await enrichTransactionWithBankDetails(transactions, banks);

    const txWithPredictions = await transactionWithPredictions(txWithBank);

    return txWithPredictions;
  }

  async getTransactionsByCategory(userId, category) {
    const transactions = await this.get({ userId: userId });
    const categoryTransactions = transactions.filter((transaction) => transaction.categorized_transactions.some((cat) => cat.category === category));
    return categoryTransactions;
  }

  async categorizeTransactions(userId, startDate, endDate) {
    const userObjectId = new mongoose.Types.ObjectId(userId);

    const buildPipeline = (fromDate, toDate) => [
      {
        $match: {
          userId: userObjectId,
          transactionTimestamp: {
            $gte: new Date(fromDate),
            $lte: new Date(toDate),
          },
          isExcluded: false,
        },
      },
      {
        $lookup: {
          from: 'splits',
          localField: '_id',
          foreignField: 'transactionId',
          as: 'splitData',
        },
      },
      {
        $addFields: {
          userSplit: {
            $first: {
              $filter: {
                input: '$splitData',
                as: 'split',
                cond: { $eq: ['$$split.userId', userObjectId] },
              },
            },
          },
        },
      },
      {
        $addFields: {
          userPaymentStatus: {
            $filter: {
              input: { $ifNull: ['$userSplit.paymentStatus', []] },
              as: 'ps',
              cond: { $eq: ['$$ps.member', userObjectId] },
            },
          },
        },
      },
      {
        $addFields: {
          computedAmount: {
            $cond: {
              if: {
                $and: [{ $eq: [{ $ifNull: ['$isBalanceOut', false] }, true] }, { $ne: [{ $ifNull: ['$balanceOut', -1] }, -1] }],
              },
              then: '$balanceOut',
              else: {
                $cond: [
                  { $gt: [{ $size: '$userPaymentStatus' }, 0] },
                  {
                    $sum: {
                      $map: {
                        input: '$userPaymentStatus',
                        as: 's',
                        in: { $ifNull: ['$$s.amount', 0] },
                      },
                    },
                  },
                  '$amount',
                ],
              },
            },
          },
          category: {
            $toLower: { $ifNull: ['$category', 'untagged'] },
          },
        },
      },
      {
        $group: {
          _id: '$category',
          total_debit: {
            $sum: {
              $cond: [{ $eq: ['$type', 'DEBIT'] }, '$computedAmount', 0],
            },
          },
          total_credit: {
            $sum: {
              $cond: [{ $eq: ['$type', 'CREDIT'] }, '$computedAmount', 0],
            },
          },
        },
      },
      {
        $project: {
          category: '$_id',
          total_debit: 1,
          total_credit: 1,
          _id: 0,
        },
      },
    ];

    const frequencyPipeline = [
      {
        $match: {
          userId: userObjectId,
          transactionTimestamp: {
            $gte: new Date(startDate),
            $lte: new Date(endDate),
          },
          type: 'DEBIT',
          narration: { $ne: null },
          manualTransaction: { $ne: true },
        },
      },
      {
        $addFields: {
          splitByDash: { $split: ['$narration', '-'] },
          splitBySlash: { $split: ['$narration', '/'] },
          splitByPlus: { $split: ['$narration', '+'] },
          splitBySpace: { $split: ['$narration', ' '] },
        },
      },
      {
        $addFields: {
          chosenSplit: {
            $cond: [
              { $gt: [{ $size: '$splitByDash' }, 1] },
              '$splitByDash',
              {
                $cond: [
                  { $gt: [{ $size: '$splitBySlash' }, 1] },
                  '$splitBySlash',
                  {
                    $cond: [{ $gt: [{ $size: '$splitByPlus' }, 1] }, '$splitByPlus', '$splitBySpace'],
                  },
                ],
              },
            ],
          },
        },
      },
      {
        $addFields: {
          trimmedParts: {
            $map: {
              input: '$chosenSplit',
              as: 'part',
              in: { $trim: { input: '$$part' } },
            },
          },
        },
      },
      {
        $addFields: {
          probableName: {
            $cond: [
              { $gte: [{ $size: '$trimmedParts' }, 4] },
              {
                $concat: [{ $arrayElemAt: ['$trimmedParts', 2] }, ' ', { $arrayElemAt: ['$trimmedParts', 3] }],
              },
              {
                $cond: [
                  { $gte: [{ $size: '$trimmedParts' }, 3] },
                  { $arrayElemAt: ['$trimmedParts', 2] },
                  {
                    $cond: [{ $gte: [{ $size: '$trimmedParts' }, 2] }, { $arrayElemAt: ['$trimmedParts', 1] }, { $arrayElemAt: ['$trimmedParts', 0] }],
                  },
                ],
              },
            ],
          },
        },
      },
      {
        $addFields: {
          computedAmount: {
            $cond: {
              if: {
                $and: [{ $eq: [{ $ifNull: ['$isBalanceOut', false] }, true] }, { $ne: [{ $ifNull: ['$balanceOut', -1] }, -1] }],
              },
              then: '$balanceOut',
              else: '$amount',
            },
          },
        },
      },
      {
        $group: {
          _id: '$probableName',
          count: { $sum: 1 },
          totalAmount: { $sum: '$computedAmount' },
          narrations: { $addToSet: '$narration' },
        },
      },
      {
        $sort: {
          count: -1,
          totalAmount: -1,
        },
      },
      {
        $limit: 4,
      },
      {
        $project: {
          name: '$_id',
          _id: 0,
          count: 1,
          totalAmount: 1,
          narrations: 1,
        },
      },
    ];

    // Fetch current month data
    const currentData = await this.model.aggregate(buildPipeline(startDate, endDate));

    // Previous month dates
    const prevStartDate = new Date(startDate);
    prevStartDate.setUTCMonth(prevStartDate.getUTCMonth() - 1);
    const prevEndDate = new Date(endDate);
    prevEndDate.setUTCMonth(prevEndDate.getUTCMonth() - 1);

    // Fetch previous month data
    const prevData = await this.model.aggregate(buildPipeline(prevStartDate, prevEndDate));

    // Map previous month by lowercased category
    const prevMap = new Map(prevData.map((item) => [item.category.toLowerCase(), item]));

    // Combine current + previous to compute percentage change
    const result = currentData
      .map((current) => {
        const categoryKey = current.category.toLowerCase();
        const previous = prevMap.get(categoryKey) || {
          total_debit: 0,
          total_credit: 0,
        };
        return {
          category: categoryKey,
          total_debit: current.total_debit,
          total_credit: current.total_credit,
          total_debit_percentage: calculatePercentageChange(current.total_debit, previous.total_debit),
          total_credit_percentage: calculatePercentageChange(current.total_credit, previous.total_credit),
          debit_diff: current.total_debit - previous.total_debit,
        };
      })
      // ✅ Filter out categories with zero debit but positive credit (e.g., pure income entries)
      .filter((item) => !(item.total_debit === 0 && item.total_credit > 0));

    const totalDebitThisMonth = result.reduce((sum, item) => sum + item.total_debit, 0);
    const totalCreditThisMonth = result.reduce((sum, item) => sum + item.total_credit, 0);

    const moreDrasticChange = [...result]
      .sort((a, b) => b.debit_diff - a.debit_diff)
      .slice(0, 4)
      .map(({ category, debit_diff }) => ({ category, debit_diff }));

    const frequentPayments = await this.model.aggregate(frequencyPipeline);

    return {
      categorized: result,
      moreDrasticChange,
      frequentPayments,
      totalDebitThisMonth,
      totalCreditThisMonth,
    };
  }

  async getHideTransactions(userId) {
    try {
      //1. Fetch hidden transactions for the user
      const transactions = await this.model
        .find({
          userId,
          Hidden: true,
        })
        .populate('accountId', 'bankId');

      // 2. enrich with bank details
      const banks = await new FipRepository().getBank(userId);
      const txWithBank = await enrichTransactionWithBankDetails(transactions, banks);

      return txWithBank;
    } catch (error) {
      logger.error(`Error fetching hidden transactions: ${error.stack}`);
      throw new AppError('Failed to fetch hidden transactions', StatusCodes.INTERNAL_SERVER_ERROR);
    }
  }

  async updateTransaction(updateData, userId, transactionId) {
    try {
      const updatedTransaction = await Transaction.findOneAndUpdate({ _id: transactionId, userId }, { $set: updateData }, { new: true });

      if (!updatedTransaction) {
        return {
          success: false,
          message: 'Transaction not found',
        };
      }

      // check if the updateData has category, then update the TransactionRule collection
      if (updatedTransaction && 'category' in updateData) {
        let narrationPattern = extractNarrationPattern(updatedTransaction.narration).toLowerCase();

        try {
          //1. Create a transaction rule for future auto tagging
          await TransactionRule.findOneAndUpdate(
            {
              userId: updatedTransaction.userId,
              narrationPattern: narrationPattern,
              amount: updatedTransaction.amount,
            },
            {
              userId: updatedTransaction.userId,
              narrationPattern: narrationPattern,
              amount: updatedTransaction.amount,
              category: updatedTransaction.category,
              subcategory: updatedTransaction.subcategory,
              source: 'manual',
            },
            { upsert: true }
          );

          //2. create a document for predicted category to train ML model in future
          if (updateData.predictedCategories && updateData.selectedCategory) {
            await PredictedCategories.create({
              narration: updatedTransaction.narration,
              selectedCategory: updateData.selectedCategory,
              predictedCategories: updateData.predictedCategories,
            });
          }

          const id = updatedTransaction.userId;
          await handleDailyCounter(id, 'dailyTags', 1, transactionId, scoreToAdd.Tag, scoreToGetReward.Tag);
        } catch (error) {
          logger.error(`error from the update transaction in repositories: ${error} `);
        }
      }

      return {
        success: true,
        message: 'Transaction updated successfully',
        data: updatedTransaction,
      };
    } catch (error) {
      return {
        success: false,
        error: error.message,
      };
    }
  }

  async getTopFiveCategories(userId) {
    const pipeline = [
      {
        $match: {
          userId: userId,
          type: 'DEBIT',
          category: { $ne: 'Untagged' },
        },
      },
      {
        $group: {
          _id: '$category',
          totalDebit: { $sum: '$amount' },
        },
      },
      { $sort: { totalDebit: -1 } },
      { $limit: 5 },
      {
        $project: {
          _id: 0,
          category: '$_id',
        },
      },
    ];

    const topCategories = await this.model.aggregate(pipeline);
    return topCategories.map((item) => item.category);
  }

  async getLastPeriodDebit(userId, accountId, startDate, endDate) {
    const pipeline = [
      {
        $match: {
          userId: userId,
          accountId: accountId,
          transactionTimestamp: {
            $gte: new Date(startDate),
            $lte: new Date(endDate),
          },
          type: 'DEBIT',
        },
      },
      {
        $group: {
          _id: null,
          totalDebit: { $sum: '$amount' },
        },
      },
    ];

    const response = await this.model.aggregate(pipeline);
    return response;
  }

  async getBudgetTransactions(userId, startDate, endDate, categories, groupBy) {
    let dateFormat;
    if (groupBy === 'monthly' || groupBy === 'weekly') {
      dateFormat = '%Y-%m-%d'; // Day-Month-Year for weekly & monthly
    } else if (groupBy === 'yearly') {
      dateFormat = '%B'; // Full month name (e.g., January, February) for yearly
    } else {
      throw new Error("Invalid groupBy value. Use 'monthly', 'weekly', or 'yearly'.");
    }

    const transactions = await this.model.aggregate([
      // Match transactions within the time range and categories
      {
        $match: {
          userId: userId,
          transactionTimestamp: {
            $gte: new Date(startDate),
            $lte: new Date(endDate),
          },
          category: { $in: categories },
        },
      },
      // Group by formatted date, transaction type, and category
      {
        $group: {
          _id: {
            date: {
              $dateToString: {
                format: dateFormat,
                date: '$transactionTimestamp',
              },
            },
            type: '$type',
            category: '$category',
          },
          totalAmount: { $sum: '$amount' },
        },
      },
      // Reshape the output structure to group transactions by date and separate DEBIT & CREDIT
      {
        $group: {
          _id: '$_id.date',
          debit: {
            $push: {
              $cond: [{ $eq: ['$_id.type', 'DEBIT'] }, { k: '$_id.category', v: '$totalAmount' }, '$$REMOVE'],
            },
          },
          credit: {
            $push: {
              $cond: [{ $eq: ['$_id.type', 'CREDIT'] }, { k: '$_id.category', v: '$totalAmount' }, '$$REMOVE'],
            },
          },
          debitTotalAmount: {
            $sum: {
              $cond: [{ $eq: ['$_id.type', 'DEBIT'] }, '$totalAmount', 0],
            },
          },
          creditTotalAmount: {
            $sum: {
              $cond: [{ $eq: ['$_id.type', 'CREDIT'] }, '$totalAmount', 0],
            },
          },
        },
      },
      // Convert debit and credit arrays into key-value objects
      {
        $project: {
          _id: 1,
          debit: { $arrayToObject: '$debit' },
          credit: { $arrayToObject: '$credit' },
          debitTotalAmount: 1,
          creditTotalAmount: 1,
        },
      },
      // Sort by date
      {
        $sort: { _id: 1 },
      },
    ]);

    return transactions;
  }

  async getSpentAmounts(userId, startDate, endDate, categories) {
    const response = await this.model.aggregate([
      {
        $match: {
          userId: userId,
          transactionTimestamp: {
            $gte: new Date(startDate),
            $lte: new Date(endDate),
          },
          category: { $in: categories },
        },
      },
      {
        $group: {
          _id: { category: '$category', subcategory: '$subcategory' },
          totalAmount: { $sum: '$amount' },
        },
      },
      {
        $group: {
          _id: '$_id.category',
          totalSpent: { $sum: '$totalAmount' },
          breakdown: {
            $push: {
              name: '$_id.subcategory',
              amount: '$totalAmount',
            },
          },
        },
      },
      {
        $project: {
          _id: 0,
          category: '$_id',
          totalSpent: 1,
          breakdown: 1,
        },
      },
    ]);

    return response;
  }

  async getPreviousTransactions(userId, startDate, accountId) {
    try {
      const start = new Date(startDate);
      const end = new Date();

      const pipeline = [
        {
          $match: {
            userId: userId,
            transactionTimestamp: {
              $gte: start,
              $lte: end,
            },
            manualTransaction: false,
            accountId: new mongoose.Types.ObjectId(accountId),
          },
        },
        {
          $sort: { transactionTimestamp: -1 },
        },
      ];

      const response = this.model.aggregate(pipeline);
      return response;
    } catch (error) {
      logger.error(`Error fetching previous transactions: ${error}`);
      throw error;
    }
  }

  async categoryWiseSpendings(userId, categoryNames, startDate, endDate) {
    const result = await Transaction.aggregate([
      {
        $match: {
          userId: new mongoose.Types.ObjectId(userId),
          type: 'DEBIT',
          category: { $in: categoryNames },
          transactionTimestamp: {
            $gte: new Date(startDate),
            $lte: new Date(endDate),
          },
        },
      },
      {
        $group: {
          _id: '$category',
          totalSpending: { $sum: '$amount' },
        },
      },
      {
        $group: {
          _id: null,
          categories: {
            $push: { category: '$_id', spending: '$totalSpending' },
          },
          totalSpending: { $sum: '$totalSpending' },
        },
      },
      {
        $unwind: '$categories',
      },
      {
        $project: {
          _id: 0,
          category: '$categories.category',
          spending: '$categories.spending',
          percentage: {
            $multiply: [{ $divide: ['$categories.spending', '$totalSpending'] }, 100],
          },
        },
      },
    ]);

    return result;
  }

  // these are related to graphs:
  // 1. This function is used to get all transactions for a specific account
  async getAllTransactionsByTimeLine(userId, accountId, startDate, endDate, groupBy = 'day') {
    return getTransactions(this.model, userId, startDate, endDate, groupBy, accountId);
  }

  // 2. This function is used to get all transactions for all accounts including manual transactions
  async getAllTransactionsForMainGraph(userId, startDate, endDate, groupBy = 'day') {
    return getTransactions(this.model, userId, startDate, endDate, groupBy);
  }

  // Grouping the transactions
  async groupSimilarTransactions(userId) {
    const pipeline = [
      {
        $match: {
          userId: new mongoose.Types.ObjectId(userId),
          category: 'Untagged',
        },
      },
      {
        $addFields: {
          narrationPattern: {
            $let: {
              vars: {
                splitSlash: { $split: ['$narration', '/'] },
                splitDash: { $split: ['$narration', '-'] },
              },
              in: {
                $trim: {
                  input: {
                    $cond: [
                      { $gte: [{ $size: '$$splitSlash' }, 5] },
                      {
                        $concat: [{ $arrayElemAt: ['$$splitSlash', 3] }, '/', { $arrayElemAt: ['$$splitSlash', 4] }],
                      },
                      {
                        $cond: [
                          { $gte: [{ $size: '$$splitDash' }, 4] },
                          {
                            $concat: [{ $arrayElemAt: ['$$splitDash', 2] }, '-', { $arrayElemAt: ['$$splitDash', 3] }],
                          },
                          '$narration', // fallback
                        ],
                      },
                    ],
                  },
                },
              },
            },
          },
        },
      },
      {
        $group: {
          _id: {
            narrationPattern: '$narrationPattern',
            amount: '$amount',
          },
          transactions: { $push: '$_id' },
          totalAmount: { $sum: '$amount' },
          count: { $sum: 1 },
          narrationPattern: { $first: '$narrationPattern' },
          latestTimestamp: { $max: '$transactionTimestamp' },
          suggestedCategory: { $first: '$category' },
        },
      },
      {
        $match: {
          count: { $gt: 3 },
        },
      },
      {
        $sort: {
          latestTimestamp: -1,
        },
      },
    ];

    return await Transaction.aggregate(pipeline);
  }

  // get headsup messages
  async getHeadsUpMessages(userId) {
    try {
      const headsUpMessages = await HeadsUp.find({ userId }).sort({
        createdAt: -1,
      });
      return headsUpMessages;
    } catch (error) {
      logger.error(`Error fetching heads-up messages: ${error}`);
      throw error;
    }
  }

  // get money map messages
  async getMoneyMapMessages(userId) {
    try {
      const moneyMapMessages = await MoneyMap.find({ userId }).sort({
        createdAt: -1,
      });
      return moneyMapMessages;
    } catch (error) {
      logger.error(`Error fetching money map messages: ${error}`);
      throw error;
    }
  }

  // get top three transactions of the week
  async getTopThreeTransactionsOfWeek(userId) {
    try {
      const now = new Date();

      // Step 1: Find the last Friday (before today)
      const lastFriday = new Date(now);
      const day = now.getDay();
      const diffToLastFriday = day >= 5 ? day - 5 : day + 2; // how many days to subtract
      lastFriday.setDate(now.getDate() - diffToLastFriday);
      lastFriday.setHours(0, 0, 0, 0); // normalize time

      // Step 2: Previous Friday is 7 days before last Friday
      const previousFriday = new Date(lastFriday);
      previousFriday.setDate(lastFriday.getDate() - 7);
      previousFriday.setHours(0, 0, 0, 0); // normalize

      const transactions = await this.model
        .find({
          userId,
          transactionTimestamp: {
            $gte: previousFriday,
            $lte: lastFriday,
          },
          type: 'DEBIT',
          manualTransaction: false,
          isExcluded: false,
        })
        .sort({ amount: -1 })
        .limit(3)
        .populate('accountId', 'bankId');

      // Add Bank Logo's to the transactions
      const banks = await new FipRepository().getBank(userId);
      const transactionsWithBankLogo = await enrichTransactionWithBankDetails(transactions, banks);

      return transactionsWithBankLogo;
    } catch (error) {
      throw error;
    }
  }

  async getIncomeAndCategorySpent(userId) {
    try {
      const now = new Date();
      const startOfCurrentMonth = new Date(now.getFullYear(), now.getMonth(), 1);
      const startOfLastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);

      const results = await this.model.aggregate([
        {
          $match: {
            userId: userId,
            isExcluded: false,
            transactionTimestamp: { $gte: startOfLastMonth }, // only last month + current month
          },
        },
        {
          $facet: {
            // ---- INCOME (credits of current month) ----
            income: [
              {
                $match: {
                  type: 'CREDIT',
                  transactionTimestamp: { $gte: startOfCurrentMonth },
                },
              },
              {
                $group: {
                  _id: null,
                  totalIncome: { $sum: '$amount' },
                },
              },
            ],

            // ---- CATEGORY SPENDING (debits grouped by category) ----
            categorySpending: [
              {
                $match: { type: 'DEBIT' },
              },
              {
                $project: {
                  amount: 1,
                  category: 1,
                  month: { $month: '$transactionTimestamp' },
                  year: { $year: '$transactionTimestamp' },
                },
              },
              {
                $group: {
                  _id: { category: '$category', month: '$month', year: '$year' },
                  totalSpent: { $sum: '$amount' },
                },
              },
              {
                $group: {
                  _id: '$_id.category',
                  months: {
                    $push: {
                      month: '$_id.month',
                      year: '$_id.year',
                      spent: '$totalSpent',
                    },
                  },
                },
              },
              {
                $project: {
                  average: {
                    $divide: [{ $sum: '$months.spent' }, 2],
                  },
                },
              },
            ],
          },
        },
      ]);

      const income = results[0]?.income[0]?.totalIncome || 0;
      const categorySpendingRaw = results[0]?.categorySpending || [];

      const averageCategorySpendingOfTwoMonths = {};
      categorySpendingRaw.forEach((c) => {
        averageCategorySpendingOfTwoMonths[c._id] = c.average;
      });

      return {
        income,
        averageCategorySpendingOfTwoMonths,
      };
    } catch (error) {
      throw error;
    }
  }

  async getLoanCalculation(data) {
    const { income, existingEmi, creditScore, loanType, expenses } = data;
    return calculateLoanEligibility({ income, existingEmi, creditScore, loanType, expenses });
  }

  // delete complete bank data
  async deleteTransactions(userId, accountId) {
    try {
      let response;
      if (accountId) {
        response = await this.model.deleteMany({ userId, accountId });
      } else {
        response = await this.model.deleteMany({ userId });
      }

      return response.deletedCount;
    } catch (error) {
      logger.error(`Error deleting transactions: ${error}`);
      throw error;
    }
  }
}

module.exports = AutoTransactionRepository;
