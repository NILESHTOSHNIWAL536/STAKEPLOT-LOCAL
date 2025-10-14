const GoogleAuth = require('../models/google-auth');
const ScrapedEmail = require('../models/scrape-result');
const creditCards = require('../utils/credit-cards.json');

async function upsertGoogleToken(userId, email, encryptedData, iv, authTag) {
  return await GoogleAuth.findOneAndUpdate(
    { userId, email },
    {
      $set: {
        refreshToken: { encryptedData, iv, authTag },
      },
    },
    { upsert: true, new: true }
  );
}

async function getGoogleTokenByUserId(userId) {
  return await GoogleAuth.findOne({ userId });
}

async function scrapeEmailsByBankId(scrapedEmails) {
  return await ScrapedEmail.insertMany(scrapedEmails);
}

async function getScrapedEmailsByUserId(userId) {
  return await ScrapedEmail.find({ userId }).sort({ createdAt: -1 });
}

async function getUnlinkedCreditCards(userId) {
  const user = await mainDB.collection('users').findOne({ _id: userId });
  if (!user) {
    throw new Error('User not found');
  }
  const linkedBankIds = user.CreditCardLinkedBanks || [];
  // Filter out cards whose bankId is not in linkedBankIds
  const unlinkedCards = creditCards.filter((card) => !linkedBankIds.includes(card.bankId));
  return unlinkedCards;
}

async function deleteGoogleTokenByUserId(userId) {
  return await GoogleAuth.deleteOne({ userId });
}

module.exports = {
  getGoogleTokenByUserId,
  upsertGoogleToken,
  getScrapedEmailsByUserId,
  getUnlinkedCreditCards,
  deleteGoogleTokenByUserId,
  scrapeEmailsByBankId,
};
