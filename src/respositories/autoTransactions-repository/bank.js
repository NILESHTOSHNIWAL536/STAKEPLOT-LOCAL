const { Bank } = require('../../models/index');
const CrudRepository = require('../crud-repository');
const { encrypt, decrypt } = require('../../services/Encryption/encryption-service');
const decryptDataKey = require('../../services/Encryption/decryptDataKey');
const AppError = require('../../utils/errors/app-error');
const logger = require('../../utils/common/logger');
const { StatusCodes } = require('http-status-codes');
class FipRepository extends CrudRepository {
  constructor() {
    super(Bank);
  }

  async createFipRecord(fipData, plaintextKey, ciphertextBlob) {
    // Parallel encryption of fiAccountInfo
    const fiAccountInfo = await Promise.all(
      fipData.fiAccountInfo.map(async ({ accountRefNo, linkRefNo }) => ({
        accountRefNo: await encrypt(accountRefNo, plaintextKey),
        linkRefNo: await encrypt(linkRefNo, plaintextKey),
      }))
    );

    // Collect all encryption operations in one array for parallel processing
    const encryptionTasks = {
      fipId: encrypt(fipData.fipId, plaintextKey),
      fipName: encrypt(fipData.fipName, plaintextKey),
      custId: encrypt(fipData.custId, plaintextKey),
      consentId: encrypt(fipData.consentId, plaintextKey),
      sessionId: encrypt(fipData.sessionId, plaintextKey),
      consentHandleId: encrypt(fipData.consentHandleId, plaintextKey),
    };

    // Run all encryption tasks in parallel
    const encryptedValues = await Promise.all(Object.values(encryptionTasks));

    // Map back to keys for the final data object
    const [fipId, fipName, custId, consentId, sessionId, consentHandleId] = encryptedValues;

    const data = {
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

    // Save data
    const response = await this.create(data);
    return response;
  }

  async getBank(userId) {
    try {
      const response = await this.get({ userId: userId });
      if (!response || (Array.isArray(response) && response.length === 0)) {
        return []; // Return empty array for no records
      }

      // Helper function to decrypt a single response object
      const decryptResponse = async (response) => {
        const plaintextKey = await decryptDataKey(response.encryptedDEK);
        const decryptField = (field) => decrypt(field.encryptedData, field.iv, field.authTag, plaintextKey);

        // const fiAccountInfo = response.fiAccountInfo.map(acc => ({
        //     accountRefNo: decryptField(acc.accountRefNo),
        //     linkRefNo: decryptField(acc.linkRefNo),
        // }));

        return {
          fipId: decryptField(response.fipId),
          fipName: decryptField(response.fipName),
          consentId: decryptField(response.consentId),
          consentHandleId: decryptField(response.consentHandleId),
          custId: decryptField(response.custId),
          userId: response.userId,
          _id: response._id,
        };
      };

      if (Array.isArray(response)) {
        const decryptedResponses = await Promise.all(response.map(decryptResponse));
        return decryptedResponses;
      } else {
        return await decryptResponse(response);
      }
    } catch (error) {
      logger.error(`Error fetching bank records for userId ${userId}: ${error}`);
      throw new AppError('Failed to fetch bank details', StatusCodes.INTERNAL_SERVER_ERROR);
    }
  }

  async getbankByName(userId, fipName, consentHandleId) {
    const response = await this.get({ userId });
    if (!response) {
      throw new Error('Bank record not found for this user.');
    }

    await Promise.all(
      response.map(async (record) => {
        const plaintextKey = await decryptDataKey(record.encryptedDEK);

        const decryptedFipName = decrypt(record.fipName.encryptedData, record.fipName.iv, record.fipName.authTag, plaintextKey);
        const decryptedConsentHandleId = decrypt(record.consentHandleId.encryptedData, record.consentHandleId.iv, record.consentHandleId.authTag, plaintextKey);

        if (decryptedFipName === fipName && decryptedConsentHandleId === consentHandleId) {
          return record;
        }
      })
    );
  }

  async getBankById(bankId, userId) {
    try {
      // Fetch the specific bank by _id and ensure it belongs to the user
      const response = await Bank.findOne({ _id: bankId, userId }).lean();

      if (!response) {
        throw new Error(`Bank record not found for bankId: ${bankId}`);
      }

      // Decrypt the bank data (reuse logic from getBank)
      const plaintextKey = await decryptDataKey(response.encryptedDEK);

      const decryptField = (field) => decrypt(field.encryptedData, field.iv, field.authTag, plaintextKey);

      // Decrypt fiAccountInfo if needed
      const fiAccountInfo = response.fiAccountInfo.map((acc) => ({
        accountRefNo: decryptField(acc.accountRefNo),
        linkRefNo: decryptField(acc.linkRefNo),
      }));

      return {
        _id: response._id,
        fipId: decryptField(response.fipId),
        fipName: decryptField(response.fipName),
        consentId: decryptField(response.consentId),
        sessionId: decryptField(response.sessionId),
        consentHandleId: decryptField(response.consentHandleId),
        custId: decryptField(response.custId),
        userId: response.userId,
        fiAccountInfo, // Include decrypted fiAccountInfo if needed
      };
    } catch (error) {
      logger.error(`Error fetching bank by ID: ${bankId}, Error: ${error}`);
      throw new AppError('Failed to fetch bank details', StatusCodes.INTERNAL_SERVER_ERROR);
    }
  }

  async getBankDetailsMap(userId) {
    const responses = await this.get({ userId });
    if (!responses || responses.length === 0) {
      return new Map();
    }

    const bankMap = new Map();

    await Promise.all(
      responses.map(async (data) => {
        const plaintextKey = await decryptDataKey(data.encryptedDEK);

        // Decrypt fipId field
        const fipId = decrypt(data.fipId.encryptedData, data.fipId.iv, data.fipId.authTag, plaintextKey);

        // Store in the map with fipId as key and _id as value
        bankMap.set(fipId, data._id);
      })
    );

    return bankMap;
  }

  async getFipById(userId, consentHandleId) {
    // Fetch the bank record(s) using userId
    const response = await this.get({ userId: userId });

    if (!response) {
      throw new Error('Bank record not found for this user.');
    }

    // Helper function to decrypt response data
    const decryptResponse = async (response) => {
      const plaintextKey = await decryptDataKey(response.encryptedDEK);

      const decryptField = (field) => decrypt(field.encryptedData, field.iv, field.authTag, plaintextKey);

      return {
        fipId: decryptField(response.fipId),
        fipName: decryptField(response.fipName),
        consentId: decryptField(response.consentId),
        sessionId: decryptField(response.sessionId),
        consentHandleId: decryptField(response.consentHandleId),
        custId: decryptField(response.custId),
        userId: response.userId,
        _id: response._id,
      };
    };

    // If response is an array, find the matching record
    if (Array.isArray(response)) {
      for (const record of response) {
        const decryptedConsentHandleId = decrypt(
          record.consentHandleId.encryptedData,
          record.consentHandleId.iv,
          record.consentHandleId.authTag,
          await decryptDataKey(record.encryptedDEK)
        );

        if (decryptedConsentHandleId === consentHandleId) {
          return await decryptResponse(record);
        }
      }
    } else {
      // If a single object, check if consentHandleId matches
      const decryptedConsentHandleId = decrypt(
        response.consentHandleId.encryptedData,
        response.consentHandleId.iv,
        response.consentHandleId.authTag,
        await decryptDataKey(response.encryptedDEK)
      );

      if (decryptedConsentHandleId === consentHandleId) {
        return await decryptResponse(response);
      }
    }

    throw new Error('No matching bank record found for the given userId and consentHandleId.');
  }

  async updateFipRecord(bankId, fipData, plaintextKey, ciphertextBlob) {
    try {
      // Parallel encryption of fiAccountInfo
      const fiAccountInfo = await Promise.all(
        fipData.fiAccountInfo.map(async ({ accountRefNo, linkRefNo }) => ({
          accountRefNo: await encrypt(accountRefNo, plaintextKey),
          linkRefNo: await encrypt(linkRefNo, plaintextKey),
        }))
      );

      // Collect all encryption operations in one array for parallel processing
      const encryptionTasks = {
        fipId: encrypt(fipData.fipId, plaintextKey),
        fipName: encrypt(fipData.fipName, plaintextKey),
        custId: encrypt(fipData.custId, plaintextKey),
        consentId: encrypt(fipData.consentId, plaintextKey),
        sessionId: encrypt(fipData.sessionId, plaintextKey),
        consentHandleId: encrypt(fipData.consentHandleId, plaintextKey),
      };

      // Run all encryption tasks in parallel
      const encryptedValues = await Promise.all(Object.values(encryptionTasks));

      // Map back to keys for the final data object
      const [encryptedFipId, fipName, custId, consentId, sessionId, consentHandleId] = encryptedValues;

      const updateData = {
        fipId: encryptedFipId,
        fipName,
        custId,
        consentId,
        sessionId,
        consentHandleId,
        fiAccountInfo,
        userId: fipData.userId,
        encryptedDEK: ciphertextBlob,
      };

      // Update the existing record
      const response = await Bank.findOneAndUpdate({ _id: bankId }, { $set: updateData });

      return response;
    } catch (error) {
      logger.error(`Error in updateFipRecord: ${error}`);
      throw error;
    }
  }

  async deleteBank(userId, bankId) {
    if (bankId) {
      // Handle single bank delete
      const bankRecord = await Bank.findOne({ _id: bankId, userId: userId });
      if (!bankRecord) {
        throw new AppError('Bank record not found', StatusCodes.NOT_FOUND);
      }
      if (bankRecord.fiAccountInfo.length === 1) {
        const response = await this.deleteOne({ _id: bankId });
        return response;
      }
      return { message: 'Bank record has multiple accounts, cannot delete.' };
    } else {
      // Handle all banks delete
      const response = await this.deleteMany({ userId: userId });
      if (!response) {
        throw new AppError('Bank record not found', StatusCodes.NOT_FOUND);
      }
      return response;
    }
  }
}

module.exports = FipRepository;
