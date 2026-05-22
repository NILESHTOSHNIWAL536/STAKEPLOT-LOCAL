import mongoose, { Schema, Document, Types } from 'mongoose';

/* ============================
   Pending Transaction Interface
============================ */

export interface IPendingTransaction extends Document {
  transactionType?: string;
  amount?: number;

  accountId?: Types.ObjectId;
  userId: Types.ObjectId;

  createdAt: Date;
  updatedAt: Date;
}

/* ============================
   Pending Transaction Schema
============================ */

const transactionSchema = new Schema<IPendingTransaction>(
  {
    transactionType: {
      type: String,
    },

    amount: {
      type: Number,
    },

    accountId: {
      type: Schema.Types.ObjectId,
      ref: 'Account',
    },

    userId: {
      type: Schema.Types.ObjectId,
      // Matches your user model name
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

/* ============================
   Export Model
============================ */

const PendingTransaction = mongoose.model<IPendingTransaction>('PendingTransaction', transactionSchema);

export default PendingTransaction;
