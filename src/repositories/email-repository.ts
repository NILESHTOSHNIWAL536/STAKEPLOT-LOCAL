import mongoose from 'mongoose';
import { decryptToken, encryptToken, encryptScrapeFields, decryptScrapeFields } from '../utils/encryption';
import creditCards from '../utils/credit-cards.json';
import AppError from '../utils/app-error';
import { StatusCodes } from 'http-status-codes';
import { ServerConfig } from '../config';
import jwt from 'jsonwebtoken';
import { googleAuthSchema } from '../models/google-auth';
import { getModels } from '../models/index-model';

// If you want, you can define a type for creditCards
type CreditCardConfig = {
  bankId: string;
  [key: string]: any;
};

export type StatementPasswordRecord = {
  bankId: string;
  email?: string;
  accountHint?: string;
  password: string;
};

export type PendingStatementInput = {
  requestId: string;
  email: string;
  bankId: string;
  bankName?: string;
  accountHint?: string;
  messageId?: string;
  attachmentName?: string;
  reason?: string;
  mail: any;
  bankConfig: any[];
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

  return await emailDB.model('googleAuth').findOne({ userId: new mongoose.Types.ObjectId(userId) });
}

export async function scrapeEmailsByBankId(scrapedEmails: any, userId: string) {
  try {
    if (!Array.isArray(scrapedEmails?.results) || scrapedEmails.results.length === 0) {
      return {};
    }

    const records = scrapedEmails.results
      .filter((obj: any) => obj.matched_bank != null)
      .map((obj: any) => {
        const matchedBank = scrapedEmails.bankConfig && scrapedEmails.bankConfig.find((b: any) => b.name.toLowerCase().includes(obj.matched_bank.toLowerCase()));

        const bankInfo = matchedBank || { name: obj.matched_bank, logo: '', bankId: '' };

        return {
          ...obj,
          userId,
          logo: bankInfo.logo,
          bankName: bankInfo.name,
          bankId: bankInfo.bankId,
        };
      });

    const emailDB = (global as any).emailDB;

    const encryptedRecords = await Promise.all(records.map(encryptScrapeFields));
    await emailDB.model('scrapeResult').insertMany(encryptedRecords);

    if (scrapedEmails.bankConfig && scrapedEmails.bankConfig.bankId) {
      try {
        const payload = { bankId: scrapedEmails.bankConfig.bankId };
        const internalToken = jwt.sign({ sub: userId, aud: 'mobile-backend' }, ServerConfig.SERVICE_JWT_SECRET, { expiresIn: '1m' });

        await require('axios').post(`${ServerConfig.MOBILE_BACKEND_URL || 'http://localhost:5000'}/api/v1/user/internal/update-banks`, payload, {
          headers: {
            authorization: `Bearer ${internalToken}`,
          },
        });
      } catch (err: any) {
        console.error('Failed to update CreditCardLinkedBanks in gateway:', err.message);
      }
    }

    return records;
  } catch (err) {
    console.error('Error in scrapeEmailsByBankId:', err);
    throw err;
  }
}

export async function getScrapedEmailsByUserId(userId: string) {
  const emailDB = (global as any).emailDB;

  const docs = await emailDB
    .model('scrapeResult')
    .find({ userId: { $eq: new mongoose.Types.ObjectId(userId) } })
    .sort({ createdAt: -1 })
    .lean();

  return Promise.all(docs.map(decryptScrapeFields));
}

export async function getUserEmailById(userId: string): Promise<string> {
  const mainDB = (global as any).mainDB;
  const user = await mainDB
    .collection('users')
    .findOne(
      { _id: new mongoose.Types.ObjectId(userId) },
      { projection: { email: 1 } }
    );

  if (!user?.email) {
    throw new AppError('User email not found', StatusCodes.BAD_REQUEST);
  }

  return user.email;
}

// export async function getUnlinkedCreditCards(userId: string) {
//   throw new AppError('This endpoint is handled by mobile-backend (gateway).', StatusCodes.BAD_REQUEST);
// }

async function getUnlinkedCreditCards(userId: string) {
  try {
    const mainDB = (global as any).mainDB;
    const user = await mainDB.collection('User').findOne({ _id: new mongoose.Types.ObjectId(userId) });
    if (!user) {
      throw new Error('User not found');
    }
    const linkedBankIds = user.CreditCardLinkedBanks || [];
    // Filter out cards whose bankId is not in linkedBankIds
    const unlinkedCards = creditCards.filter((card) => !linkedBankIds.includes(card.bankId));
    return unlinkedCards;
  } catch (error) {
    console.error('Error fetching unlinked credit cards:', error);
    throw new AppError('Failed to fetch unlinked credit cards', StatusCodes.INTERNAL_SERVER_ERROR);
  }
}

export async function deleteGoogleTokenByEmail(email: string) {
  const emailDB = (global as any).emailDB;
  return await emailDB.model('googleAuth').deleteOne({ email });
}

export async function removeUserBankMapEmailMapping(userId: string, email: string) {
  const { UserBankMap } = await getModels();

  return await UserBankMap.updateOne(
    { userId: new mongoose.Types.ObjectId(userId) },
    { $pull: { mappings: { email } } }
  );
}

export async function getDecryptedRefreshToken(email: string) {
  const emailDB = (global as any).emailDB;

    // ✅ Get model safely (no overwrite error)
  const GoogleAuth = emailDB.models.googleAuth || emailDB.model('googleAuth', googleAuthSchema);
  
  const googleAuth = await GoogleAuth.findOne({ email });
  if (!googleAuth?.refreshToken?.encryptedData) {
    throw new AppError('No refresh token found', StatusCodes.NOT_FOUND);
  }

  return decryptToken(googleAuth.refreshToken.encryptedData, googleAuth.refreshToken.iv, googleAuth.refreshToken.authTag);
}

export async function upsertStatementPassword(
  userId: string,
  bankId: string,
  password: string,
  email?: string,
  accountHint?: string
) {
  const { StatementPassword } = await getModels();
  const normalizedEmail = email ? email.trim().toLowerCase() : '';
  const normalizedAccountHint = accountHint ? accountHint.trim() : '';
  const query = {
    userId: new mongoose.Types.ObjectId(userId),
    bankId,
    email: normalizedEmail,
    accountHint: normalizedAccountHint,
  };

  const existing = await StatementPassword.findOne(query);
  const existingPasswords = existing
    ? await decryptStatementPasswordFields(existing.toObject())
    : [];

  const update: Record<string, any> = {
    $set: {
      lastStatus: 'active',
      lastError: '',
    },
  };

  if (existing?.password?.encryptedData) {
    const nextPasswords = Array.from(new Set([...existingPasswords, password]));
    update.$set.passwords = await Promise.all(
      nextPasswords.map((plainPassword) => encryptToken(plainPassword))
    );
    update.$unset = { password: '' };
  } else if (!existingPasswords.includes(password)) {
    update.$push = {
      passwords: await encryptToken(password),
    };
  }

  return StatementPassword.findOneAndUpdate(
    query,
    update,
    { upsert: true, new: true, setDefaultsOnInsert: true }
  );
}

export async function getStatementPasswords(
  userId: string,
  bankIds: string[],
  email?: string
): Promise<StatementPasswordRecord[]> {
  const { StatementPassword } = await getModels();
  const normalizedEmail = email ? email.trim().toLowerCase() : undefined;
  const query: Record<string, any> = {
    userId: new mongoose.Types.ObjectId(userId),
    // bankId: { $in: bankIds },
  };

  if (normalizedEmail) {
    query.$or = [
      { email: normalizedEmail },
      { email: '' },
      { email: { $exists: false } },
      { email: null },
    ];
  }

  const docs = await StatementPassword.find(query).sort({ updatedAt: -1 }).lean();

  const records = await Promise.all(
    docs.map(async (doc: any) => {
      const passwords = await decryptStatementPasswordFields(doc);

      return passwords.map((password) => ({
        bankId: doc.bankId,
        email: doc.email,
        accountHint: doc.accountHint,
        password,
      }));
    })
  );

  return records.flat();
}

export async function upsertPendingStatementExtraction(
  userId: string,
  input: PendingStatementInput
) {
  const { PendingStatementExtraction } = await getModels();

  const encryptedMailPayload = await encryptToken(JSON.stringify(input.mail || {}));
  const normalizedEmail = input.email ? input.email.trim().toLowerCase() : '';

  return PendingStatementExtraction.findOneAndUpdate(
    {
      userId: new mongoose.Types.ObjectId(userId),
      requestId: input.requestId,
    },
    {
      $set: {
        email: normalizedEmail,
        bankId: input.bankId,
        bankName: input.bankName || 'Bank statement',
        accountHint: input.accountHint || '',
        messageId: input.messageId || '',
        attachmentName: input.attachmentName || '',
        reason: input.reason || 'password_required',
        status: 'PENDING_PASSWORD',
        encryptedMailPayload,
        bankConfig: input.bankConfig || [],
        lastError: '',
      },
      $unset: {
        completedAt: '',
      },
    },
    { upsert: true, new: true, setDefaultsOnInsert: true }
  );
}

export async function getPendingStatementExtractions(userId: string) {
  const { PendingStatementExtraction } = await getModels();

  const docs = await PendingStatementExtraction.find({
    userId: new mongoose.Types.ObjectId(userId),
    status: { $in: ['PENDING_PASSWORD', 'FAILED'] },
  })
    .sort({ updatedAt: -1 })
    .lean();

  return docs.map((doc: any) => ({
    id: doc.requestId,
    requestId: doc.requestId,
    email: doc.email || '',
    bankId: doc.bankId,
    bankName: doc.bankName,
    accountHint: doc.accountHint || '',
    messageId: doc.messageId || '',
    filename: doc.attachmentName || '',
    reason: doc.reason || 'password_required',
    status: doc.status,
    lastError: doc.lastError || '',
    updatedAt: doc.updatedAt,
  }));
}

// export async function getPendingStatementExtractionForProcessing(
//   userId: string,
//   requestId: string
// ) {
//   const { PendingStatementExtraction } = await getModels();

//   const doc = await PendingStatementExtraction.findOne({
//     userId: new mongoose.Types.ObjectId(userId),
//     requestId,
//     status: { $in: ['PENDING_PASSWORD', 'FAILED'] },
//   });

//   if (!doc) {
//     throw new AppError('Pending statement not found', StatusCodes.NOT_FOUND);
//   }

//   const payload = doc.encryptedMailPayload;
//   if (!payload?.encryptedData || !payload.iv || !payload.authTag) {
//     throw new AppError('Pending statement content is not available', StatusCodes.BAD_REQUEST);
//   }

//   const mail = JSON.parse(
//     await decryptToken(payload.encryptedData, payload.iv, payload.authTag)
//   );

//   return { doc, mail };
// }



export async function getPendingStatementExtractionForProcessing(
  userId: string
) {
  const { PendingStatementExtraction } = await getModels();

  const docs = await PendingStatementExtraction.find({
    userId: new mongoose.Types.ObjectId(userId),
    status: { $in: ['PENDING_PASSWORD', 'FAILED'] },
  }).lean();

  if (!docs.length) {
    return [];
  }

  const results = await Promise.all(
    docs.map(async (doc) => {
      const payload = doc.encryptedMailPayload;

      if (
        !payload?.encryptedData ||
        !payload.iv ||
        !payload.authTag
      ) {
        return {
          ...doc,
          mail: null,
        };
      }

      const mail = JSON.parse(
        await decryptToken(
          payload.encryptedData,
          payload.iv,
          payload.authTag
        )
      );

      return {
        ...doc,
        mail,
      };
    })
  );

  return results;
}


export async function markPendingStatementProcessing(userId: string, requestId: string) {
  const { PendingStatementExtraction } = await getModels();

  return PendingStatementExtraction.updateOne(
    {
      userId: new mongoose.Types.ObjectId(userId),
      requestId,
    },
    {
      $set: {
        status: 'PROCESSING',
        lastError: '',
      },
    }
  );
}

export async function markPendingStatementCompleted(userId: string, requestId: string) {
  const { PendingStatementExtraction } = await getModels();

  return PendingStatementExtraction.updateOne(
    {
      userId: new mongoose.Types.ObjectId(userId),
      requestId,
    },
    {
      $set: {
        status: 'COMPLETED',
        lastError: '',
        completedAt: new Date(),
      },
      $unset: {
        encryptedMailPayload: '',
      },
    }
  );
}

export async function deletePendingStatement(userId: string, requestId: string) {
  const { PendingStatementExtraction } = await getModels();

  return PendingStatementExtraction.deleteOne(
    {
      userId: new mongoose.Types.ObjectId(userId),
      requestId,
    },
  );
}

export async function markPendingStatementFailed(
  userId: string,
  requestId: string,
  error: string
) {
  const { PendingStatementExtraction } = await getModels();

  return PendingStatementExtraction.updateOne(
    {
      userId: new mongoose.Types.ObjectId(userId),
      requestId,
    },
    {
      $set: {
        status: 'FAILED',
        lastError: error,
      },
    }
  );
}

async function decryptStatementPasswordFields(doc: any): Promise<string[]> {
  const encryptedPasswords = [
    ...(Array.isArray(doc.passwords) ? doc.passwords : []),
    ...(doc.password?.encryptedData ? [doc.password] : []),
  ];

  const decrypted = await Promise.all(
    encryptedPasswords.map(async (encrypted) => {
      try {
        if (!encrypted?.encryptedData || !encrypted?.iv || !encrypted?.authTag) {
          return '';
        }

        return await decryptToken(
          encrypted.encryptedData,
          encrypted.iv,
          encrypted.authTag
        );
      } catch (error) {
        return '';
      }
    })
  );

  return Array.from(new Set(decrypted.filter(Boolean)));
}

export async function markStatementPasswordInvalid(
  userId: string,
  bankId: string,
  email?: string,
  error = 'Invalid PDF password'
) {
  const { StatementPassword } = await getModels();
  const normalizedEmail = email ? email.trim().toLowerCase() : undefined;

  return StatementPassword.updateMany(
    {
      userId: new mongoose.Types.ObjectId(userId),
      bankId,
      ...(normalizedEmail ? { email: normalizedEmail } : {}),
    },
    {
      $set: {
        lastStatus: 'invalid',
        lastError: error,
      },
    }
  );
}

export default {
  getGoogleTokenByUserId,
  upsertGoogleToken,
  getScrapedEmailsByUserId,
  getUserEmailById,
  getUnlinkedCreditCards,
  deleteGoogleTokenByEmail,
  removeUserBankMapEmailMapping,
  scrapeEmailsByBankId,
  getDecryptedRefreshToken,
  upsertStatementPassword,
  getStatementPasswords,
  markStatementPasswordInvalid,
  upsertPendingStatementExtraction,
  getPendingStatementExtractions,
  getPendingStatementExtractionForProcessing,
  markPendingStatementProcessing,
  markPendingStatementCompleted,
  markPendingStatementFailed,
  deletePendingStatement
};
