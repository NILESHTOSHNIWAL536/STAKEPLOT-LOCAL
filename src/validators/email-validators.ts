import { NextFunction, Request, Response } from 'express';
import creditCards from '../utils/credit-cards.json';

const allowedBankIds = new Set((creditCards as any[]).map((card) => card.bankId));
const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const googleAuthCodePattern = /^[A-Za-z0-9._~+/=-]{1,4096}$/;

const rejectInvalid = (res: Response, message = 'Invalid request input') =>
  res.status(400).json({ success: false, error: message });

const rejectUnexpectedQuery = (req: Request, res: Response): Response | void => {
  if (Object.keys(req.query || {}).length > 0) return rejectInvalid(res);
};

const validateBankIds = (bankIds: unknown): bankIds is string[] =>
  Array.isArray(bankIds) &&
  bankIds.length > 0 &&
  bankIds.length <= 20 &&
  bankIds.every((bankId) => typeof bankId === 'string' && allowedBankIds.has(bankId));

export const validateNoQuery = (req: Request, res: Response, next: NextFunction): Response | void => {
  const rejected = rejectUnexpectedQuery(req, res);
  if (rejected) return rejected;
  return next();
};

export const validateGenerateToken = (req: Request, res: Response, next: NextFunction): Response | void => {
  const rejected = rejectUnexpectedQuery(req, res);
  if (rejected) return rejected;

  const { idToken, bankId } = req.body || {};
  if (
    typeof bankId !== 'string' ||
    !allowedBankIds.has(bankId) ||
    typeof idToken !== 'string' ||
    !googleAuthCodePattern.test(idToken)
  ) {
    return rejectInvalid(res);
  }

  return next();
};

export const validateScrape = (req: Request, res: Response, next: NextFunction): Response | void => {
  const rejected = rejectUnexpectedQuery(req, res);
  if (rejected) return rejected;

  const { bankIds, email } = req.body || {};
  if (!validateBankIds(bankIds) || typeof email !== 'string' || !emailPattern.test(email)) {
    return rejectInvalid(res);
  }

  return next();
};

export const validateRemoveAccess = (req: Request, res: Response, next: NextFunction): Response | void => {
  const rejected = rejectUnexpectedQuery(req, res);
  if (rejected) return rejected;

  const { email } = req.body || {};
  const normalizedEmail = typeof email === 'string' ? email.trim().toLowerCase() : '';
  if (email === undefined || email === null || normalizedEmail === '') {
    return next();
  }

  if (!emailPattern.test(normalizedEmail)) {
    return rejectInvalid(res);
  }

  req.body.email = normalizedEmail;
  return next();
};
