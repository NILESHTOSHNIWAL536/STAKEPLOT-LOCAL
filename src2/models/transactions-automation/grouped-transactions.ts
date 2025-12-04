import mongoose, { Schema, Document, Types } from "mongoose";

/* ============================
   Grouped Transaction Interface
============================ */

export interface IGroupedTransaction extends Document {
  userId: Types.ObjectId;

  groupKey: string;

  transactions: Types.ObjectId[];

  narrationPattern: string;

  totalAmount: number;
  count: number;

  suggestedCategory: string;

  createdAt: Date;
  updatedAt: Date;
}

/* ============================
   Grouped Transaction Schema
============================ */

const groupedTransactionSchema = new Schema<IGroupedTransaction>({
  userId: {
    type: Schema.Types.ObjectId,
    ref: "User",
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
      ref: "BankTransaction",
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
    default: "Untagged",
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
groupedTransactionSchema.pre<IGroupedTransaction>("save", function (next) {
  this.updatedAt = new Date();
  next();
});

/* ============================
   Indexes
============================ */

groupedTransactionSchema.index(
  { userId: 1, groupKey: 1 },
  { unique: true }
);

/* ============================
   Export Model
============================ */

const GroupedTransaction = mongoose.model<IGroupedTransaction>(
  "GroupedTransaction",
  groupedTransactionSchema
);

export default GroupedTransaction;
