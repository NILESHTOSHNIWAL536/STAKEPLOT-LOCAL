import mongoose, { Schema, Document, Types } from 'mongoose';

/* ============================
   Transaction Rule Interface
============================ */

export interface ITransactionRule extends Document {
  userId: Types.ObjectId;

  narrationPattern: string;
  amount?: number;

  category: string;
  subcategory: string;

  source: 'manual' | 'group';

  createdAt: Date;
  updatedAt: Date;
}

/* ============================
   Transaction Rule Schema
============================ */

const transactionRuleSchema = new Schema<ITransactionRule>({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true,
  },

  narrationPattern: {
    type: String,
    required: true,
  },

  amount: {
    type: Number,
    index: true,
  },

  category: {
    type: String,
    required: true,
  },

  subcategory: {
    type: String,
    default: '',
  },

  source: {
    type: String,
    enum: ['manual', 'group'],
    required: true,
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
   Indexes
============================ */

// Compound index for fast rule matching
transactionRuleSchema.index({
  userId: 1,
  narrationPattern: 1,
  amount: 1,
});

/* ============================
   Export Model
============================ */

const TransactionRule = mongoose.model<ITransactionRule>('TransactionRule', transactionRuleSchema);

export default TransactionRule;
