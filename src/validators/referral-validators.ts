import Joi from 'joi';

export const createReferralCodeSchema = {
  body: Joi.object({
    expiresAt: Joi.date().iso().required(),
    usageLimit: Joi.number().integer().min(1).default(1),
    bonusAmount: Joi.number().integer().min(1).default(1),
  }),
};

export const applyReferralCodeSchema = {
  body: Joi.object({
    code: Joi.string().trim().uppercase().min(6).max(32).required(),
  }),
};

export const validateReferralCodeSchema = {
  body: Joi.object({
    code: Joi.string().trim().uppercase().min(6).max(32).required(),
  }),
};
