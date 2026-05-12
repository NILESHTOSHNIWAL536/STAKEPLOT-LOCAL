import { Schema, Types } from 'mongoose';

export interface IUserMinimal {
  _id: Types.ObjectId;
  email?: string;
  CreditCardLinkedBanks: Types.ObjectId[];
}

// Minimal projection-only schema — only declares fields the email-service reads
export const userSchema = new Schema<IUserMinimal>(
  {
    email: {
      type: String,
      trim: true,
      lowercase: true,
    },
    CreditCardLinkedBanks: [{ type: Schema.Types.ObjectId, ref: 'CreditCardBank' }],
  },
  { strict: false, collection: 'users' }
);
