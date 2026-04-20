import mongoose, { Document, Schema } from 'mongoose';

export interface IReferralUsage extends Document {
  referralCodeId: mongoose.Types.ObjectId;
  referralCode: string;
  referrerUserId: mongoose.Types.ObjectId;
  referredUserId: mongoose.Types.ObjectId;
  bonusAwarded: number;
  usedAt: Date;
  createdAt: Date;
  updatedAt: Date;
}

const referralUsageSchema = new Schema<IReferralUsage>(
  {
    referralCodeId: {
      type: Schema.Types.ObjectId,
      ref: 'ReferralCode',
      required: true,
      index: true,
    },
    referralCode: {
      type: String,
      required: true,
      uppercase: true,
      trim: true,
      index: true,
    },
    referrerUserId: {
      type: Schema.Types.ObjectId,
      required: true,
      index: true,
    },
    referredUserId: {
      type: Schema.Types.ObjectId,
      required: true,
      unique: true,
      index: true,
    },
    bonusAwarded: {
      type: Number,
      required: true,
      min: 1,
    },
    usedAt: {
      type: Date,
      default: Date.now,
      index: true,
    },
  },
  { timestamps: true }
);

referralUsageSchema.index({ referralCodeId: 1, referredUserId: 1 }, { unique: true });

const ReferralUsage = mongoose.model<IReferralUsage>('ReferralUsage', referralUsageSchema);

export default ReferralUsage;
