import { NextFunction, Request, Response } from 'express';
import { StatusCodes } from 'http-status-codes';
import ReferralService from '@/services/referral-service';
import { SuccessResponse } from '@/utils/common';

export const createReferralCode = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const result = await ReferralService.createReferralCode(userId, req.body);

    SuccessResponse.data = result;
    SuccessResponse.message = 'Referral code created successfully';
    res.status(StatusCodes.CREATED).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export const getShareReferralCode = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const result = await ReferralService.getOrCreateShareReferralCode(userId);

    SuccessResponse.data = result;
    SuccessResponse.message = 'Referral share code fetched successfully';
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export const applyReferralCode = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const result = await ReferralService.applyReferralCode(userId, req.body.code);

    SuccessResponse.data = result;
    SuccessResponse.message = 'Referral code applied successfully';
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export const validateReferralCode = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const userId = req.user._id;
    const result = await ReferralService.validateReferralCode(userId, req.body.code);

    SuccessResponse.data = result;
    SuccessResponse.message = 'Referral code validation completed';
    res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    next(error);
  }
};

export default {
  createReferralCode,
  getShareReferralCode,
  validateReferralCode,
  applyReferralCode,
};
