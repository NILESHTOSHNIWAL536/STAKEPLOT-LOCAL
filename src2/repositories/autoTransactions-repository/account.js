const { Account } = require('../../models/index');
const CrudRepository = require('../crud-repository');
const { encrypt, decrypt } = require('../../services/Encryption/encryption-service');
const decryptDataKey = require('../../services/Encryption/decryptDataKey');
const AppError = require('../../utils/errors/app-error');
const logger = require('../../utils/common/logger');

class AccountRespository extends CrudRepository {
  constructor() {
    super(Account);
  }

  async createAccount(data, plaintextKey, ciphertextBlob) {
    try {
      // 1. Encrypt incoming fields
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

      // 2. Get ALL accounts for this bank + user
      const existingAccounts = await this.model.find({
        bankId: data.bankId,
        userId: data.userId,
      });

      if (existingAccounts) {
        // 3. Try to find matching linkedAccRef by decryption
        for (const doc of existingAccounts) {
          const existingPlaintextKey = await decryptDataKey(doc.encryptedDEK);

          const existingLinkedAccRef = await decrypt(doc.linkedAccRef.encryptedData, doc.linkedAccRef.iv, doc.linkedAccRef.authTag, existingPlaintextKey);

          // 4. If match → UPDATE
          if (existingLinkedAccRef === data.linkedAccRef) {
            const updated = await this.model.findByIdAndUpdate(doc._id, { $set: accountData }, { new: true });

            return updated;
          }
        }
      }

      // 5. If NO match → CREATE new account
      const response = await this.create(accountData);
      return response;
    } catch (error) {
      return error;
    }
  }

  async getAccounts(bankId) {
    const response = await this.get(bankId);
    if (!response || response.length === 0) {
      return '';
    }

    // Decrypt the data encryption key (DEK)
    const accountData = await Promise.all(
      response.map(async (data) => {
        const plaintextKey = await decryptDataKey(data.encryptedDEK);

        // Helper function for decryption
        const decryptField = (field) => decrypt(field.encryptedData, field.iv, field.authTag, plaintextKey);

        // Map through accounts to decrypt fields
        const accounts = {
          type: decryptField(data.type),
          maskedAccNumber: decryptField(data.maskedAccNumber),
          version: decryptField(data.version),
          linkedAccRef: decryptField(data.linkedAccRef),
          // schemaLocation: decryptField(data.schemaLocation),
          lastFetch: data.lastFetch,
          fetchCount: data.fetchCount,
          nextFetch: data.nextFetch,
        };

        // Construct the final data object
        return {
          bankId: data.bankId,
          accounts,
          _id: data._id,
        };
      })
    );

    return accountData;
  }

  async getAccountById(accountId) {
    const response = await this.getById({ _id: accountId });
    if (!response) throw new AppError('Account not found', 404);

    const plaintextKey = await decryptDataKey(response.encryptedDEK);
    const decryptField = (field) => decrypt(field.encryptedData, field.iv, field.authTag, plaintextKey);

    return {
      type: decryptField(response.type),
      maskedAccNumber: decryptField(response.maskedAccNumber),
      version: decryptField(response.version),
      linkedAccRef: decryptField(response.linkedAccRef),
      lastFetch: response.lastFetch,
      nextFetch: response.nextFetch,
      fetchCount: response.fetchCount,
      bankId: response.bankId,
      userId: response.userId,
    };
  }

  async updateAccount(accountId, data, plaintextKey, ciphertextBlob) {
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

    const response = await Account.findOneAndUpdate({ _id: accountId }, { ...updatedData, $inc: { fetchCount: 1 } }, { new: true });

    return response;
  }

  async getMap(userId) {
    const accounts = await this.get({ userId });
    if (!accounts || accounts.length === 0) {
      return new Map();
    }
    const accountMap = new Map();
    await Promise.all(
      accounts.map(async (data) => {
        const plaintextKey = await decryptDataKey(data.encryptedDEK);

        // Decrypt the linkedAccRef field
        const linkedAccRef = decrypt(data.linkedAccRef.encryptedData, data.linkedAccRef.iv, data.linkedAccRef.authTag, plaintextKey);

        // Store in the map with _id as key and linkedAccRef as value
        accountMap.set(linkedAccRef, data._id);
      })
    );
    return accountMap;
  }

  async deleteAccount(userId, accountId) {
    try {
      if (accountId) {
        // Delete single account
        const response = await this.deleteOne({ userId, _id: accountId });
        return response;
      } else {
        // Delete all accounts for the user
        const response = await this.deleteMany({ userId });
        return response;
      }
    } catch (error) {
      logger.error(`Error in deleteAccount: ${error}`);
      throw error;
    }
  }
}

module.exports = AccountRespository;
