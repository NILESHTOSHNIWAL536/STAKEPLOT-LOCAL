import { Summary } from '../../models';
import CrudRepository from '../crud-repository';
import { encryptObject, decryptObject } from '@/services/Encryption/encryption-service';
import decryptDataKey from '@/services/Encryption/decryptDataKey';
import AppError from '@/utils/errors/app-error';
import logger from '@/utils/common/logger';
import { StatusCodes } from 'http-status-codes';
import { ISummary } from '@/types/bank';
import { Types, ClientSession } from 'mongoose';

interface CreateSummaryData {
  data: Record<string, any>;
  accountId: string;
  userId: string | Types.ObjectId;
}

interface UpdateSummaryData {
  data: Record<string, any>;
  accountId: string;
  userId: string | Types.ObjectId;
}

class SummaryRepository extends CrudRepository<typeof Summary> {
  constructor() {
    super(Summary);
  }

  // ----------------------------------------------------
  // CREATE SUMMARY
  // ----------------------------------------------------
  async createSummary(data: CreateSummaryData, plaintextKey: string | Uint8Array, ciphertextBlob: string, session?: ClientSession) {
    try {
      // Check if summary already exists
      const existingSummary = await this.model.find({
        accountId: data.accountId,
        userId: data.userId,
      });

      const summaryData = {
        data: await encryptObject(data.data, plaintextKey),
        accountId: data.accountId,
        userId: data.userId,
        encryptedDEK: ciphertextBlob,
      };

      // UPDATE CASE
      if (Array.isArray(existingSummary) && existingSummary.length > 0) {
        const existing = existingSummary[0];

        return await this.model.findByIdAndUpdate(existing._id, { $set: summaryData }, { new: true, session });
      }

      // CREATE CASE
      return await this.create(summaryData, session);
    } catch (error: any) {
      logger.error(`Error creating summary: ${error.message}`);
      throw error;
    }
  }

  // ----------------------------------------------------
  // GET SUMMARY FOR MULTIPLE ACCOUNTS
  // ----------------------------------------------------
  async getSummary({ accountIds }: { accountIds: (string | Types.ObjectId)[] }) {
    const results = await this.get({ accountId: { $in: accountIds } });

    if (!results || results.length === 0) {
      throw new AppError('No summaries found for the given accountIds', StatusCodes.NOT_FOUND);
    }

    return Promise.all(
      results.map(async (summary: ISummary) => {
        const plaintextKey = await decryptDataKey(summary.encryptedDEK);
        return {
          _id: summary._id,
          accountId: summary.accountId,
          encryptedDEK: summary.encryptedDEK,
          data: await decryptObject(summary.data, plaintextKey),
        };
      })
    );
  }

  // ----------------------------------------------------
  // UPDATE SUMMARY
  // ----------------------------------------------------
  async updateSummary(query: { accountId: string | Types.ObjectId }, data: UpdateSummaryData, plaintextKey: string | Uint8Array, ciphertextBlob: string, session?: ClientSession) {
    try {
      const existingSummary = await Summary.findOne({
        accountId: query.accountId,
        userId: data.userId,
      });

      if (!existingSummary) {
        throw new AppError('Summary not found', StatusCodes.NOT_FOUND);
      }

      const summaryData = {
        data: await encryptObject(data.data, plaintextKey),
        accountId: data.accountId,
        userId: data.userId,
        encryptedDEK: ciphertextBlob,
      };

      return await Summary.findOneAndUpdate({ _id: existingSummary._id }, { $set: summaryData }, { new: true, session });
    } catch (error) {
      logger.error(`Error in updateSummary: ${error}`);
      throw error;
    }
  }

  // ----------------------------------------------------
  // DELETE SUMMARY
  // ----------------------------------------------------
  async deleteSummary(userId: string | Types.ObjectId, accountId?: string | Types.ObjectId, session?: ClientSession) {
    try {
      if (accountId) {
        return await this.deleteOne({ userId, accountId }, session);
      }

      return await this.deleteMany({ userId }, session);
    } catch (error) {
      logger.error(`Error in deleteSummary: ${error}`);
      throw error;
    }
  }
}

export default SummaryRepository;
