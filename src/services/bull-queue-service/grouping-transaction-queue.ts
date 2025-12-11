import Queue, { Job } from 'bull';
import { Types } from 'mongoose';
import saveGroupedTransactions from '@/utils/helpers/saveGroupedTransactions';

// Load Redis config
const REDIS_HOST: string = process.env.REDIS_HOST || '127.0.0.1';
const REDIS_PORT: number = Number(process.env.REDIS_PORT) || 6379;
const REDIS_PASSWORD: string | undefined = process.env.REDIS_PASSWORD;

// Create Bull queue
const groupingQueue = new Queue('transaction-grouping', {
  redis: {
    host: REDIS_HOST,
    port: REDIS_PORT,
    password: REDIS_PASSWORD || undefined,
  },
});

// Queue processor
groupingQueue.process(async (job: Job<{ userId: string | Types.ObjectId }>) => {
  const { userId } = job.data;

  try {
    await saveGroupedTransactions(userId);
  } catch (error) {
    console.error(`Error processing user ${userId}:`, error);
  }
});

export default groupingQueue;
