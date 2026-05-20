import Queue, { Job } from 'bull';
import { Types } from 'mongoose';
import saveGroupedTransactions from '@/utils/helpers/saveGroupedTransactions';

let _queue: InstanceType<typeof Queue> | null = null;

// Deferred so process.env.REDIS_PASSWORD is populated by loadSecrets() before connection.
const getQueue = (): InstanceType<typeof Queue> => {
  if (_queue) return _queue;
  _queue = new Queue('transaction-grouping', {
    redis: {
      host: process.env.REDIS_HOST || '127.0.0.1',
      port: Number(process.env.REDIS_PORT) || 6379,
      password: process.env.REDIS_PASSWORD || undefined,
    },
  });
  _queue.process(async (job: Job<{ userId: string | Types.ObjectId }>) => {
    const { userId } = job.data;
    try {
      await saveGroupedTransactions(userId);
    } catch (error) {
      console.error(`Error processing user ${userId}:`, error);
    }
  });
  return _queue;
};

const groupingQueue = new Proxy({} as InstanceType<typeof Queue>, {
  get(_target, prop: string) {
    const q = getQueue();
    const value = (q as any)[prop];
    return typeof value === 'function' ? value.bind(q) : value;
  },
});

export default groupingQueue;
