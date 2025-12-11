import { Document, Types } from 'mongoose';

export interface IGroupedTransaction extends Document {
  userId: Types.ObjectId;

  groupKey: string;

  amount? : number;

  transactions: Types.ObjectId[];

  narrationPattern: string;

  totalAmount: number;
  count: number;

  suggestedCategory: string;

  createdAt: Date;
  updatedAt: Date;
}
