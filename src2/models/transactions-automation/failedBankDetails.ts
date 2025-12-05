import mongoose, { Schema, Document } from 'mongoose';
import { IFailedTransaction } from '@/types/bank';

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
