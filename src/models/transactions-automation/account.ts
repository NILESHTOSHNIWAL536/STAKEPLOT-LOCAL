import mongoose, { Schema, Types } from 'mongoose';
import { IAccount, encryptedFieldSchema } from '@/types/bank';

const accountSchema = new Schema<IAccount>({
  linkedAccRef: {
    type: encryptedFieldSchema,
    required: true,
    unique: true,
  },

  type: {
    type: encryptedFieldSchema,
    enum: ['term_deposit', 'recurring_deposit', 'deposit'],
    required: true,
  },

  maskedAccNumber: {
    type: encryptedFieldSchema,
    required: true,
  },

  version: {
    type: encryptedFieldSchema,  // ✅ Changed from spread
    required: true,
  },

  schemaLocation: {
    type: encryptedFieldSchema,  // ✅ Changed from spread
  },

  startDate: {
    type: Date,
    required: false,
  },

  endDate: {
    type: Date,
    required: false,
  },

  bankId: {
    type: Schema.Types.ObjectId,
    ref: 'Bank',
    required: true,
  },

  userId: {
    type: Schema.Types.ObjectId,
    
    required: true,
  },

  fetchCount: {
    type: Number,
    default: 1,
  },

  nextFetch: {
    type: Date,
  },

  lastFetch: {
    type: Date,
  },

  encryptedDEK: {
    type: String,
    required: true,
  },
});

/* ============================
   Export Model
============================ */

const Account = mongoose.model<IAccount>('Account', accountSchema);
export default Account;