import { Schema, Document } from 'mongoose';

export interface IEncryptedToken {
  encryptedData: string;
  iv: string;
  authTag: string;
}

export interface IGoogleAuth extends Document {
  email: string;
  refreshToken: IEncryptedToken;
}

export const googleAuthSchema = new Schema<IGoogleAuth>(
  {
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    refreshToken: {
      encryptedData: { type: String, required: true },
      iv: { type: String, required: true },
      authTag: { type: String, required: true },
    },
  },
  { timestamps: true }
);