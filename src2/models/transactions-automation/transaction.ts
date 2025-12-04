import mongoose, { Schema, Document, Types } from 'mongoose';

/* ============================
   Transaction Interface
============================ */

export interface IBankTransaction extends Document {
  type: 'DEBIT' | 'CREDIT' | 'TDS';
  mode: string;
  name?: string;

  amount: number;
  transactionalBalance: number;
  balanceOut: number;

  transactionTimestamp: Date;
  valueDate?: Date;

  txnId: string;
  narration?: string;
  reference: string;

  manualTransaction: boolean;

  category: string;
  subcategory: string;

  Hidden: boolean;
  isBill: boolean;
  isDebt: boolean;
  isSplit: boolean;
  needsReview: boolean;
  isAutoPay: boolean;
  isExcluded: boolean;
  isBalanceOut: boolean;

  autoPayId: string;
  merchant: string;
  expectedFrequency: string;

  accountId?: Types.ObjectId;
  userId: Types.ObjectId;
  bankId?: Types.ObjectId;
}

/* ============================
   Transaction Schema
============================ */

const transactionSchema = new Schema<IBankTransaction>({
  type: {
    type: String,
    required: true,
    enum: ['DEBIT', 'CREDIT', 'TDS'],
  },

  mode: {
    type: String,
    required: true,
  },

  name: {
    type: String,
  },

  amount: {
    type: Number,
    required: true,
  },

  transactionalBalance: {
    type: Number,
    default: 0,
  },

  balanceOut: {
    type: Number,
    default: 0,
  },

  transactionTimestamp: {
    type: Date,
    required: true,
  },

  valueDate: {
    type: Date,
  },

  txnId: {
    type: String,
    default: '',
  },

  narration: {
    type: String,
  },

  reference: {
    type: String,
    default: '',
  },

  manualTransaction: {
    type: Boolean,
    default: false,
  },

  category: {
    type: String,
    required: true,
  },

  subcategory: {
    type: String,
    default: '',
  },

  Hidden: {
    type: Boolean,
    default: false,
  },

  isBill: {
    type: Boolean,
    default: false,
  },

  isDebt: {
    type: Boolean,
    default: false,
  },

  isSplit: {
    type: Boolean,
    default: false,
  },

  needsReview: {
    type: Boolean,
    default: false,
  },

  isAutoPay: {
    type: Boolean,
    default: false,
  },

  isExcluded: {
    type: Boolean,
    default: false,
  },

  isBalanceOut: {
    type: Boolean,
    default: false,
  },

  autoPayId: {
    type: String,
    default: '',
  },

  merchant: {
    type: String,
    default: '',
  },

  expectedFrequency: {
    type: String,
    default: '',
  },

  accountId: {
    type: Schema.Types.ObjectId,
    ref: 'Account',
  },

  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },

  bankId: {
    type: Schema.Types.ObjectId,
    ref: 'Bank',
  },
});

/* ============================
   Indexes
============================ */

// Optimized compound index for faster queries
transactionSchema.index({
  userId: 1,
  accountId: 1,
  bankId: 1,
  transactionTimestamp: -1,
});

/* ============================
   Export Model
============================ */

const BankTransaction = mongoose.model<IBankTransaction>('BankTransaction', transactionSchema);

export default BankTransaction;
