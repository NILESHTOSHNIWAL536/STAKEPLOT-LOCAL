const { GoogleAuth } = require('../models/google-auth');
const { ScrapedEmail } = require('../models/scrape-result');
const { encryptToken, decryptToken } = require('../utils/encryption');
const creditCards = require('../utils/credit-cards.json');
const mongoose = require('mongoose');

async function upsertGoogleToken(userId, email, encryptedData, iv, authTag) {
  return await emailDB.model('googleAuth').findOneAndUpdate(
    { userId: { $eq: new mongoose.Types.ObjectId(userId) } },
    {
      $set: {
        refreshToken: { encryptedData, iv, authTag },
      },
    },
    { upsert: true, new: true }
  );
}

async function getGoogleTokenByUserId(userId) {
  return await emailDB.model('googleAuth').findOne({ userId: { $eq: new mongoose.Types.ObjectId(userId) } });
}

async function scrapeEmailsByBankId(scrapedEmails, userId) {
  try {
    if (!Array.isArray(scrapedEmails?.results) || scrapedEmails.results.length === 0) {
      return {};
    }

    const records = scrapedEmails.results
      .filter((obj) => obj.matched_bank != null)
      .map((obj) => {
        const matchedBank = scrapedEmails.bankConfig.find((b) => b.name.toLowerCase().includes(obj.matched_bank.toLowerCase()));

        // Fallback if no match is found
        const bankInfo = matchedBank || { name: obj.matched_bank, logo: '', bankId: '' };

        return {
          ...obj,
          userId,
          logo: bankInfo.logo,
          bankName: bankInfo.name,
          bankId: bankInfo.bankId,
        };
      });

    await emailDB.model('scrapeResult').insertMany(records);

    if (scrapedEmails.bankConfig && scrapedEmails.bankConfig.bankId) {
      await mainDB.model('User').findByIdAndUpdate(
        new mongoose.Types.ObjectId(userId),
        { $addToSet: { CreditCardLinkedBanks: scrapedEmails.bankConfig.bankId } }, // prevent duplicates
        { new: true }
      );
    }
    return records;
  } catch (err) {
    console.error('Error in scrapeEmailsByBankId:', err);
    throw err;
  }
}

async function getScrapedEmailsByUserId(userId) {
  return await emailDB
    .model('scrapeResult')
    .find({ userId: { $eq: new mongoose.Types.ObjectId(userId) } })
    .sort({ createdAt: -1 });
}

async function getUnlinkedCreditCards(userId) {
  const user = await mainDB.collection('users').findOne({ _id: new mongoose.Types.ObjectId(userId) });
  if (!user) {
    throw new Error('User not found');
  }
  const linkedBankIds = user.CreditCardLinkedBanks || [];
  // Filter out cards whose bankId is not in linkedBankIds
  const unlinkedCards = creditCards.filter((card) => !linkedBankIds.includes(card.bankId));
  return unlinkedCards;
}

async function deleteGoogleTokenByUserId(userId) {
  return await emailDB.model('googleAuth').deleteOne({ userId: { $eq: new mongoose.Types.ObjectId(userId) } });
}

async function getDecryptedRefreshToken(userId) {
  const user = await emailDB.model('googleAuth').findOne({
    userId: userId, // the User's _id
    'refreshToken.encryptedData': { $exists: true, $ne: '' }, // optional filter
  });

  if (!user || !user.refreshToken?.encryptedData) {
    throw new Error('No refresh token found');
  }
  return decryptToken(user.refreshToken.encryptedData, user.refreshToken.iv, user.refreshToken.authTag);
}

module.exports = {
  getGoogleTokenByUserId,
  upsertGoogleToken,
  getScrapedEmailsByUserId,
  getUnlinkedCreditCards,
  deleteGoogleTokenByUserId,
  scrapeEmailsByBankId,
  getDecryptedRefreshToken,
};
