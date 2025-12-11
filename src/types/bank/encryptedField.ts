import { Schema } from 'mongoose';

export interface IEncryptedField {
  encryptedData: string;
  iv: string;
  authTag: string;
}

export const encryptedFieldSchema = new Schema<IEncryptedField>(
  {
    encryptedData: { type: String, required: true },
    iv: { type: String, required: true },
    authTag: { type: String, required: true },
  },
  { _id: false }
);
