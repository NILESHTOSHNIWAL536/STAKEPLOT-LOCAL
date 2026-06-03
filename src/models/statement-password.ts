import { Schema, Types, Document } from 'mongoose';
import { IEncryptedField } from './scrape-result';

export interface IStatementPassword extends Document {
  userId: Types.ObjectId;
  bankId: string;
  email?: string;
  accountHint?: string;
  password?: IEncryptedField;
  passwords: IEncryptedField[];
  lastStatus: 'active' | 'invalid';
  lastError?: string;
}

export const statementPasswordSchema = new Schema<IStatementPassword>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      required: true,
      index: true,
    },
    bankId: {
      type: String,
      required: true,
      trim: true,
      index: true,
    },
    email: {
      type: String,
      lowercase: true,
      trim: true,
      index: true,
    },
    accountHint: {
      type: String,
      trim: true,
    },
    password: {
      encryptedData: { type: String },
      iv: { type: String },
      authTag: { type: String },
    },
    passwords: {
      type: [
        {
          encryptedData: { type: String, required: true },
          iv: { type: String, required: true },
          authTag: { type: String, required: true },
        },
      ],
      default: [],
    },
    lastStatus: {
      type: String,
      enum: ['active', 'invalid'],
      default: 'active',
    },
    lastError: {
      type: String,
      trim: true,
    },
  },
  { timestamps: true }
);

statementPasswordSchema.index(
  { userId: 1, bankId: 1, email: 1, accountHint: 1 },
  { unique: true }
);
