import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IWealthscapeAccountData extends Document {
  userId: Types.ObjectId;
  uniqueIdentifier: string;
  accountId: string;            // from user-linked-accounts API
  fromDate: string;             // "YYYY-MM-DD"
  toDate: string;               // "YYYY-MM-DD"
  type?: string;                // "equities", "deposit", etc.
  version?: string;
  profile?: Record<string, any>;
  summary?: Record<string, any>;
  transactions?: any[];
  rawData?: Record<string, any>; // full raw response
  fetchedAt: Date;
}

const WealthscapeAccountDataSchema = new Schema<IWealthscapeAccountData>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    uniqueIdentifier: { type: String, required: true, index: true },
    accountId: { type: String, required: true },
    fromDate: { type: String, required: true },
    toDate: { type: String, required: true },
    type: { type: String },
    version: { type: String },
    profile: { type: Schema.Types.Mixed, default: {} },
    summary: { type: Schema.Types.Mixed, default: {} },
    transactions: { type: Schema.Types.Mixed, default: [] },
    rawData: { type: Schema.Types.Mixed, default: {} },
    fetchedAt: { type: Date, default: Date.now },
  },

  { timestamps: true }
);

WealthscapeAccountDataSchema.index({ userId: 1, accountId: 1 });
WealthscapeAccountDataSchema.index({ fetchedAt: -1 });

const WealthscapeAccountData = mongoose.model<IWealthscapeAccountData>(
  'WealthscapeAccountData',
  WealthscapeAccountDataSchema
);

export default WealthscapeAccountData;
