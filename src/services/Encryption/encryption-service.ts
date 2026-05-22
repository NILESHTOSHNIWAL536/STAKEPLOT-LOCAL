import { error } from 'console';
import crypto from 'crypto';

const ivLength = 12; // AES-GCM standard IV length

// -------------------------
// Types
// -------------------------
export interface EncryptedPayload {
  encryptedData: string;
  iv: string;
  authTag: string;
}

export interface EncryptedObject {
  [key: string]: EncryptedPayload;
}

// -------------------------
// Encryption function
// -------------------------
export async function encrypt(text: string, plaintextKey: string | Uint8Array): Promise<EncryptedPayload> {
  if (!text) {
    return { encryptedData: '', iv: '', authTag: '' };
  }

  const keyBuffer = Buffer.isBuffer(plaintextKey) ? plaintextKey : Buffer.from(plaintextKey);

  if (keyBuffer.length !== 32) {
    throw new Error('Invalid key length: must be 32 bytes for AES-256');
  }

  const iv = crypto.randomBytes(ivLength);
  const cipher = crypto.createCipheriv('aes-256-gcm', keyBuffer, iv);

  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');

  const authTag = cipher.getAuthTag();

  return {
    encryptedData: encrypted,
    iv: iv.toString('hex'),
    authTag: authTag.toString('hex'),
  };
}

// -------------------------
// Decryption function
// -------------------------
export function decrypt(encryptedData: string, ivHex: string, authTagHex: string, plaintextKey: string | Uint8Array): string {
  const keyBuffer = Buffer.isBuffer(plaintextKey) ? plaintextKey : Buffer.from(plaintextKey);

  const iv = Buffer.from(ivHex, 'hex');
  const authTag = Buffer.from(authTagHex, 'hex');

  const decipher = crypto.createDecipheriv('aes-256-gcm', keyBuffer, iv);
  decipher.setAuthTag(authTag);

  let decrypted = decipher.update(encryptedData, 'hex', 'utf8');
  decrypted += decipher.final('utf8');

  return decrypted;
}

// -------------------------
// Encrypt an object
// -------------------------
export async function encryptObject(obj: Record<string, any> | Map<string, any>, plaintextKey: string | Uint8Array): Promise<EncryptedObject> {
  const encryptedObj: EncryptedObject = {};
  const entries = obj instanceof Map ? obj.entries() : Object.entries(obj);

  for (const [key, value] of entries) {
    if (value === null || value === undefined) continue;
    if (typeof value === 'string' && value.trim() === '') continue;

    encryptedObj[key] = await encrypt(String(value), plaintextKey);
  }

  return encryptedObj;
}

// -------------------------
// Decrypt an object
// -------------------------
export async function decryptObject(obj: Record<string, EncryptedPayload> | Map<string, EncryptedPayload>, plaintextKey: string | Uint8Array): Promise<Record<string, any>> {
  const decryptedObj: Record<string, any> = {};
  const entries = obj instanceof Map ? obj.entries() : Object.entries(obj);

  for (const [key, value] of entries) {
    if (value?.encryptedData && value.iv && value.authTag) {
      decryptedObj[key] = decrypt(value.encryptedData, value.iv, value.authTag, plaintextKey);
    } else {
      decryptedObj[key] = value;
    }
  }

  return decryptedObj;
}
