import { Document, Types } from 'mongoose';

export interface IRecurringPayment extends Document {
  recentMostTransactionId: Types.ObjectId;
  userId: Types.ObjectId;
  merchant: string;

  frequency: 'daily' | 'weekly' | 'monthly' | 'quarterly' | 'biannual';

  amount: number;
  recentMostTransactionTimestamp: Date;
  nextReminderAt: Date;

  narration?: string;
  source?: string;

  recentMostTwoOccurrences?: Date[];

  occurrencesCount: number;
  isActive: boolean;
  isDaily: boolean;

  createdAt: Date;
  updatedAt: Date;
}
