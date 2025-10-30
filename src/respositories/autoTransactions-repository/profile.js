const { Profile } = require("../../models/index");
const CrudRepository = require("../crud-repository");
const {
  encrypt,
  decrypt,
  encryptObject,
  decryptObject,
} = require("../../services/Encryption/encryption-service");
const decryptDataKey = require("../../services/Encryption/decryptDataKey");
const AppError = require("../../utils/errors/app-error");
const logger = require("../../utils/common/logger");
const { StatusCodes } = require("http-status-codes");


class UserProfileRepository extends CrudRepository {
  constructor() {
    super(Profile);
  }

  async createProfile(data, plaintextKey, ciphertextBlob) {
    const profileData = {
      holder: await encryptObject(data.holder, plaintextKey),
      type: await encrypt(data.type, plaintextKey),
      accountId: data.accountId,
      userId: data.userId,
      encryptedDEK: ciphertextBlob,
    };
    const response = await this.create(profileData);
    return response;
  }

  async getProfile({ accountIds }) {
      // Query for all accountIds using $in
      const responses = await this.get({ accountId: { $in: accountIds } });

      // Ensure at least one document is returned
      if (!responses.length) {
        throw new Error("No profiles found for the given accountIds");
      }

      // Iterate over the responses to decrypt each profile
      const profiles = await Promise.all(
        responses.map(async (response) => {
          const plaintextKey = await decryptDataKey(response.encryptedDEK);
          return {
            holder: await decryptObject(response.holder, plaintextKey),
            type: decrypt(
              response.type.encryptedData,
              response.type.iv,
              response.type.authTag,
              plaintextKey
            ),
            _id: response._id,
            accountId: response.accountId,
            encryptedDEK: response.encryptedDEK,
          };
        })
      );
      return profiles;
  }

  async updateProfile(query, data, plaintextKey, ciphertextBlob) {
    try {
      // Find the existing profile to update
      const existingProfile = await Profile.findOne({
        accountId: query.accountId,
        userId: data.userId,
      });

      if (!existingProfile) {
        throw new AppError("Profile not found", StatusCodes.NOT_FOUND);
      }

      // Prepare the updated profile data with encryption
      const profileData = {
        holder: await encryptObject(data.holder, plaintextKey),
        type: await encrypt(data.type, plaintextKey),
        accountId: data.accountId,
        userId: data.userId,
        encryptedDEK: ciphertextBlob,
      };

      // Update the existing record
      const response = await Profile.findOneAndUpdate(
        { _id: existingProfile._id },
        { $set: profileData }
      );

      return response;
    } catch (error) {
      logger.error(`Error in updateProfile: ${error}`);
      throw error;
    }
  }

  async deleteProfile(userId, accountId) {
    try {
      let response;
      if (accountId) {
        response = await this.deleteOne({ userId, accountId });
      } else {
        response = await this.deleteMany({ userId });
      }
      return response;
    } catch (error) {
      logger.error(`Error in deleteProfile from repositories: ${error}`);
      throw error;
    }
  }
}

module.exports = UserProfileRepository;
