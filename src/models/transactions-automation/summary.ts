import mongoose, { Schema, Document, Types } from 'mongoose';
import { ISummary, encryptedFieldSchema } from '@/types/bank';

const summarySchema = new Schema<ISummary>({
  accountId: {
    type: Schema.Types.ObjectId,
    ref: 'Account',
    required: true,
  },

  userId: {
    type: Schema.Types.ObjectId,
    
    required: true,
  },

  data: {
    type: Map,
    of: encryptedFieldSchema,
    required: true,
  },

  encryptedDEK: {
    type: String,
    required: true,
  },
});

const Summary = mongoose.model<ISummary>('Summary', summarySchema);
export default Summary;
