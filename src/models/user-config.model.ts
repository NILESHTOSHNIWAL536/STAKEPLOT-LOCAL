import mongoose, { Document, Schema } from 'mongoose';
import { AppLimits } from '@/utils/helpers/collections_envs';

export interface IUserConfig extends Document {
  userId: mongoose.Types.ObjectId;
  baseLimit: number;
  referralBonus: number;
  createdAt: Date;
  updatedAt: Date;
}

const userConfigSchema = new Schema<IUserConfig>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      required: true,
      unique: true,
      index: true,
    },
    baseLimit: {
      type: Number,
      default: AppLimits.MAX_COLLECTIONS_PER_USER,
      min: 0,
    },
    referralBonus: {
      type: Number,
      default: 0,
      min: 0,
    },
  },
  { timestamps: true }
);

const UserConfig = mongoose.model<IUserConfig>('UserConfig', userConfigSchema);

export default UserConfig;
