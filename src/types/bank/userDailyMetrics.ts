import { Document, Types } from 'mongoose';

export type MetricsSourceType = 'BANK' | 'MANUAL';

export interface ICategoryMetrics {
  category: string;
  debit: number;
  credit: number;
}

export interface ISubcategoryMetrics {
  category: string;
  subcategory: string;
  debit: number;
  credit: number;
}

export interface IUserDailyMetrics extends Document {
  userId: Types.ObjectId;
  date: Date; // UTC midnight

  sourceType: MetricsSourceType;
  bankId: Types.ObjectId | null;
  accountId: Types.ObjectId | null;

  totalDebit: number;
  totalCredit: number;
  transactionCount: number;

  categoryBreakdown: ICategoryMetrics[];
  subcategoryBreakdown: ISubcategoryMetrics[];

  createdAt?: Date;
  updatedAt?: Date;
}
