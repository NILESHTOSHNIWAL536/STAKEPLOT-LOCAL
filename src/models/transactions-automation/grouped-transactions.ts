import mongoose, { Schema, Document, Types } from 'mongoose';
import { IGroupedTransaction } from '@/types/bank';

const groupedTransactionSchema = new Schema<IGroupedTransaction>({
  userId: {
    type: Schema.Types.ObjectId,
    
    required: true,
    index: true,
  },

  groupKey: {
    type: String,
    required: true,
  },

  transactions: [
    {
      type: Schema.Types.ObjectId,
      ref: 'BankTransaction',
      required: true,
    },
  ],

  narrationPattern: {
    type: String,
    required: true,
  },

  totalAmount: {
    type: Number,
    required: true,
  },

  count: {
    type: Number,
    required: true,
  },

  suggestedCategory: {
    type: String,
    default: 'Untagged',
  },

  createdAt: {
    type: Date,
    default: Date.now,
  },

  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

/* ============================
   Pre-save Hook
============================ */

// Update `updatedAt` before saving
groupedTransactionSchema.pre<IGroupedTransaction>('save', function (next) {
  this.updatedAt = new Date();
  next();
});

/* ============================
   Indexes
============================ */

groupedTransactionSchema.index({ userId: 1, groupKey: 1 }, { unique: true });

/* ============================
   Export Model
============================ */

const GroupedTransaction = mongoose.model<IGroupedTransaction>('GroupedTransaction', groupedTransactionSchema);

export default GroupedTransaction;
