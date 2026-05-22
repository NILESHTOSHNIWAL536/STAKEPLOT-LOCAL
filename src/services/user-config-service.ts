import mongoose from 'mongoose';
import UserConfig from '@/models/user-config.model';
import { AppLimits } from '@/utils/helpers/collections_envs';

export interface IUserCollectionLimit {
  baseLimit: number;
  referralBonus: number;
  totalLimit: number;
}

const buildLimitPayload = (config?: { baseLimit?: number; referralBonus?: number } | null): IUserCollectionLimit => {
  const baseLimit = config?.baseLimit ?? AppLimits.MAX_COLLECTIONS_PER_USER;
  const referralBonus = config?.referralBonus ?? 0;

  return {
    baseLimit,
    referralBonus,
    totalLimit: baseLimit + referralBonus,
  };
};

export const ensureUserConfig = async (userId: string, session?: mongoose.ClientSession) => {
  const objectId = new mongoose.Types.ObjectId(userId);

  return UserConfig.findOneAndUpdate(
    { userId: objectId },
    {
      $setOnInsert: {
        userId: objectId,
        baseLimit: AppLimits.MAX_COLLECTIONS_PER_USER,
        referralBonus: 0,
      },
    },
    {
      upsert: true,
      new: true,
      setDefaultsOnInsert: true,
      session,
    }
  );
};

export const getUserCollectionLimit = async (userId: string): Promise<IUserCollectionLimit> => {
  const config = await UserConfig.findOne({ userId: new mongoose.Types.ObjectId(userId) }).lean();
  return buildLimitPayload(config);
};

export const getUserCollectionLimitMap = async (userIds: string[]): Promise<Map<string, IUserCollectionLimit>> => {
  const uniqueUserIds = Array.from(new Set(userIds.filter(Boolean)));
  const objectIds = uniqueUserIds
    .filter((userId) => mongoose.Types.ObjectId.isValid(userId))
    .map((userId) => new mongoose.Types.ObjectId(userId));

  const configs = await UserConfig.find({ userId: { $in: objectIds } }).lean();
  const configMap = new Map(configs.map((config) => [config.userId.toString(), buildLimitPayload(config)]));

  uniqueUserIds.forEach((userId) => {
    if (!configMap.has(userId)) {
      configMap.set(userId, buildLimitPayload());
    }
  });

  return configMap;
};

export default {
  ensureUserConfig,
  getUserCollectionLimit,
  getUserCollectionLimitMap,
};
