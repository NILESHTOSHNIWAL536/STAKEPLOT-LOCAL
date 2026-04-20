import crypto from 'crypto';
import mongoose from 'mongoose';
import { StatusCodes } from 'http-status-codes';
import ReferralCode from '@/models/referral-code.model';
import ReferralUsage from '@/models/referral-usage.model';
import UserConfig from '@/models/user-config.model';
import AppError from '@/utils/errors/app-error';
import UserConfigService from './user-config-service';

const transactionOptions: mongoose.mongo.TransactionOptions = {
  readPreference: 'primary',
  readConcern: { level: 'snapshot' },
  writeConcern: { w: 'majority' },
};

const normalizeReferralCode = (code: string) => code.trim().toUpperCase();

const generateReferralCodeValue = () => crypto.randomBytes(5).toString('hex').toUpperCase();

const generateUniqueReferralCode = async (): Promise<string> => {
  for (let attempt = 0; attempt < 5; attempt += 1) {
    const candidate = generateReferralCodeValue();
    const existing = await ReferralCode.exists({ code: candidate });

    if (!existing) {
      return candidate;
    }
  }

  throw new AppError('Unable to generate a unique referral code. Please try again.', StatusCodes.INTERNAL_SERVER_ERROR);
};

const getDefaultExpiryDate = () => {
  const expiresAt = new Date();
  expiresAt.setFullYear(expiresAt.getFullYear() + 1);
  return expiresAt;
};

export const getOrCreateShareReferralCode = async (userId: string) => {
  const existingReferralCode = await ReferralCode.findOne({
    createdByUserId: new mongoose.Types.ObjectId(userId),
    active: true,
    expiresAt: { $gt: new Date() },
    $expr: { $lt: ['$usageCount', '$usageLimit'] },
  }).sort({ createdAt: -1 });

  if (existingReferralCode) {
    return {
      code: existingReferralCode.code,
      active: existingReferralCode.active,
      usageCount: existingReferralCode.usageCount,
      usageLimit: existingReferralCode.usageLimit,
      bonusAmount: existingReferralCode.bonusAmount,
      expiresAt: existingReferralCode.expiresAt,
      reusedExistingCode: true,
    };
  }

  const referralCode = new ReferralCode({
    code: await generateUniqueReferralCode(),
    createdByUserId: new mongoose.Types.ObjectId(userId),
    usageLimit: 1,
    bonusAmount: 1,
    expiresAt: getDefaultExpiryDate(),
  });

  await referralCode.save();
  await UserConfigService.ensureUserConfig(userId);

  return {
    code: referralCode.code,
    active: referralCode.active,
    usageCount: referralCode.usageCount,
    usageLimit: referralCode.usageLimit,
    bonusAmount: referralCode.bonusAmount,
    expiresAt: referralCode.expiresAt,
    reusedExistingCode: false,
  };
};

export const validateReferralCode = async (userId: string, rawCode: string) => {
  const normalizedCode = normalizeReferralCode(rawCode);

  if (!normalizedCode) {
    throw new AppError('Referral code is required', StatusCodes.BAD_REQUEST);
  }

  const referralCode = await ReferralCode.findOne({
    code: normalizedCode,
    active: true,
  });

  if (!referralCode) {
    return {
      code: normalizedCode,
      isValid: false,
      canApply: false,
      reason: 'Referral code not found',
    };
  }

  if (referralCode.createdByUserId.toString() === userId) {
    return {
      code: referralCode.code,
      isValid: false,
      canApply: false,
      reason: 'You cannot apply your own referral code',
    };
  }

  if (referralCode.expiresAt <= new Date()) {
    if (referralCode.active) {
      referralCode.active = false;
      await referralCode.save();
    }

    return {
      code: referralCode.code,
      isValid: false,
      canApply: false,
      reason: 'Referral code has expired',
    };
  }

  if (referralCode.usageCount >= referralCode.usageLimit) {
    if (referralCode.active) {
      referralCode.active = false;
      await referralCode.save();
    }

    return {
      code: referralCode.code,
      isValid: false,
      canApply: false,
      reason: 'Referral code usage limit reached',
    };
  }

  const existingUsage = await ReferralUsage.findOne({
    referredUserId: new mongoose.Types.ObjectId(userId),
  });

  if (existingUsage) {
    return {
      code: referralCode.code,
      isValid: false,
      canApply: false,
      reason: 'Referral code has already been used by this user',
    };
  }

  return {
    code: referralCode.code,
    isValid: true,
    canApply: true,
    reason: 'Referral code is valid',
    referralCode: {
      code: referralCode.code,
      usageLimit: referralCode.usageLimit,
      usageCount: referralCode.usageCount,
      bonusAmount: referralCode.bonusAmount,
      expiresAt: referralCode.expiresAt,
      active: referralCode.active,
      createdByUserId: referralCode.createdByUserId,
    },
  };
};

export const createReferralCode = async (
  userId: string,
  payload: { expiresAt: Date; usageLimit?: number; bonusAmount?: number }
) => {
  const expiresAt = new Date(payload.expiresAt);

  if (Number.isNaN(expiresAt.getTime()) || expiresAt <= new Date()) {
    throw new AppError('Referral code expiry must be a future date', StatusCodes.BAD_REQUEST);
  }

  const referralCode = new ReferralCode({
    code: await generateUniqueReferralCode(),
    createdByUserId: new mongoose.Types.ObjectId(userId),
    usageLimit: payload.usageLimit ?? 1,
    bonusAmount: payload.bonusAmount ?? 1,
    expiresAt,
  });

  await referralCode.save();
  await UserConfigService.ensureUserConfig(userId);

  return referralCode.toObject();
};

export const applyReferralCode = async (userId: string, rawCode: string) => {
  const normalizedCode = normalizeReferralCode(rawCode);

  if (!normalizedCode) {
    throw new AppError('Referral code is required', StatusCodes.BAD_REQUEST);
  }

  const session = await mongoose.startSession();

  try {
    let result: Record<string, unknown> | undefined;

    await session.withTransaction(async () => {
      const referralCode = await ReferralCode.findOne({
        code: normalizedCode,
        active: true,
      }).session(session);

      if (!referralCode) {
        throw new AppError('Referral code not found', StatusCodes.NOT_FOUND);
      }

      if (referralCode.createdByUserId.toString() === userId) {
        throw new AppError('You cannot apply your own referral code', StatusCodes.BAD_REQUEST);
      }

      if (referralCode.expiresAt <= new Date()) {
        referralCode.active = false;
        await referralCode.save({ session });
        throw new AppError('Referral code has expired', StatusCodes.BAD_REQUEST);
      }

      if (referralCode.usageCount >= referralCode.usageLimit) {
        referralCode.active = false;
        await referralCode.save({ session });
        throw new AppError('Referral code usage limit reached', StatusCodes.BAD_REQUEST);
      }

      const existingUsage = await ReferralUsage.findOne({
        referredUserId: new mongoose.Types.ObjectId(userId),
      }).session(session);

      if (existingUsage) {
        throw new AppError('Referral code has already been used by this user', StatusCodes.BAD_REQUEST);
      }

      await UserConfigService.ensureUserConfig(userId, session);
      const referrerConfig = await UserConfigService.ensureUserConfig(referralCode.createdByUserId.toString(), session);

      const usage = new ReferralUsage({
        referralCodeId: referralCode._id,
        referralCode: referralCode.code,
        referrerUserId: referralCode.createdByUserId,
        referredUserId: new mongoose.Types.ObjectId(userId),
        bonusAwarded: referralCode.bonusAmount,
        usedAt: new Date(),
      });

      referralCode.usageCount += 1;
      if (referralCode.usageCount >= referralCode.usageLimit) {
        referralCode.active = false;
      }

      referrerConfig.referralBonus = (referrerConfig.referralBonus || 0) + referralCode.bonusAmount;

      await usage.save({ session });
      await referralCode.save({ session });
      await referrerConfig.save({ session });

      result = {
        usage: usage.toObject(),
        referralCode: referralCode.toObject(),
        referrerConfig: {
          userId: referrerConfig.userId,
          baseLimit: referrerConfig.baseLimit,
          referralBonus: referrerConfig.referralBonus,
          totalLimit: referrerConfig.baseLimit + referrerConfig.referralBonus,
        },
      };
    }, transactionOptions);

    return result!;
  } finally {
    await session.endSession();
  }
};

export default {
  createReferralCode,
  getOrCreateShareReferralCode,
  validateReferralCode,
  applyReferralCode,
};
