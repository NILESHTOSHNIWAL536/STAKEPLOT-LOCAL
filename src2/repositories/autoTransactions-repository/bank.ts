import { Bank } from '../../models';
import CrudRepository from '../crud-repository';
import { encrypt, decrypt } from '@/services/Encryption/encryption-service';
import decryptDataKey from '@/services/Encryption/decryptDataKey';
import AppError from '@/utils/errors/app-error';
import logger from '@/utils/common/logger';
import { StatusCodes } from 'http-status-codes';
import { IAccount, IBank, IEncryptedField, IFiAccountInfo } from '@/types/bank';
import { Types } from 'mongoose';

interface CreateFipData {
  fipId: string;
  fipName: string;
  custId: string;
  consentId: string;
  sessionId: string;
  consentHandleId: string;
  from: Date;
  to: Date;
  userId: string;
  fiAccountInfo: { accountRefNo: string; linkRefNo: string }[];
}

class FipRepository extends CrudRepository<typeof Bank> {
  constructor() {
    super(Bank);
  }

  // ----------------------------------------------------
  // CREATE FIP RECORD
  // ----------------------------------------------------
  async createFipRecord(fipData: any, plaintextKey: string | Uint8Array, ciphertextBlob: string) {
    const existingBanks = await Bank.find({ userId: fipData.userId });

    // Check duplicates
    for (const existing of existingBanks as IBank[]) {
      const existingKey = await decryptDataKey(existing.encryptedDEK);

      const decFipId = decrypt(existing.fipId.encryptedData, existing.fipId.iv, existing.fipId.authTag, existingKey);
      const decCustId = decrypt(existing.custId.encryptedData, existing.custId.iv, existing.custId.authTag, existingKey);
      const decConsentId = decrypt(existing.consentId.encryptedData, existing.consentId.iv, existing.consentId.authTag, existingKey);
      const decCHId = decrypt(existing.consentHandleId.encryptedData, existing.consentHandleId.iv, existing.consentHandleId.authTag, existingKey);

      if (decFipId === fipData.fipId && decCustId === fipData.custId && decConsentId === fipData.consentId && decCHId === fipData.consentHandleId) {
        return existing;
      }
    }

    // Encrypt FI account list
    const fiAccountInfo: IFiAccountInfo[] = await Promise.all(
      fipData.fiAccountInfo.map(async (acc: any) => ({
        accountRefNo: await encrypt(acc.accountRefNo, plaintextKey),
        linkRefNo: await encrypt(acc.linkRefNo, plaintextKey),
      }))
    );

    // Encrypt main fields
    const encryptionTasks = {
      fipId: encrypt(fipData.fipId, plaintextKey),
      fipName: encrypt(fipData.fipName, plaintextKey),
      custId: encrypt(fipData.custId, plaintextKey),
      consentId: encrypt(fipData.consentId, plaintextKey),
      sessionId: encrypt(fipData.sessionId, plaintextKey),
      consentHandleId: encrypt(fipData.consentHandleId, plaintextKey),
    };

    const encrypted = await Promise.all(Object.values(encryptionTasks));
    const [fipId, fipName, custId, consentId, sessionId, consentHandleId] = encrypted;

    const payload = {
      fipId,
      fipName,
      custId,
      consentId,
      sessionId,
      consentHandleId,
      fiAccountInfo,
      from: fipData.from,
      to: fipData.to,
      userId: fipData.userId,
      encryptedDEK: ciphertextBlob,
    };

    return await this.create(payload);
  }

  // ----------------------------------------------------
  // GET ALL BANK RECORDS FOR USER
  // ----------------------------------------------------
  async getBank(userId: string | Types.ObjectId) {
    try {
      const response = await this.get({ userId });

      if (!response || response.length === 0) return [];

      const decryptResponse = async (doc: IBank) => {
        const plaintextKey = await decryptDataKey(doc.encryptedDEK);
        const decryptField = (f: IEncryptedField) => decrypt(f.encryptedData, f.iv, f.authTag, plaintextKey);

        return {
          _id: doc._id,
          userId: doc.userId,
          fipId: decryptField(doc.fipId),
          fipName: decryptField(doc.fipName),
          custId: decryptField(doc.custId),
          consentId: decryptField(doc.consentId),
          consentHandleId: decryptField(doc.consentHandleId),
        };
      };

      return Promise.all(response.map(decryptResponse));
    } catch (error) {
      logger.error(`Error fetching bank for userId ${userId}: ${error}`);
      throw new AppError('Failed to fetch bank details', StatusCodes.INTERNAL_SERVER_ERROR);
    }
  }

  // ----------------------------------------------------
  // GET BANK BY NAME + CONSENT HANDLE ID
  // ----------------------------------------------------
  async getBankByName(userId: string | Types.ObjectId, fipName: string, consentHandleId: string) {
    const records = await this.get({ userId });

    for (const record of records as IBank[]) {
      const plaintextKey = await decryptDataKey(record.encryptedDEK);

      const name = decrypt(record.fipName.encryptedData, record.fipName.iv, record.fipName.authTag, plaintextKey);
      const ch = decrypt(record.consentHandleId.encryptedData, record.consentHandleId.iv, record.consentHandleId.authTag, plaintextKey);

      if (name === fipName && ch === consentHandleId) {
        return record;
      }
    }
  }

  // ----------------------------------------------------
  // GET BANK BY ID
  // ----------------------------------------------------
  async getBankById(bankId: string | Types.ObjectId, userId: string) {
    const record = await Bank.findOne({ _id: bankId, userId }).lean();

    if (!record) throw new AppError('Bank not found', 404);

    const plaintextKey = await decryptDataKey(record.encryptedDEK);
    const decryptField = (f: IEncryptedField) => decrypt(f.encryptedData, f.iv, f.authTag, plaintextKey);

    return {
      _id: record._id,
      fipId: decryptField(record.fipId),
      fipName: decryptField(record.fipName),
      custId: decryptField(record.custId),
      consentId: decryptField(record.consentId),
      sessionId: decryptField(record.sessionId),
      consentHandleId: decryptField(record.consentHandleId),
      userId: record.userId,
      fiAccountInfo: record.fiAccountInfo.map((acc: any) => ({
        accountRefNo: decryptField(acc.accountRefNo),
        linkRefNo: decryptField(acc.linkRefNo),
      })),
    };
  }

  // ----------------------------------------------------
  // GET MAP (fipId → _id)
  // ----------------------------------------------------
  async getBankDetailsMap(userId: string) {
    const records = await this.get({ userId });

    const map = new Map<string, string>();

    await Promise.all(
      records.map(async (doc: IBank) => {
        const key = await decryptDataKey(doc.encryptedDEK);

        const fipId = decrypt(doc.fipId.encryptedData, doc.fipId.iv, doc.fipId.authTag, key);

        map.set(fipId, doc._id.toString());
      })
    );

    return map;
  }

  // ----------------------------------------------------
  // GET BANK USING CONSENT HANDLE
  // ----------------------------------------------------
  async getFipById(userId: string, consentHandleId: string) {
    const records = await this.get({ userId });

    for (const rec of records as IBank[]) {
      const plaintextKey = await decryptDataKey(rec.encryptedDEK);

      const ch = decrypt(rec.consentHandleId.encryptedData, rec.consentHandleId.iv, rec.consentHandleId.authTag, plaintextKey);

      if (ch === consentHandleId) {
        const decryptField = (f: IEncryptedField) => decrypt(f.encryptedData, f.iv, f.authTag, plaintextKey);

        return {
          _id: rec._id,
          fipId: decryptField(rec.fipId),
          fipName: decryptField(rec.fipName),
          custId: decryptField(rec.custId),
          consentId: decryptField(rec.consentId),
          sessionId: decryptField(rec.sessionId),
          consentHandleId: ch,
          userId: rec.userId,
        };
      }
    }

    throw new AppError('No matching bank record found', 404);
  }

  // ----------------------------------------------------
  // UPDATE FIP RECORD
  // ----------------------------------------------------
  async updateFipRecord(bankId: string | Types.ObjectId, data: any, plaintextKey: string | Uint8Array, ciphertextBlob: string) {
    // Encrypt fiAccountInfo
    const fiAccountInfo = await Promise.all(
      data.fiAccountInfo.map(async (acc: any) => ({
        accountRefNo: await encrypt(acc.accountRefNo, plaintextKey),
        linkRefNo: await encrypt(acc.linkRefNo, plaintextKey),
      }))
    );

    // Encrypt fields
    const encrypted = await Promise.all([
      encrypt(data.fipId, plaintextKey),
      encrypt(data.fipName, plaintextKey),
      encrypt(data.custId, plaintextKey),
      encrypt(data.consentId, plaintextKey),
      encrypt(data.sessionId, plaintextKey),
      encrypt(data.consentHandleId, plaintextKey),
    ]);

    const [fipId, fipName, custId, consentId, sessionId, consentHandleId] = encrypted;

    const updateData = {
      fipId,
      fipName,
      custId,
      consentId,
      sessionId,
      consentHandleId,
      fiAccountInfo,
      userId: data.userId,
      encryptedDEK: ciphertextBlob,
    };

    return Bank.findOneAndUpdate({ _id: bankId }, { $set: updateData }, { new: true });
  }

  // ----------------------------------------------------
  // DELETE BANK
  // ----------------------------------------------------
  async deleteBank(userId: string | Types.ObjectId, bankId?: string | Types.ObjectId) {
    if (bankId) {
      const record = await Bank.findOne({ _id: bankId, userId });

      if (!record) throw new AppError('Bank record not found', 404);

      if (record.fiAccountInfo.length === 1) {
        return this.deleteOne({ _id: bankId });
      }

      return { message: 'Bank has multiple accounts; cannot delete.' };
    }

    return this.deleteMany({ userId });
  }
}

export default FipRepository;
