import mongoose, { Schema, Document, Types } from 'mongoose';
import { IBank, encryptedFieldSchema, IFiAccountInfo } from '@/types/bank';

const fiAccountInfoSchema = new Schema<IFiAccountInfo>({
  accountRefNo: {
    type: encryptedFieldSchema,  // ✅ Changed from spread
    required: true,
  },

  linkRefNo: {
    type: encryptedFieldSchema,  // ✅ Changed from spread
    required: true,
  },
});

const bankSchema = new Schema<IBank>({
  fipId: {
    type: encryptedFieldSchema,  // ✅ Changed from spread
    required: true,
  },

  fipName: {
    type: encryptedFieldSchema,  // ✅ Changed from spread
    required: true,
  },

  custId: {
    type: encryptedFieldSchema,  // ✅ Changed from spread
    required: true,
  },

  consentId: {
    type: encryptedFieldSchema,  // ✅ Changed from spread
    required: true,
  },

  consentHandleId: {
    type: encryptedFieldSchema,  // ✅ Changed from spread
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