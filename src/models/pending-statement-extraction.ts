import { Document, Schema } from 'mongoose';
import { EncryptedToken } from '../utils/encryption';

export type PendingStatementStatus =
  | 'PENDING_PASSWORD'
  | 'PROCESSING'
  | 'COMPLETED'
  | 'FAILED';

export interface IPendingStatementExtraction extends Document {
  userId: Schema.Types.ObjectId;
  requestId: string;
  email: string;
  bankId: string;
  bankName: string;
  accountHint?: string;
  messageId?: string;
  attachmentName?: string;
  reason?: string;
  status: PendingStatementStatus;
  encryptedMailPayload?: EncryptedToken;
  bankConfig: any[];
  lastError?: string;
  completedAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

export const pendingStatementExtractionSchema =
  new Schema<IPendingStatementExtraction>(
    {
      userId: { type: Schema.Types.ObjectId, required: true, index: true },
      requestId: { type: String, required: true, unique: true, index: true },
      email: { type: String, default: '', index: true },
      bankId: { type: String, required: true, index: true },
      bankName: { type: String, default: 'Bank statement' },
      accountHint: { type: String, default: '' },
      messageId: { type: String, default: '' },
      attachmentName: { type: String, default: '' },
      reason: { type: String, default: 'password_required' },
      status: {
        type: String,
        enum: ['PENDING_PASSWORD', 'PROCESSING', 'COMPLETED', 'FAILED'],
        default: 'PENDING_PASSWORD',
        index: true,
      },
      encryptedMailPayload: {
        encryptedData: String,
        iv: String,
        authTag: String,
      },
      bankConfig: { type: [Schema.Types.Mixed] as any, default: [] },
      lastError: { type: String, default: '' },
      completedAt: { type: Date },
    },
    { timestamps: true }
  );

pendingStatementExtractionSchema.index({
  userId: 1,
  bankId: 1,
  email: 1,
  status: 1,
});
