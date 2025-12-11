import { Document } from 'mongoose';

export interface IFailedTransaction extends Document {
  custId?: string;
  userId?: string;
  fipId?: string;
  consentId?: string;
  consendHandleId?: string; // Keeping original field name as-is
  bankName?: string;
  accountId?: string;
  fetchCount?: string;

  FROM?: Date;

  retryCount: number;
}
