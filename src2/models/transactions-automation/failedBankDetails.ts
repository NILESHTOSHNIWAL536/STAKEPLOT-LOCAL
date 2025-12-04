import mongoose, { Schema, Document } from 'mongoose';

/* ============================
   Failed Transaction Interface
============================ */

export interface IFailedTransaction extends Document {
  custId?: string;
  userId?: string;
  fipId?: string;
  consentId?: string;
  consendHandleId?: string; // Keeping original field name as-is
  bankName?: string;
  accountId?: string;
  fetchCount?: string;

  FROM?: Date;

  retryCount: number;
}

/* ============================
   Failed Transaction Schema
============================ */

const FailedTransactionSchema = new Schema<IFailedTransaction>({
  custId: {
    type: String,
  },

  userId: {
    type: String,
  },

  fipId: {
    type: String,
  },

  consentId: {
    type: String,
  },

  consendHandleId: {
    type: String,
  },

  bankName: {
    type: String,
  },

  accountId: {
    type: String,
  },

  fetchCount: {
    type: String,
  },

  FROM: {
    type: Date,
  },

  retryCount: {
    type: Number,
    default: 0,
  },
});

/* ============================
   Export Model
============================ */

const FailedTransaction = mongoose.model<IFailedTransaction>('FailedTransaction', FailedTransactionSchema);

export default FailedTransaction;
