import { Types, Model, PipelineStage } from 'mongoose';

import { IBankTransaction, IRecurringPayment } from '@/types/bank';
import { ITransactionRule } from '@/models/transactions-automation/transactionRule';

import { buildSearchPipeline } from '@/pipelines/search.pipeline';
import { buildMonthlyCategorizationPipeline } from '@/pipelines/categorize-monthly.pipeline';
import { buildFrequencyAnalysisPipeline, buildMostSpentCategoriesPipeline, buildMostSpentDayPipeline, buildWeeklyTotalSpendPipeline, getCurrentWeekRangeUTC, getLastWeekRangeUTC } from '@/pipelines/frequency-analysis.pipeline';
import { groupSimilarTransactionsPipeline } from '@/pipelines/group-similar.pipeline';
import { buildBudgetPipeline } from '@/pipelines/budget.pipeline';
import { buildSpendingPipeline } from '@/pipelines/spending.pipeline';

import { enrichTransactionWithBankDetails } from '@/helpers/enrich-bank.helper';
import { createTransactionsBulk } from '@/helpers/transaction-create.helper';
import { updateTransactionLogic } from '@/helpers/transaction-update.helper';
import { predictCategoriesForTransactions } from '@/helpers/predictions.helper';
import { calculateLoanEligibilityTS } from '@/helpers/loan-calculation.helper';

import { Transaction, TransactionRule, RecurringPayment, GroupedTransaction, PredictedCategories } from '@/models';

import CrudRepository from '../crud-repository';
import logger from '@/utils/common/logger';
import FipRepository from './bank';
import extractNarrationPattern from '@/utils/helpers/extractNarrationPattern';
import calculatePercentageChange from '@/utils/helpers/comparePersentage';
import { getTransactions } from '@/utils/helpers/graphDataFromTransactions';
import { getMatchedKeywords } from '@/utils/helpers/transactionSearchFilter';
import { startOfWeek, endOfWeek, subDays, startOfMonth, endOfMonth } from 'date-fns';

type GroupBy = 'day' | 'week' | 'month';

/**
 * AutoTransactionRepository:
 * The refactored TypeScript class that now composes logic from pipelines + helpers
 * instead of containing 1300 lines of inline logic.
 */

export default class AutoTransactionRepository extends CrudRepository<typeof Transaction> {
  protected readonly TransactionModel: Model<IBankTransaction> = Transaction;
  protected readonly RuleModel: Model<ITransactionRule> = TransactionRule;
  protected readonly RecurringModel: Model<IRecurringPayment> = RecurringPayment;
  protected readonly BankRepo = FipRepository;

  constructor() {
    super(Transaction);
  }

  // -------------------------
  // 1. Create transactions
  // -------------------------
  async createTransaction(
    transactions: Partial<IBankTransaction>[],
    accountId: string | Types.ObjectId | null,
    userId: string | Types.ObjectId,
    bankId: string | Types.ObjectId | null
  ) {
    try {
      return await createTransactionsBulk({
        transactions,
        accountId,
        userId,
        bankId,
        Transaction: this.TransactionModel,
        TransactionRule: this.RuleModel,
      });
    } catch (error: any) {
      logger.error('Error creating transactions:', error);
      throw error;
    }
  }

  // -------------------------
  // 3. Search transactions
  // -------------------------
  async getTransactions(match: any, page: number) {
    const limit = 20;
    const skip = (page - 1) * limit;

    const pipeline: PipelineStage[] = [{ $match: match }, { $sort: { transactionTimestamp: -1 } as const }, { $skip: skip }, { $limit: limit }];

    return this.model.aggregate(pipeline);
  }

  // -------------------------
  // 4. Get transactions of user (all)
  // -------------------------
  async getTransactionsOfUser(userId: string | Types.ObjectId) {
    const response = await this.model.find({ userId, Hidden: false });
    return response;
  }

  // -------------------------
  // 6. Recurring Payments
  // -------------------------
  async getRecurringPayments(userId: string | Types.ObjectId, isActive: boolean) {
    try {
      return await this.RecurringModel.find({ userId, isActive }).lean();
    } catch (error) {
      logger.error(`Error from getRecurringPayments: ${error}`);
      throw error;
    }
  }

  async updateRecurringPayment(recurringId: string | Types.ObjectId, userId: string | Types.ObjectId, data: Partial<IRecurringPayment>) {
    return await this.RecurringModel.findOneAndUpdate({ _id: recurringId, userId }, { $set: data }, { new: true, upsert: true });
  }

  async deleteRecurringPayment(recurringId: string | Types.ObjectId) {
    return this.RecurringModel.deleteOne({ _id: recurringId });
  }

  // -------------------------
  // 7. Grouped Transactions
  // -------------------------
  async getGroupedTransactions(userId: string | Types.ObjectId) {
    try {
      const response = await GroupedTransaction.find({ userId }).populate('transactions').sort({ count: -1 });
      return response;
    } catch (error) {
      logger.error(`Error from getGroupedTransactions: ${error}`);
      throw error;
    }
  }

  async categorizeGroupedTransaction(userId: string | Types.ObjectId, groupId: string | Types.ObjectId, category: string, subcategory: string, removedTransactions: string[]) {
    const group = await GroupedTransaction.findOne({ _id: groupId, userId });
    if (!group) return { message: 'Group not found' };

    const transactionIds = group.transactions.map((txn: any) => txn._id.toString());
    const filteredIds = transactionIds.filter((id: string) => !removedTransactions.includes(id));

    if (filteredIds.length > 0) {
      await Transaction.updateMany({ _id: { $in: filteredIds } }, { $set: { category, subcategory } });
    }

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
        category,
        subcategory,
        source: 'group',
      },
      { upsert: true }
    );

    await GroupedTransaction.deleteOne({ _id: groupId });
  }

  // -------------------------
  // 8. Pending Review Transactions
  // -------------------------
  async getPendingForReviewTransactions(userId: string | Types.ObjectId) {
    try {
      const response = await this.model.find({ userId, needsReview: true }).sort({ transactionTimestamp: -1 });
      return response;
    } catch (error) {
      logger.error(`Error from getPendingForReviewTransactions: ${error}`);
      throw error;
    }
  }

  async verifyPendingTransaction(userId: string | Types.ObjectId, transactionId: string | Types.ObjectId, isCorrect: boolean) {
    try {
      const transaction = await Transaction.findOne({ _id: transactionId, userId });
      if (!transaction) return { message: 'Transaction not found' };

      isCorrect = String(isCorrect).toLowerCase() === 'true';
      const narrationPattern = extractNarrationPattern(transaction.narration)?.toLowerCase();

      if (isCorrect) {
        transaction.needsReview = false;
        await transaction.save();

        await TransactionRule.findOneAndUpdate(
          { userId, narrationPattern, amount: transaction.amount },
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
      logger.error(`Error from verifyPendingTransaction: ${error}`);
      throw error;
    }
  }

  // -------------------------
  // 9. Monthly Transactions History
  // -------------------------
  async getMonthlyTransactionsHistory(userId: string | Types.ObjectId, type: string, page: number) {
    const limit = 20;
    const skip = (page - 1) * limit;

    let startDate: Date, endDate: Date;

    if (/^\d{4}$/.test(type)) {
      const y = parseInt(type, 10);
      startDate = new Date(Date.UTC(y, 0, 1, 18, 30, 0, 0));
      endDate = new Date(Date.UTC(y, 11, 31, 18, 29, 59, 999));
    } else if (/^\d{4}-\d{2}$/.test(type)) {
      const [year, month] = type.split('-');
      const y = parseInt(year, 10);
      const m = parseInt(month, 10) - 1;
      startDate = new Date(Date.UTC(y, m, 1, 18, 30, 0, 0));
      endDate = new Date(Date.UTC(y, m + 1, 0, 18, 29, 59, 999));
    } else {
      throw new Error("Invalid date format. Use 'YYYY' or 'YYYY-MM'.");
    }

    const transactions = await this.model
      .find({
        userId,
        Hidden: false,
        transactionTimestamp: { $gte: startDate, $lte: endDate },
      })
      .sort({ transactionTimestamp: -1 })
      .skip(skip)
      .limit(limit)
      .lean()
      ;

    const banks = await new this.BankRepo().getBank(userId);
    const txWithBank = await enrichTransactionWithBankDetails(transactions, banks);
    const txWithPredictions = await predictCategoriesForTransactions(txWithBank);

    return { transactions: txWithPredictions };
  }

  // -------------------------
  // 10. Day-wise Transactions Summary
  // -------------------------

  async getDayWiseTransactionsSummary(userId: string | Types.ObjectId) {
    const pipeline: PipelineStage[] = [
      {
        $match: {
          userId: new Types.ObjectId(userId as string),
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
            $sum: { $cond: [{ $eq: ['$type', 'CREDIT'] }, '$amount', 0] },
          },
          debitAmount: {
            $sum: { $cond: [{ $eq: ['$type', 'DEBIT'] }, '$amount', 0] },
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

    return this.model.aggregate(pipeline);
  }

  // -------------------------
  // 11. Get Transactions by Date
  // -------------------------
  async getTransactionsByDate(userId: string | Types.ObjectId, date: string) {
    const start = new Date(date);
    const end = new Date(date);
    end.setDate(start.getDate() + 1);

    const transactions = await this.model
      .find({
        userId,
        transactionTimestamp: { $gte: start, $lt: end },
      })
      .sort({ transactionTimestamp: -1 });

    const banks = await new this.BankRepo().getBank(userId);
    const txWithBank = await enrichTransactionWithBankDetails(transactions, banks);
    const txWithPredictions = await predictCategoriesForTransactions(txWithBank);

    return txWithPredictions;
  }

  // -------------------------
  // 12. Get Transactions by Category
  // -------------------------
  async getTransactionsByCategory(userId: string | Types.ObjectId, category: string) {
    const transactions = await this.model.find({ userId });
    const categoryTransactions = transactions.filter((transaction: any) => transaction.categorized_transactions?.some((cat: any) => cat.category === category));
    return categoryTransactions;
  }

  // -------------------------
  // 13. Monthly Categorization with Frequency & Drastic Changes
  // -------------------------
  async categorizeTransactions(userId: string | Types.ObjectId, startDate: Date, endDate: Date) {
    const userObjectId = new Types.ObjectId(userId as string);

    const currentData = await this.model.aggregate(buildMonthlyCategorizationPipeline(userObjectId, startDate, endDate));

    const prevStartDate = new Date(startDate);
    prevStartDate.setUTCMonth(prevStartDate.getUTCMonth() - 1);
    const prevEndDate = new Date(endDate);
    prevEndDate.setUTCMonth(prevEndDate.getUTCMonth() - 1);

    const prevData = await this.model.aggregate(buildMonthlyCategorizationPipeline(userObjectId, prevStartDate, prevEndDate));

    const prevMap = new Map(prevData.map((item: any) => [item.category.toLowerCase(), item]));

    const result = currentData
      .map((current: any) => {
        const categoryKey = current.category.toLowerCase();
        const previous = prevMap.get(categoryKey) || { total_debit: 0, total_credit: 0 };
        return {
          category: categoryKey,
          total_debit: current.total_debit,
          total_credit: current.total_credit,
          total_debit_percentage: calculatePercentageChange(current.total_debit, previous.total_debit),
          total_credit_percentage: calculatePercentageChange(current.total_credit, previous.total_credit),
          debit_diff: current.total_debit - previous.total_debit,
        };
      })
      .filter((item: any) => !(item.total_debit === 0 && item.total_credit > 0));

    const totalDebitThisMonth = result.reduce((sum: number, item: any) => sum + item.total_debit, 0);
    const totalCreditThisMonth = result.reduce((sum: number, item: any) => sum + item.total_credit, 0);

    const moreDrasticChange = [...result]
      .sort((a: any, b: any) => b.debit_diff - a.debit_diff)
      .slice(0, 4)
      .map(({ category, debit_diff }: any) => ({ category, debit_diff }));

    const frequentPayments = await this.model.aggregate(buildFrequencyAnalysisPipeline(userObjectId, startDate, endDate));
    // NEW ADDITIONS (THIS IS WHAT YOU WANT)
    const [mostSpentDay] = await this.model.aggregate(
      buildMostSpentDayPipeline(userObjectId, startDate, endDate)
    );

    const mostSpentCategory = await this.model.aggregate(
      buildMostSpentCategoriesPipeline(userObjectId, startDate, endDate)
    );
    //  WEEKLY TREND (NEW)
    const { weekStart, weekEnd } = getCurrentWeekRangeUTC();
    const { lastWeekStart, lastWeekEnd } = getLastWeekRangeUTC();

    const [currentWeekData] = await this.model.aggregate(
      buildWeeklyTotalSpendPipeline(userObjectId, weekStart, weekEnd)
    );

    const [lastWeekData] = await this.model.aggregate(
      buildWeeklyTotalSpendPipeline(userObjectId, lastWeekStart, lastWeekEnd)
    );

    const currentWeekSpend = currentWeekData?.totalSpend || 0;
    const lastWeekSpend = lastWeekData?.totalSpend || 0;

    const difference = currentWeekSpend - lastWeekSpend;

    const percentage =
      lastWeekSpend === 0
        ? 0
        : Math.abs(((difference / lastWeekSpend) * 100));

    const weeklyTrend = {
      lastWeekSpend,
      currentWeekSpend,
      difference,
      percentageChange: `${percentage.toFixed(2)}%`,
      trend:
        difference > 0
          ? 'increase'
          : difference < 0
            ? 'decrease'
            : 'no-change',

    };


    return {
      categorized: result,
      moreDrasticChange,
      frequentPayments,
      totalDebitThisMonth,
      totalCreditThisMonth,
      mostSpentDay: mostSpentDay || null,
      mostSpentCategory: mostSpentCategory || null,
      weeklyTrend
    };
  }

  // -------------------------
  // 15. Update a Transaction
  // -------------------------
  async updateTransaction(userId: string | Types.ObjectId, txId: string | Types.ObjectId, data: Partial<IBankTransaction>) {
    return await updateTransactionLogic({
      userId,
      txId,
      data,
      Transaction: this.TransactionModel,
      TransactionRule: this.RuleModel,
    });
  }

  // -------------------------
  // 16. Top Five Categories
  // -------------------------
  async getTopFiveCategories(userId: string | Types.ObjectId) {
    const pipeline: PipelineStage[] = [
      {
        $match: {
          userId: new Types.ObjectId(userId as string),
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
    return topCategories.map((item: any) => item.category);
  }

  // -------------------------
  // 17. Last Period Debit
  // -------------------------
  async getLastPeriodDebit(userId: string | Types.ObjectId, accountId: string | Types.ObjectId, startDate: Date, endDate: Date) {
    const pipeline = [
      {
        $match: {
          userId: new Types.ObjectId(userId as string),
          accountId: new Types.ObjectId(accountId as string),
          transactionTimestamp: { $gte: startDate, $lte: endDate },
          type: 'DEBIT',
        },
      },
      { $group: { _id: null, totalDebit: { $sum: '$amount' } } },
    ];

    return await this.model.aggregate(pipeline);
  }

  // -------------------------
  // 18. Budget Transactions (with groupBy)
  // -------------------------
  async getBudgetTransactions(userId: string | Types.ObjectId, startDate: Date, endDate: Date, categories: string[], groupBy: 'day' | 'week' | 'month') {
    return this.model.aggregate(buildBudgetPipeline(userId, startDate, endDate, categories, groupBy));
  }

  // -------------------------
  // 19. Category Spending (w/ subcategories)
  // -------------------------
  async getSpentAmounts(userId: string | Types.ObjectId, startDate: Date, endDate: Date, categories: string[]) {
    const pipeline = buildSpendingPipeline(new Types.ObjectId(userId as string), startDate, endDate, categories);

    return this.model.aggregate(pipeline);
  }

  // -------------------------
  // 20. Previous Transactions (for an account)
  // -------------------------
  async getPreviousTransactions(userId: string | Types.ObjectId, startDate: Date, accountId: string | Types.ObjectId) {
    try {
      const start = new Date(startDate);
      const end = new Date();

      const pipeline: PipelineStage[] = [
        {
          $match: {
            userId: new Types.ObjectId(userId as string),
            transactionTimestamp: { $gte: start, $lte: end },
            manualTransaction: false,
            accountId: new Types.ObjectId(accountId as string),
          },
        },

        // TypeScript now understands this is a valid Sort stage
        {
          $sort: { transactionTimestamp: -1 },
        },
      ];

      return this.model.aggregate(pipeline);
    } catch (error) {
      logger.error(`Error fetching previous transactions: ${error}`);
      throw error;
    }
  }

  // -------------------------
  // 21. Category-wise Spendings (with percentage)
  // -------------------------
  async categoryWiseSpendings(userId: string | Types.ObjectId, categoryNames: string[], startDate: Date, endDate: Date) {
    const result = await Transaction.aggregate([
      {
        $match: {
          userId: new Types.ObjectId(userId as string),
          type: 'DEBIT',
          category: { $in: categoryNames },
          transactionTimestamp: { $gte: startDate, $lte: endDate },
        },
      },
      { $group: { _id: '$category', totalSpending: { $sum: '$amount' } } },
      {
        $group: {
          _id: null,
          categories: { $push: { category: '$_id', spending: '$totalSpending' } },
          totalSpending: { $sum: '$totalSpending' },
        },
      },
      { $unwind: '$categories' },
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

  // -------------------------
  // 22. Graph Data - Timeline for specific account
  // -------------------------
  async getAllTransactionsByTimeLine(userId: string | Types.ObjectId, accountId: string | Types.ObjectId | null, startDate: Date, endDate: Date, groupBy: GroupBy = 'day') {
    return getTransactions(this.model, userId, startDate, endDate, groupBy, accountId);
  }

  // -------------------------
  // 23. Graph Data - Main graph (all accounts)
  // -------------------------
  async getAllTransactionsForMainGraph(userId: string | Types.ObjectId, startDate: Date, endDate: Date, groupBy: GroupBy = 'day') {
    return getTransactions(this.model, userId, startDate, endDate, groupBy);
  }

  // -------------------------
  // 24. Group Similar (Untagged)
  // -------------------------
  async groupSimilarTransactions(userId: string | Types.ObjectId) {
    const pipeline = groupSimilarTransactionsPipeline(new Types.ObjectId(userId as string));
    return this.model.aggregate(pipeline);
  }

  // -------------------------
  // 27. Top Three Transactions of Week
  // -------------------------
  async getTopThreeTransactionsOfWeek(userId: string | Types.ObjectId) {
    try {
      const now = new Date();
      const lastFriday = new Date(now);
      const day = now.getDay();
      const diffToLastFriday = day >= 5 ? day - 5 : day + 2;
      lastFriday.setDate(now.getDate() - diffToLastFriday);
      lastFriday.setHours(0, 0, 0, 0);

      const previousFriday = new Date(lastFriday);
      previousFriday.setDate(lastFriday.getDate() - 7);
      previousFriday.setHours(0, 0, 0, 0);

      const transactions = await this.model
        .find({
          userId,
          transactionTimestamp: { $gte: previousFriday, $lte: lastFriday },
          type: 'DEBIT',
          manualTransaction: false,
          isExcluded: false,
        })
        .sort({ amount: -1 })
        .limit(3)
        .populate('accountId', 'bankId');

      const banks = await new this.BankRepo().getBank(userId);
      const transactionsWithBankLogo = await enrichTransactionWithBankDetails(transactions, banks);

      return transactionsWithBankLogo;
    } catch (error) {
      throw error;
    }
  }

  // -------------------------
  // 28. Income and Category Spent
  // -------------------------
  async getIncomeAndCategorySpent(userId: string | Types.ObjectId) {
    try {
      const now = new Date();
      const startOfCurrentMonth = new Date(now.getFullYear(), now.getMonth(), 1);
      const startOfLastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);

      const results = await this.model.aggregate([
        {
          $match: {
            userId: new Types.ObjectId(userId as string),
            isExcluded: false,
            transactionTimestamp: { $gte: startOfLastMonth },
          },
        },
        {
          $facet: {
            income: [
              {
                $match: {
                  type: 'CREDIT',
                  transactionTimestamp: { $gte: startOfCurrentMonth },
                },
              },
              { $group: { _id: null, totalIncome: { $sum: '$amount' } } },
            ],
            categorySpending: [
              { $match: { type: 'DEBIT' } },
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
              { $project: { average: { $divide: [{ $sum: '$months.spent' }, 2] } } },
            ],
          },
        },
      ]);

      const income = results[0]?.income[0]?.totalIncome || 0;
      const categorySpendingRaw = results[0]?.categorySpending || [];

      const averageCategorySpendingOfTwoMonths: Record<string, number> = {};
      categorySpendingRaw.forEach((c: any) => {
        averageCategorySpendingOfTwoMonths[c._id] = c.average;
      });

      return { income, averageCategorySpendingOfTwoMonths };
    } catch (error) {
      throw error;
    }
  }

  // -------------------------
  // 29. Loan Eligibility Calculation
  // -------------------------
  async getLoanCalculation(data: { income: number; existingEmi: number; creditScore: number; loanType: string; expenses: number }) {
    return calculateLoanEligibilityTS(data);
  }

  // -------------------------
  // 30. Delete transactions
  // -------------------------
  async deleteTransactions(userId: string | Types.ObjectId, accountId?: string | Types.ObjectId) {
    try {
      const criteria: any = { userId };
      if (accountId) criteria.accountId = accountId;

      const result = await this.TransactionModel.deleteMany(criteria);
      return result.deletedCount ?? 0;
    } catch (error) {
      logger.error(`Error deleting transactions: ${error}`);
      throw error;
    }
  }

  async getTotals(baseMatch: any, start: Date, end: Date) {
    const match = {
      ...baseMatch,
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
  }
}


