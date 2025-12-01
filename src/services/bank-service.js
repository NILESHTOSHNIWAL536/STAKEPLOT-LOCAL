const { StatusCodes } = require('http-status-codes');
const AppError = require('../utils/errors/app-error');
const { FipRepository, AccountRepository, ProfileRespository, SummaryRepository, AutoTransactionRepository } = require('../respositories');
const redisClient = require('../config/redis-config');
const logger = require('../utils/common/logger');
const { updateExistingAccounts, createNewBankAccount } = require('../utils/helpers/update-existing-accounts');
const { PendingTransaction } = require('../models');
const headsUpMessages = require('../utils/common/headsup-messages');
const moneyMapMessages = require('../utils/common/money-map');
const saveGroupedTransactions = require('../utils/helpers/saveGroupedTransactions');
const { HeadsUp, MoneyMap, GroupedTransaction, Transaction } = require('../models/index');
const detectRecurringPayments = require('../utils/helpers/detect-recurring-payments');
const { generateDataKey } = require('../services/Encryption/generateDataKey');
const { getNextFetch, getNextMonthFetch } = require('../utils/helpers/get-next-fetch');
const getISTTimestamp = require('../utils/helpers/get-IST-timeStamp');
const bankLogos = require('../config/bankLogos');
const mongoose = require('mongoose');

async function createBankDetails(data, consentHandleId, userId) {
  try {
    // Generate plaintextKey and ciphertextBlob
    const { plaintextKey, ciphertextBlob } = await generateDataKey();

    // This function will fetch the next upcoming monday and sets it to the nextFetch
    const nextFetch = getNextFetch();
    const lastFetch = getISTTimestamp();
    logger.debug(`lastFetch from the createNewBank: ${lastFetch}`);
    logger.debug(`nextFetch from the createNewBank ${nextFetch}`);

    // Creating new BANK (FIP) record
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

    // Create new ACCOUNT(s) record(s), profile(s), summary(s) and transactions
    const fiObjects = data.fiObjects;

    for (const fiObject of fiObjects) {
      if (typeof fiObject === 'string') continue; // skip string values

      // Create account record
      const accountData = {
        type: fiObject.type,
        maskedAccNumber: fiObject.maskedAccNumber,
        version: fiObject.version,
        linkedAccRef: fiObject.linkedAccRef,
        schemaLocation: fiObject.schemaLocation,
        startDate: fiObject.Transactions.startDate,
        endDate: fiObject.Transactions.endDate,
        bankId: bank._id,
        nextFetch: new Date(nextFetch),
        lastFetch: new Date(lastFetch),
        fetchCount: 1,
        userId,
      };

      const account = await new AccountRepository().createAccount(accountData, plaintextKey, ciphertextBlob);

      if (fiObject.Profile) {
        // Create profile, summary and transactions
        await new ProfileRespository().createProfile(
          {
            holder: { ...fiObject.Profile.Holders.Holder },
            accountId: account._id,
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
            accountId: account._id,
            userId,
          },
          plaintextKey,
          ciphertextBlob
        );
      }

      // Create pending transactions
      // Normalize pending data into array
      const pendingData = Array.isArray(fiObject?.Summary?.PendingTxns) ? fiObject.Summary.PendingTxns : fiObject?.Summary?.PendingTxns ? [fiObject.Summary.PendingTxns] : [];

      // Save each pending transaction
      await Promise.all(
        pendingData.map((txn) =>
          PendingTransaction.create({
            ...txn,
            accountId: account._id,
            userId,
          })
        )
      );

      // Store transactions if present
      if (fiObject.Transactions) {
        await new AutoTransactionRepository().createTransaction(fiObject.Transactions.Transaction, account._id, userId, bank._id);

        // grouping the transactions function
        await saveGroupedTransactions(userId);

        // call the grouping, money-map messages
        await headsUpMessages(userId);
        await moneyMapMessages(userId);

        // call the funtion to get recurring payments and store them in DB
        await detectRecurringPayments(userId);
      }
    }

    // When a new bank is added, clear the cache
    const cacheKey = `banksWithAccountDetails:${userId}`;
    const clearedBanksCache = await redisClient.del(cacheKey);
    logger.debug(`cleared bank cached details: ${clearedBanksCache}`);
  } catch (error) {
    logger.error(`Error creating user details ${error}`);
    throw new AppError('Error creating user details', StatusCodes.INTERNAL_SERVER_ERROR);
  }
}

async function updateBankDetails(data, consentHandleId, userId) {
  try {
    // Generate new encryption key for updates
    const { plaintextKey, ciphertextBlob } = await generateDataKey();

    // Update FIP record
    const fipData = {
      fipId: data.fipId,
      fipName: data.fipName,
      custId: data.custId,
      consentId: data.consentId,
      fiAccountInfo: data.fiAccountInfo,
      consentHandleId,
      userId,
    };

    const existingBank = await new FipRepository().getbankByName(userId, data.fipId, consentHandleId);
    const bank = await new FipRepository().updateFipRecord(existingBank._id, fipData, plaintextKey, ciphertextBlob);

    const getAccountLinkedsByBank = await new AccountRepository().getAccounts({ bankId: bank._id });

    // Update each ACCOUNT(s) record(s), profile(s), summary(s) and transactions
    for (const fiObject of data.fiObjects) {
      if (typeof fiObject === 'string') continue;
      const matchedAccount = getAccountLinkedsByBank.find((acc) => acc.accounts.linkedAccRef === fiObject.linkedAccRef);

      // If matched account found, update it
      let nextFetch;
      const lastFetch = getISTTimestamp();
      if (matchedAccount && matchedAccount.fetchCount == 4) {
        nextFetch = getNextMonthFetch();
      } else {
        nextFetch = getNextFetch();
      }

      const accountData = {
        type: fiObject.type,
        maskedAccNumber: fiObject.maskedAccNumber,
        version: fiObject.version,
        linkedAccRef: fiObject.linkedAccRef,
        schemaLocation: fiObject.schemaLocation,
        startDate: fiObject.Transactions.startDate,
        endDate: fiObject.Transactions.endDate,
        bankId: bank._id,
        nextFetch: new Date(nextFetch),
        lastFetch: new Date(lastFetch),
        userId,
      };

      await new AccountRepository().updateAccount(matchedAccount._id, accountData, plaintextKey, ciphertextBlob);

      // Update profile if present
      if (fiObject.Profile) {
        await new ProfileRespository().updateProfile(
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

      // Update summary if present
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

        try {
          // Normalize pending data into array
          const pendingData = Array.isArray(fiObject?.Summary?.Pending) ? fiObject.Summary.Pending : fiObject?.Summary?.Pending ? [fiObject.Summary.Pending] : [];

          // Save each pending transaction
          await Promise.all(
            pendingData.map((txn) =>
              PendingTransaction.create({
                ...txn,
                accountId: account._id,
                userId,
              })
            )
          );
        } catch (e) {}
      }

      // Update transactions - assuming we want to append new transactions
      if (fiObject.Transactions && fiObject.Transactions.Transaction) {
        const newTransactions = fiObject.Transactions.Transaction;
        await new AutoTransactionRepository().createTransaction(newTransactions, accountId, userId, fip._id);

        // grouping the transactions function
        await saveGroupedTransactions(userId);

        // call the grouping, money-map messages
        await headsUpMessages(userId);
        await moneyMapMessages(userId);
      }
    }

    // When a bank is updated, clear the cache
    const cacheKey = `banksWithAccountDetails:${userId}`;
    const clearedBanksCache = await redisClient.del(cacheKey);
    logger.debug(`cleared bank cached details: ${clearedBanksCache}`);
  } catch (error) {
    logger.error(`Error updating user details ${error}`);
    throw new AppError('Error updating user details', StatusCodes.INTERNAL_SERVER_ERROR);
  }
}

async function getMap(userId) {
  try {
    const response = await new AccountRepository().getMap(userId);
    return response;
  } catch (error) {
    logger.error(`Error from getBanksLinked: ${error}`);
    return { error: error.message };
  }
}

async function getUserDetails(userId) {
  // Fetch Bank
  const Bank = await new FipRepository().getBank(userId);
  // Fetch accounts
  const accounts = await new AccountRepository().getAccounts({ bankId: Bank[0]._id });

  // Extract account IDs
  const accountIds = accounts.map((acc) => acc._id);

  // Fetch profiles, summaries, and transactions in parallel
  const [profiles, summaries] = await Promise.all([
    new ProfileRespository().getProfile({ accountIds }),
    new SummaryRepository().getSummary({ accountIds }),
    // new AutoTransactionRepository().getTransactions({ accountIds })
  ]);

  const response = {
    Bank,
    profiles,
    summaries,
    accounts,
  };
  return response;
}

async function getBanksLinkedAndAccounts(userId) {
  try {
    const cacheKey = `banksWithAccountDetails:${userId}`;

    // Step 1: Check Redis Cache
    const cachedData = await redisClient.get(cacheKey);
    if (cachedData) return JSON.parse(cachedData);

    // Step 2: Fetch data from database
    const banks = await new FipRepository().getBank(userId);

    let accounts = await Promise.all(
      banks.map(async (bank) => {
        const bankAccounts = await new AccountRepository().getAccounts({ bankId: bank._id });
        if (!bankAccounts || bankAccounts.length === 0) {
          return '';
        }

        const accountIds = bankAccounts.map((acc) => acc._id);

        const summaries = await new SummaryRepository().getSummary({ accountIds });
        const profiles = await new ProfileRespository().getProfile({ accountIds });

        const balanceMap = new Map(summaries.map((summary) => [summary.accountId.toString(), summary || null]));

        const profilesMap = new Map(profiles.map((p) => [p.accountId.toString(), p]));

        // Find the respective bank logo
        const bankLogo = bankLogos[bank.fipId] || 'https://cdn.finvu.in/finvulogos/bank_large_light.png';

        async function fetchAddress(ifscCode) {
          try {
            const ifscResponse = await fetch(`https://ifsc.razorpay.com/${ifscCode}`);
            return await ifscResponse.json();
          } catch (ifscError) {
            console.error('Error fetching IFSC data:', ifscError.message);
            return {};
          }
        }

        // resolve all accounts for this bank
        const accountsForBank = await Promise.all(
          bankAccounts.map(async (acc) => {
            const data = balanceMap.get(acc._id.toString())?.data || {};
            const ifscCode = data.ifscCode || data.ifsc;
            const branchAddress = ifscCode ? await fetchAddress(ifscCode) : {};

            return {
              accountId: acc._id,
              maskedAccNumber: acc.accounts.maskedAccNumber,
              linkedAccRef: acc.accounts.linkedAccRef,
              type: acc.accounts.type,
              nextFetch: acc.accounts.nextFetch,
              lastFetch: acc.accounts.lastFetch,
              fetchCount: acc.accounts.fetchCount,
              currentBalance: data?.currentBalance || null,
              ifscCode: ifscCode,
              branchAddress: branchAddress?.ADDRESS || null,
              profile: profilesMap.get(acc._id.toString()) || null,
            };
          })
        );

        return {
          bankId: bank._id,
          userId: bank.userId,
          bankName: bank.fipName,
          bankLogo: bankLogo,
          fipId: bank.fipId,
          consentId: bank.consentId,
          sessionId: bank.sessionId,
          consendHandleId: bank.consentHandleId,
          custId: bank.custId,
          accounts: accountsForBank,
        };
      })
    );

    accounts = accounts.filter((account) => typeof account === 'object' && account !== null);
    // Step 3: Store result in Redis (cache for 1 hour)
    await redisClient.setEx(cacheKey, 3600, JSON.stringify(accounts));

    return accounts;
  } catch (error) {
    logger.error(`Error from getBanksLinkedAndAccounts: ${error}`);
    return { error: error.message };
  }
}

async function getAllTransactions(userId, page) {
  const response = await new AutoTransactionRepository().getTransactions(userId, page);
  return response;
}

async function getSearchedTransactions(userId, page, search, isBankAccount, query) {
  try {
    const response = await new AutoTransactionRepository().getSearchedTransactions(userId, page, search, isBankAccount, query);
    return response;
  } catch (error) {
    return error;
  }
}

async function getAllTransactionsOfUser(userId) {
  try {
    const response = await new AutoTransactionRepository().getTransactionsOfUser(userId);
    return response;
  } catch (error) {
    return error;
  }
}

async function getAllTransactionsForAccount(userId, accountId, page) {
  try {
    const response = await new AutoTransactionRepository().getTransactionsForAccount(userId, accountId, page);
    return response;
  } catch (Error) {
    return Error;
  }
}

async function getGroupedTransactions(userId) {
  try {
    const response = await new AutoTransactionRepository().getGroupedTransactions(userId);
    return response;
  } catch (error) {
    logger.error(`error from getGroupedTransactions, bank-service: ${error}`);
    return error;
  }
}

async function categorizeGroupedTransaction(userId, groupId, category, subcategory, removedTransactions) {
  try {
    const response = await new AutoTransactionRepository().categorizeGroupedTransaction(userId, groupId, category, subcategory, removedTransactions);

    // delete from the cache, categorizedTransactions
    const cacheKey = `categorizedTransactions:${userId}`;
    const deleteCategorizedTransactions = await redisClient.del(cacheKey);
    logger.debug(`Deleted cache for key: ${cacheKey}, result: ${deleteCategorizedTransactions}`);

    return response;
  } catch (error) {
    logger.error(`error from categorizedGroupedTransaction, bank-service ${error}`);
    return error;
  }
}

async function getPendingForReviewTransactions(userId) {
  try {
    const response = await new AutoTransactionRepository().getPendingForReviewTransactions(userId);
    return response;
  } catch (error) {
    logger.debug(`error from getPendingForReviewTransactions: ${error}`);
    return error;
  }
}

async function verifyPendingTransaction(userId, transactionId, isCorrect) {
  try {
    const response = await new AutoTransactionRepository().verifyPendingTransaction(userId, transactionId, isCorrect);
    return response;
  } catch (error) {
    logger.debug(`error from verifyPendingTransaction ${error}`);
    return error;
  }
}

async function getMonthlyTransactionsHistory(userId, type, page) {
  try {
    const response = await new AutoTransactionRepository().getMonthlyTransactionsHistory(userId, type, page);
    return response;
  } catch (error) {
    return error;
  }
}

async function categorizeTransactions(userId) {
  try {
    // Start of the month (1st day at 12:00 AM)
    const startDate = new Date();
    startDate.setUTCDate(1);
    startDate.setUTCHours(0, 0, 0, 0);

    // End of the month (last day at 11:59:59 PM)
    const endDate = new Date(Date.UTC(startDate.getUTCFullYear(), startDate.getUTCMonth() + 1, 0, 23, 59, 59, 999));

    // ----- Week Range (Last Friday to Now) -----
    const now = new Date();
    const currentDay = now.getUTCDay(); // Sunday=0 ... Friday=5
    const daysSinceFriday = (currentDay + 2) % 7; // Calculates how many days ago Friday was
    const weekStartDate = new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() - daysSinceFriday, 0, 0, 0, 0));

    const weekEndDate = now;

    // 2. Fetch data from database
    const categorizedMonth = await new AutoTransactionRepository().categorizeTransactions(userId, startDate, endDate);
    const categorizedWeek = await new AutoTransactionRepository().categorizeTransactions(userId, weekStartDate, weekEndDate);

    return {
      week: categorizedWeek,
      ...categorizedMonth,
    };
  } catch (error) {
    return error;
  }
}

async function createTransaction(userId, data) {
  try {
    const response = await new AutoTransactionRepository().createTransaction(data, null, userId, null);

    // clear budget cache:
    await redisClient.del(`all-budgets-${userId}`);
    await redisClient.del(`banksWithAccountDetails:${userId}`);

    return response;
  } catch (error) {
    return error;
  }
}

async function getTopFiveCategories(userId) {
  try {
    const response = await new AutoTransactionRepository().getTopFiveCategories(userId);
    return response;
  } catch (error) {
    return error;
  }
}

async function getAllTransactionsByTimeLine(userId, accountId, startDate, endDate, groupBy) {
  try {
    const response = await new AutoTransactionRepository().getAllTransactionsByTimeLine(userId, accountId, startDate, endDate, groupBy);
    return response;
  } catch (error) {
    return error;
  }
}

async function getAllTransactionsForMainGraph(userId, startDate, endDate, groupBy) {
  try {
    const response = await new AutoTransactionRepository().getAllTransactionsForMainGraph(userId, startDate, endDate, groupBy);
    return response;
  } catch (error) {
    return error;
  }
}

async function getHideTransactions(userId) {
  try {
    // 1. check cached data If available
    const cacheKey = `hiddenTransactions:${userId}`;
    const cachedData = await redisClient.get(cacheKey);
    if (cachedData) return JSON.parse(cachedData);

    // 2. Fetch data from database
    const response = await new AutoTransactionRepository().getHideTransactions(userId);

    // 3. Store result in Redis (cache for 1 hour)
    await redisClient.setEx(cacheKey, 3600, JSON.stringify(response));

    return response;
  } catch (error) {
    return error;
  }
}

async function getRecurringPayments(userId, type) {
  try {
    const response = await new AutoTransactionRepository().getRecurringPayments(userId, type);
    return response;
  } catch (error) {
    logger.debug(`error from the bank-service getRecurringPayments: ${error}`);
    return error;
  }
}

async function updateRecurringPayment(recurringPaymentId, userId, data) {
  const response = await new AutoTransactionRepository().updateRecurringPayment(recurringPaymentId, userId, data);
  return response;
}

async function deleteRecurringPayment(recurringPaymentId) {
  const response = await new AutoTransactionRepository().deleteRecurringPayment(recurringPaymentId);
  return response;
}

async function updateTransaction(updateData, userId, transactionId) {
  try {
    // 1. If updateData has Hidden field, clear cache
    if ('Hidden' in updateData) {
      const cacheKey = `hiddenTransactions:${userId}`;
      await redisClient.del(cacheKey);
    }

    // 2. Update transaction
    const ObjectId = new mongoose.Types.ObjectId(transactionId);
    const response = await new AutoTransactionRepository().updateTransaction(updateData, userId, ObjectId);

    if (response) {
      await headsUpMessages(response.data.userId);
      await moneyMapMessages(response.data.userId);
    }

    return response;
  } catch (error) {
    return error;
  }
}

async function getLastPeriodDebit(userId, accountId, startDate, endDate) {
  try {
    const response = await new AutoTransactionRepository().getLastPeriodDebit(userId, accountId, startDate, endDate);
    return response;
  } catch (error) {
    return error;
  }
}

async function categoryWiseSpendings(userId, categoryNames, startDate, endDate) {
  try {
    const response = await new AutoTransactionRepository().categoryWiseSpendings(userId, categoryNames, startDate, endDate);
    return response;
  } catch (error) {
    return error;
  }
}

async function getDayWiseTransactionsSummary(userId) {
  try {
    const response = await new AutoTransactionRepository().getDayWiseTransactionsSummary(userId);
    return response;
  } catch (error) {
    return error;
  }
}

async function getTransactionsByDate(userId, date) {
  try {
    const response = await new AutoTransactionRepository().getTransactionsByDate(userId, date);
    return response;
  } catch (error) {
    return error;
  }
}

async function updateUserDetails(data, consenthandleid, userId, accountId) {
  try {
    const response = await updateExistingAccounts(data, consenthandleid, userId, accountId);

    // When a new bank is added, clear the cache
    const cacheKey = `banksWithAccountDetails:${userId}`;
    const clearedCachedData = await redisClient.del(cacheKey);
    logger.debug(`cleared the cached bank data from update call: ${clearedCachedData}`);

    return response;
  } catch (error) {
    return error;
  }
}

async function getBudgetTransactions(userId, startDate, endDate, categories, groupBy) {
  try {
    const response = await new AutoTransactionRepository().getBudgetTransactions(userId, startDate, endDate, categories, groupBy);
    return response;
  } catch (error) {
    return error;
  }
}

async function getBudgetSpents(userId, startDate, endDate, categories) {
  try {
    const response = await new AutoTransactionRepository().getSpentAmounts(userId, startDate, endDate, categories);
    return response;
  } catch (error) {
    return error;
  }
}

async function updateTransactionById(userId, transactionId, updateData) {
  try {
    const response = await new AutoTransactionRepository().updateTransactionById(userId, transactionId, updateData);
    return response;
  } catch (error) {
    return error;
  }
}

async function getPreviousTransactions(userId, date, accountId) {
  try {
    const response = await new AutoTransactionRepository().getPreviousTransactions(userId, date, accountId);
    const accountIds = [accountId];
    const summary = await new SummaryRepository().getSummary({ accountIds });
    const profile = await new ProfileRespository().getProfile({ accountIds });
    const account = await new AccountRepository().getAccountById(accountId);

    let ifscData = {};
    const ifscCode = summary[0].data.ifscCode || summary[0].data.ifsc;
    try {
      const ifscResponse = await fetch(`https://ifsc.razorpay.com/${ifscCode}`, {
        method: 'GET',
      });
      ifscData = await ifscResponse.json();
    } catch (ifscError) {
      console.error('Error fetching IFSC data:', ifscError.message);
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
  } catch (error) {
    console.error('Error in getPreviousTransactions:', error);
    return error;
  }
}

async function getHeadsUpMessages(userId) {
  try {
    const newUserId = new mongoose.Types.ObjectId(userId);
    const response = await new AutoTransactionRepository().getHeadsUpMessages(newUserId);
    return response;
  } catch (error) {
    return error;
  }
}

async function getMoneyMapMessages(userId) {
  try {
    const newUserId = new mongoose.Types.ObjectId(userId);
    const response = await new AutoTransactionRepository().getMoneyMapMessages(newUserId);
    return response;
  } catch (error) {
    return error;
  }
}

async function getTopThreeTransactionsOfWeek(userId) {
  return await new AutoTransactionRepository().getTopThreeTransactionsOfWeek(userId);
}

async function getIncomeAndCategorySpent(userId) {
  return await new AutoTransactionRepository().getIncomeAndCategorySpent(userId);
}

async function getLoanCalculation(data) {
  return await new AutoTransactionRepository().getLoanCalculation(data);
}

async function deleteBankAccount(userId, bankId, accountId) {
  try {
    const objectBankId = new mongoose.Types.ObjectId(bankId);
    const objectAccountId = new mongoose.Types.ObjectId(accountId);

    // 1. Delete bank data from the database
    const deleteBank = await new FipRepository().deleteBank(userId, objectBankId);

    // 2. Delete account data from the database
    const deleteAccount = await new AccountRepository().deleteAccount(userId, objectAccountId);

    // 3. Delete profile data from the database
    const deleteProfile = await new ProfileRespository().deleteProfile(userId, objectAccountId);

    // 4. Delete summary data from the database
    const deleteSummary = await new SummaryRepository().deleteSummary(userId, objectAccountId);

    // 5. Delete transactions data from the database
    const deleteTransactions = await new AutoTransactionRepository().deleteTransactions(userId, objectAccountId);

    const cacheKey = `banksWithAccountDetails:${userId}`;
    // 6. Clear the cache for banksWithAccountDetails
    const deleteBanksWithAccountDetails = await redisClient.del(cacheKey);
    logger.debug(`Deleted cache for key: ${cacheKey}, result: ${deleteBanksWithAccountDetails}`);

    await HeadsUp.deleteMany({ userId: new mongoose.Types.ObjectId(userId) });
    await MoneyMap.deleteMany({ userId: new mongoose.Types.ObjectId(userId) });
    await GroupedTransaction.deleteMany({ userId: new mongoose.Types.ObjectId(userId) });

    // grouping the transactions function
    await saveGroupedTransactions(userId);
    // call the grouping, money-map messages
    await headsUpMessages(userId);
    await moneyMapMessages(userId);

    return { deleteBank, deleteAccount, deleteProfile, deleteSummary, deleteTransactions };
  } catch (error) {
    return error;
  }
}

async function deleteWholeBankData(userId) {
  try {
    // 1. Delete bank data from the database
    const deleteBank = await new FipRepository().deleteBank(userId);

    // 2. Delete account data from the database
    const deleteAccount = await new AccountRepository().deleteAccount(userId);

    // 3. Delete profile data from the database
    const deleteProfile = await new ProfileRespository().deleteProfile(userId);

    // 4. Delete summary data from the database
    const deleteSummary = await new SummaryRepository().deleteSummary(userId);

    // 5. Delete transactions data from the database
    const deleteTransactions = await new AutoTransactionRepository().deleteTransactions(userId);

    return { deleteBank, deleteAccount, deleteProfile, deleteSummary, deleteTransactions };
  } catch (error) {
    return error;
  }
}

async function getUserSpending(userId) {
  try {
    // Get current date and calculate the last two months
    const currentDate = new Date(); // Today: July 23, 2025
    const months = [];

    // Generate the last two months dynamically
    for (let i = 1; i <= 2; i++) {
      const date = new Date(currentDate);
      date.setMonth(currentDate.getMonth() - i);
      date.setDate(1); // Start of the month
      date.setHours(0, 0, 0, 0); // Start of the day
      months.push({
        month: date.getMonth() + 1, // MongoDB months are 1-12
        year: date.getFullYear(),
        daysInMonth: new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate(),
      });
    }

    // Set the date range for the query
    const startDate = new Date(months[1].year, months[1].month - 1, 1); // Start of the earlier month
    const endDate = new Date(months[0].year, months[0].month, 0); // End of the later month
    endDate.setHours(23, 59, 59, 999); // End of the day

    // Aggregation pipeline to get daily totals
    const transactionData = await Transaction.aggregate([
      // Step 1: Filter transactions for the user, date range, and DEBIT type
      {
        $match: {
          userId: new mongoose.Types.ObjectId(userId),
          transactionTimestamp: {
            $gte: startDate,
            $lte: endDate,
          },
          type: 'DEBIT',
        },
      },
      // Step 2: Group by month, year, and day to calculate daily totals
      {
        $group: {
          _id: {
            month: { $month: '$transactionTimestamp' },
            year: { $year: '$transactionTimestamp' },
            day: { $dayOfMonth: '$transactionTimestamp' },
          },
          total: { $sum: '$amount' },
        },
      },
    ]);

    // Process the results to include all days with zeros
    const monthNames = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

    const formattedResult = {
      month1Name: '',
      month1Avg: '0.00',
      month1DailySums: [],
      month2Name: '',
      month2Avg: '0.00',
      month2DailySums: [],
    };

    months.forEach((monthInfo, index) => {
      const { month, year, daysInMonth } = monthInfo;
      const monthData = transactionData.filter((data) => data._id.month === month && data._id.year === year);

      // Create an array of all days (1 to daysInMonth) with zero amounts
      const dailySums = Array.from({ length: daysInMonth }, (_, i) => {
        const day = i + 1;
        const transaction = monthData.find((data) => data._id.day === day);
        return {
          day,
          amount: transaction ? transaction.total : 0,
        };
      });

      // Calculate the monthly average
      const monthTotal = dailySums.reduce((sum, day) => sum + day.amount, 0);
      const monthAvg = daysInMonth > 0 ? monthTotal / daysInMonth : 0;

      // Format the daily sums
      const formattedDailySums = dailySums.map((d) => ({
        day: d.day,
        amount: d.amount.toLocaleString('en-US', {
          minimumFractionDigits: 2,
          maximumFractionDigits: 2,
        }),
      }));

      // Assign to the result (month1 is the most recent, month2 is the earlier)
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
  } catch (error) {
    console.error('Error fetching user spending:', error);
    throw error;
  }
}

module.exports = {
  createBankDetails,
  updateBankDetails,
  getUserDetails,
  getAllTransactions,
  categorizeTransactions,
  getAllTransactionsByTimeLine,
  getHideTransactions,
  updateTransaction,
  updateUserDetails,
  getAllTransactionsForAccount,
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
  getHeadsUpMessages,
  getMoneyMapMessages,
  getSearchedTransactions,
  deleteBankAccount,
  deleteWholeBankData,
  getRecurringPayments,
  updateRecurringPayment,
  deleteRecurringPayment,
  getDayWiseTransactionsSummary,
  getTransactionsByDate,
  getTopThreeTransactionsOfWeek,
  getTransactionsByDate,
  getUserSpending,
  getIncomeAndCategorySpent,
  getLoanCalculation,
  getTopFiveCategories,
  getBudgetSpents,
  createTransaction,
  updateTransactionById,
};
