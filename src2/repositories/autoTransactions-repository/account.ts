import { Account } from '../../models';
import CrudRepository from '../crud-repository';
import { encrypt, decrypt } from '@/services/Encryption/encryption-service';
import decryptDataKey from '@/services/Encryption/decryptDataKey';
import AppError from '@/utils/errors/app-error';
import logger from '@/utils/common/logger';
import { IAccount } from '@/types/bank';
import { IEncryptedField } from '@/types/bank';
import { Types } from 'mongoose';

// Type for create/update incoming request
interface CreateAccountData {
  type: string;
  maskedAccNumber: string;
  version: string;
  linkedAccRef: string;
  schemaLocation: string;

  startDate?: Date;
  endDate?: Date;
  lastFetch?: Date;
  nextFetch?: Date;
  fetchCount?: number;
  bankId: string;
  userId: string;
}

class AccountRepository extends CrudRepository<typeof Account> {
  constructor() {
    super(Account);
  }

  // -----------------------------
  // CREATE ACCOUNT
  // -----------------------------
  async createAccount(data: CreateAccountData, plaintextKey: string | Uint8Array, ciphertextBlob: string) {
    try {
      const fieldsToEncrypt = [data.type, data.maskedAccNumber, data.version, data.linkedAccRef, data.schemaLocation];

      const encryptedFields = await Promise.all(fieldsToEncrypt.map((field) => encrypt(field, plaintextKey)));

      const accountData = {
        type: encryptedFields[0],
        maskedAccNumber: encryptedFields[1],
        version: encryptedFields[2],
        linkedAccRef: encryptedFields[3],
        schemaLocation: encryptedFields[4],
        startDate: data.startDate,
        endDate: data.endDate,
        lastFetch: data.lastFetch,
        nextFetch: data.nextFetch,
        fetchCount: data.fetchCount,
        bankId: data.bankId,
        userId: data.userId,
        encryptedDEK: ciphertextBlob,
      };

      // Fetch all existing accounts for the same user + bank
      const existingAccounts = await this.model.find({
        bankId: data.bankId,
        userId: data.userId,
      });

      // Check for account update scenario
      if (existingAccounts) {
        for (const doc of existingAccounts as IAccount[]) {
          const existingPlaintextKey = await decryptDataKey(doc.encryptedDEK);

          const existingLinkedAccRef = decrypt(doc.linkedAccRef.encryptedData, doc.linkedAccRef.iv, doc.linkedAccRef.authTag, existingPlaintextKey);

          if (existingLinkedAccRef === data.linkedAccRef) {
            return await this.model.findByIdAndUpdate(doc._id, { $set: accountData }, { new: true });
          }
        }
      }

      // Create new account
      return await this.create(accountData);
    } catch (error) {
      return error;
    }
  }

  // -----------------------------
  // GET ALL ACCOUNTS BY BANK
  // -----------------------------
  async getAccounts(query: Object | string) {
    const response = await this.get(query);

    if (!response || response.length === 0) {
      return '';
    }

    const accountData = await Promise.all(
      response.map(async (data: IAccount) => {
        const plaintextKey = await decryptDataKey(data.encryptedDEK);
        const decryptField = (field: IEncryptedField) => decrypt(field.encryptedData, field.iv, field.authTag, plaintextKey);

        const accounts = {
          type: decryptField(data.type),
          maskedAccNumber: decryptField(data.maskedAccNumber),
          version: decryptField(data.version),
          linkedAccRef: decryptField(data.linkedAccRef),
          lastFetch: data.lastFetch,
          fetchCount: data.fetchCount,
          nextFetch: data.nextFetch,
        };

        return {
          bankId: data.bankId,
          accounts,
          _id: data._id,
        };
      })
    );

    return accountData;
  }

  // -----------------------------
  // GET ACCOUNT BY ID
  // -----------------------------
  async getAccountById(accountId: string | Types.ObjectId) {
    const response = await this.getById({ _id: accountId });

    if (!response) throw new AppError('Account not found', 404);

    const data = response as IAccount;
    const plaintextKey = await decryptDataKey(data.encryptedDEK);

    const decryptField = (field: IEncryptedField) => decrypt(field.encryptedData, field.iv, field.authTag, plaintextKey);

    return {
      type: decryptField(data.type),
      maskedAccNumber: decryptField(data.maskedAccNumber),
      version: decryptField(data.version),
      linkedAccRef: decryptField(data.linkedAccRef),
      lastFetch: data.lastFetch,
      nextFetch: data.nextFetch,
      fetchCount: data.fetchCount,
      bankId: data.bankId,
      userId: data.userId,
    };
  }

  // -----------------------------
  // UPDATE ACCOUNT
  // -----------------------------
  async updateAccount(accountId: string, data: CreateAccountData, plaintextKey: string | Uint8Array, ciphertextBlob: string) {
    const fieldsToEncrypt = [data.type, data.maskedAccNumber, data.version, data.linkedAccRef, data.schemaLocation];

    const encryptedFields = await Promise.all(fieldsToEncrypt.map((field) => encrypt(field, plaintextKey)));

    const updatedData = {
      type: encryptedFields[0],
      maskedAccNumber: encryptedFields[1],
      version: encryptedFields[2],
      linkedAccRef: encryptedFields[3],
      schemaLocation: encryptedFields[4],
      startDate: data.startDate,
      endDate: data.endDate,
      bankId: data.bankId,
      lastFetch: data.lastFetch,
      nextFetch: data.nextFetch,
      userId: data.userId,
      encryptedDEK: ciphertextBlob,
    };

    return await Account.findOneAndUpdate({ _id: accountId }, { ...updatedData, $inc: { fetchCount: 1 } }, { new: true });
  }

  // -----------------------------
  // GET MAP (linkedAccRef → _id)
  // -----------------------------
  async getMap(userId: string) {
    const accounts = await this.get({ userId });

    if (!accounts || accounts.length === 0) {
      return new Map<string, string>();
    }

    const accountMap = new Map<string, string>();

    await Promise.all(
      accounts.map(async (data: IAccount) => {
        const plaintextKey = await decryptDataKey(data.encryptedDEK);

        const linkedAccRef = decrypt(data.linkedAccRef.encryptedData, data.linkedAccRef.iv, data.linkedAccRef.authTag, plaintextKey);

        accountMap.set(linkedAccRef!, data._id);
      })
    );

    return accountMap;
  }

  // -----------------------------
  // DELETE ACCOUNT(S)
  // -----------------------------
  async deleteAccount(userId: string, accountId?: string) {
    try {
      if (accountId) {
        return await this.deleteOne({ userId, _id: accountId });
      } else {
        return await this.deleteMany({ userId });
      }
    } catch (error) {
      logger.error(`Error in deleteAccount: ${error}`);
      throw error;
    }
  }
}

export default AccountRepository;
