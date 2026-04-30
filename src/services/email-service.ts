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

const CLIENT_ID = process.env.CLIENT_ID || '';
const CLIENT_SECRET = process.env.CLIENT_SECRET || '';
const REDIRECT_URI = '';

const oauth2Client = new google.auth.OAuth2(CLIENT_ID, CLIENT_SECRET, REDIRECT_URI);

export async function generateAccessToken(userId: string, authCode: string, bankId: string) {
  const { GoogleAuth, UserBankMap } = await getModels();

  const { tokens } = await oauth2Client.getToken(authCode);
  oauth2Client.setCredentials(tokens);

  const oauth2 = google.oauth2({ auth: oauth2Client, version: 'v2' });
  const { data } = await oauth2.userinfo.get();

  const email = data.email!;
  if (!email) throw new Error('Email missing');

  // 🔥 HANDLE REFRESH TOKEN
  let existing = await GoogleAuth.findOne({ email });

  if (tokens.refresh_token) {
    const encrypted = await encryptToken(tokens.refresh_token);

    existing = await GoogleAuth.findOneAndUpdate({ email }, { refreshToken: encrypted }, { upsert: true, new: true });
  }

  if (!existing){
    //  throw new Error('Reconnect required');
      throw new AppError('Reconnect required', StatusCodes.BAD_REQUEST);
  }

  // 🔥 USER BANK MAP
  let map = await UserBankMap.findOne({ userId });
  console.log("Existing map:", map);
  if (!map) {
    await UserBankMap.create({
      userId,
      mappings: [{ email, creditCardIds: [bankId] }],
    });
    return;
  }

  const group = map.mappings.find((m) => m.email === email);
  console.log("Existing group for email:", group);
  if (group) {
    if (group.creditCardIds.includes(bankId)) {
      throw new AppError('Bank already connected', StatusCodes.INTERNAL_SERVER_ERROR);
    }
    group.creditCardIds.push(bankId);
  } else {
    map.mappings.push({ email, creditCardIds: [bankId] });
  }
  console.log("Updated mapping:", map);
  await map.save();
}

// export async function generateAccessToken(
//   userId: string,
//   idToken: string
// ): Promise<{ message: string }> {
//   const { tokens } = await oauth2Client.getToken(idToken);
//   oauth2Client.setCredentials(tokens);

//   const oauth2 = google.oauth2({ auth: oauth2Client, version: 'v2' });
//   const { data } = await oauth2.userinfo.get();
//   const email = data.email || '';

//   console.log('Generated Access Token:', tokens);
//   console.log('Generated Refresh Token:', email);

//   if (tokens.refresh_token) {
//     const { encryptedData, iv, authTag } = await encryptToken(
//       tokens.refresh_token
//     );
//     await EmailRepository.upsertGoogleToken(
//       userId,
//       email,
//       encryptedData,
//       iv,
//       authTag
//     );
//   }

//   return { message: 'Access token generated and stored successfully' };
// }

// export async function scrapeEmailsByBankId(
//   userId: string,
//   bankIds: string[]
// ): Promise<any> {
//   const response = await EmailRepository.getGoogleTokenByUserId(userId);
//   const encryptedRefreshToken = response.refreshToken;
//   const decryptedRefreshToken = await decryptToken(
//     encryptedRefreshToken.encryptedData,
//     encryptedRefreshToken.iv,
//     encryptedRefreshToken.authTag
//   );

export async function scrapeEmailsByBankId(userId: string, bankIds: string[], email: string): Promise<any> {
  // 🔥 1. Get token by EMAIL (not userId)
  const emailDB = (global as any).emailDB;

  // ✅ Get model safely (no overwrite error)
  const GoogleAuth = emailDB.models.googleAuth || emailDB.model('googleAuth', googleAuthSchema);

  const googleAuth = await GoogleAuth.findOne({ email });

  if (!googleAuth) {
    throw new Error(`No refresh token found for ${email}`);
  }

  // 🔥 2. Decrypt refresh token
  const decryptedRefreshToken = await decryptToken(googleAuth.refreshToken.encryptedData, googleAuth.refreshToken.iv, googleAuth.refreshToken.authTag);
  console.log("decryptedRefreshToken")
  console.log(decryptedRefreshToken)
  const creditCard = (creditCards as any[]).filter((card) => bankIds.includes(card.bankId));

  if (creditCard.length === 0) {
    throw new AppError('No credit card found for the provided bank IDs', StatusCodes.BAD_REQUEST);
  }

  oauth2Client.setCredentials({ refresh_token: decryptedRefreshToken });
  const gmailClient = google.gmail({ version: 'v1', auth: oauth2Client });

  const scrapeEmailsUsingParser = await emailScraperHelper(gmailClient as any, creditCard);

  const scrapedEmails = await EmailRepository.scrapeEmailsByBankId(scrapeEmailsUsingParser, userId);

  return scrapedEmails;
}

export async function getScrapedEmails(userId: string): Promise<any> {
  const emails = await EmailRepository.getScrapedEmailsByUserId(userId);
  return emails;
}

export async function getUnlinkedCreditCards(userId: string): Promise<any> {
  const cards = await EmailRepository.getUnlinkedCreditCards(userId);
  return cards;
}

export async function removeAccessToken(userId: string): Promise<{ message: string }> {
  const cacheKey = `google_access_token_${userId}`;
  await RedisClient.del(cacheKey);

  const token = await EmailRepository.getDecryptedRefreshToken(userId);

  await axios.post(ServerConfig.REVOKE_URI, new URLSearchParams({ token }), {
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
  });

  await EmailRepository.deleteGoogleTokenByUserId(userId);

  return { message: 'Access token removed successfully' };
}

export default {
  generateAccessToken,
  getScrapedEmails,
  getUnlinkedCreditCards,
  scrapeEmailsByBankId,
  removeAccessToken,
};
