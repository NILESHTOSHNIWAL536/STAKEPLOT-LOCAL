import { Types, Document } from 'mongoose';

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
