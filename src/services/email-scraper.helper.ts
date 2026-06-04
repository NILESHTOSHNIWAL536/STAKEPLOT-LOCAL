import { google } from 'googleapis';
import { StatusCodes } from 'http-status-codes';
import AppError from '../utils/app-error';
import creditCards from '../utils/credit-cards.json';
import { googleAuthSchema } from '../models/google-auth';
import { RedisClient } from '../config';
import { decryptToken } from '../utils/encryption';


export const allowedBankIds = new Set((creditCards as any[]).map((card) => card.bankId));

let _oauth2Client: InstanceType<typeof google.auth.OAuth2> | null = null;

export const getOAuth2Client = () => {
  if (!_oauth2Client) {
    _oauth2Client = new google.auth.OAuth2(
      process.env.CLIENT_ID || '',
      process.env.CLIENT_SECRET || '',
      ''
    );
  }
  return _oauth2Client;
};

const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export function normalizeEmail(email: string): string {
  const normalized = String(email || '')
    .trim()
    .toLowerCase();
  if (!emailPattern.test(normalized)) {
    throw new AppError('Invalid email', StatusCodes.BAD_REQUEST);
  }
  return normalized;
}




export async function getGoogleAuthByEmail(normalizedEmail: string) {
  const emailDB = (global as any).emailDB;

  const GoogleAuth = emailDB.models.googleAuth || emailDB.model('googleAuth', googleAuthSchema);

  const googleAuth = await GoogleAuth.findOne({
    email: normalizedEmail,
  });

  if (!googleAuth) {
    throw new AppError('Unauthorized', StatusCodes.UNAUTHORIZED);
  }

  return googleAuth;
}

export function validateBankIds(bankIds: string[]) {
  if (!Array.isArray(bankIds) || bankIds.some((bankId) => !allowedBankIds.has(bankId))) {
    throw new AppError('Invalid bank ID', StatusCodes.BAD_REQUEST);
  }
}

export function getCreditCardConfigs(bankIds: string[]) {
  const cards = (creditCards as any[]).filter((card) => bankIds.includes(card.bankId));

  if (cards.length === 0) {
    throw new AppError('No credit card found for the provided bank IDs', StatusCodes.BAD_REQUEST);
  }

  return cards;
}

export function createGmailClient(oauthClient: any) {
  return google.gmail({
    version: 'v1',
    auth: oauthClient,
  });
}

export async function sendPasswordRequiredEvent(userId: string, passwordRequests: any[]) {
  const payload = {
    requiresPassword: true,
    status: 'password_required',
    message: 'PDF statement password is required for extraction.',
    passwordRequests,
  };

  await publishSocketEvent(userId, 'statementPasswordRequired', payload);

  return payload;
}

async function publishSocketEvent(userId: string, event: string, data: any): Promise<void> {
  try {
    await RedisClient.publish('email-events', JSON.stringify({ userId, event, data }));
  } catch (error: any) {
    throw error;
  }
}


export async function initializeEmailScraper(
  bankIds: string[],
  normalizedEmail: string
) {
  validateBankIds(bankIds);

  const googleAuth =
    await getGoogleAuthByEmail(normalizedEmail);

  const refreshToken = await decryptToken(
    googleAuth.refreshToken.encryptedData,
    googleAuth.refreshToken.iv,
    googleAuth.refreshToken.authTag
  );

  const oauthClient = getOAuth2Client();

  oauthClient.setCredentials({
    refresh_token: refreshToken,
  });

  return {
    gmailClient: createGmailClient(oauthClient),
    creditCardConfigs: getCreditCardConfigs(bankIds),
  };
}