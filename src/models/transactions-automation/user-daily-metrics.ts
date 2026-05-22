import mongoose, { Schema } from 'mongoose';
import type { IUserDailyMetrics } from '@/types/bank';

const categoryBreakdownSchema = new Schema(
  {
    category: { type: String, required: true },
    debit: { type: Number, default: 0 },
    credit: { type: Number, default: 0 },
  },
  { _id: false }
);

const subcategoryBreakdownSchema = new Schema(
  {
    category: { type: String, required: true },
    subcategory: { type: String, required: true },
    debit: { type: Number, default: 0 },
    credit: { type: Number, default: 0 },
  },
  { _id: false }
);

const userDailyMetricsSchema = new Schema<IUserDailyMetrics>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      required: true,
      index: true,
    },
    date: {
      type: Date,
      required: true,
    },
    sourceType: {
      type: String,
      enum: ['BANK', 'MANUAL'],
      required: true,
    },
    bankId: {
      type: Schema.Types.ObjectId,
      ref: 'Bank',
      default: null,
    },
    accountId: {
      type: Schema.Types.ObjectId,
      ref: 'Account',
      default: null,
    },
    totalDebit: {
      type: Number,
      default: 0,
    },
    totalCredit: {
      type: Number,
      default: 0,
    },
    transactionCount: {
      type: Number,
      default: 0,
    },
    categoryBreakdown: {
      type: [categoryBreakdownSchema],
      default: [],
    },
    subcategoryBreakdown: {
      type: [subcategoryBreakdownSchema],
      default: [],
    },
  },
  { timestamps: true }
);

userDailyMetricsSchema.index({ userId: 1, date: 1, sourceType: 1, bankId: 1, accountId: 1 }, { unique: true });
userDailyMetricsSchema.index({ userId: 1, date: -1, sourceType: 1, bankId: 1 });

const UserDailyMetrics = mongoose.model<IUserDailyMetrics>('UserDailyMetrics', userDailyMetricsSchema);

export default UserDailyMetrics;
