import { UserActivity } from '../../models';
import { HydratedDocument } from 'mongoose';
import logger from '../common/logger';
import moment from 'moment';
import { scoreToAdd } from '../common/enums';
import jwt from 'jsonwebtoken';
import axios from 'axios';
import redisClient from '../../config/redis-config';
import {Types} from "mongoose"

/* ============================================================
   Local Interfaces (NOT imported from model)
============================================================ */

interface IDateCount {
  date?: string;
  count: number;
}

interface IPendingPost {
  postId?: string;
  createdAt: Date;
  processed: boolean;
}

/**
 * This matches your Mongoose schema shape.
 * This interface exists ONLY in this file.
 */
interface IUserActivity {
  userId: string;
  score: number;
  unclaimedCount: number;

  transactionIdList: (string | Types.ObjectId)[];

  hasReached50: boolean;

  dailyClaimCount: IDateCount[];
  dailyTransaction: IDateCount[];
  dailyTags: IDateCount[];
  dailyBillClears: IDateCount[];

  pendingPosts: IPendingPost[];

  lastActivityDate?: string;

  save(): Promise<any>;
}

/* ============================================================
   Helper Utils
============================================================ */

export const getCurrentDate = (): string => moment().format('YYYY-MM-DD');

async function publishSocketEvent(userId: string, event: string, data: any): Promise<void> {
  await redisClient.publish('bank_events', JSON.stringify({ userId, event, data }));
}

const baseUrl = process.env.REWARD_BASE_URL;

/* ============================================================
   JWT Generator
============================================================ */

const generateServiceToken = (): string => {
  return jwt.sign({ service: 'mobile-backend' }, process.env.SERVICE_JWT_SECRET as string, { expiresIn: '10m' });
};

/* ============================================================
   Increment Score
============================================================ */

export const incrementScore = async (userId: string, amount: number): Promise<number | undefined> => {
  try {
    let user: HydratedDocument<IUserActivity> | null = await UserActivity.findOne({ userId });

    if (!user) {
      user = new UserActivity({ userId }) as HydratedDocument<IUserActivity>;
    }

    user.score += amount;

    if (!user.hasReached50 && user.score >= 50) {
      user.hasReached50 = true;
      user.unclaimedCount += 1;
    }

    user.lastActivityDate = getCurrentDate();
    await user.save();

    return user.score;
  } catch (error: any) {
    logger.error(`Failed incrementScore: ${error.message}`);
  }
};

/* ============================================================
   Get Coupon Count
============================================================ */

export const getCouponsCount = async (): Promise<{ data: number }> => {
  try {
    const token = generateServiceToken();

    const response = await axios.get(`${baseUrl}/coupon/get-unclaimed-coupons-count`, { headers: { Authorization: `Bearer ${token}` } });

    return response.data;
  } catch {
    return { data: 0 };
  }
};

/* ============================================================
   Post Score Counter
============================================================ */

export const postScoreCounter = async (userId: string, postId: string, isDelete: boolean): Promise<void> => {
  try {
    let user: HydratedDocument<IUserActivity> | null = await UserActivity.findOne({ userId });

    if (!user) {
      user = new UserActivity({ userId }) as HydratedDocument<IUserActivity>;
    }

    if (isDelete) {
      const found = user.pendingPosts.find((p) => p.postId?.toString() === postId.toString());

      if (!found) return;

      const ageHours = (Date.now() - found.createdAt.getTime()) / (1000 * 60 * 60);

      if (ageHours <= 48) {
        user.score -= scoreToAdd.Post;
      }
    } else {
      user.pendingPosts.push({
        postId,
        createdAt: new Date(),
        processed: false,
      });
    }

    user.lastActivityDate = getCurrentDate();
    await user.save();
  } catch (error: any) {
    logger.error(`Failed postScoreCounter: ${error.message}`);
  }
};

/* ============================================================
   Generic Daily Counter Handler
============================================================ */

export const handleDailyCounter = async (
  userId: string | Types.ObjectId,
  counterField: keyof IUserActivity,
  points: number,
  objectId: string | Types.ObjectId,
  incScoreCount: number,
  countBreak: number
): Promise<number> => {
  try {
    const today = getCurrentDate();

    let user: HydratedDocument<IUserActivity> | null = await UserActivity.findOne({ userId });

    if (!user) {
      user = new UserActivity({ userId }) as HydratedDocument<IUserActivity>;
      await user.save();
    }

    if (!Array.isArray(user[counterField])) {
      (user as any)[counterField] = [];
    }

    if (!user.transactionIdList) user.transactionIdList = [];
    if (!user.dailyClaimCount) user.dailyClaimCount = [];

    // Today's counter record
    let dailyCounter = (user[counterField] as any).find((c: any) => c.date === today) || { date: today, count: 0 };

    if (!(user[counterField] as any).includes(dailyCounter)) {
      (user[counterField] as any).push(dailyCounter);
    }

    let claimToday = user.dailyClaimCount.find((c) => c.date === today) || { date: today, count: 0 };

    if (!user.dailyClaimCount.includes(claimToday)) {
      user.dailyClaimCount.push(claimToday);
    }

    const exists = objectId && user.transactionIdList.some((id) => id.toString() === objectId.toString());

    if (!objectId || !exists) {
      dailyCounter.count += points;
    }

    if (!exists && objectId) {
      user.transactionIdList.push(objectId);
    }

    // Threshold reached
    if (dailyCounter.count >= countBreak) {
      const resp = await getCouponsCount();

      if (resp.data > 0) {
        user.unclaimedCount++;
        dailyCounter.count = 0;

        if (claimToday.count < 2) {
          setTimeout(() => {
            publishSocketEvent(userId as string, 'addUserToSocket', {
              type: 'Reward',
              data: { count: user.unclaimedCount },
            });
          }, 1000);
        }
      }
    }

    if (!objectId || !exists) {
      await incrementScore(userId as string, incScoreCount);
    }

    await user.save();
    return dailyCounter.count;
  } catch (error: any) {
    throw new Error(`Daily counter failed: ${error.message}`);
  }
};

/* ============================================================
   Daily Claim Count Handler
============================================================ */

export const handleDailyClaimCount = async (userId: string, counterField: keyof IUserActivity, countBreak: number): Promise<number> => {
  try {
    const today = getCurrentDate();

    let user: HydratedDocument<IUserActivity> | null = await UserActivity.findOne({ userId });

    if (!user) {
      user = new UserActivity({ userId }) as HydratedDocument<IUserActivity>;
      await user.save();
    }

    if (!Array.isArray(user[counterField])) {
      (user as any)[counterField] = [];
    }

    let counter = (user[counterField] as any).find((c: any) => c.date === today) || { date: today, count: 0 };

    if (!(user[counterField] as any).includes(counter)) {
      (user[counterField] as any).push(counter);
    }

    counter.count++;

    if (counter.count <= countBreak) {
      await user.save();
    }

    return counter.count;
  } catch (error: any) {
    throw new Error(`Daily claim count failed: ${error.message}`);
  }
};

/* ============================================================
   Export
============================================================ */

export default {
  incrementScore,
  handleDailyCounter,
  getCurrentDate,
  postScoreCounter,
  handleDailyClaimCount,
  getCouponsCount,
};
