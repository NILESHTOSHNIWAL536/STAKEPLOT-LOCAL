// const { GoogleAuth } = require('../models/google-auth');
// const { ScrapedEmail } = require('../models/scrape-result');
// const { encryptToken, decryptToken } = require('../utils/encryption');
// const creditCards = require('../utils/credit-cards.json');
// const mongoose = require('mongoose');

// async function upsertGoogleToken(userId, email, encryptedData, iv, authTag) {
//   return await emailDB.model('googleAuth').findOneAndUpdate(
//     { userId: { $eq: new mongoose.Types.ObjectId(userId) } },
//     {
//       $set: {
//         refreshToken: { encryptedData, iv, authTag },
//       },
//     },
//     { upsert: true, new: true }
//   );
// }

// async function getGoogleTokenByUserId(userId) {
//   return await emailDB.model('googleAuth').findOne({ userId: new mongoose.Types.ObjectId(userId) });
// }

// async function scrapeEmailsByBankId(scrapedEmails, userId) {
//   try {
//     if (!Array.isArray(scrapedEmails?.results) || scrapedEmails.results.length === 0) {
//       return {};
//     }

//     const records = scrapedEmails.results
//       .filter((obj) => obj.matched_bank != null)
//       .map((obj) => {
//         const matchedBank = scrapedEmails.bankConfig.find((b) => b.name.toLowerCase().includes(obj.matched_bank.toLowerCase()));

//         // Fallback if no match is found
//         const bankInfo = matchedBank || { name: obj.matched_bank, logo: '', bankId: '' };

//         return {
//           ...obj,
//           userId,
//           logo: bankInfo.logo,
//           bankName: bankInfo.name,
//           bankId: bankInfo.bankId,
//         };
//       });

//     await emailDB.model('scrapeResult').insertMany(records);

//     if (scrapedEmails.bankConfig && scrapedEmails.bankConfig.bankId) {
//       await mainDB.model('User').findByIdAndUpdate(
//         new mongoose.Types.ObjectId(userId),
//         { $addToSet: { CreditCardLinkedBanks: scrapedEmails.bankConfig.bankId } }, // prevent duplicates
//         { new: true }
//       );
//     }
//     return records;
//   } catch (err) {
//     console.error('Error in scrapeEmailsByBankId:', err);
//     throw err;
//   }
// }

// async function getScrapedEmailsByUserId(userId) {
//   return await emailDB
//     .model('scrapeResult')
//     .find({ userId: { $eq: new mongoose.Types.ObjectId(userId) } })
//     .sort({ createdAt: -1 });
// }

// async function getUnlinkedCreditCards(userId) {
//   const user = await mainDB.collection('users').findOne({ _id: new mongoose.Types.ObjectId(userId) });
//   if (!user) {
//     throw new Error('User not found');
//   }
//   const linkedBankIds = user.CreditCardLinkedBanks || [];
//   // Filter out cards whose bankId is not in linkedBankIds
//   const unlinkedCards = creditCards.filter((card) => !linkedBankIds.includes(card.bankId));
//   return unlinkedCards;
// }

// async function deleteGoogleTokenByUserId(userId) {
//   return await emailDB.model('googleAuth').deleteOne({ userId: { $eq: new mongoose.Types.ObjectId(userId) } });
// }

// async function getDecryptedRefreshToken(userId) {
//   const user = await emailDB.model('googleAuth').findOne({
//     userId: userId, // the User's _id
//     'refreshToken.encryptedData': { $exists: true, $ne: '' }, // optional filter
//   });

//   if (!user || !user.refreshToken?.encryptedData) {
//     throw new Error('No refresh token found');
//   }
//   return decryptToken(user.refreshToken.encryptedData, user.refreshToken.iv, user.refreshToken.authTag);
// }

// module.exports = {
//   getGoogleTokenByUserId,
//   upsertGoogleToken,
//   getScrapedEmailsByUserId,
//   getUnlinkedCreditCards,
//   deleteGoogleTokenByUserId,
//   scrapeEmailsByBankId,
//   getDecryptedRefreshToken,
// };


import mongoose from 'mongoose';
import { decryptToken } from '../utils/encryption';
import creditCards from '../utils/credit-cards.json';

// If you want, you can define a type for creditCards
type CreditCardConfig = {
  bankId: string;
  [key: string]: any;
};

export async function upsertGoogleToken(
  userId: string,
  email: string, // not used currently, kept for signature
  encryptedData: string,
  iv: string,
  authTag: string
) {
  const emailDB = (global as any).emailDB;

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

export async function getGoogleTokenByUserId(userId: string) {
  const emailDB = (global as any).emailDB;

  return await emailDB
    .model('googleAuth')
    .findOne({ userId: new mongoose.Types.ObjectId(userId) });
}

export async function scrapeEmailsByBankId(
  scrapedEmails: any,
  userId: string
) {
  try {
    if (
      !Array.isArray(scrapedEmails?.results) ||
      scrapedEmails.results.length === 0
    ) {
      return {};
    }

    const records = scrapedEmails.results
      .filter((obj: any) => obj.matched_bank != null)
      .map((obj: any) => {
        const matchedBank =
          scrapedEmails.bankConfig &&
          scrapedEmails.bankConfig.find((b: any) =>
            b.name.toLowerCase().includes(obj.matched_bank.toLowerCase())
          );

        const bankInfo =
          matchedBank || { name: obj.matched_bank, logo: '', bankId: '' };

        return {
          ...obj,
          userId,
          logo: bankInfo.logo,
          bankName: bankInfo.name,
          bankId: bankInfo.bankId,
        };
      });

    const emailDB = (global as any).emailDB;
    const mainDB = (global as any).mainDB;

    await emailDB.model('scrapeResult').insertMany(records);

    if (scrapedEmails.bankConfig && scrapedEmails.bankConfig.bankId) {
      await mainDB.model('User').findByIdAndUpdate(
        new mongoose.Types.ObjectId(userId),
        { $addToSet: { CreditCardLinkedBanks: scrapedEmails.bankConfig.bankId } },
        { new: true }
      );
    }

    return records;
  } catch (err) {
    console.error('Error in scrapeEmailsByBankId:', err);
    throw err;
  }
}

export async function getScrapedEmailsByUserId(userId: string) {
  const emailDB = (global as any).emailDB;

  return await emailDB
    .model('scrapeResult')
    .find({ userId: { $eq: new mongoose.Types.ObjectId(userId) } })
    .sort({ createdAt: -1 });
}

export async function getUnlinkedCreditCards(userId: string) {
  const mainDB = (global as any).mainDB;

  const user = await mainDB
    .collection('users')
    .findOne({ _id: new mongoose.Types.ObjectId(userId) });

  if (!user) {
    throw new Error('User not found');
  }

  const linkedBankIds: string[] = user.CreditCardLinkedBanks || [];

  const cards = creditCards as CreditCardConfig[];

  const unlinkedCards = cards.filter(
    (card) => !linkedBankIds.includes(card.bankId)
  );

  return unlinkedCards;
}

export async function deleteGoogleTokenByUserId(userId: string) {
  const emailDB = (global as any).emailDB;

  return await emailDB
    .model('googleAuth')
    .deleteOne({ userId: { $eq: new mongoose.Types.ObjectId(userId) } });
}

export async function getDecryptedRefreshToken(userId: string) {
  const emailDB = (global as any).emailDB;

  const user = await emailDB.model('googleAuth').findOne({
    userId: userId,
    'refreshToken.encryptedData': { $exists: true, $ne: '' },
  });

  if (!user || !user.refreshToken?.encryptedData) {
    throw new Error('No refresh token found');
  }

  return decryptToken(
    user.refreshToken.encryptedData,
    user.refreshToken.iv,
    user.refreshToken.authTag
  );
}

export default {
  getGoogleTokenByUserId,
  upsertGoogleToken,
  getScrapedEmailsByUserId,
  getUnlinkedCreditCards,
  deleteGoogleTokenByUserId,
  scrapeEmailsByBankId,
  getDecryptedRefreshToken,
};
