import { Document, Types } from 'mongoose';
import { IEncryptedField } from './encryptedField';

export interface ISummary extends Document {
  accountId: Types.ObjectId;
  userId: Types.ObjectId;

  data: Map<string, IEncryptedField>;
  encryptedDEK: string;
}
