import mongoose, { Document, Schema } from 'mongoose';

export interface IReferralCode extends Document {
  code: string;
  createdByUserId: mongoose.Types.ObjectId;
  usageLimit: number;
  usageCount: number;
  bonusAmount: number;
  expiresAt: Date;
  active: boolean;
  createdAt: Date;
  updatedAt: Date;
}

const referralCodeSchema = new Schema<IReferralCode>(
  {
    code: {
      type: String,
      required: true,
      unique: true,
      uppercase: true,
      trim: true,
      index: true,
    },
    createdByUserId: {
      type: Schema.Types.ObjectId,
      required: true,
      index: true,
    },
    usageLimit: {
      type: Number,
      default: 1,
      min: 1,
    },
    usageCount: {
      type: Number,
      default: 0,
      min: 0,
    },
    bonusAmount: {
      type: Number,
      default: 1,
      min: 1,
    },
    expiresAt: {
      type: Date,
      required: true,
      index: true,
    },
    active: {
      type: Boolean,
      default: true,
      index: true,
    },
  },
  { timestamps: true }
);

referralCodeSchema.index({ createdByUserId: 1, active: 1 });

const ReferralCode = mongoose.model<IReferralCode>('ReferralCode', referralCodeSchema);

export default ReferralCode;
