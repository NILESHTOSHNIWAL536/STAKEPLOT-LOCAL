import mongoose, { Schema, Document, Types } from 'mongoose';

export interface IWealthscapeSession extends Document {
  userId: Types.ObjectId;
  uniqueIdentifier: string; // mobile number or unique ID
  mobileNumber: string;
  aaCustId: string;          // e.g. "9860801720@finvu"
  pan?: string;
  templateName: string;
  userSessionId?: string;
  redirectUrl?: string;
  consentHandle?: string;
  url?: string;              // AA redirect URL returned by Wealthscape
  consentStatus: 'PENDING' | 'ACTIVE' | 'REJECTED' | 'REVOKED' | 'PAUSED' | 'EXPIRED' | 'FAILED';
  subscribed: boolean;
  userToken?: string;
  expiresAt: Date;
}

const WealthscapeSessionSchema = new Schema<IWealthscapeSession>(
  {
    userId: { type: Schema.Types.ObjectId, required: true },
    uniqueIdentifier: { type: String, required: true },
    mobileNumber: { type: String, required: true },
    aaCustId: { type: String, required: true },
    pan: { type: String },
    templateName: { type: String, required: true },
    userSessionId: { type: String },
    redirectUrl: { type: String },
    consentHandle: { type: String },
    url: { type: String },
    consentStatus: {
      type: String,
      enum: ['PENDING', 'ACTIVE', 'REJECTED', 'REVOKED', 'PAUSED', 'EXPIRED', 'FAILED'],
      default: 'PENDING',
    },
    subscribed: { type: Boolean, default: false },
    userToken: { type: String },
    expiresAt: {
      type: Date,
      default: () => new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days
      index: { expires: '7d' },
    },
  },
  { timestamps: true }
);

// Index for fast lookup by userId + consentHandle
WealthscapeSessionSchema.index({ userId: 1, consentHandle: 1 });
WealthscapeSessionSchema.index({ uniqueIdentifier: 1 });

const WealthscapeSession = mongoose.model<IWealthscapeSession>('WealthscapeSession', WealthscapeSessionSchema);

export default WealthscapeSession;
