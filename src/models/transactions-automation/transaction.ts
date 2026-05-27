import mongoose, { Schema, Document, Types } from 'mongoose';
import { IBankTransaction } from '@/types/bank';

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

  // Structured fields extracted from the raw narration by the parser layer (PR2).
  // Optional — populated for recognised narration formats only.
  counterpartyName: {
    type: String,
    default: '',
  },

  counterpartyVPA: {
    type: String,
    default: '',
  },

  counterpartyBankHandle: {
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
