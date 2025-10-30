require("dotenv").config();
const { Summary } = require("../../models/index");
const CrudRepository = require("../crud-repository");
const {
  encryptObject,
  decryptObject,
} = require("../../services/Encryption/encryption-service");
const decryptDataKey = require("../../services/Encryption/decryptDataKey");
// const { type } = require('os');
const AppError = require("../../utils/errors/app-error");
// const account = require('../../models/transactions-automation/account');
const logger = require("../../utils/common/logger");
const { StatusCodes } = require("http-status-codes");


class SummaryRepository extends CrudRepository {
  constructor() {
    super(Summary);
  }

  async createSummary(data, plaintextKey, ciphertextBlob) {
    try {
      const summaryData = {
        data: await encryptObject(data.data, plaintextKey),
        accountId: data.accountId,
        userId: data.userId,
        encryptedDEK: ciphertextBlob,
      };
      const response = await this.create(summaryData);
      return response;
    } catch (error) {
      console.error("Error creating summary:", error.message);
      throw error;
    }
  }

  async getSummary({ accountIds }) {
    // Query for all accountIds using $in
    const responses = await this.get({ accountId: { $in: accountIds } });

    // Ensure at least one document is returned
    if (!responses.length) {
      throw new Error("No Summaries found for the given accountIds");
    }

    const summaries = await Promise.all(
      responses.map(async (response) => {
        const plaintextKey = await decryptDataKey(response.encryptedDEK);
        const summaryData = {
          data: await decryptObject(response.data, plaintextKey),
          accountId: response.accountId,
          encryptedDEK: response.encryptedDEK,
          _id: response._id,
        };
        return summaryData;
      })
    );
    return summaries;
  }

  async updateSummary(query, data, plaintextKey, ciphertextBlob) {
    try {
      // Find the existing summary to update
      const existingSummary = await Summary.findOne({
        accountId: query.accountId,
        userId: data.userId,
      });

      if (!existingSummary) {
        throw new AppError("Summary not found", StatusCodes.NOT_FOUND);
      }

      // Prepare the updated summary data with encryption
      const summaryData = {
        data: await encryptObject(data.data, plaintextKey),
        accountId: data.accountId,
        userId: data.userId,
        encryptedDEK: ciphertextBlob,
      };

      // Update the existing record
      const response = await Summary.findOneAndUpdate(
        { _id: existingSummary._id },
        { $set: summaryData }
      );

      return response;
    } catch (error) {
      logger.error(`Error in updateSummary: ${error}`);
      throw error;
    }
  }

  async deleteSummary(userId, accountId) {
    try {
      let response;
      if (accountId) {
        response = await this.deleteOne({ userId, accountId });
      } else {
        response = await this.deleteMany({ userId });
      }
      return response;
    } catch (error) {
      logger.error(`Error in deleteSummary: ${error}`);
      throw error;
    }
  }
}

module.exports = SummaryRepository;
