const { fetchTransactionsWeekly } = require('../controllers/finvu-controller');
const { BankService, UserService, pushNotificationService } = require('../services/index');
const cron = require('node-cron');
const generateToken = require('./helpers/generate-finvu-token');
const logger = require('./common/logger');
const groupingQueue = require('../services/bull-queue-service/grouping-transaction-queue');
const headsUpMessages = require('../utils/common/headsup-messages');
const moneyMapMessages = require('../utils/common/money-map');
const { pushNotificationController } = require('../controllers/index');
const { getDeviceIdsByUserId, getDeviceIdsofCupons } = require('./helpers/getDeviceIds');
const fetchNextReminderAt = require('./helpers/fetchNextReminderTime');
const moment = require('moment');
const { Bill, User, Account, FailedTransaction, notificationTracker, UserActivity, RecurringPayment, FipsMetric } = require('../models');
const FinvuController = require('../controllers/finvu-controller');
const { Parser } = require('json2csv');
const { getCouponsCount } = require('../utils/helpers/increment_score');
const { updateNextFetchByUserId } = require('../utils/helpers/update-existing-accounts');
const { createAndUploadBackup } = require('../services/db-backup/backup');
const { enforceRetention } = require('../services/db-backup/retention');
const { SESClient, SendRawEmailCommand } = require('@aws-sdk/client-ses');
const plimit = require('p-limit');
require('dotenv').config();

const limit = plimit(10);

// Initialize SES client
const sesClient = new SESClient({
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

// Mock response object for cron job usage
const createMockRes = () => ({
  status: (code) => {
    logger.debug(`Status: ${code}`);
    return {
      json: (data) => logger.debug(`Response: ${JSON.stringify(data)}`),
    };
  },
  json: (data) => logger.debug(`Response: ${JSON.stringify(data)}`),
});

// retry count for the cron job
async function retryFailedTransactions(flag) {
  try {
    let fipIds = [];
    if (flag) {
      fipIds = await FipsMetric.find({
        success_percent: { $gt: 60 },
      }).distinct('fip_id');
    }

    const failedItems = !flag ? await FailedTransaction.find({ retryCount: { $lt: 2 } }) : await FailedTransaction.find({ retryCount: { $lt: 2 }, fipId: { $in: fipIds } });

    if (failedItems.length === 0) {
      logger.debug('No failed transactions to retry.');
      return; // Early exit if no failed transactions
    }

    const retryDetails = failedItems.map((item) => ({
      consendHandleId: item.consendHandleId,
      consentId: item.consentId,
      custId: item.custId,
      userId: item.userId,
      accounts: [{ lastFetch: item.FROM, fetchCount: item.fetchCount, accountId: item.accountId || '' }],
    }));

    const results = await processBankDetailsForTransactions([retryDetails], true);

    for (const result of results) {
      if (result.success) {
        await FailedTransaction.deleteOne({ custId: result.custId });
      } else {
        await FailedTransaction.updateOne({ custId: result.custId }, { $inc: { retryCount: 1 } });
        await updateNextFetchByUserId(result.accountId);
      }
    }
  } catch (err) {
    logger.error(`🔁 Retry Error: ${err}`);
  }
}

// Helper function to fetch transactions for each bank detail
async function processBankDetailsForTransactions(bankDetailsOfUsers) {
  // Generate Token
  const token = await generateToken();

  // Flatten the nested arrays and remove empty groups
  const allBankDetails = bankDetailsOfUsers.filter((group) => group.length > 0).flat();

  // Only include bank details where at least one account has fetchCount < 5
  const filteredBankDetails = allBankDetails.filter((bank) => bank.accounts?.some((acc) => acc.fetchCount < 5));

  // Remove duplicates based on consendHandleId-consentId-custId
  const uniqueBankDetails = Array.from(new Map(filteredBankDetails.map((item) => [`${item.consendHandleId}-${item.consentId}-${item.custId}`, item])).values());

  logger.debug(`Unique bank details for transactions: ${JSON.stringify(uniqueBankDetails)}`);

  // Build request payloads with necessary metadata
  const transactionRequests = uniqueBankDetails.map((bankDetail) => {
    const lastFetchDate = bankDetail.accounts[0].lastFetch;
    const accountId = bankDetail.accounts[0].accountId || '';
    const fetchCount = bankDetail.accounts[0].fetchCount || 0;
    const fipId = bankDetail.fipId || 'fipId';
    const bankName = bankDetail.bankName;

    return {
      body: {
        handleId: bankDetail.consendHandleId,
        consentId: bankDetail.consentId,
        custId: bankDetail.custId,
        userId: bankDetail.userId,
        FROM: lastFetchDate,
        token,
        isCron: true,
      },
      meta: {
        custId: bankDetail.custId,
        consentId: bankDetail.consentId,
        consendHandleId: bankDetail.consendHandleId,
        userId: bankDetail.userId,
        FROM: lastFetchDate,
        fetchCount: fetchCount,
        bankName: bankName,
        fipId: fipId,
        accountId: accountId,
      },
    };
  });

  try {
    const results = await Promise.all(
      transactionRequests.map(({ body, meta }) =>
        limit(async () => {
          const mockRes = createMockRes();
          try {
            await fetchTransactionsWeekly({ body }, mockRes);
            return { success: true, custId: meta.custId };
          } catch (error) {
            logger.error(`❌ Error processing ${meta.custId}: ${error}`);
            return {
              success: false,
              custId: meta.custId,
              consentId: meta.consentId,
              consendHandleId: meta.consendHandleId,
              userId: meta.userId,
              FROM: meta.FROM,
              bankName: meta.bankName,
              accountId: meta.accountId,
              fipId: meta.fipId,
              fetchCount: meta.fetchCount,
              error: error.message,
            };
          }
        })
      )
    );

    return results;
  } catch (error) {
    logger.error(`🔥 Fatal error processing all transactions: ${error}`);
    throw error;
  }
}

async function dropFailedCollection() {
  try {
    await FailedTransaction.collection.drop();
  } catch (err) {
    if (err.code === 26) {
    } else {
      console.error('❌ Error dropping collection:', err);
    }
  }
}

// Schedule cron job for every friday at 8:00 AM IST for fetching bank transactions
// cron.schedule('* * * * *', async () => {
cron.schedule(
  '0 8 * * 5',
  async () => {
    // cleared the failed fetching banks details collection
    await dropFailedCollection();

    try {
      let userIds;
      try {
        userIds = await UserService.getUserInfo();
        logger.debug(`UserId's from the cron-job: ${userIds.length}`);
      } catch (err) {
        logger.error('Failed to fetch user info:', err);
        return; // Stop execution if this fails
      }

      let bankDetailsOfUsers;
      try {
        bankDetailsOfUsers = await Promise.all(
          userIds.map(async (userId) => {
            return await BankService.getBanksLinkedAndAccounts(userId);
          })
        );
      } catch (err) {
        logger.error('Failed to fetch bank details:', err);
        return;
      }
      try {
        const results = await processBankDetailsForTransactions(bankDetailsOfUsers);
        results.forEach(async (result) => {
          if (result.success) {
            logger.debug(`Successfully processed transactions for ${result.custId}`);
          } else {
            logger.debug(`Failed to process transactions for ${result.custId}: ${result.error}`);

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
            await updateNextFetchByUserId(result.accountId);
          }
        });
      } catch (err) {
        logger.error(`Error in processing transactions: ${err}`);
      }
    } catch (error) {
      logger.error(`General error in cron job: ${error}`);
    }
  },
  {
    scheduled: true,
    timezone: 'Asia/Kolkata',
  }
);

// schedule cron job for headsup messages && money map messages every friday at 8:30AM IST
cron.schedule(
  '30 8 * * 5',
  async () => {
    try {
      const userIds = await UserService.getUserInfo();
      for (const userId of userIds) {
        try {
          // 1. headsup messages
          await headsUpMessages(userId);

          // 2. money map messages
          await moneyMapMessages(userId);

          logger.debug(`headsup and moneyMap messages called for user ${userId}`);
        } catch (err) {
          logger.error(`Failed headsup & moneyMap for user ${userId}: ${err}`);
        }
      }
    } catch (error) {
      logger.error(`Error headsup & moneyMap: ${error}`);
    }
  },
  {
    scheduled: true,
    timezone: 'Asia/Kolkata',
  }
);

// Run daily at midnight 12:00 AM IST for grouping transactions
cron.schedule('0 0 * * *',
  async () => {
    const userIds = await UserService.getUserInfo();
    for (const userId of userIds) {
      try {
        await groupingQueue.add({ userId }, { attempts: 3, backoff: 3000 });
        logger.debug(`Grouping job added for user ${userId}`);
      } catch (err) {
        logger.error(`Failed to add job for user ${userId}: ${err}`);
      }
    }
  },
  {
    scheduled: true,
    timezone: 'Asia/Kolkata',
  }
);

// Schedule cron job for sending notifications every day at 7:00 PM IST
cron.schedule(
  '0 19 * * *',
  async () => {
    try {
      const response = await pushNotificationController.SendNotification();
      logger.debug(`Notification response: ${response}`);
    } catch (err) {
      logger.error(`Error in sending notification: ${err}`);
    }
  },
  {
    scheduled: true,
    timezone: 'Asia/Kolkata',
  }
);

// schedule cron job for sending notifications every day at 12:00 PM IST
cron.schedule(
  '0 12 * * *',
  async () => {
    try {
      const reminderOffsets = [3, 2, 1, 0];

      for (const offset of reminderOffsets) {
        const targetDate = moment().add(offset, 'days').startOf('day').toDate();
        const nextDay = moment(targetDate).add(1, 'day').toDate();

        const bills = await Bill.find({
          dueDate: { $gte: targetDate, $lt: nextDay },
          markAsComplete: false,
        });

        for (const bill of bills) {
          const user = await User.findById(bill.userId);
          const receiver = await User.findById(bill.billReceiverId);

          const userName = user?.name || 'Someone';
          const receiverName = receiver?.name || 'someone';
          // const formattedDate = moment(bill.dueDate).format('YYYY-MM-DD');

          // Customize message based on offset
          let dayPrefix = '';
          if (offset === 3) dayPrefix = 'in 3 days';
          else if (offset === 2) dayPrefix = 'in 2 days';
          else if (offset === 1) dayPrefix = 'tomorrow';
          else if (offset === 0) dayPrefix = 'today';

          // Message to bill creator
          const userMessage = `Hey ${userName}, your pending bill of ₹${bill.amount} from ${receiverName} is due ${dayPrefix}.`;
          const userDeviceIds = await getDeviceIdsByUserId(bill.userId);
          await pushNotificationService.SendNotificationToDeviceSpecific(userMessage, userDeviceIds, '/home');

          // Message to bill receiver
          const receiverMessage = `Hey ${receiverName}, you owe ₹${bill.amount} to ${userName} is due ${dayPrefix}.`;
          const receiverDeviceIds = await getDeviceIdsByUserId(bill.billReceiverId);
          await pushNotificationService.SendNotificationToDeviceSpecific(receiverMessage, receiverDeviceIds, '/home');
        }
      }
    } catch (err) {
      logger.error(`Error in sending bill reminders: ${err}`);
    }
  },
  {
    scheduled: true,
    timezone: 'Asia/Kolkata',
  }
);

// Cron job to send auto-pay(recurring payments reminders) reminders daily at 9:00 AM IST
cron.schedule(
  '0 9 * * *',
  async () => {
    try {
      const reminderOffsets = [3, 2, 1, 0];
      const today = moment().tz('Asia/Kolkata').startOf('day');

      const timestamp = new Date().setUTCHours(9, 0, 0, 0);
      const date = new Date(timestamp);

      const dateRanges = reminderOffsets.map((offset) => {
        const start = today.clone().add(offset, 'days').toDate();
        const end = today
          .clone()
          .add(offset + 1, 'days')
          .toDate();
        return { start, end };
      });

      // Now build an OR query for those date ranges
      const upcomingReminders = await RecurringPayment.find({
        $or: [{ isActive: true, nextReminderAt: date.toISOString() }, { isDaily: true }],
      });

      logger.debug(`Found ${upcomingReminders.length} upcoming auto-pay reminders`);

      for (const reminder of upcomingReminders) {
        const { userId, merchant, amount, nextReminderAt, frequency } = reminder;

        // Determine how many days ahead this reminder is
        const reminderDay = moment(nextReminderAt).tz('Asia/Kolkata').startOf('day');
        const offset = reminderDay.diff(today, 'days');

        // Get human-readable label
        let dayPrefix = '';
        if (offset === 3) dayPrefix = 'in 3 days';
        else if (offset === 2) dayPrefix = 'in 2 days';
        else if (offset === 1) dayPrefix = 'tomorrow';
        else if (offset === 0) dayPrefix = 'today';

        const user = await User.findById(userId);
        if (!user) continue;

        const userName = user.name?.charAt(0).toUpperCase() + user.name?.slice(1) || 'Someone';

        const message = `Hey ${userName}, your recurring ${merchant} payment of ₹${amount} is due ${dayPrefix}. Make sure you're prepared!`;

        const deviceIds = await getDeviceIdsByUserId(userId);

        if (deviceIds.length > 0) {
          await pushNotificationService.SendNotificationToDeviceSpecific(userId, message, deviceIds, '/home', '', '', '');

          try {
            reminder.nextReminderAt = fetchNextReminderAt(nextReminderAt, frequency);
            const response = await reminder.save();
            logger.debug(`next reminder time updated: ${response.narration} document`);
          } catch (e) {
            logger.error(`Failed to save reminder: ${e.message}`, e);
          }

          logger.debug(`Notification sent to user ${userId} for ${merchant} due ${dayPrefix}`);
        } else {
          logger.debug(`No device IDs found for user ${userId}`);
        }
      }

      logger.debug(`Auto-pay reminders processed successfully.`);
    } catch (err) {
      logger.error(`Error in auto-pay reminder cron: ${err.message}`, err);
    }
  },
  {
    scheduled: true,
    timezone: 'Asia/Kolkata',
  }
);

cron.schedule('2 9 * * *', async () => {
  try {
    const upcomingReminders = await RecurringPayment.find({ frequency: 'daily' });
    for (const reminder of upcomingReminders) {
      const newDate = new Date();
      reminder.nextReminderAt = fetchNextReminderAt(newDate, frequency);
      const response = await reminder.save();
    }
  } catch (err) {
    logger.error(`Error in auto-pay reminder cron: ${err.message}`, err);
  }
});

// Reset fetchCount to 0 for all accounts on the 1st day of each month at 12:00 AM IST
cron.schedule(
  '0 0 1 * *',
  async () => {
    try {
      const result = await Account.updateMany({}, { $set: { fetchCount: 0 } });
      logger.debug(`[${moment().tz('Asia/Kolkata').format()}] Reset fetchCount for ${result.modifiedCount} accounts.`);
    } catch (error) {
      logger.error(`[${moment().tz('Asia/Kolkata').format()}] Error resetting fetchCount: ${error}`);
    }
  },
  {
    scheduled: true,
    timezone: 'Asia/Kolkata',
  }
);

//  Retry at 8:30 AM
cron.schedule('30 8 * * 5', () => retryFailedTransactions(false), {
  scheduled: true,
  timezone: 'Asia/Kolkata',
});

// Retry at 9:00 AM
cron.schedule('0 9 * * 5', () => retryFailedTransactions(false), {
  scheduled: true,
  timezone: 'Asia/Kolkata',
});

// Delete notification tracker complete documents for bills, splits
cron.schedule(
  '0 0 * * *',
  async () => {
    try {
      await notificationTracker.deleteMany({});
    } catch (err) {
      console.error('Error clearing notification trackers:', err);
    }
  },
  {
    scheduled: true,
    timezone: 'Asia/Kolkata',
  }
);

// send the new user from the DB on every thursday
cron.schedule(
  '0 9 * * 4',
  async () => {
    try {
      const now = new Date();
      const thisThursday = new Date(now.setDate(now.getDate() - now.getDay() + 4));
      thisThursday.setHours(0, 0, 0, 0);

      const lastThursday = new Date(thisThursday);
      lastThursday.setDate(lastThursday.getDate() - 7);

      const subscribers = await User.find({
        createdAt: { $gte: lastThursday, $lt: thisThursday },
      }).lean();

      if (subscribers.length === 0) {
        logger.debug('ℹ️ No subscribers found this week.');
        return;
      }

      // Create CSV
      const fields = ['name', 'email', 'createdAt'];
      const parser = new Parser({ fields });
      const csvData = parser.parse(subscribers);

      // MIME message for attachment
      const boundary = 'NextPart_' + Date.now();
      const subject = 'Stakeplot newly joined users (Weekly CSV)';
      const bodyText = 'Attached is the latest users (last Thursday to this Thursday).';

      const rawMessage = [
        `From: ${process.env.EMAIL_USER}`,
        `To: info@stakeplot.com`,
        `Subject: ${subject}`,
        'MIME-Version: 1.0',
        `Content-Type: multipart/mixed; boundary="${boundary}"`,
        '',
        `--${boundary}`,
        'Content-Type: text/plain; charset=UTF-8',
        'Content-Transfer-Encoding: 7bit',
        '',
        bodyText,
        '',
        `--${boundary}`,
        'Content-Type: text/csv; name="subscribers.csv"',
        'Content-Disposition: attachment; filename="subscribers.csv"',
        'Content-Transfer-Encoding: base64',
        '',
        Buffer.from(csvData).toString('base64'),
        '',
        `--${boundary}--`,
      ].join('\n');

      // Send via SES
      const command = new SendRawEmailCommand({
        RawMessage: { Data: Buffer.from(rawMessage) },
      });

      await sesClient.send(command);

      logger.debug('✅ Weekly newsletter CSV email sent via SES.');
    } catch (err) {
      logger.error(`❌ Error sending newsletter CSV: ${err}`);
    }
  },
  {
    scheduled: true,
    timezone: 'Asia/Kolkata',
  }
);

async function runFipsCronJob() {
  try {
    const count = await FinvuController.fetchAndStoreFipsMetrics();
    retryFailedTransactions(false);
  } catch (error) {
    console.error('Cron job error:', error.message);
  }
}

async function sendNotificationsForCoupons() {
  try {
    const response = await getCouponsCount();
    if (response.data > 0) {
      const uniqueDeviceIds = await getDeviceIdsofCupons();
      const message = 'Grab your unclaimed coupons before they expire!';
      await pushNotificationService.SendNotificationToDeviceSpecific('', message, uniqueDeviceIds, 'coupons', 'Claim Coupons Now 🔥🔥');
    }
  } catch (err) {
    logger.error(`Error in sending notification: ${err}`);
  }
}

// Schedule to run once every 24 hours at 6:00 AM
cron.schedule('0 18 * * *', sendNotificationsForCoupons, {
  scheduled: true,
  timezone: 'Asia/Kolkata',
});

cron.schedule('0 0,2,4,6,8,10,12,14,16,18,20,22 * * *', runFipsCronJob, {
  scheduled: true,
  timezone: 'Asia/Kolkata',
});

cron.schedule(
  '0 0 * * *',
  async () => {
    try {
      await UserActivity.updateMany(
        {},
        {
          $set: {
            dailyClaimCount: [],
            dailyTransaction: [],
            dailyTags: [],
            dailyBillClears: [],
            pendingPosts: [],
            transactionIdList: [],
          },
        }
      );
    } catch (err) {
      console.error('❌ Error resetting daily counters:', err);
    }
  },
  {
    scheduled: true,
    timezone: 'Asia/Kolkata', // Adjust for your timezone
  }
);

cron.schedule(
  '0 14 * * 5',
  async () => {
    try {
      const res = await createAndUploadBackup();
      logger.debug(`Uploaded ${res.s3Key}`);

      const r = await enforceRetention();
      logger.debug(`Retention enforced, deleted: ${r.deleted}`);
    } catch (e) {
      console.error('Backup failed', e);
    }
  },
  {
    scheduled: true,
    timezone: 'Asia/Kolkata',
  }
);
