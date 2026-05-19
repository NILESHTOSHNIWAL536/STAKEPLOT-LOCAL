import dotenv from 'dotenv';
import crypto, { CipherGCM, DecipherGCM } from 'crypto';

dotenv.config();

const ENCRYPTION_KEY_HEX = process.env.ENCRYPTION_KEY || '';
const ALGORITHM = process.env.ALGORITHM || '';

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
    const cipher = crypto.createCipheriv(ALGORITHM, ENCRYPTION_KEY, iv) as CipherGCM;

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

export async function decryptToken(encryptedData: string, iv: string, authTag: string): Promise<string> {
  try {
    const decipher = crypto.createDecipheriv(ALGORITHM, ENCRYPTION_KEY, Buffer.from(iv, 'base64')) as DecipherGCM;

    decipher.setAuthTag(Buffer.from(authTag, 'base64'));

    let decrypted = decipher.update(encryptedData, 'base64', 'utf8');
    decrypted += decipher.final('utf8');
    return decrypted;
  } catch (err) {
    console.error('Decryption error:', err);
    throw err;
  }
}

// All scrape result payload fields — every attribute is encrypted at rest
export const SCRAPE_STRING_FIELDS = [
  'amount', 'card_number', 'transaction_id', 'total_due', 'date',
  'category', 'mode', 'type', 'matched_bank', 'logo', 'bankName',
] as const;

export type ScrapeStringField = (typeof SCRAPE_STRING_FIELDS)[number];

export async function encryptScrapeFields(record: Record<string, any>): Promise<Record<string, any>> {
  const result = { ...record };
  for (const field of SCRAPE_STRING_FIELDS) {
    result[field] = await encryptToken(String(result[field] ?? ''));
  }
  // banks_checked is an array — serialize to JSON before encrypting
  result.banks_checked = await encryptToken(JSON.stringify(result.banks_checked ?? []));
  return result;
}

export async function decryptScrapeFields(record: Record<string, any>): Promise<Record<string, any>> {
  const result = { ...record };
  for (const field of SCRAPE_STRING_FIELDS) {
    const val = result[field];
    if (val && typeof val === 'object' && val.encryptedData) {
      result[field] = await decryptToken(val.encryptedData, val.iv, val.authTag);
    }
  }
  // banks_checked: decrypt then parse back to array
  const bc = result.banks_checked;
  if (bc && typeof bc === 'object' && bc.encryptedData) {
    try {
      result.banks_checked = JSON.parse(await decryptToken(bc.encryptedData, bc.iv, bc.authTag));
    } catch {
      result.banks_checked = [];
    }
  }
  return result;
}

export default {
  encryptToken,
  decryptToken,
  encryptScrapeFields,
  decryptScrapeFields,
};
