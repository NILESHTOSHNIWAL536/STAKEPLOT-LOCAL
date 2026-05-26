import Queue, { Job } from 'bull';
import moment from 'moment-timezone';
import { Types } from 'mongoose';
import { ReserveService } from '../reserve-service';
import reserveEngine from '../reserve-engine';
import logger from '@/utils/common/logger';

type ReminderJob = {
  reserveId: string;
  userId: string;
};

let _queue: InstanceType<typeof Queue> | null = null;

// Deferred so process.env.REDIS_PASSWORD is populated by loadSecrets() before connection.
const getQueue = (): InstanceType<typeof Queue> => {
  if (_queue) return _queue;
  _queue = new Queue<ReminderJob>('reserve-reminder', {
    redis: {
      host: process.env.REDIS_HOST || '127.0.0.1',
      port: Number(process.env.REDIS_PORT) || 6379,
      password: process.env.REDIS_PASSWORD || undefined,
    },
  });
  _queue.process(async (job: Job<ReminderJob>) => {
    const { reserveId, userId } = job.data;
    try {
      const reserve = await ReserveService.getReserveById(userId, reserveId);
      if (!reserve) return;
      await reserveEngine.evaluateReserve(reserve as any);
      await reserve.save();
    } catch (err: any) {
      logger.error(`Reserve reminder job failed (${reserveId}): ${err.message}`);
    }
  });
  return _queue;
};

export async function scheduleReserveReminder(reserveId: string, userId: string, startDate: Date, endDate: Date, reminderTime: string) {
  const [hours, minutes] = reminderTime.split(':').map((v) => Number(v));
  const tz = 'Asia/Kolkata';
  const end = moment(endDate).tz(tz).hours(hours).minutes(minutes).seconds(0).milliseconds(0);

  await getQueue().add(
    { reserveId, userId },
    {
      jobId: `${reserveId}:${hours}:${minutes}`,
      repeat: {
        cron: `${minutes} ${hours} * * *`,
        startDate: startDate,
        endDate: end.toDate(),
        tz,
      },
      removeOnComplete: true,
      removeOnFail: true,
    }
  );
}

export async function removeReserveReminder(reserveId: string) {
  const jobs = await getQueue().getRepeatableJobs();
  for (const job of jobs) {
    if (job.id && job.id.startsWith(reserveId)) {
      await getQueue().removeRepeatableByKey(job.key);
    }
  }
}
