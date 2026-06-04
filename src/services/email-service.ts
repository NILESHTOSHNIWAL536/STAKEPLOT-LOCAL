import { google } from 'googleapis';
import axios from 'axios';
import { URLSearchParams } from 'url';
import { encryptToken, decryptToken } from '../utils/encryption';
import { ServerConfig, RedisClient } from '../config';
import EmailRepository from '../repositories/email-repository';
import creditCards from '../utils/credit-cards.json';
import AppError from '../utils/app-error';
import { StatusCodes } from 'http-status-codes';
import { getModels } from '../models/index-model';
import { googleAuthSchema } from '../models/google-auth';
import {
  allowedBankIds,
  getOAuth2Client,
  initializeEmailScraper,
  normalizeEmail,
  sendPasswordRequiredEvent,
} from './email-scraper.helper';
import { buildPasswordRequests, StatementPasswordInput } from './email-password-request';
import { emailScraperHelper } from '../utils/scraping-helper/email-scraper';

function assertAllowedBankId(bankId: string) {
  if (!allowedBankIds.has(bankId)) {
    throw new AppError('Invalid bank ID', StatusCodes.BAD_REQUEST);
  }
}

export async function generateAccessToken(userId: string, authCode: string, bankId: string) {
  assertAllowedBankId(bankId);
  const { GoogleAuth, UserBankMap } = await getModels();

  const { tokens } = await getOAuth2Client().getToken(authCode);
  getOAuth2Client().setCredentials(tokens);

  const oauth2 = google.oauth2({ auth: getOAuth2Client(), version: 'v2' });
  const { data } = await oauth2.userinfo.get();

  const email = data.email!;
  if (!email) throw new Error('Email missing');

  // 🔥 HANDLE REFRESH TOKEN
  let existing = await GoogleAuth.findOne({ email });

  if (tokens.refresh_token) {
    const encrypted = await encryptToken(tokens.refresh_token);
    existing = await GoogleAuth.findOneAndUpdate(
      { email },
      { refreshToken: encrypted },
      { upsert: true, new: true }
    );
  }

  if (!existing) {
    throw new AppError('Reconnect required', StatusCodes.BAD_REQUEST);
  }

  // 🔥 USER BANK MAP
  let map = await UserBankMap.findOne({ userId });
  if (!map) {
    await UserBankMap.create({
      userId,
      mappings: [{ email, creditCardIds: [bankId] }],
    });
    return;
  }

  const group = map.mappings.find((m) => m.email === email);
  if (group) {
    if (group.creditCardIds.includes(bankId)) {
      // throw new AppError('Bank already connected', StatusCodes.INTERNAL_SERVER_ERROR);
      throw new AppError(
        JSON.stringify({
          message: 'Bank already connected',
          connectedIds: group.creditCardIds,
        }),
        StatusCodes.INTERNAL_SERVER_ERROR
      );
    }
    group.creditCardIds.push(bankId);
  } else {
    map.mappings.push({ email, creditCardIds: [bankId] });
  }
  await map.save();
}

export async function scrapeEmailsByBankId(
  userId: string,
  bankIds: string[],
  email: string
): Promise<any> {
  const normalizedEmail = normalizeEmail(email);
  const { gmailClient, creditCardConfigs } = await initializeEmailScraper(bankIds, normalizedEmail);

  const storedPasswords = await EmailRepository.getStatementPasswords(
    userId,
    bankIds,
    normalizedEmail
  );

  const scraperResult = await emailScraperHelper(
    gmailClient as any,
    creditCardConfigs,
    'initial',
    storedPasswords
  );

  if (scraperResult.requiresPassword) {
    return sendPasswordRequiredEvent(userId, scraperResult.passwordRequests || []);
  }

  const passwordRequests = buildPasswordRequests(scraperResult, creditCardConfigs);

  if (passwordRequests.length > 0) {
    return sendPasswordRequiredEvent(userId, passwordRequests);
  }

  return EmailRepository.scrapeEmailsByBankId(scraperResult, userId);
}

export async function saveStatementPassword(
  userId: string,
  input: StatementPasswordInput
): Promise<{ message: string }> {
  assertAllowedBankId(input.bankId);
  const password = String(input.password || '');

  if (!password || password.length > 256) {
    throw new AppError('Invalid PDF password', StatusCodes.BAD_REQUEST);
  }

  const normalizedEmail = input.email ? normalizeEmail(input.email) : undefined;

  await EmailRepository.upsertStatementPassword(
    userId,
    input.bankId,
    password,
    normalizedEmail,
    input.accountHint
  );

  return { message: 'Statement password saved successfully' };
}

export async function getScrapedEmails(userId: string): Promise<any> {
  const emails = await EmailRepository.getScrapedEmailsByUserId(userId);
  return emails;
}

export async function getUnlinkedCreditCards(userId: string): Promise<any> {
  const cards = await EmailRepository.getUnlinkedCreditCards(userId);
  return cards;
}

export async function removeAccessToken(
  userId: string,
  email?: string
): Promise<{ message: string }> {
  const emailToRemove = email || (await EmailRepository.getUserEmailById(userId));
  const normalizedEmail = normalizeEmail(emailToRemove);

  try {
    const cacheKey = `google_access_token_${normalizedEmail}`;
    await RedisClient.del(cacheKey);
  } catch (error) {}

  try {
    const token = await EmailRepository.getDecryptedRefreshToken(normalizedEmail);

    await axios.post(ServerConfig.REVOKE_URI, new URLSearchParams({ token }), {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    });
  } catch (error: any) {
    if (error?.statusCode !== StatusCodes.NOT_FOUND) {
      throw error;
    }
  }

  await EmailRepository.deleteGoogleTokenByEmail(normalizedEmail);
  await EmailRepository.removeUserBankMapEmailMapping(userId, normalizedEmail);

  return { message: 'Access token removed successfully' };
}

 const addBankMapping = async (email: string, bankId: string,userId:string) => {
  // const map = await EmailBankMapping.findOne();
    const { UserBankMap } = await getModels();
  let map = await UserBankMap.findOne({ userId });

  if (!map) {
    throw new AppError('Mapping document not found', StatusCodes.NOT_FOUND);
  }

  const group = map.mappings.find((m) => m.email === email);

  if (group) {
    if (!group.creditCardIds.includes(bankId)) {
      group.creditCardIds.push(bankId);
    }
  } else {
    map.mappings.push({
      email,
      creditCardIds: [bankId],
    });
  }
  await map.save();
  return {
    email,
    connectedIds: group?.creditCardIds ?? [bankId],
  };
};

export default {
  generateAccessToken,
  getScrapedEmails,
  getUnlinkedCreditCards,
  scrapeEmailsByBankId,
  saveStatementPassword,
  removeAccessToken,
  addBankMapping
};
