import mongoose, { Schema, Types } from 'mongoose';
import { IRecurringPayment } from '@/types/bank';

const recurringPaymentSchema = new Schema<IRecurringPayment>(
  {
    recentMostTransactionId: {
      type: Schema.Types.ObjectId,
      ref: 'BankTransaction',
      required: true,
    },

    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },

    merchant: {
      type: String,
      required: true,
    },

    frequency: {
      type: String,
      enum: ['daily', 'weekly', 'monthly', 'quarterly', 'biannual'],
      required: true,
    },

    amount: {
      type: Number,
      required: true,
    },

    recentMostTransactionTimestamp: {
      type: Date,
      required: true,
    },

    nextReminderAt: {
      type: Date,
      required: true,
    },

    narration: {
      type: String,
    },

    source: {
      type: String,
    },

    recentMostTwoOccurrences: {
      type: [Date],
      validate: [(array: Date[]) => array.length <= 2, 'Must contain at most 2 dates'],
    },

    occurrencesCount: {
      type: Number,
      default: 1,
      min: 1,
    },

    isActive: {
      type: Boolean,
      default: false,
    },

    isDaily: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

/* ============================
   Index
============================ */

recurringPaymentSchema.index({ nextReminderAt: 1 });

/* ============================
   Export Model
============================ */

const RecurringPayment = mongoose.model<IRecurringPayment>('RecurringPayment', recurringPaymentSchema);

export default RecurringPayment;
