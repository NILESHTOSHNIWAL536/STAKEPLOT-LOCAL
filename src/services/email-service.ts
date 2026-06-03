import { google } from 'googleapis';
import axios from 'axios';
import { URLSearchParams } from 'url';
import { encryptToken, decryptToken } from '../utils/encryption';
import { ServerConfig, RedisClient } from '../config';
import EmailRepository from '../repositories/email-repository';
import creditCards from '../utils/credit-cards.json';
import emailScraperHelper from '../utils/scraping-helper/email-scraper';
import AppError from '../utils/app-error';
import { StatusCodes } from 'http-status-codes';
import { getModels } from '../models/index-model';
import { googleAuthSchema } from '../models/google-auth';

// Client created lazily so CLIENT_SECRET (from loadSecrets) and REDIRECT_URI are
// read after process.env is fully populated — not at module-import time.
let _oauth2Client: InstanceType<typeof google.auth.OAuth2> | null = null;

const getOAuth2Client = () => {
  if (!_oauth2Client) {
    _oauth2Client = new google.auth.OAuth2(
      process.env.CLIENT_ID || '',
      process.env.CLIENT_SECRET || '',
      '',
    );
  }
  return _oauth2Client;
};
const allowedBankIds = new Set((creditCards as any[]).map((card) => card.bankId));
const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

type StatementPasswordInput = {
  bankId: string;
  password: string;
  email?: string;
  accountHint?: string;
};

async function publishSocketEvent(userId: string, event: string, data: any): Promise<void> {
  try {
    const subscribers = await RedisClient.publish(
      'email-events',
      JSON.stringify({ userId, event, data })
    );
    console.log(`Published socket event '${event}' for user ${userId}. Subscribers: ${subscribers}`);
  } catch (error: any) {
    console.error(`Failed to publish socket event '${event}' for user ${userId}:`, error?.message || error);
    throw error;
  }
}

function assertAllowedBankId(bankId: string) {
  if (!allowedBankIds.has(bankId)) {
    throw new AppError('Invalid bank ID', StatusCodes.BAD_REQUEST);
  }
}

function normalizeEmail(email: string): string {
  const normalized = String(email || '').trim().toLowerCase();
  if (!emailPattern.test(normalized)) {
    throw new AppError('Invalid email', StatusCodes.BAD_REQUEST);
  }
  return normalized;
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
    existing = await GoogleAuth.findOneAndUpdate({ email }, { refreshToken: encrypted }, { upsert: true, new: true });
  }

  // if (tokens.refresh_token) {
  //   const userEmail = await EmailRepository.getUserEmailById(userId);
  //   const normalizedUserEmail = normalizeEmail(userEmail);
  //   const encrypted = await encryptToken(tokens.refresh_token);
  //   await GoogleAuth.findOneAndUpdate({ email }, { refreshToken: encrypted }, { upsert: true, new: true });
  //   existing = await GoogleAuth.findOneAndUpdate({ email: normalizedUserEmail }, { refreshToken: encrypted }, { upsert: true, new: true });
  // }

  if (!existing) {
    //  throw new Error('Reconnect required');
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
      throw new AppError('Bank already connected', StatusCodes.INTERNAL_SERVER_ERROR);
    }
    group.creditCardIds.push(bankId);
  } else {
    map.mappings.push({ email, creditCardIds: [bankId] });
  }
  await map.save();
}



export async function scrapeEmailsByBankId(userId: string, bankIds: string[], email: string): Promise<any> {
  const normalizedEmail = normalizeEmail(email);
  if (!Array.isArray(bankIds) || bankIds.some((bankId) => !allowedBankIds.has(bankId))) {
    throw new AppError('Invalid bank ID', StatusCodes.BAD_REQUEST);
  }

  // 🔥 1. Get token by EMAIL (not userId)
  const emailDB = (global as any).emailDB;

  // ✅ Get model safely (no overwrite error)
  const GoogleAuth = emailDB.models.googleAuth || emailDB.model('googleAuth', googleAuthSchema);

  const googleAuth = await GoogleAuth.findOne({ email: normalizedEmail });

  if (!googleAuth) {
    throw new AppError('Unauthorized', StatusCodes.UNAUTHORIZED);
  }

  // 🔥 2. Decrypt refresh token
  const decryptedRefreshToken = await decryptToken(googleAuth.refreshToken.encryptedData, googleAuth.refreshToken.iv, googleAuth.refreshToken.authTag);
  const creditCard = (creditCards as any[]).filter((card) => bankIds.includes(card.bankId));

  if (creditCard.length === 0) {
    throw new AppError('No credit card found for the provided bank IDs', StatusCodes.BAD_REQUEST);
  }

  getOAuth2Client().setCredentials({ refresh_token: decryptedRefreshToken });
  const gmailClient = google.gmail({ version: 'v1', auth: getOAuth2Client() });

  const storedPasswords = await EmailRepository.getStatementPasswords(userId, bankIds, normalizedEmail);
  const scrapeEmailsUsingParser = await emailScraperHelper(
    gmailClient as any,
    creditCard,
    'initial',
    storedPasswords
  );
  if (scrapeEmailsUsingParser.requiresPassword) {
    const payload = {
      requiresPassword: true,
      status: 'password_required',
      message: 'PDF statement password is required for extraction.',
      passwordRequests: scrapeEmailsUsingParser.passwordRequests || [],
    };

    await markInvalidStatementPasswordsFromRequests(userId, payload.passwordRequests, normalizedEmail);
    await publishSocketEvent(userId, 'statementPasswordRequired', payload);
    return payload;
  }

  const passwordRequests = buildPasswordRequests(scrapeEmailsUsingParser, creditCard);
  console.log(passwordRequests);
  if (passwordRequests.length > 0) {
    const payload = {
      requiresPassword: true,
      status: 'password_required',
      message: 'PDF statement password is required for extraction.',
      passwordRequests,
    };
     console.log(payload);
    await markInvalidStatementPasswordsFromRequests(userId, passwordRequests, normalizedEmail);
    await publishSocketEvent(userId, 'statementPasswordRequired', payload);

    return payload;
  }

  const scrapedEmails = await EmailRepository.scrapeEmailsByBankId(scrapeEmailsUsingParser, userId);

  return scrapedEmails;
}

function buildPasswordRequests(scrapedEmails: any, bankConfig: any[]) {
  const results = Array.isArray(scrapedEmails?.results) ? scrapedEmails.results : [];
  const requests = new Map<string, any>();

  for (const result of results) {
    if (!result?.sources_processed?.needs_password) continue;

    const matchedBank = resolveMatchedBank(result, bankConfig);
    const bankId = matchedBank?.bankId || '';
    const key = `${bankId}:${result.message_id || result.messageId || result.subject || ''}`;

    requests.set(key, {
      bankId,
      bankName: matchedBank?.name || result.matched_bank || 'Bank statement',
      messageId: result.message_id || result.messageId || '',
      filename: result.sources_processed?.password_file || '',
      reason: result.sources_processed?.password_error || 'password_required',
    });
  }

  return Array.from(requests.values());
}

function resolveMatchedBank(result: any, bankConfig: any[]) {
  const matched = String(result?.matched_bank || '').toLowerCase();
  return bankConfig.find((bank) => {
    const name = String(bank.name || '').toLowerCase();
    const bankId = String(bank.bankId || '').toLowerCase();
    return (
      (matched && (name.includes(matched) || matched.includes(name))) ||
      (bankId && matched === bankId)
    );
  }) || bankConfig[0];
}

async function markInvalidStatementPasswordsFromRequests(
  userId: string,
  passwordRequests: any[],
  email: string
) {
  const invalidRequests = (passwordRequests || []).filter(
    (request) => request?.bankId && request?.reason === 'invalid_password'
  );

  await Promise.all(
    invalidRequests.map((request) =>
      EmailRepository.markStatementPasswordInvalid(
        userId,
        String(request.bankId),
        email,
        'Invalid PDF password'
      )
    )
  );
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

export async function removeAccessToken(userId: string, email?: string): Promise<{ message: string }> {
  const emailToRemove = email || await EmailRepository.getUserEmailById(userId);
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

export default {
  generateAccessToken,
  getScrapedEmails,
  getUnlinkedCreditCards,
  scrapeEmailsByBankId,
  saveStatementPassword,
  removeAccessToken,
};
