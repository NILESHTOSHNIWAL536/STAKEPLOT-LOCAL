import { Types, Document } from "mongoose";

export interface IRecurringPayment extends Document {
  _id: Types.ObjectId;
  userId: Types.ObjectId;
  isActive: boolean;
  amount: number;
  type: string;
  narration: string;
  cycle: string;
  nextDate: Date;
}
