import { Profile } from '../../models';
import CrudRepository from '../crud-repository';
import { encrypt, decrypt, encryptObject, decryptObject } from '@/services/Encryption/encryption-service';
import decryptDataKey from '@/services/Encryption/decryptDataKey';
import AppError from '@/utils/errors/app-error';
import logger from '@/utils/common/logger';
import { StatusCodes } from 'http-status-codes';

import { IProfile, IEncryptedField } from '@/types/bank';
import { Types } from 'mongoose';

interface CreateProfileData {
  holder: Record<string, any>;
  type: string;
  accountId: string;
  userId: string | Types.ObjectId;
}

interface UpdateProfileData {
  holder: Record<string, any>;
  type: string;
  accountId: string;
  userId: string;
}

class UserProfileRepository extends CrudRepository<typeof Profile> {
  constructor() {
    super(Profile);
  }

  // ----------------------------------------------------
  // CREATE PROFILE
  // ----------------------------------------------------
  async createProfile(data: CreateProfileData, plaintextKey: string | Uint8Array, ciphertextBlob: string) {
    try {
      const existingProfiles = await this.model.find({
        accountId: data.accountId,
        userId: data.userId,
      });

      const profileData = {
        holder: await encryptObject(data.holder, plaintextKey),
        type: await encrypt(data.type, plaintextKey),
        accountId: data.accountId,
        userId: data.userId,
        encryptedDEK: ciphertextBlob,
      };

      // --------------------------
      // UPDATE if exists
      // --------------------------
      if (Array.isArray(existingProfiles) && existingProfiles.length > 0) {
        const existing = existingProfiles[0];

        return this.model.findByIdAndUpdate(existing._id, { $set: profileData }, { new: true });
      }

      // --------------------------
      // CREATE NEW PROFILE
      // --------------------------
      return await this.create(profileData);
    } catch (error) {
      logger.error(`Error in createProfile: ${error}`);
      throw error;
    }
  }

  // ----------------------------------------------------
  // GET PROFILES BY ACCOUNT IDS
  // ----------------------------------------------------
  async getProfile({ accountIds }: { accountIds: string[] }) {
    const results = await this.get({ accountId: { $in: accountIds } });

    if (!results || results.length === 0) throw new AppError('No profiles found', StatusCodes.NOT_FOUND);

    return Promise.all(
      results.map(async (profile: IProfile) => {
        const plaintextKey = await decryptDataKey(profile.encryptedDEK);

        return {
          _id: profile._id,
          accountId: profile.accountId,
          encryptedDEK: profile.encryptedDEK,
          holder: await decryptObject(profile.holder, plaintextKey),
          type: decrypt(profile.type.encryptedData, profile.type.iv, profile.type.authTag, plaintextKey),
        };
      })
    );
  }

  // ----------------------------------------------------
  // UPDATE PROFILE
  // ----------------------------------------------------
  async updateProfile(query: { accountId: string }, data: UpdateProfileData, plaintextKey: string | Buffer, ciphertextBlob: string) {
    try {
      const existingProfile = await Profile.findOne({
        accountId: query.accountId,
        userId: data.userId,
      });

      if (!existingProfile) throw new AppError('Profile not found', StatusCodes.NOT_FOUND);

      const profileData = {
        holder: await encryptObject(data.holder, plaintextKey),
        type: await encrypt(data.type, plaintextKey),
        accountId: data.accountId,
        userId: data.userId,
        encryptedDEK: ciphertextBlob,
      };

      return await Profile.findOneAndUpdate({ _id: existingProfile._id }, { $set: profileData }, { new: true });
    } catch (error) {
      logger.error(`Error in updateProfile: ${error}`);
      throw error;
    }
  }

  // ----------------------------------------------------
  // DELETE PROFILE
  // ----------------------------------------------------
  async deleteProfile(userId: string, accountId?: string) {
    try {
      if (accountId) {
        return await this.deleteOne({ userId, accountId });
      }
      return await this.deleteMany({ userId });
    } catch (error) {
      logger.error(`Error in deleteProfile: ${error}`);
      throw error;
    }
  }
}

export default UserProfileRepository;
