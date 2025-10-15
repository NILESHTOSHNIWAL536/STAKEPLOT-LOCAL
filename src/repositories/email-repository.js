const {GoogleAuth} = require('../models/google-auth');
const {ScrapedEmail} = require('../models/scrape-result');
const creditCards = require('../utils/credit-cards.json');

async function upsertGoogleToken(userId, email, encryptedData, iv, authTag) {
  return await emailDB.model('googleAuth').findOneAndUpdate(
    { userId, email },
    {
      $set: {
        refreshToken: { encryptedData, iv, authTag },
      },
    },
    { upsert: true, new: true }
  );
}

async function getGoogleTokenByUserId(userId)
{
  return await emailDB.model('googleAuth').findOne({ userId });
}

async function scrapeEmailsByBankId(scrapedEmails) {
  return await emailDB.model('scrapeResult').insertMany(scrapedEmails);
}

async function getScrapedEmailsByUserId(userId) {
  return await emailDB.model('scrapeResult').find({ userId }).sort({ createdAt: -1 });
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
  return await emailDB.model('googleAuth').deleteOne({ userId });
}

module.exports = {
  getGoogleTokenByUserId,
  upsertGoogleToken,
  getScrapedEmailsByUserId,
  getUnlinkedCreditCards,
  deleteGoogleTokenByUserId,
  scrapeEmailsByBankId,
};
