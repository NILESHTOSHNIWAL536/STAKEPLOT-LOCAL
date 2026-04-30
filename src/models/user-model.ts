import { Schema, Types } from 'mongoose';

export interface IUserMinimal {
  _id: Types.ObjectId;
  CreditCardLinkedBanks: Types.ObjectId[];
}

// Minimal projection-only schema — only declares fields the email-service reads
export const userSchema = new Schema<IUserMinimal>(
  {
    CreditCardLinkedBanks: [{ type: Schema.Types.ObjectId, ref: 'CreditCardBank' }],
  },
  { strict: false, collection: 'users' }
);
