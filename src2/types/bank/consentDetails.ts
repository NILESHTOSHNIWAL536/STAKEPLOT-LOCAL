import { Document, Types } from 'mongoose';

export interface IConsentHandleId extends Document {
  custId: string;
  handleId: string;
  userId?: Types.ObjectId;
  expiresAt: Date;
}
