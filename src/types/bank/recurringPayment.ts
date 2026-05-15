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
  normalizedMerchantKey: string;
  transactionIds?: Types.ObjectId[];
  amountVariance?: number;
  currency?: string;
  confidenceScore?: number;
  confidenceLabel?: 'high' | 'medium' | 'low';
  detectionMethod?: 'keyword_match' | 'merchant_name' | 'bbps' | 'amount_pattern' | 'manual' | 'merchantMatch' | 'patternMatch';
  merchantCategory?: string;
  matchedNarrations?: string[];
  isUserDefined?: boolean;

  recentMostTwoOccurrences?: Date[];

  occurrencesCount: number;
  isActive: boolean;
  isDaily: boolean;

  createdAt: Date;
  updatedAt: Date;
}
