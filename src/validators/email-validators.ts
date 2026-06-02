import { NextFunction, Request, Response } from 'express';
import creditCards from '../utils/credit-cards.json';

const allowedBankIds = new Set((creditCards as any[]).map((card) => card.bankId));
const emailPattern = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
const googleAuthCodePattern = /^[A-Za-z0-9._~+/=-]{1,4096}$/;
const sqlInjectionPayloadPattern =
  /(?:--|\/\*|\*\/|;|\b(?:or|and)\b\s+\d+\s*=\s*\d+|\bunion\b\s+\bselect\b|\bselect\b.+\bfrom\b|\binsert\b\s+\binto\b|\bupdate\b.+\bset\b|\bdelete\b\s+\bfrom\b|\bdrop\b\s+\b(?:table|database)\b|\bexec(?:ute)?\b)/i;

const rejectInvalid = (res: Response, message = 'Invalid request input') =>
  res.status(400).json({ success: false, error: message });

const rejectUnexpectedQuery = (req: Request, res: Response): Response | void => {
  if (Object.keys(req.query || {}).length > 0) return rejectInvalid(res);
};

const containsSqlInjectionPayload = (value: unknown): boolean => {
  if (typeof value === 'string') {
    return sqlInjectionPayloadPattern.test(value);
  }

  if (Array.isArray(value)) {
    return value.some(containsSqlInjectionPayload);
  }

  if (value && typeof value === 'object') {
    return Object.entries(value as Record<string, unknown>).some(
      ([key, nestedValue]) =>
        sqlInjectionPayloadPattern.test(key) || containsSqlInjectionPayload(nestedValue)
    );
  }

  return false;
};

const rejectSqlInjectionPayload = (req: Request, res: Response): Response | void => {
  if (containsSqlInjectionPayload(req.query) || containsSqlInjectionPayload(req.body)) {
    return res.status(403).json({ success: false, error: 'Forbidden request parameter' });
  }
};

const validateBankIds = (bankIds: unknown): bankIds is string[] =>
  Array.isArray(bankIds) &&
  bankIds.length > 0 &&
  bankIds.length <= 20 &&
  bankIds.every((bankId) => typeof bankId === 'string' && allowedBankIds.has(bankId));

export const validateNoQuery = (req: Request, res: Response, next: NextFunction): Response | void => {
  const rejectedPayload = rejectSqlInjectionPayload(req, res);
  if (rejectedPayload) return rejectedPayload;

  const rejected = rejectUnexpectedQuery(req, res);
  if (rejected) return rejected;
  return next();
};

export const validateGenerateToken = (req: Request, res: Response, next: NextFunction): Response | void => {
  const rejectedPayload = rejectSqlInjectionPayload(req, res);
  if (rejectedPayload) return rejectedPayload;

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
  const rejectedPayload = rejectSqlInjectionPayload(req, res);
  if (rejectedPayload) return rejectedPayload;

  const rejected = rejectUnexpectedQuery(req, res);
  if (rejected) return rejected;

  const { bankIds, email } = req.body || {};
  const normalizedEmail = typeof email === 'string' ? email.trim().toLowerCase() : '';

  if (!validateBankIds(bankIds) || !normalizedEmail || !emailPattern.test(normalizedEmail)) {
    return rejectInvalid(res);
  }

  req.body.email = normalizedEmail;
  return next();
};

export const validateStatementPassword = (req: Request, res: Response, next: NextFunction): Response | void => {
  const bodyWithoutPassword = { ...(req.body || {}), password: '' };
  if (containsSqlInjectionPayload(req.query) || containsSqlInjectionPayload(bodyWithoutPassword)) {
    return res.status(403).json({ success: false, error: 'Forbidden request parameter' });
  }

  const rejected = rejectUnexpectedQuery(req, res);
  if (rejected) return rejected;

  const { bankId, email, password, accountHint } = req.body || {};
  const normalizedEmail = typeof email === 'string' ? email.trim().toLowerCase() : '';

  if (
    typeof bankId !== 'string' ||
    !allowedBankIds.has(bankId) ||
    typeof password !== 'string' ||
    password.length === 0 ||
    password.length > 256 ||
    (email !== undefined && email !== null && !emailPattern.test(normalizedEmail)) ||
    (accountHint !== undefined && accountHint !== null && typeof accountHint !== 'string')
  ) {
    return rejectInvalid(res);
  }

  if (normalizedEmail) req.body.email = normalizedEmail;
  return next();
};

export const validateRemoveAccess = (req: Request, res: Response, next: NextFunction): Response | void => {
  const rejectedPayload = rejectSqlInjectionPayload(req, res);
  if (rejectedPayload) return rejectedPayload;

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
