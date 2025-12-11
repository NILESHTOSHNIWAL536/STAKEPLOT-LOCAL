import cron from 'node-cron';
import moment from 'moment-timezone';
import dotenv from 'dotenv';
dotenv.config();

import { fetchTransactionsWeekly } from '../controllers/finvu-controller';
import { BankService, UserService, pushNotificationService } from '@/services';

import generateToken from './helpers/generate-finvu-token';
import logger from './common/logger';

import groupingQueue from '@/services/bull-queue-service/grouping-transaction-queue';

import { pushNotificationController } from '../controllers/index';

import { getDeviceIdsByUserId, getDeviceIdsofCupons } from './helpers/getDeviceIds';

import fetchNextReminderAt from './helpers/fetchNextReminderTime';

import { User, Account, FailedTransaction, notificationTracker, UserActivity, RecurringPayment, FipsMetric } from '../models';

import { FinvuController } from '@/controllers';
import { getCouponsCount } from './helpers/increment_score';
import updateNextFetchForFailedAccounts from '@/utils/helpers/updateNextFetchForFailedAccounts';
import { Types } from 'mongoose';

import pLimit from 'p-limit';

// ----------------------------
//       INTERFACES
// ----------------------------

interface AccountInfo {
  lastFetch: string | Date;
  fetchCount: number;
  accountId?: string;
}

interface BankDetailInput {
  consendHandleId: string;
  consentId: string;
  custId: string;
  userId: string;
  accounts: AccountInfo[];
  bankName?: string;
  fipId?: string;
}

interface TransactionRequestMeta extends BankDetailInput {
  FROM: string | Date;
}

interface ProcessResult {
  success: boolean;
  custId: string;
  error?: string;
  consentId?: string;
  consendHandleId?: string;
  userId?: string;
  FROM?: string | Date;
  bankName?: string;
  accountId?: string;
  fipId?: string;
  fetchCount?: number;
}

// ----------------------------
// UTILITIES
// ----------------------------

const limit = pLimit(10);

const createMockRes = () => ({
  status: (code: number) => ({
    json: (data: unknown) => logger.debug(`Response: ${JSON.stringify(data)}`),
  }),
  json: (data: unknown) => logger.debug(`Response: ${JSON.stringify(data)}`),
});

// ---------------------------------------
// RETRY FAILED TRANSACTIONS
// ---------------------------------------

async function retryFailedTransactions(flag: boolean): Promise<void> {
  try {
    let fipIds: string[] = [];

    if (flag) {
      fipIds = await FipsMetric.find({
        success_percent: { $gt: 60 },
      }).distinct('fip_id');
    }

    const failedItems = await FailedTransaction.find(!flag ? { retryCount: { $lt: 2 } } : { retryCount: { $lt: 2 }, fipId: { $in: fipIds } });

    if (failedItems.length === 0) {
      logger.debug('No failed transactions to retry.');
      return;
    }

    const retryPayload: BankDetailInput[] = failedItems.map((item: any) => ({
      consendHandleId: item.consendHandleId,
      consentId: item.consentId,
      custId: item.custId,
      userId: item.userId,
      accounts: [
        {
          lastFetch: item.FROM,
          fetchCount: item.fetchCount,
          accountId: item.accountId || '',
        },
      ],
    }));

    const results = await processBankDetailsForTransactions([retryPayload]);

    for (const result of results) {
      if (result.success) {
        await FailedTransaction.deleteOne({ custId: result.custId });
      } else {
        await FailedTransaction.updateOne({ custId: result.custId }, { $inc: { retryCount: 1 } });
        await updateNextFetchForFailedAccounts(result.accountId);
      }
    }
  } catch (err) {
    logger.error(`Retry Error: ${err}`);
  }
}

// -----------------------------------------------------
// PROCESS TRANSACTION FETCHING FOR ALL BANK DETAILS
// -----------------------------------------------------

async function processBankDetailsForTransactions(bankDetailsOfUsers: BankDetailInput[][]): Promise<any[]> {
  const token = await generateToken();

  const allBanks = bankDetailsOfUsers
    .filter((arr) => arr.length > 0)
    .flat()
    .filter((bank) => bank.accounts?.some((acc) => acc.fetchCount < 5));

  const uniqueBanks = Array.from(new Map(allBanks.map((b) => [`${b.consendHandleId}-${b.consentId}-${b.custId}`, b])).values());

  const transactionRequests = uniqueBanks.map((bank) => {
    const acct = bank.accounts[0];
    return {
      body: {
        handleId: bank.consendHandleId,
        consentId: bank.consentId,
        custId: bank.custId,
        userId: bank.userId,
        FROM: acct.lastFetch,
        token,
        isCron: true,
      },
      meta: {
        ...bank,
        FROM: acct.lastFetch,
        fetchCount: acct.fetchCount,
        accountId: acct.accountId || '',
      },
    };
  });

  try {
    const results = await Promise.all(
      transactionRequests.map(({ body, meta }) =>
        limit(async () => {
          const mockRes: any = createMockRes();
          try {
            await fetchTransactionsWeekly({ body } as any, mockRes);
            return { success: true, custId: meta.custId };
          } catch (err: any) {
            logger.error(`Error processing ${meta.custId}: ${err}`);
            return { success: false, error: err.message, ...meta };
          }
        })
      )
    );

    return results;
  } catch (err) {
    logger.error(`Fatal error processing all transactions: ${err}`);
    throw err;
  }
}

// DROP FAILED COLLECTION

async function dropFailedCollection() {
  try {
    await FailedTransaction.collection.drop();
  } catch (err: any) {
    if (err.code !== 26) console.error('Error dropping collection:', err);
  }
}

// --------------------------------------------------
//                      CRON JOBS
// --------------------------------------------------

/** Every Friday at 8:00 AM */
cron.schedule(
  '0 8 * * 5',
  async () => {
    console.log('Cron job started');
    await dropFailedCollection();

    try {
      const userIds = await UserService.getUserInfo();

      const bankDetails = await Promise.all(userIds.map((userId) => BankService.getBanksLinkedAndAccounts(userId as string | Types.ObjectId)));

      const results = await processBankDetailsForTransactions(bankDetails);

      for (const result of results) {
        if (!result.success) {
          await FailedTransaction.create({
            custId: result.custId,
            consentId: result.consentId,
            consendHandleId: result.consendHandleId,
            userId: result.userId,
            FROM: result.FROM,
            retryCount: 0,
            accountId: result.accountId,
            bankName: result.bankName,
            fipId: result.fipId,
            fetchCount: result.fetchCount,
            createdAt: new Date(),
          });
          await updateNextFetchForFailedAccounts(result.accountId);
        }
      }
    } catch (err) {
      logger.error(`Error in main cron: ${err}`);
    }
  },
  { scheduled: true, timezone: 'Asia/Kolkata' }
);

/** Daily at midnight: grouping transactions */
cron.schedule(
  '0 0 * * *',
  async () => {
    const userIds = await UserService.getUserInfo();
    for (const userId of userIds) {
      await groupingQueue.add({ userId }, { attempts: 3, backoff: 3000 });
    }
  },
  { scheduled: true, timezone: 'Asia/Kolkata' }
);

/** Daily at 9AM: recurring payment reminders */
cron.schedule(
  '0 9 * * *',
  async () => {
    try {
      const today = moment().tz('Asia/Kolkata').startOf('day');

      const targetTime = new Date();
      targetTime.setUTCHours(9, 0, 0, 0);

      const upcoming = await RecurringPayment.find({
        $or: [{ isActive: true, nextReminderAt: targetTime.toISOString() }, { isDaily: true }],
      });

      for (const rem of upcoming) {
        const reminderDay = moment(rem.nextReminderAt).tz('Asia/Kolkata').startOf('day');
        const offset = reminderDay.diff(today, 'days');

        const labels: any = {
          3: 'in 3 days',
          2: 'in 2 days',
          1: 'tomorrow',
          0: 'today',
        };

        const dayPrefix = labels[offset] || 'soon';

        const user = await User.findById(rem.userId);
        if (!user) continue;

        const userName = user.name?.charAt(0).toUpperCase() + user.name?.slice(1);

        const message = `Hey ${userName}, your recurring ${rem.merchant} payment of ₹${rem.amount} is due ${dayPrefix}.`;

        const deviceIds = await getDeviceIdsByUserId(rem.userId);

        if (deviceIds.length > 0) {
          await pushNotificationService.SendNotificationToDeviceSpecific(rem.userId, message, deviceIds, '/home', '', '');

          rem.nextReminderAt = fetchNextReminderAt(rem.nextReminderAt, rem.frequency);
          await rem.save();
        }
      }
    } catch (err: any) {
      logger.error(`Auto-pay cron error: ${err.message}`);
    }
  },
  { scheduled: true, timezone: 'Asia/Kolkata' }
);

/** Reset fetchCount on 1st of every month */
cron.schedule(
  '0 0 1 * *',
  async () => {
    try {
      const result = await Account.updateMany({}, { $set: { fetchCount: 0 } });
      logger.debug(`[${moment().tz('Asia/Kolkata').format()}] Reset fetchCount for ${result.modifiedCount} accounts.`);
    } catch (err) {
      logger.error(`Error resetting fetch count: ${err}`);
    }
  },
  { scheduled: true, timezone: 'Asia/Kolkata' }
);

/** Retry failed transactions at 8:30 AM Friday */
cron.schedule('30 8 * * 5', () => retryFailedTransactions(false), { scheduled: true, timezone: 'Asia/Kolkata' });

/** Fetch FIP metrics every 2 hours and retry failed */
cron.schedule(
  '0 0,2,4,6,8,10,12,14,16,18,20,22 * * *',
  async () => {
    try {
      await FinvuController.fetchAndStoreFipsMetrics();
      await retryFailedTransactions(false);
    } catch (err: any) {
      console.error('Cron job error:', err.message);
    }
  },
  { scheduled: true, timezone: 'Asia/Kolkata' }
);
