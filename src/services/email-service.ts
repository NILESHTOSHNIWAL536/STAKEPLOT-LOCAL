// const { google } = require('googleapis');
// const axios = require('axios');
// const { encryptToken, decryptToken } = require('../utils/encryption');
// const { ServerConfig, RedisClient } = require('../config/index');
// const EmailRepository = require('../repositories/email-repository');
// const creditCards = require('../utils/credit-cards.json');
// const emailScraperHelper = require('../utils/scraping-helper/email-scraper');
// const AppError = require('../utils/app-error');
// const { StatusCodes } = require('http-status-codes');

// const CLIENT_ID = process.env.CLIENT_ID;
// const CLIENT_SECRET = process.env.CLIENT_SECRET;
// const REDIRECT_URI = '';

// const oauth2Client = new google.auth.OAuth2(CLIENT_ID, CLIENT_SECRET, REDIRECT_URI);

// async function generateAccessToken(userId, idToken) {
//   // 1. Exchange idToken for tokens
//   const { tokens } = await oauth2Client.getToken(idToken);
//   oauth2Client.setCredentials(tokens);

//   // 2. Get Gmail user info
//   const oauth2 = google.oauth2({ auth: oauth2Client, version: 'v2' });
//   const { data } = await oauth2.userinfo.get();
//   const email = data.email;

//   // Encrypt and store the refresh token securely
//   if (tokens.refresh_token) {
//     const { encryptedData, iv, authTag } = await encryptToken(tokens.refresh_token);
//     await EmailRepository.upsertGoogleToken(userId, email, encryptedData, iv, authTag);
//   }

//   return { message: 'Access token generated and stored successfully' };
// }

// // scrape emails based on bank id
// async function scrapeEmailsByBankId(userId, bankIds) {
//   // Retrieve the stored Google token, and decrypt the refresh token
//   const response = await EmailRepository.getGoogleTokenByUserId(userId);
//   const encryptedRefreshToken = response.refreshToken;
//   const decryptedRefreshToken = await decryptToken(encryptedRefreshToken.encryptedData, encryptedRefreshToken.iv, encryptedRefreshToken.authTag);
//   // based on the bank id, get the credit card details
//   const creditCard = creditCards.filter(card => bankIds.includes(card.bankId));

//   if(creditCard.length===0){
//     throw new AppError('No credit card found for the provided bank IDs',StatusCodes.BAD_REQUEST);
//   }
//   // create Gmail client
//   oauth2Client.setCredentials({ refresh_token: decryptedRefreshToken });
//   const gmailClient = google.gmail({ version: 'v1', auth: oauth2Client });
//   // Scrape emails using the helper function
//   const scrapeEmailsUsingParser = await emailScraperHelper(gmailClient, creditCard);
 
//   // Store scraped emails in the database
//   const scrapedEmails = await EmailRepository.scrapeEmailsByBankId(scrapeEmailsUsingParser,userId);
//   return scrapedEmails;
// }

// async function getScrapedEmails(userId) {
//   const emails = await EmailRepository.getScrapedEmailsByUserId(userId);
//   return emails;
// }

// async function getUnlinkedCreditCards(userId) {
//   const cards = await EmailRepository.getUnlinkedCreditCards(userId);
//   return cards;
// }




// async function removeAccessToken(userId) {
  
//   // Remove cached access token
//   const cacheKey = `google_access_token_${userId}`;
//   await RedisClient.del(cacheKey);
  
//   // Revoke token with Google
//   const token = await EmailRepository.getDecryptedRefreshToken(userId);
//   await axios.post(ServerConfig.REVOKE_URI, new URLSearchParams({ token }), { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } });
  
//   await EmailRepository.deleteGoogleTokenByUserId(userId);

//   return { message: 'Access token removed successfully' };
// }

// module.exports = {
//   generateAccessToken,
//   getScrapedEmails,
//   getUnlinkedCreditCards,
//   scrapeEmailsByBankId,
//   removeAccessToken,
// };


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

const CLIENT_ID = process.env.CLIENT_ID || '';
const CLIENT_SECRET = process.env.CLIENT_SECRET || '';
const REDIRECT_URI = '';

const oauth2Client = new google.auth.OAuth2(
  CLIENT_ID,
  CLIENT_SECRET,
  REDIRECT_URI
);

export async function generateAccessToken(
  userId: string,
  idToken: string
): Promise<{ message: string }> {
  const { tokens } = await oauth2Client.getToken(idToken);
  oauth2Client.setCredentials(tokens);

  const oauth2 = google.oauth2({ auth: oauth2Client, version: 'v2' });
  const { data } = await oauth2.userinfo.get();
  const email = data.email || '';

  if (tokens.refresh_token) {
    const { encryptedData, iv, authTag } = await encryptToken(
      tokens.refresh_token
    );
    await EmailRepository.upsertGoogleToken(
      userId,
      email,
      encryptedData,
      iv,
      authTag
    );
  }

  return { message: 'Access token generated and stored successfully' };
}

export async function scrapeEmailsByBankId(
  userId: string,
  bankIds: string[]
): Promise<any> {
  const response = await EmailRepository.getGoogleTokenByUserId(userId);
  const encryptedRefreshToken = response.refreshToken;
  console.log('Encrypted Refresh Token:', encryptedRefreshToken); // Debug log for encrypted token
  console.log('Bank IDs:', response); // Debug log for bank IDs
  const decryptedRefreshToken = await decryptToken(
    encryptedRefreshToken.encryptedData,
    encryptedRefreshToken.iv,
    encryptedRefreshToken.authTag
  );

  const creditCard = (creditCards as any[]).filter((card) =>
    bankIds.includes(card.bankId)
  );

  if (creditCard.length === 0) {
    throw new AppError(
      'No credit card found for the provided bank IDs',
      StatusCodes.BAD_REQUEST
    );
  }

  oauth2Client.setCredentials({ refresh_token: decryptedRefreshToken });
  const gmailClient = google.gmail({ version: 'v1', auth: oauth2Client });

  const scrapeEmailsUsingParser = await emailScraperHelper(
    gmailClient as any,
    creditCard
  );

  const scrapedEmails = await EmailRepository.scrapeEmailsByBankId(
    scrapeEmailsUsingParser,
    userId
  );

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

export async function removeAccessToken(
  userId: string
): Promise<{ message: string }> {
  const cacheKey = `google_access_token_${userId}`;
  await RedisClient.del(cacheKey);

  const token = await EmailRepository.getDecryptedRefreshToken(userId);

  await axios.post(
    ServerConfig.REVOKE_URI,
    new URLSearchParams({ token }),
    {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    }
  );

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
