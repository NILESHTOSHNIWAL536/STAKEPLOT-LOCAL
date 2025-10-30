const {
  generateDataKey,
} = require("../../services/Encryption/generateDataKey");
const {
  AccountRepository,
  ProfileRespository,
  SummaryRepository,
  FipRepository,
  AutoTransactionRepository,
} = require("../../repositories/index");
const {
  getNextFetch,
  getNextMonthFetch,
} = require("../helpers/get-next-fetch");
const getISTTimestamp = require("../helpers/get-IST-timeStamp");
const logger = require("../common/logger");
const saveGroupedTransactions = require("./saveGroupedTransactions");
const AppError = require("../errors/app-error");
const headsUpMessages = require("../common/headsup-messages");
const moneyMapMessages = require("../common/money-map");
const { StatusCodes } = require("http-status-codes");
const { PendingTransaction,Account } = require("../../models/");
const detectRecurringPayments = require("../helpers/detect-recurring-payments");

async function updateExistingAccounts(
  data,
  consentHandleId,
  userId,
  accountId
) {
  try {
    // Generate new encryption key for updates
    const { plaintextKey, ciphertextBlob } = await generateDataKey();

    // Update FIP record
    const fipData = {
      fipId: data.fipId,
      fipName: data.fipName,
      custId: data.custId,
      consentId: data.consentId,
      sessionId: data.sessionId,
      fiAccountInfo: data.fiAccountInfo,
      consentHandleId,
      userId,
    };

    const existingFip = await new FipRepository().getFipById(
      userId,
      consentHandleId
    );
    let fip;
    if (existingFip) {
      fip = await new FipRepository().updateFipRecord(
        existingFip._id,
        fipData,
        plaintextKey,
        ciphertextBlob
      );
    }

    // Process fiObjects (assuming we're updating based on the first fiObject as per previous context)
    const fiObject = data.fiObjects[0]; // Taking first object as per previous logic

    if (!fiObject) {
      return { status: "no_update_needed" };
    }

    // Update nextFetch, lastFetch;
    let nextFetch;
    const lastFetch = getISTTimestamp();

    const existingAccount = await new AccountRepository().getAccountById(
      accountId
    );
    if (existingAccount && existingAccount.fetchCount == 4) {
      nextFetch = getNextMonthFetch();
    } else {
      nextFetch = getNextFetch();
    }

    // call the recurring payments function and store them in DB
    await detectRecurringPayments(userId, {fromDate: existingAccount.lastFetch});

    const accountData = {
      type: fiObject.type,
      maskedAccNumber: fiObject.maskedAccNumber,
      version: fiObject.version,
      linkedAccRef: fiObject.linkedAccRef,
      schemaLocation: fiObject.schemaLocation,
      startDate: fiObject.Transactions.startDate,
      endDate: fiObject.Transactions.endDate,
      bankId: fip._id,
      nextFetch: new Date(nextFetch),
      lastFetch: new Date(lastFetch),
      userId,
    };

    const account = await new AccountRepository().updateAccount(
      accountId,
      accountData,
      plaintextKey,
      ciphertextBlob
    );

    if (!account) {
      logger.error(`Account not found for update: ${accountId}`);
      throw new AppError("Account not found", StatusCodes.NOT_FOUND);
    }

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
        const pendingData = Array.isArray(fiObject?.Summary?.Pending)
          ? fiObject.Summary.Pending
          : fiObject?.Summary?.Pending
          ? [fiObject.Summary.Pending]
          : [];

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
      } catch (e) {
      }
    }

    // Update transactions - assuming we want to append new transactions
    if (fiObject.Transactions && fiObject.Transactions.Transaction) {
      const newTransactions = fiObject.Transactions.Transaction;
      await new AutoTransactionRepository().createTransaction(
        newTransactions,
        accountId,
        userId,
        fip._id
      );

      // grouping the transactions function
      await saveGroupedTransactions(userId);

      // call the grouping, money-map messages
      await headsUpMessages(userId);
      await moneyMapMessages(userId);
    }

    return {
      status: "updated",
      accountId: account._id,
      bankId: fip._id,
    };
  } catch (error) {
    logger.error(`error from the update existing accoutns call: ${error}`);
    throw new AppError(
      error.message || "Error updating user details",
      error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR
    );
  }
}

async function createNewBankAccount(data, consentHandleId, userId) {
  // Generate encryption key
  const { plaintextKey, ciphertextBlob } = await generateDataKey();

  // Create FIP record
  const fipData = {
    fipId: data.fipId,
    fipName: data.fipName,
    custId: data.custId,
    consentId: data.consentId,
    sessionId: data.sessionId,
    fiAccountInfo: data.fiAccountInfo,
    consentHandleId,
    userId,
  };

  const fip = await new FipRepository().createFipRecord(
    fipData,
    plaintextKey,
    ciphertextBlob
  );

  // Create a lookup map for fiObjects to speed up matching
  const fiObjectMap = new Map(
    data.fiObjects.map((obj) => [obj.linkedAccRef, obj])
  );

  // Process accounts in parallel
  const processedAccounts = await Promise.all(
    data.fiAccountInfo.map(async (fiAccount) => {
      try {
        let fiObject = fiObjectMap.get(fiAccount.linkRefNo);
        if (!fiObject) {
          fiObject = fiObjectMap.get(fiAccount.accountRefNo);
        }

        if (!fiObject) {
          return { account: null };
        }

        // This function will fetch the next upcoming monday and sets it to the nextFetch
        const nextFetch = getNextFetch();
        const lastFetch = getISTTimestamp();
        logger.debug(`lastFetch from the createNewBank: ${lastFetch}`);
        logger.debug(`nextFetch from the createNewBank ${nextFetch}`);

        // Create account record
        const accountData = {
          type: fiObject.type,
          maskedAccNumber: fiObject.maskedAccNumber,
          version: fiObject.version,
          linkedAccRef: fiObject.linkedAccRef,
          schemaLocation: fiObject.schemaLocation,
          startDate: fiObject.Transactions.startDate,
          endDate: fiObject.Transactions.endDate,
          bankId: fip._id,
          nextFetch: new Date(nextFetch),
          lastFetch: new Date(lastFetch),
          fetchCount: 1,
          userId,
        };
        const account = await new AccountRepository().createAccount(
          accountData,
          plaintextKey,
          ciphertextBlob
        );
        logger.debug(`account data not found, created new account: ${account}`);

        // Encrypt and store profile if present
        if (fiObject.Profile) {
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

        // Encrypt and store summary if present
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

          try {
            // Normalize pending data into array
            const pendingData = Array.isArray(fiObject?.Summary?.PendingTxns)
              ? fiObject.Summary.PendingTxns
              : fiObject?.Summary?.PendingTxns
              ? [fiObject.Summary.PendingTxns]
              : [];

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
          } catch (e) {
          }
        }

        // Store transactions if present
        if (fiObject.Transactions) {
          await new AutoTransactionRepository().createTransaction(
            fiObject.Transactions.Transaction,
            account._id,
            userId,
            fip._id
          );

          // grouping the transactions function
          await saveGroupedTransactions(userId);

          // call the grouping, money-map messages
          await headsUpMessages(userId);
          await moneyMapMessages(userId);

          // call the funtion to get recurring payments and store them in DB
          await detectRecurringPayments(userId);
        }

        return { account };
      } catch (error) {
        logger.error(`Error processing account: ${error}`);
        throw new AppError(
          "Error processing account data",
          StatusCodes.INTERNAL_SERVER_ERROR
        );
      }
    })
  );

  return processedAccounts;
}


async function updateNextFetchByUserId(_id) {
    try {
        if(_id=="")return;
        const accounts = await Account.find({ _id });
        for (const account of accounts)
        {
            const nextFetch = getNextFetch(); // replace with your own logic
            account.nextFetch = nextFetch;
            await account.save();
        }

    } catch (error) {
        console.error('Error updating nextFetch:', error);
    }
}

module.exports = { updateExistingAccounts, createNewBankAccount,updateNextFetchByUserId };
