import { Types, Model } from 'mongoose';

import { IBankTransaction, IRecurringPayment } from '@/types/bank';
import { ITransactionRule } from '@/models/transactions-automation/transactionRule';

import { buildSearchPipeline } from '@/pipelines/search.pipeline';
import { buildMonthlyCategorizationPipeline } from '@/pipelines/categorize-monthly.pipeline';
import { buildFrequencyAnalysisPipeline } from '@/pipelines/frequency-analysis.pipeline';
import { groupSimilarTransactionsPipeline } from '@/pipelines/group-similar.pipeline';
import { buildBudgetPipeline } from '@/pipelines/budget.pipeline';
import { buildSpendingPipeline } from '@/pipelines/spending.pipeline';

import { enrichWithBankDetails } from '@/helpers/enrich-bank.helper';
import { createTransactionsBulk } from '@/helpers/transaction-create.helper';
import { updateTransactionLogic } from '@/helpers/transaction-update.helper';
import { predictCategoriesForTransactions } from '@/helpers/predictions.helper';
import { calculateLoanEligibilityTS } from '@/helpers/loan-calculation.helper';

import { Transaction, TransactionRule, RecurringPayment } from '@/models';

import CrudRepository from '../crud-repository';
import logger from '@/utils/common/logger';
import FipRepository from './bank';
import extractNarrationPattern from '@/utils/helpers/extractNarrationPattern';

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
  // 2. Paginated get
  // -------------------------
  async getTransactions(userId: string | Types.ObjectId, page: number) {
    try {
      const limit = 20;
      const skip = (page - 1) * limit;

      const transactions = await this.model
        .find({
          userId,
          Hidden: false,
        })
        .sort({ transactionTimestamp: -1 })
        .skip(skip)
        .limit(limit)
        .populate('accountId', 'bankId');

      const banks = await new this.BankRepo().getBank(userId);

      const enriched = await enrichWithBankDetails(transactions, banks);

      const predicted = await predictCategoriesForTransactions(enriched);

      return predicted;
    } catch (error: any) {
      logger.error('Error fetching transactions:', error);
      throw error;
    }
  }

  // -------------------------
  // 3. Search transactions
  // -------------------------
  async getSearchedTransactions(params: {
    userId: string | Types.ObjectId;
    page: number;
    searchFilter?: any[];
    minAmount?: number;
    maxAmount?: number;
    startDate?: Date;
    endDate?: Date;
    accountId?: string;
    isCash?: boolean;
  }) {
    const { userId, page, searchFilter, minAmount, maxAmount, startDate, endDate, accountId, isCash } = params;

    try {
      const limit = 20;
      const skip = (page - 1) * limit;

      const pipeline = buildSearchPipeline({
        userId: new Types.ObjectId(userId),
        searchFilter,
        accountId: accountId ? new Types.ObjectId(accountId) : undefined,
        minAmount,
        maxAmount,
        startDate,
        endDate,
        isCash,
      });

      pipeline.push({ $skip: skip }, { $limit: limit });

      const transactions = await this.model.aggregate(pipeline);

      const banks = await new this.BankRepo().getBank(userId);
      const withBank = await enrichWithBankDetails(transactions, banks);
      const predicted = await predictCategoriesForTransactions(withBank);

      return { transactions: predicted };
    } catch (error) {
      logger.error('Error in getSearchedTransactions:', error);
      throw error;
    }
  }

  // -------------------------
  // 4. Monthly Categorization
  // -------------------------
  async getMonthlyCategorization(userId: string, startDate: Date, endDate: Date) {
    const userObj = new Types.ObjectId(userId);

    const pipeline = buildMonthlyCategorizationPipeline(userObj, startDate, endDate);

    return await this.model.aggregate(pipeline);
  }

  // -------------------------
  // 5. Frequency Analysis
  // -------------------------
  async getFrequentPayments(userId: string, start: Date, end: Date) {
    const pipeline = buildFrequencyAnalysisPipeline(new Types.ObjectId(userId), start, end);

    return this.model.aggregate(pipeline);
  }

  // -------------------------
  // 6. Group Similar (Untagged)
  // -------------------------
  async groupSimilarTransactions(userId: string) {
    const pipeline = groupSimilarTransactionsPipeline(new Types.ObjectId(userId));
    return this.model.aggregate(pipeline);
  }

  // -------------------------
  // 7. Budget pipeline
  // -------------------------
  async getBudgetData(userId: string, startDate: Date, endDate: Date, categories: string[], groupBy: 'monthly' | 'weekly' | 'yearly') {
    const pipeline = buildBudgetPipeline(new Types.ObjectId(userId), startDate, endDate, categories, groupBy);
    return this.model.aggregate(pipeline);
  }

  // -------------------------
  // 8. Category Spending (w/ subcategories)
  // -------------------------
  async getSpentAmounts(userId: string, startDate: Date, endDate: Date, categories: string[]) {
    const pipeline = buildSpendingPipeline(new Types.ObjectId(userId), startDate, endDate, categories);

    return this.model.aggregate(pipeline);
  }

  // -------------------------
  // 9. Hide transactions
  // -------------------------
  async getHiddenTransactions(userId: string) {
    const tx = await this.model
      .find({
        userId,
        Hidden: true,
      })
      .populate('accountId', 'bankId');

    const banks = await new this.BankRepo().getBank(userId);
    return enrichWithBankDetails(tx, banks);
  }

  // -------------------------
  // 10. Update a Transaction
  // -------------------------
  async updateTransaction(userId: string, txId: string, data: Partial<typeof Transaction>) {
    return await updateTransactionLogic({
      userId,
      txId,
      data,
      Transaction: this.TransactionModel,
      TransactionRule: this.RuleModel,
    });
  }

  // -------------------------
  // 11. Recurring Payments
  // -------------------------
  async getRecurringPayments(userId: string, isActive: boolean) {
    return await this.RecurringModel.find({ userId, isActive }).lean();
  }

  async updateRecurringPayment(recurringId: string, userId: string, data: Partial<IRecurringPayment>) {
    return await this.RecurringModel.findOneAndUpdate({ _id: recurringId, userId }, { $set: data }, { new: true });
  }

  async deleteRecurringPayment(recurringId: string) {
    return this.RecurringModel.deleteOne({ _id: recurringId });
  }

  // -------------------------
  // 12. Loan Eligibility
  // -------------------------
  async getLoanCalculation(data: { income: number; existingEmi: number; creditScore: number; loanType: string; expenses: number }) {
    return calculateLoanEligibilityTS(data);
  }

  // -------------------------
  // 13. Delete transactions
  // -------------------------
  async deleteTransactions(userId: string, accountId?: string) {
    const criteria: any = { userId };
    if (accountId) criteria.accountId = accountId;

    const result = await this.TransactionModel.deleteMany(criteria);
    return result.deletedCount ?? 0;
  }

  async verifyPendingTransaction(userId: string | Types.ObjectId, transactionId: string | Types.ObjectId, isCorrect: boolean) {
    try {
      const transaction = await Transaction.findOne({
        _id: transactionId,
        userId,
      });
      if (!transaction) return { message: 'Transaction not found' };

      isCorrect = String(isCorrect).toLowerCase() === 'true';
      const narrationPattern = extractNarrationPattern(transaction.narration)?.toLowerCase();

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
}
