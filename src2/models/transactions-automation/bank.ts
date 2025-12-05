import mongoose, { Schema, Document, Types } from 'mongoose';
import { IBank, encryptedFieldSchema, IFiAccountInfo } from '@/types/bank';

const fiAccountInfoSchema = new Schema<IFiAccountInfo>({
  accountRefNo: {
    ...encryptedFieldSchema,
    required: true,
  },

  linkRefNo: {
    ...encryptedFieldSchema,
    required: true,
  },
});

const bankSchema = new Schema<IBank>({
  fipId: {
    ...encryptedFieldSchema,
    required: true,
  },

  fipName: {
    ...encryptedFieldSchema,
    required: true,
  },

  custId: {
    ...encryptedFieldSchema,
    required: true,
  },

  consentId: {
    ...encryptedFieldSchema,
    required: true,
  },

  consentHandleId: {
    ...encryptedFieldSchema,
    required: true,
  },

  fiAccountInfo: {
    type: [fiAccountInfoSchema],
    required: true,
  },

  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },

  encryptedDEK: {
    type: String,
    required: true,
  },
});

/* ============================
   Compound Index
============================ */

bankSchema.index({ fipId: 1, consentHandleId: 1, userId: 1 }, { unique: true });

/* ============================
   Export Model
============================ */

const Bank = mongoose.model<IBank>('Bank', bankSchema);
export default Bank;
