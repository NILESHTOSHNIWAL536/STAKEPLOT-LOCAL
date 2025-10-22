const { google } = require('googleapis');
const axios = require('axios');
const { encryptToken, decryptToken } = require('../utils/encryption');
const { ServerConfig, RedisClient } = require('../config/index');
const EmailRepository = require('../repositories/email-repository');
const creditCards = require('../utils/credit-cards.json');
const emailScraperHelper = require('../utils/scraping-helper/email-scraper');

const CLIENT_ID = process.env.CLIENT_ID;
const CLIENT_SECRET = process.env.CLIENT_SECRET;
const REDIRECT_URI = '';

const oauth2Client = new google.auth.OAuth2(CLIENT_ID, CLIENT_SECRET, REDIRECT_URI);

async function generateAccessToken(userId, idToken) {
  // 1. Exchange idToken for tokens
  const { tokens } = await oauth2Client.getToken(idToken);
  oauth2Client.setCredentials(tokens);

  // 2. Get Gmail user info
  const oauth2 = google.oauth2({ auth: oauth2Client, version: 'v2' });
  const { data } = await oauth2.userinfo.get();
  const email = data.email;

  // Encrypt and store the refresh token securely
  if (tokens.refresh_token) {
    const { encryptedData, iv, authTag } = await encryptToken(tokens.refresh_token);
    await EmailRepository.upsertGoogleToken(userId, email, encryptedData, iv, authTag);
  }

  return { message: 'Access token generated and stored successfully' };
}

// scrape emails based on bank id
async function scrapeEmailsByBankId(userId, bankIds) {
  // Retrieve the stored Google token, and decrypt the refresh token
  const response = await EmailRepository.getGoogleTokenByUserId(userId);
  const encryptedRefreshToken = response.refreshToken;
  const decryptedRefreshToken = await decryptToken(encryptedRefreshToken.encryptedData, encryptedRefreshToken.iv, encryptedRefreshToken.authTag);
  // based on the bank id, get the credit card details
  const creditCard = creditCards.filter(card => bankIds.includes(card.bankId));
  // create Gmail client
  oauth2Client.setCredentials({ refresh_token: decryptedRefreshToken });
  const gmailClient = google.gmail({ version: 'v1', auth: oauth2Client });
  // Scrape emails using the helper function
  const scrapeEmailsUsingParser = await emailScraperHelper(gmailClient, creditCard);
 
  // Store scraped emails in the database
  const scrapedEmails = await EmailRepository.scrapeEmailsByBankId(scrapeEmailsUsingParser,userId);
  return scrapedEmails;
}

async function getScrapedEmails(userId) {
  const emails = await EmailRepository.getScrapedEmailsByUserId(userId);
  return emails;
}

async function getUnlinkedCreditCards(userId) {
  const cards = await EmailRepository.getUnlinkedCreditCards(userId);
  return cards;
}




async function removeAccessToken(userId) {
  
  // Remove cached access token
  const cacheKey = `google_access_token_${userId}`;
  await RedisClient.del(cacheKey);
  
  // Revoke token with Google
  const token = await EmailRepository.getDecryptedRefreshToken(userId);
  await axios.post(ServerConfig.REVOKE_URI, new URLSearchParams({ token }), { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } });
  
  await EmailRepository.deleteGoogleTokenByUserId(userId);

  return { message: 'Access token removed successfully' };
}

module.exports = {
  generateAccessToken,
  getScrapedEmails,
  getUnlinkedCreditCards,
  scrapeEmailsByBankId,
  removeAccessToken,
};
