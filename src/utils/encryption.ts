// require('dotenv').config();
// const crypto = require('crypto');
// const googleAuth = require('../models/google-auth');

// const ENCRYPTION_KEY = Buffer.from(process.env.ENCRYPTION_KEY, 'hex');
// const ALGORITHM = process.env.ALGORITHM;

// async function encryptToken(token) {
//   try {
//     const iv = crypto.randomBytes(16); // 16 bytes IV for GCM
//     const cipher = crypto.createCipheriv(ALGORITHM, ENCRYPTION_KEY, iv);

//     let encrypted = cipher.update(token, 'utf8', 'base64');
//     encrypted += cipher.final('base64');

//     const authTag = cipher.getAuthTag().toString('base64');

//     return {
//       encryptedData: encrypted,
//       iv: iv.toString('base64'),
//       authTag,
//     };
//   } catch (err) {
//     console.error('Encryption error:', err);
//     throw err;
//   }
// }

// async function decryptToken(encryptedData, iv, authTag) {
//   try {
//     const decipher = crypto.createDecipheriv(ALGORITHM, ENCRYPTION_KEY, Buffer.from(iv, 'base64'));
//     decipher.setAuthTag(Buffer.from(authTag, 'base64'));

//     let decrypted = decipher.update(encryptedData, 'base64', 'utf8');
//     decrypted += decipher.final('utf8');
//     return decrypted;
//   } catch (err) {
//     console.error('Decryption error:', err);
//     throw err;
//   }
// }

// async function migrateTokenById() {
//   // Find all users with a non-empty googleRefreshToken
//   const users = await googleAuth.find({
//     googleRefreshToken: { $exists: true, $ne: '' },
//   });

//   for (const user of users) {
//     try {
//       const { encryptedData, iv, authTag } = await encryptToken(user.googleRefreshToken);

//       // Save encrypted token
//       user.refreshToken = { encryptedData, iv, authTag };
//       await user.save();
//     } catch (err) {
//       // console.error(`Failed to migrate user ${user._id}:`, err);
//     }
//   }
// }

// module.exports = {
//   encryptToken,
//   decryptToken,
//   migrateTokenById,
// };
import dotenv from 'dotenv';
import crypto, { CipherGCM, DecipherGCM } from 'crypto';
import { GoogleAuth } from '../models/google-auth';

dotenv.config();

const ENCRYPTION_KEY_HEX = process.env.ENCRYPTION_KEY || '';
const ALGORITHM = process.env.ALGORITHM || 'aes-256-gcm';

// 32-byte key for AES-256 (assumed)
const ENCRYPTION_KEY = Buffer.from(ENCRYPTION_KEY_HEX, 'hex');

export interface EncryptedToken {
  encryptedData: string;
  iv: string;
  authTag: string;
}

export async function encryptToken(token: string): Promise<EncryptedToken> {
  try {
    const iv = crypto.randomBytes(16); // 16 bytes IV for GCM

    // explicitly tell TS we're using a GCM cipher
    const cipher = crypto.createCipheriv(
      ALGORITHM,
      ENCRYPTION_KEY,
      iv
    ) as CipherGCM;

    let encrypted = cipher.update(token, 'utf8', 'base64');
    encrypted += cipher.final('base64');

    const authTag = cipher.getAuthTag().toString('base64');

    return {
      encryptedData: encrypted,
      iv: iv.toString('base64'),
      authTag,
    };
  } catch (err) {
    console.error('Encryption error:', err);
    throw err;
  }
}

export async function decryptToken(
  encryptedData: string,
  iv: string,
  authTag: string
): Promise<string> {
  try {
    const decipher = crypto.createDecipheriv(
      ALGORITHM,
      ENCRYPTION_KEY,
      Buffer.from(iv, 'base64')
    ) as DecipherGCM;

    decipher.setAuthTag(Buffer.from(authTag, 'base64'));

    let decrypted = decipher.update(encryptedData, 'base64', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
  } catch (err) {
    console.error('Decryption error:', err);
    throw err;
  }
}

// Migration helper (legacy, one-off job)
export async function migrateTokenById(): Promise<void> {
  // googleRefreshToken is a legacy field not in the TS interface, so we cast to any
  const users: any[] = await (GoogleAuth as any).find({
    googleRefreshToken: { $exists: true, $ne: '' },
  });

  for (const user of users) {
    try {
      const { encryptedData, iv, authTag } = await encryptToken(
        user.googleRefreshToken
      );

      user.refreshToken = { encryptedData, iv, authTag };
      await user.save();
    } catch (err) {
      // optional logging if you want
      // console.error(`Failed to migrate user ${user._id}:`, err);
    }
  }
}

export default {
  encryptToken,
  decryptToken,
  migrateTokenById,
};
