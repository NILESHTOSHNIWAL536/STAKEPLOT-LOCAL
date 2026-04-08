import Queue, { Job } from 'bull';
import moment from 'moment-timezone';
import { Types } from 'mongoose';
import { ReserveService } from '../reserve-service';
import reserveEngine from '../reserve-engine';
import logger from '@/utils/common/logger';

const REDIS_HOST: string = process.env.REDIS_HOST || '127.0.0.1';
const REDIS_PORT: number = Number(process.env.REDIS_PORT) || 6379;
const REDIS_PASSWORD: string | undefined = process.env.REDIS_PASSWORD;

type ReminderJob = {
  reserveId: string;
  userId: string;
};

const reserveReminderQueue = new Queue<ReminderJob>('reserve-reminder', {
  redis: {
    host: REDIS_HOST,
    port: REDIS_PORT,
    password: REDIS_PASSWORD || undefined,
  },
});

reserveReminderQueue.process(async (job: Job<ReminderJob>) => {
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

export async function scheduleReserveReminder(reserveId: string, userId: string, startDate: Date, endDate: Date, reminderTime: string) {
  const [hours, minutes] = reminderTime.split(':').map((v) => Number(v));
  const tz = 'Asia/Kolkata';
  const start = moment(startDate).tz(tz).hours(hours).minutes(minutes).seconds(0).milliseconds(0);
  const end = moment(endDate).tz(tz).hours(hours).minutes(minutes).seconds(0).milliseconds(0);

  await reserveReminderQueue.add(
    { reserveId, userId },
    {
      jobId: `${reserveId}:${hours}:${minutes}`,
      repeat: {
        cron: `${minutes} ${hours} * * *`,
        startDate: start.toDate(),
        endDate: end.toDate(),
        tz,
      },
      removeOnComplete: true,
      removeOnFail: true,
    }
  );
}

export async function removeReserveReminder(reserveId: string) {
  const jobs = await reserveReminderQueue.getRepeatableJobs();
  for (const job of jobs) {
    if (job.id && job.id.startsWith(reserveId)) {
      await reserveReminderQueue.removeRepeatableByKey(job.key);
    }
  }
}

export default reserveReminderQueue;
