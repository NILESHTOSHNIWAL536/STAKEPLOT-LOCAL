import Queue, { Job } from 'bull';
import { Types } from 'mongoose';
import { FinvuController, TransactionAutoController } from '@/controllers';
import { NotificationRepository } from '@/repositories';
import { FailedTransaction, Finvu } from '@/models';
import redisClient from '@/config/redis-config';
import generateToken from '@/utils/helpers/generate-finvu-token';
import bankLogos from '@/config/bankLogos';
import logger from '@/utils/common/logger';
import { clearUserFetchStatus, publishSocketEvent } from '@/utils/webHook';

export type FinvuFetchJobData = {
  sessionId: string;
  custId: string;
  consentId: string;
  handleId: string;
  isUpdate: boolean;
  userId: string;
};

const notificationRepository = new NotificationRepository();

let _queue: InstanceType<typeof Queue> | null = null;

// ─── Lazy factory ─────────────────────────────────────────────────────────────
// Deferred so process.env.REDIS_PASSWORD is populated by loadSecrets() before connection.

const getQueue = (): InstanceType<typeof Queue> => {
  if (_queue) return _queue;
  _queue = new Queue<FinvuFetchJobData>('finvu-fetch', {
    redis: {
      host: process.env.REDIS_HOST || '127.0.0.1',
      port: Number(process.env.REDIS_PORT) || 6379,
      password: process.env.REDIS_PASSWORD || undefined,
    },
  });

  // ─── Worker ─────────────────────────────────────────────────────────────────

  _queue.process(async (job: Job<FinvuFetchJobData>) => {
  const { sessionId, custId, consentId, handleId, isUpdate, userId } = job.data;

  logger.info(`[FinvuFetchQueue] Processing job ${job.id} for session ${sessionId}`);

  // Reuse cached auth token or generate a fresh one
  let token = await redisClient.get('auth_token');
  if (!token) {
    token = await generateToken();
    await redisClient.setEx('auth_token', 800, token);
  }

  const finalData = await FinvuController.fetchFinalData(token, custId, consentId, sessionId);

  if (finalData !== 'Account data not found.') {
    await Finvu.findOneAndUpdate({ sessionId }, { $set: { data: finalData } }, { new: true });

    if (isUpdate) {
      await TransactionAutoController.updateBankDetails(finalData, handleId, userId);
    } else {
      await TransactionAutoController.createBankDetails(finalData, handleId, userId);
    }

    await FinvuController.deleteConsentHandleById(handleId);
    await FailedTransaction.deleteMany({ consendHandleId: handleId });

    let totalTransactions = 0;
    const name = finalData?.[0]?.fipName || 'Bank';
    const bankId = finalData?.[0]?.fipId || '';

    finalData.forEach((data: any) => {
      data.fiObjects.forEach((obj: any) => {
        totalTransactions += obj.Transactions?.Transaction?.length || 0;
      });
    });

    const bankLogo = bankLogos[bankId] || 'https://cdn.finvu.in/finvulogos/bank_large_light.png';

    await notificationRepository.createNotification({
      userId: new Types.ObjectId(userId),
      notificationMessage: {
        type: 'FetchedData',
        message: `${name} Data has been successfully fetched`,
        avatarType: bankLogo,
        logo: bankLogo,
      },
    });

    await publishSocketEvent(custId, 'registerUser', {
      message: 'Your bank account data has been successfully fetched.',
      data: { number_id: custId, data: finalData },
    });

    await publishSocketEvent(userId, 'addUserToSocket', {
      type: 'fetchedApiCall',
      data: {
        message: `${name} fetched successfully! ${totalTransactions} new transactions.`,
        failed: false,
        handleId,
        consentId,
        bankName: name,
      },
    });

    await clearUserFetchStatus({ userId, handleId, consentId });

    await Finvu.deleteOne({ sessionId });
  } else {
    await publishSocketEvent(custId, 'registerUser', {
      message: 'Sorry, we are unable to fetch your bank details. Please try again later.',
      data: { number_id: custId, data: 'account-data-not-found' },
    });

    await publishSocketEvent(userId, 'addUserToSocket', {
      type: 'fetchedApiCall',
      data: {
        message: 'No transactions were found at the moment, try again later',
        failed: true,
        handleId,
        consentId,
      },
    });
  }

  logger.info(`[FinvuFetchQueue] Job ${job.id} completed for session ${sessionId}`);
  });

  _queue.on('failed', (job, err) => {
    logger.error(`[FinvuFetchQueue] Job ${job.id} failed: ${err.message}`);
  });

  _queue.on('completed', (job) => {
    logger.info(`[FinvuFetchQueue] Job ${job.id} completed`);
  });

  return _queue;
};

// ─── Enqueue helper ───────────────────────────────────────────────────────────

const FETCH_DELAY_MS = 12_000; // 12 s — gives the aggregator time to settle

export async function enqueueFinvuFetch(data: FinvuFetchJobData, delayMs = FETCH_DELAY_MS): Promise<void> {
  await getQueue().add(data, {
    jobId: `finvu-fetch:${data.sessionId}`, // deduplicates if triggered twice
    delay: delayMs,
    removeOnComplete: true,
    removeOnFail: false,
    attempts: 3,
    backoff: { type: 'exponential', delay: 5000 },
  });

  logger.info(`[FinvuFetchQueue] Enqueued session ${data.sessionId} — fires in ${delayMs / 1000}s`);
}

const finvuFetchQueue = new Proxy({} as InstanceType<typeof Queue>, {
  get(_target, prop: string) {
    const q = getQueue();
    const value = (q as any)[prop];
    return typeof value === 'function' ? value.bind(q) : value;
  },
});

export default finvuFetchQueue;
