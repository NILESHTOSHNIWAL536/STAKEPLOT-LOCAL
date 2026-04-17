/* eslint-disable @typescript-eslint/no-explicit-any */
/* services/bank-service.ts */

import mongoose, { Types } from 'mongoose';
import { StatusCodes } from 'http-status-codes';
import AppError from '../utils/errors/app-error';
import { FipRepository, AccountRepository, ProfileRepository, SummaryRepository, AutoTransactionRepository } from '@/repositories';
import redisClient from '../config/redis-config';
import logger from '@/utils/common/logger';
import { PendingTransaction, GroupedTransaction, Transaction } from '@/models';
import saveGroupedTransactions from '../utils/helpers/saveGroupedTransactions';
import detectRecurringPayments from '../utils/helpers/detect-recurring-payments';
import { generateDataKey } from '@/services/Encryption/generateDataKey';
import { getNextFetch, getNextMonthFetch } from '@/utils/helpers/get-next-fetch';
import getISTTimestamp from '@/utils/helpers/get-IST-timeStamp';
import bankLogos from '@/config/bankLogos';
import fetch from 'node-fetch'; // used for IFSC fetch; ensure node-fetch is installed
import { IBankTransaction } from '@/types/bank';
import { enrichTransactionWithBankDetails } from '@/helpers/enrich-bank.helper';
import { predictCategoriesForTransactions } from '@/helpers/predictions.helper';
import { startOfWeek, endOfWeek, subDays, startOfMonth, endOfMonth } from 'date-fns';
import buildMatch from '@/utils/helpers/buildMatch';
import { getMatchedKeywords } from '@/utils/helpers/transactionSearchFilter';
import BankTransaction from '@/models/transactions-automation/transaction';
import UserDailyMetrics from '@/models/transactions-automation/user-daily-metrics';
import { updateDailyMetrics } from '@/services/daily-metrics.service';

// Helper type for userId inputs
type UserIdLike = string | Types.ObjectId;
type GroupBy = 'day' | 'week' | 'month';

const autoTransactionRepo = new AutoTransactionRepository();

// -------------------------
// CREATE BANK DETAILS
// -------------------------
export async function createBankDetails(data: any, consentHandleId: string, userId: UserIdLike): Promise<any> {
  try {
    const { plaintextKey, ciphertextBlob } = await generateDataKey();

    const nextFetch = getNextFetch();
    const lastFetch = getISTTimestamp();
    logger.debug(`lastFetch from the createNewBank: ${lastFetch}`);
    logger.debug(`nextFetch from the createNewBank ${nextFetch}`);

    const bankData = {
      fipId: data.fipId,
      fipName: data.fipName,
      custId: data.custId,
      consentId: data.consentId,
      fiAccountInfo: data.fiAccountInfo,
      consentHandleId,
      userId,
    };

    const bank = await new FipRepository().createFipRecord(bankData, plaintextKey, ciphertextBlob);

    const fiObjects = data.fiObjects || [];

    for (const fiObject of fiObjects) {
      if (typeof fiObject === 'string') continue; // skip non-object entries

      const accountData: any = {
        type: fiObject.type,
        maskedAccNumber: fiObject.maskedAccNumber,
        version: fiObject.version,
        linkedAccRef: fiObject.linkedAccRef,
        schemaLocation: fiObject.schemaLocation,
        startDate: fiObject.Transactions?.startDate,
        endDate: fiObject.Transactions?.endDate,
        bankId: bank._id,
        nextFetch: new Date(nextFetch),
        lastFetch: new Date(lastFetch),
        fetchCount: 1,
        userId,
      };

      const account = await new AccountRepository().createAccount(accountData, plaintextKey, ciphertextBlob);
      const accountId = account._id;

      if (fiObject.Profile) {
        await new ProfileRepository().createProfile(
          {
            holder: { ...fiObject.Profile.Holders.Holder },
            accountId,
            type: fiObject.Profile.Holders.type,
            userId,
          },
          plaintextKey,
          ciphertextBlob
        );
      }

      if (fiObject.Summary) {
        await new SummaryRepository().createSummary(
          {
            data: { ...fiObject.Summary },
            accountId,
            userId,
          },
          plaintextKey,
          ciphertextBlob
        );
      }

      // Normalize pending txns (PendingTxns)
      const pendingData = Array.isArray(fiObject?.Summary?.PendingTxns) ? fiObject.Summary.PendingTxns : fiObject?.Summary?.PendingTxns ? [fiObject.Summary.PendingTxns] : [];

      if (pendingData.length > 0) {
        await Promise.all(
          pendingData.map((txn: any) =>
            PendingTransaction.create({
              ...txn,
              accountId,
              userId,
            })
          )
        );
      }

      // Transactions
      if (fiObject.Transactions?.Transaction) {
        await new AutoTransactionRepository().createTransaction(fiObject.Transactions.Transaction, accountId, userId, bank._id, data.fipId);

        // grouping and downstream jobs
        await saveGroupedTransactions(userId);
        await detectRecurringPayments(userId);
      }
    }

    // Clear cache
    const cacheKey = `banksWithAccountDetails:${userId}`;
    const clearedBanksCache = await redisClient.del(cacheKey);
    logger.debug(`cleared bank cached details: ${clearedBanksCache}`);
  } catch (error: any) {
    logger.error(`Error creating user details ${error}`);
    throw new AppError('Error creating user details', StatusCodes.INTERNAL_SERVER_ERROR);
  }
}

// -------------------------
// UPDATE BANK DETAILS
// -------------------------
export async function updateBankDetails(data: any, consentHandleId: string, userId: UserIdLike): Promise<any> {
  try {
    const { plaintextKey, ciphertextBlob } = await generateDataKey();

    const fipData = {
      fipId: data.fipId,
      fipName: data.fipName,
      custId: data.custId,
      consentId: data.consentId,
      fiAccountInfo: data.fiAccountInfo,
      consentHandleId,
      userId,
    };

    const existingBank = await new FipRepository().getBankByName(userId, data.fipId, consentHandleId);
    if (!existingBank) {
      throw new AppError('Bank not found', StatusCodes.NOT_FOUND);
    }

    const bank = await new FipRepository().updateFipRecord(existingBank._id, fipData, plaintextKey, ciphertextBlob);
    const getAccountLinkedsByBank = await new AccountRepository().getAccounts({ bankId: bank!._id });

    for (const fiObject of data.fiObjects || []) {
      if (typeof fiObject === 'string') continue;

      const matchedAccount = getAccountLinkedsByBank.find((acc: any) => acc.accounts?.linkedAccRef === fiObject.linkedAccRef);
      if (!matchedAccount) continue;

      const accountId = matchedAccount._id;
      let nextFetch: Date | string | number;
      const lastFetch = getISTTimestamp();

      if (matchedAccount.accounts.fetchCount === 4) {
        nextFetch = getNextMonthFetch();
      } else {
        nextFetch = getNextFetch();
      }

      const accountData: any = {
        type: fiObject.type,
        maskedAccNumber: fiObject.maskedAccNumber,
        version: fiObject.version,
        linkedAccRef: fiObject.linkedAccRef,
        schemaLocation: fiObject.schemaLocation,
        startDate: fiObject.Transactions?.startDate,
        endDate: fiObject.Transactions?.endDate,
        bankId: bank!._id,
        nextFetch: new Date(nextFetch),
        lastFetch: new Date(lastFetch),
        userId,
      };

      await new AccountRepository().updateAccount(accountId, accountData, plaintextKey, ciphertextBlob);

      if (fiObject.Profile) {
        await new ProfileRepository().updateProfile(
          { accountId },
          {
            holder: { ...fiObject.Profile.Holders.Holder },
            type: fiObject.Profile.Holders.type,
            userId,
          },
          plaintextKey,
          ciphertextBlob
        );
      }

      if (fiObject.Summary) {
        await new SummaryRepository().updateSummary(
          { accountId },
          {
            data: { ...fiObject.Summary },
            accountId,
            userId,
          },
          plaintextKey,
          ciphertextBlob
        );

        // Normalize PendingTxns (note: original code had different key names)
        const pendingData = Array.isArray(fiObject?.Summary?.PendingTxns) ? fiObject.Summary.PendingTxns : fiObject?.Summary?.PendingTxns ? [fiObject.Summary.PendingTxns] : [];

        if (pendingData.length > 0) {
          await Promise.all(
            pendingData.map((txn: any) =>
              PendingTransaction.create({
                ...txn,
                accountId,
                userId,
              })
            )
          );
        }
      }

      if (fiObject.Transactions?.Transaction) {
        await new AutoTransactionRepository().createTransaction(fiObject.Transactions.Transaction, accountId, userId, bank!._id, data.fipId);
        await saveGroupedTransactions(userId);
      }
    }

    const cacheKey = `banksWithAccountDetails:${userId}`;
    const clearedBanksCache = await redisClient.del(cacheKey);
    logger.debug(`cleared bank cached details: ${clearedBanksCache}`);
  } catch (error: any) {
    logger.error(`Error updating user details ${error}`);
    throw new AppError('Error updating user details', StatusCodes.INTERNAL_SERVER_ERROR);
  }
}

// -------------------------
// SIMPLE PASSTHROUGH HELPERS
// -------------------------
export async function getMap(userId: UserIdLike): Promise<any> {
  try {
    const response = await new AccountRepository().getMap(userId);
    return response;
  } catch (error: any) {
    logger.error(`Error from getBanksLinked: ${error}`);
    return { error: error.message || String(error) };
  }
}

export async function getUserDetails(userId: UserIdLike): Promise<any> {
  // Return structure: { Bank, profiles, summaries, accounts }
  try {
    const Bank = await new FipRepository().getBank(userId);
    const accounts = Bank && Bank[0] ? await new AccountRepository().getAccounts({ bankId: Bank[0]._id }) : [];

    const accountIds = accounts.map((acc: any) => acc._id);

    const [profiles, summaries] = await Promise.all([
      new ProfileRepository().getProfile({ accountIds }),
      new SummaryRepository().getSummary({ accountIds }),
      // transactions omitted as in original
    ]);

    return { Bank, profiles, summaries, accounts };
  } catch (error: any) {
    logger.error(`Error in getUserDetails: ${error}`);
    throw error;
  }
}

// -------------------------
// getBanksLinkedAndAccounts (with caching + IFSC fetch per account)
// -------------------------
export async function getBanksLinkedAndAccounts(userId: UserIdLike): Promise<any> {
  try {
    const cacheKey = `banksWithAccountDetails:${userId}`;

    const cachedData = await redisClient.get(cacheKey);
    if (cachedData) return JSON.parse(cachedData);

    const banks = await new FipRepository().getBank(userId);

    let accounts = await Promise.all(
      (banks || []).map(async (bank: any) => {
        const bankAccounts = await new AccountRepository().getAccounts({ bankId: bank._id });
        if (!bankAccounts || bankAccounts.length === 0) return '';

        const accountIds = bankAccounts.map((acc: any) => acc._id);

        const summaries = await new SummaryRepository().getSummary({ accountIds });
        const profiles = await new ProfileRepository().getProfile({ accountIds });

        const balanceMap = new Map(summaries.map((summary: any) => [String(summary.accountId), summary || null]));
        const profilesMap = new Map(profiles.map((p: any) => [String(p.accountId), p]));

        const bankLogo = bankLogos[bank.fipId] || 'https://cdn.finvu.in/finvulogos/bank_large_light.png';

        async function fetchAddress(ifscCode?: string) {
          if (!ifscCode) return {};
          try {
            const ifscResponse = await fetch(`https://ifsc.razorpay.com/${ifscCode}`);
            return await ifscResponse.json();
          } catch (ifscError: any) {
            console.error('Error fetching IFSC data:', ifscError?.message || ifscError);
            return {};
          }
        }

        const accountsForBank = await Promise.all(
          bankAccounts.map(async (acc: any) => {
            const data = balanceMap.get(String(acc._id))?.data || {};
            const ifscCode = data.ifscCode || data.ifsc;
            const branchAddress = ifscCode ? await fetchAddress(ifscCode) : {};

            return {
              accountId: acc._id,
              maskedAccNumber: acc.accounts?.maskedAccNumber,
              linkedAccRef: acc.accounts?.linkedAccRef,
              type: acc.accounts?.type,
              nextFetch: acc.accounts?.nextFetch,
              lastFetch: acc.accounts?.lastFetch,
              fetchCount: acc.accounts?.fetchCount,
              currentBalance: data?.currentBalance ?? null,
              ifscCode,
              branchAddress: branchAddress?.ADDRESS || null,
              profile: profilesMap.get(String(acc._id)) || null,
            };
          })
        );

        return {
          bankId: bank._id,
          userId: bank.userId,
          bankName: bank.fipName,
          bankLogo,
          fipId: bank.fipId,
          consentId: bank.consentId,
          sessionId: bank.sessionId,
          consendHandleId: bank.consentHandleId,
          custId: bank.custId,
          accounts: accountsForBank,
        };
      })
    );

    accounts = accounts.filter((account: any) => typeof account === 'object' && account !== null);
    await redisClient.setEx(cacheKey, 3600, JSON.stringify(accounts));
    return accounts;
  } catch (error: any) {
    logger.error(`❌ Error from getBanksLinkedAndAccounts: ${error}`);
    return { error: error.message || String(error) };
  }
}

/* =====================================================
   HELPER: PERCENTAGE CALCULATION
===================================================== */

export function calculatePercentages(
  credit: number,
  debit: number,
  outstanding: number
) {
  const total = credit + debit + outstanding;

  if (total === 0) {
    return {
      creditPercent: 0,
      debitPercent: 0,
      outstandingPercent: 0,
    };
  }

  return {
    creditPercent: Number(((credit / total) * 100).toFixed(2)),
    debitPercent: Number(((debit / total) * 100).toFixed(2)),
    outstandingPercent: Number(((outstanding / total) * 100).toFixed(2)),
  };
}


export async function getMonthlyAggregation({
  userId,
  bankId,
  accountIds,
  fromDate,
  toDate,
}: {
  userId: Types.ObjectId;
  bankId: Types.ObjectId;
  accountIds: Types.ObjectId[];
  fromDate: Date;
  toDate: Date;
}) {
  const [totals] = await UserDailyMetrics.aggregate([
    {
      $match: {
        userId,
        bankId,
        accountId: { $in: accountIds },
        sourceType: 'BANK',
        date: { $gte: fromDate, $lte: toDate },
      },
    },
    {
      $group: {
        _id: null,
        totalDebit: { $sum: '$totalDebit' },
        totalCredit: { $sum: '$totalCredit' },
      },
    },
  ]);

  const totalDebit = totals?.totalDebit || 0;
  const totalCredit = totals?.totalCredit || 0;

  return [
    { _id: { type: 'CREDIT', manual: false }, total: totalCredit },
    { _id: { type: 'DEBIT', manual: false }, total: totalDebit },
  ];
}


export async function getBankBalanceAndDebitSummary({
  userId,
  view,
  month,
  year,
}: {
  userId: Types.ObjectId;
  view: "monthly" | "yearly";
  month?: number;
  year: number;
}) {
  const banks = await new FipRepository().getBank(userId);

  const combined = {
    currentBalance: 0,
    credit: 0,
    debit: 0,
    outstanding: 0,
  };

  const now = new Date();
  const maxMonth =
    view === "yearly" && year === now.getFullYear()
      ? now.getMonth() + 1
      : 12;

  const bankResults = await Promise.all(
    banks.map(async (bank) => {
      const accounts = await new AccountRepository().getAccounts({
        bankId: bank._id,
      });

      if (!accounts.length) return null;

      const accountIds = accounts.map(a => a._id);

      // -------- CURRENT BALANCE
      const summaries = await new SummaryRepository().getSummary({
        accountIds,
      });

      const currentBalance = summaries.reduce(
        (sum, s) => sum + Number(s?.data?.currentBalance || 0),
        0
      );

      combined.currentBalance += currentBalance;

      // ================= MONTHLY =================
      if (view === "monthly") {
        const fromDate = new Date(year, month! - 1, 1, 0, 0, 0);
        const toDate = new Date(year, month!, 0, 23, 59, 59);

        const agg = await getMonthlyAggregation({
          userId,
          bankId: bank._id,
          accountIds,
          fromDate,
          toDate,
        });

        let credit = 0;
        let debit = 0;
        let manualCredit = 0;
        let manualDebit = 0;

        for (const r of agg) {
          if (r._id.type === "CREDIT") {
            credit += r.total;
            if (r._id.manual) manualCredit += r.total;
          }
          if (r._id.type === "DEBIT") {
            debit += r.total;
            if (r._id.manual) manualDebit += r.total;
          }
        }

        const outstanding =
          currentBalance + manualCredit - manualDebit;

        combined.credit += credit;
        combined.debit += debit;
        combined.outstanding += outstanding;

        return {
          bankId: bank._id,
          bankName: bank.fipName,
          fipId: bank.fipId,
          month,
          year,
          currentBalance,
          credit,
          debit,
          outstanding,
          percentages: calculatePercentages(
            credit,
            debit,
            outstanding
          ),
        };
      }

      // ================= YEARLY =================
      let lastBalance = currentBalance;
      const monthsData: any[] = [];

      let yearlyCredit = 0;
      let yearlyDebit = 0;
      let yearlyOutstanding = 0;

      for (let m = 0; m < maxMonth; m++) {
        const fromDate = new Date(year, m, 1, 0, 0, 0);
        const toDate = new Date(year, m + 1, 0, 23, 59, 59);

        const agg = await getMonthlyAggregation({
          userId,
          bankId: bank._id,
          accountIds,
          fromDate,
          toDate,
        });

        let credit = 0;
        let debit = 0;
        let manualCredit = 0;
        let manualDebit = 0;

        for (const r of agg) {
          if (r._id.type === "CREDIT") {
            credit += r.total;
            if (r._id.manual) manualCredit += r.total;
          }
          if (r._id.type === "DEBIT") {
            debit += r.total;
            if (r._id.manual) manualDebit += r.total;
          }
        }

        const outstanding =
          lastBalance + manualCredit - manualDebit;

        lastBalance = outstanding;

        yearlyCredit += credit;
        yearlyDebit += debit;
        yearlyOutstanding += outstanding;

        monthsData.push({
          month: m + 1,
          credit,
          debit,
          outstanding,
          percentages: calculatePercentages(
            credit,
            debit,
            outstanding
          ),
        });
      }

      combined.credit += yearlyCredit;
      combined.debit += yearlyDebit;
      combined.outstanding += yearlyOutstanding;

      return {
        bankId: bank._id,
        bankName: bank.fipName,
        fipId: bank.fipId,
        year,
        currentBalance,
        credit: yearlyCredit,
        debit: yearlyDebit,
        outstanding: yearlyOutstanding,
        percentages: calculatePercentages(
          yearlyCredit,
          yearlyDebit,
          yearlyOutstanding
        ),
        months: monthsData,
      };
    })
  );

  return {
    view,
    year,
    month: view === "monthly" ? month : undefined,
    combined: {
      ...combined,
      percentages: calculatePercentages(
        combined.credit,
        combined.debit,
        combined.outstanding
      ),
    },
    banks: bankResults.filter(Boolean),
  };
}


export async function getSearchedTransactions(params: any) {
  const keywords = params.search ? params.search.split(' ').filter(Boolean) : [];

  // Build shared match object ONCE
  const match = buildMatch({
    ...params,
    keywords,
  });

  // 1. Fetch paginated transactions
  const transactions = await autoTransactionRepo.getTransactions(match, params.page);

  // 2. Add bank data + category AI
  const banks = await new FipRepository().getBank(params.userId);
  const enriched = await enrichTransactionWithBankDetails(transactions, banks);
  const predicted = await predictCategoriesForTransactions(enriched);

  // 3. Totals (last week, current month)
  const now = new Date();
  const lastWeekStart = startOfWeek(subDays(now, 7), { weekStartsOn: 1 });
  const lastWeekEnd = endOfWeek(subDays(now, 7), { weekStartsOn: 1 });

  const monthStart = startOfMonth(now);
  const monthEnd = endOfMonth(now);

  const lastWeekTotals = await autoTransactionRepo.getTotals(match, lastWeekStart, lastWeekEnd);
  const currentMonthTotals = await autoTransactionRepo.getTotals(match, monthStart, monthEnd);

  // 4. Keyword suggestions (optional)
  const matchedKeywords = params.search ? await getMatchedKeywords(params.userId, params.search) : [];

  return {
    transactions: predicted,
    lastWeek: lastWeekTotals,
    lastMonth: currentMonthTotals,
    matchedKeywords,
  };
}

export async function getAllTransactionsOfUser(userId: UserIdLike): Promise<any> {
  try {
    return await autoTransactionRepo.getTransactionsOfUser(userId);
  } catch (error: any) {
    return error;
  }
}

export async function getGroupedTransactions(userId: UserIdLike): Promise<any> {
  try {
    return await autoTransactionRepo.getGroupedTransactions(userId);
  } catch (error: any) {
    logger.error(`error from getGroupedTransactions, bank-service: ${error}`);
    return error;
  }
}

export async function categorizeGroupedTransaction(
  userId: UserIdLike,
  groupId: string | Types.ObjectId,
  category: string,
  subcategory: string,
  removedTransactions: any[]
): Promise<any> {
  try {
    const response = await autoTransactionRepo.categorizeGroupedTransaction(userId, groupId, category, subcategory, removedTransactions);

    const cacheKey = `categorizedTransactions:${userId}`;
    const deleteCategorizedTransactions = await redisClient.del(cacheKey);
    logger.debug(`Deleted cache for key: ${cacheKey}, result: ${deleteCategorizedTransactions}`);

    return response;
  } catch (error: any) {
    logger.error(`error from categorizedGroupedTransaction, bank-service ${error}`);
    return error;
  }
}

export async function getPendingForReviewTransactions(userId: UserIdLike): Promise<any> {
  try {
    return await new AutoTransactionRepository().getPendingForReviewTransactions(userId);
  } catch (error: any) {
    logger.debug(`error from getPendingForReviewTransactions: ${error}`);
    return error;
  }
}

export async function verifyPendingTransaction(userId: UserIdLike, transactionId: string | Types.ObjectId, isCorrect: boolean): Promise<any> {
  try {
    return await new AutoTransactionRepository().verifyPendingTransaction(userId, transactionId, isCorrect);
  } catch (error: any) {
    logger.debug(`error from verifyPendingTransaction ${error}`);
    return error;
  }
}

export async function getMonthlyTransactionsHistory(userId: UserIdLike, type: string, page: number): Promise<any> {
  try {
    return await new AutoTransactionRepository().getMonthlyTransactionsHistory(userId, type, page);
  } catch (error: any) {
    return error;
  }
}

// categorizeTransactions (week + month)
export async function categorizeTransactions(userId: UserIdLike): Promise<any> {
  try {
    const startDate = new Date();
    startDate.setUTCDate(1);
    startDate.setUTCHours(0, 0, 0, 0);

    const endDate = new Date(Date.UTC(startDate.getUTCFullYear(), startDate.getUTCMonth() + 1, 0, 23, 59, 59, 999));

    const now = new Date();
    const currentDay = now.getUTCDay();
    const daysSinceFriday = (currentDay + 2) % 7;
    const weekStartDate = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() - daysSinceFriday, 0, 0, 0, 0));
    const weekEndDate = now;

    const categorizedMonth = await new AutoTransactionRepository().categorizeTransactions(userId, startDate, endDate);
    const categorizedWeek = await new AutoTransactionRepository().categorizeTransactions(userId, weekStartDate, weekEndDate);

    return {
      week: categorizedWeek,
      ...categorizedMonth,
    };
  } catch (error: any) {
    return error;
  }
}

export async function createTransaction(userId: UserIdLike, data: IBankTransaction | IBankTransaction[]): Promise<any> {
  try {
    const response = await new AutoTransactionRepository().createTransaction(data as any, null, userId, null);

    await redisClient.del(`all-budgets-${userId}`);
    await redisClient.del(`banksWithAccountDetails:${userId}`);

    return response;
  } catch (error: any) {
    return error;
  }
}

export async function getTopFiveCategories(userId: UserIdLike): Promise<any> {
  try {
    return await new AutoTransactionRepository().getTopFiveCategories(userId);
  } catch (error: any) {
    return error;
  }
}

export async function getAllTransactionsByTimeLine(userId: UserIdLike, accountId: string | Types.ObjectId | null, startDate: Date, endDate: Date, groupBy: GroupBy): Promise<any> {
  try {
    return await new AutoTransactionRepository().getAllTransactionsByTimeLine(userId, accountId, startDate, endDate, groupBy);
  } catch (error: any) {
    return error;
  }
}

export async function getAllTransactionsForMainGraph(userId: UserIdLike, startDate: Date, endDate: Date, groupBy: GroupBy): Promise<any> {
  try {
    return await new AutoTransactionRepository().getAllTransactionsForMainGraph(userId, startDate, endDate, groupBy);
  } catch (error: any) {
    return error;
  }
}

// Recurring payments
export async function getRecurringPayments(userId: UserIdLike, type: boolean): Promise<any> {
  try {
    return await new AutoTransactionRepository().getRecurringPayments(userId, type);
  } catch (error: any) {
    logger.debug(`error from the bank-service getRecurringPayments: ${error}`);
    return error;
  }
}

export async function updateRecurringPayment(recurringPaymentId: string | Types.ObjectId, userId: UserIdLike, data: any): Promise<any> {
  return await new AutoTransactionRepository().updateRecurringPayment(recurringPaymentId, userId, data);
}

export async function deleteRecurringPayment(recurringPaymentId: string | Types.ObjectId): Promise<any> {
  return await new AutoTransactionRepository().deleteRecurringPayment(recurringPaymentId);
}

// updateTransaction (handles hidden cache clear + downstream messages)
export async function updateTransaction(updateData: any, userId: UserIdLike, transactionId: string): Promise<any> {
  try {
    if ('Hidden' in updateData) {
      const cacheKey = `hiddenTransactions:${userId}`;
      await redisClient.del(cacheKey);
    }

    const ObjectId = new mongoose.Types.ObjectId(transactionId);
    const existing = await Transaction.findOne({ _id: ObjectId, userId }).select('transactionTimestamp manualTransaction bankId accountId').lean();
    const response = await new AutoTransactionRepository().updateTransaction(userId, ObjectId, updateData);
    if (response?.data) {
      const metricsTxs: any[] = [response.data];
      const oldTimestamp = existing?.transactionTimestamp ? new Date(existing.transactionTimestamp) : null;
      const newTimestamp = response?.data?.transactionTimestamp ? new Date(response.data.transactionTimestamp) : null;
      if (oldTimestamp && newTimestamp) {
        const oldDay = oldTimestamp.toISOString().slice(0, 10);
        const newDay = newTimestamp.toISOString().slice(0, 10);
        if (oldDay !== newDay) {
          metricsTxs.push({
            transactionTimestamp: oldTimestamp,
            manualTransaction: existing?.manualTransaction,
            bankId: existing?.bankId || null,
            accountId: existing?.accountId || null,
          });
        }
      }
      await updateDailyMetrics(metricsTxs, userId);
    }

    return response;
  } catch (error: any) {
    return error;
  }
}

// last period debit
export async function getLastPeriodDebit(userId: UserIdLike, accountId: string | Types.ObjectId, startDate: Date, endDate: Date): Promise<any> {
  try {
    return await new AutoTransactionRepository().getLastPeriodDebit(userId, accountId, startDate, endDate);
  } catch (error: any) {
    return error;
  }
}

// categoryWiseSpendings
export async function categoryWiseSpendings(userId: UserIdLike, categoryNames: string[], startDate: Date, endDate: Date): Promise<any> {
  try {
    return await new AutoTransactionRepository().categoryWiseSpendings(userId, categoryNames, startDate, endDate);
  } catch (error: any) {
    return error;
  }
}

export async function getDayWiseTransactionsSummary(userId: UserIdLike): Promise<any> {
  try {
    return await new AutoTransactionRepository().getDayWiseTransactionsSummary(userId);
  } catch (error: any) {
    return error;
  }
}

export async function getTransactionsByDate(userId: UserIdLike, date: string): Promise<any> {
  try {
    return await new AutoTransactionRepository().getTransactionsByDate(userId, date);
  } catch (error: any) {
    return error;
  }
}

// Budget related
export async function getBudgetTransactions(userId: UserIdLike, startDate: Date, endDate: Date, categories: string[], groupBy: GroupBy): Promise<any> {
  try {
    return await new AutoTransactionRepository().getBudgetTransactions(userId, startDate, endDate, categories, groupBy);
  } catch (error: any) {
    return error;
  }
}

export async function getBudgetSpents(userId: UserIdLike, startDate: Date, endDate: Date, categories: string[]): Promise<any> {
  try {
    return await new AutoTransactionRepository().getSpentAmounts(userId, startDate, endDate, categories);
  } catch (error: any) {
    return error;
  }
}

// getPreviousTransactions (includes IFSC fetch)
export async function getPreviousTransactions(userId: UserIdLike, date: Date, accountId: string | Types.ObjectId): Promise<any> {
  try {
    const response = await new AutoTransactionRepository().getPreviousTransactions(userId, date, accountId);
    const accountIds = [accountId];
    const summary = await new SummaryRepository().getSummary({ accountIds });
    const profile = await new ProfileRepository().getProfile({ accountIds });
    const account = await new AccountRepository().getAccountById(accountId);

    let ifscData: any = {};
    const ifscCode = summary && summary[0] && (summary[0].data.ifscCode || summary[0].data.ifsc);
    try {
      if (ifscCode) {
        const ifscResponse = await fetch(`https://ifsc.razorpay.com/${ifscCode}`, {
          method: 'GET',
        });
        ifscData = await ifscResponse.json();
      }
    } catch (ifscError: any) {
      console.error('Error fetching IFSC data:', ifscError?.message || ifscError);
    }

    const overData = {
      transactions: response,
      profile,
      summary,
      account,
      bankAddress: ifscData.ADDRESS || '',
      bankName: ifscData.BANK || '',
    };

    return overData;
  } catch (error: any) {
    console.error('Error in getPreviousTransactions:', error);
    return error;
  }
}

export async function getTopThreeTransactionsOfWeek(userId: UserIdLike): Promise<any> {
  return await new AutoTransactionRepository().getTopThreeTransactionsOfWeek(userId);
}

export async function getIncomeAndCategorySpent(userId: UserIdLike): Promise<any> {
  return await new AutoTransactionRepository().getIncomeAndCategorySpent(userId);
}

export async function getLoanCalculation(data: any): Promise<any> {
  return await new AutoTransactionRepository().getLoanCalculation(data);
}

// -------------------------
// DELETE BANK / ACCOUNT
// -------------------------
export async function deleteBankAccount(userId: UserIdLike, bankId: string | Types.ObjectId, accountId: string | Types.ObjectId): Promise<any> {
  try {
    const objectBankId = new mongoose.Types.ObjectId(String(bankId));
    const objectAccountId = new mongoose.Types.ObjectId(String(accountId));

    const deleteBank = await new FipRepository().deleteBank(userId, objectBankId);
    const deleteAccount = await new AccountRepository().deleteAccount(userId, objectAccountId);
    const deleteProfile = await new ProfileRepository().deleteProfile(userId, objectAccountId);
    const deleteSummary = await new SummaryRepository().deleteSummary(userId, objectAccountId);
    const deleteTransactions = await new AutoTransactionRepository().deleteTransactions(userId, objectAccountId);

    const cacheKey = `banksWithAccountDetails:${userId}`;
    const deleteBanksWithAccountDetails = await redisClient.del(cacheKey);
    logger.debug(`Deleted cache for key: ${cacheKey}, result: ${deleteBanksWithAccountDetails}`);

    await GroupedTransaction.deleteMany({ userId: new mongoose.Types.ObjectId(String(userId)) });

    await saveGroupedTransactions(userId);

    return { deleteBank, deleteAccount, deleteProfile, deleteSummary, deleteTransactions };
  } catch (error: any) {
    return error;
  }
}

export async function deleteWholeBankData(userId: UserIdLike): Promise<any> {
  try {
    const deleteBank = await new FipRepository().deleteBank(userId);
    const deleteAccount = await new AccountRepository().deleteAccount(userId);
    const deleteProfile = await new ProfileRepository().deleteProfile(userId);
    const deleteSummary = await new SummaryRepository().deleteSummary(userId);
    const deleteTransactions = await new AutoTransactionRepository().deleteTransactions(userId);

    return { deleteBank, deleteAccount, deleteProfile, deleteSummary, deleteTransactions };
  } catch (error: any) {
    return error;
  }
}

// -------------------------
// getUserSpending (last two months)
// -------------------------
export async function getUserSpending(userId: UserIdLike): Promise<any> {
  try {
    const currentDate = new Date();
    const months: { month: number; year: number; daysInMonth: number }[] = [];

    for (let i = 1; i <= 2; i++) {
      const date = new Date(currentDate);
      date.setMonth(currentDate.getMonth() - i);
      date.setDate(1);
      date.setHours(0, 0, 0, 0);
      months.push({
        month: date.getMonth() + 1,
        year: date.getFullYear(),
        daysInMonth: new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate(),
      });
    }

    const startDate = new Date(months[1].year, months[1].month - 1, 1);
    const endDate = new Date(months[0].year, months[0].month, 0);
    endDate.setHours(23, 59, 59, 999);

    const transactionData = await UserDailyMetrics.aggregate([
      {
        $match: {
          userId: new mongoose.Types.ObjectId(String(userId)),
          date: {
            $gte: startDate,
            $lte: endDate,
          },
        },
      },
      {
        $group: {
          _id: {
            month: { $month: '$date' },
            year: { $year: '$date' },
            day: { $dayOfMonth: '$date' },
          },
          total: { $sum: '$totalDebit' },
        },
      },
    ]);

    const monthNames = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    const formattedResult: any = {
      month1Name: '',
      month1Avg: '0.00',
      month1DailySums: [],
      month2Name: '',
      month2Avg: '0.00',
      month2DailySums: [],
    };

    months.forEach((monthInfo, index) => {
      const { month, year, daysInMonth } = monthInfo;
      const monthData = (transactionData || []).filter((data: any) => data._id.month === month && data._id.year === year);

      const dailySums = Array.from({ length: daysInMonth }, (_, i) => {
        const day = i + 1;
        const transaction = monthData.find((data: any) => data._id.day === day);
        return {
          day,
          amount: transaction ? transaction.total : 0,
        };
      });

      const monthTotal = dailySums.reduce((sum, day) => sum + day.amount, 0);
      const monthAvg = daysInMonth > 0 ? monthTotal / daysInMonth : 0;

      const formattedDailySums = dailySums.map((d) => ({
        day: d.day,
        amount: d.amount.toLocaleString('en-US', {
          minimumFractionDigits: 2,
          maximumFractionDigits: 2,
        }),
      }));

      if (index === 0) {
        formattedResult.month1Name = monthNames[month];
        formattedResult.month1Avg = monthAvg.toLocaleString('en-US', {
          minimumFractionDigits: 2,
          maximumFractionDigits: 2,
        });
        formattedResult.month1DailySums = formattedDailySums;
      } else {
        formattedResult.month2Name = monthNames[month];
        formattedResult.month2Avg = monthAvg.toLocaleString('en-US', {
          minimumFractionDigits: 2,
          maximumFractionDigits: 2,
        });
        formattedResult.month2DailySums = formattedDailySums;
      }
    });

    return formattedResult;
  } catch (error: any) {
    console.error('Error fetching user spending:', error);
    throw error;
  }
}

// -------------------------
// EXPORTS
// -------------------------
export default {
  createBankDetails,
  updateBankDetails,
  getUserDetails,
  categorizeTransactions,
  getAllTransactionsByTimeLine,
  updateTransaction,
  getGroupedTransactions,
  categorizeGroupedTransaction,
  getPendingForReviewTransactions,
  verifyPendingTransaction,
  getBudgetTransactions,
  getAllTransactionsOfUser,
  getBanksLinkedAndAccounts,
  getMonthlyTransactionsHistory,
  getAllTransactionsForMainGraph,
  getLastPeriodDebit,
  getPreviousTransactions,
  categoryWiseSpendings,
  getMap,
  getSearchedTransactions,
  deleteBankAccount,
  deleteWholeBankData,
  getRecurringPayments,
  updateRecurringPayment,
  deleteRecurringPayment,
  getDayWiseTransactionsSummary,
  getTransactionsByDate,
  getTopThreeTransactionsOfWeek,
  getUserSpending,
  getIncomeAndCategorySpent,
  getLoanCalculation,
  getTopFiveCategories,
  getBudgetSpents,
  createTransaction,
};
