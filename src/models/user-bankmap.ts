import { Schema, Types, Document } from 'mongoose';

export interface IUserBankMap extends Document {
  userId: Types.ObjectId;
  mappings: {
    email: string;
    creditCardIds: string[];
  }[];
}

export const userBankMapSchema = new Schema<IUserBankMap>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      required: true,
      unique: true,
      index: true, // 🔥 ensure fast lookup
    },
    mappings: [
      {
        email: {
          type: String,
          required: true,
          lowercase: true,
          trim: true,
        },
        creditCardIds: {
          type: [String],
          default: [],
        },
      },
    ],
  },
  { timestamps: true }
);