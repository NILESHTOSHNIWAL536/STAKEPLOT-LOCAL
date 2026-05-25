
import { Schema, model, Types, Document } from 'mongoose';

export interface IEncryptedField {
  encryptedData: string;
  iv: string;
  authTag: string;
}

export interface IScrapeResult extends Document {
  userId: Types.ObjectId;
  // all payload fields stored as AES-256-GCM ciphertext
  category: IEncryptedField;
  mode: IEncryptedField;
  type: IEncryptedField;
  matched_bank: IEncryptedField;
  logo: IEncryptedField;
  bankName: IEncryptedField;
  banks_checked: IEncryptedField; // JSON-stringified array, then encrypted
  amount: IEncryptedField;
  date: IEncryptedField;
  card_number: IEncryptedField;
  transaction_id: IEncryptedField;
  total_due: IEncryptedField;
}

const encryptedFieldSchema = {
  encryptedData: { type: String, default: '' },
  iv: { type: String, default: '' },
  authTag: { type: String, default: '' },
};

const scrapeResultSchema = new Schema<IScrapeResult>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      required: true,
    },
    category: { type: encryptedFieldSchema, default: () => ({ encryptedData: '', iv: '', authTag: '' }) },
    mode: { type: encryptedFieldSchema, default: () => ({ encryptedData: '', iv: '', authTag: '' }) },
    type: { type: encryptedFieldSchema, default: () => ({ encryptedData: '', iv: '', authTag: '' }) },
    matched_bank: { type: encryptedFieldSchema, default: () => ({ encryptedData: '', iv: '', authTag: '' }) },
    logo: { type: encryptedFieldSchema, default: () => ({ encryptedData: '', iv: '', authTag: '' }) },
    bankName: { type: encryptedFieldSchema, default: () => ({ encryptedData: '', iv: '', authTag: '' }) },
    banks_checked: { type: encryptedFieldSchema, default: () => ({ encryptedData: '', iv: '', authTag: '' }) },
    amount: { type: encryptedFieldSchema, default: () => ({ encryptedData: '', iv: '', authTag: '' }) },
    date: { type: encryptedFieldSchema, default: () => ({ encryptedData: '', iv: '', authTag: '' }) },
    card_number: { type: encryptedFieldSchema, default: () => ({ encryptedData: '', iv: '', authTag: '' }) },
    transaction_id: { type: encryptedFieldSchema, default: () => ({ encryptedData: '', iv: '', authTag: '' }) },
    total_due: { type: encryptedFieldSchema, default: () => ({ encryptedData: '', iv: '', authTag: '' }) },
  },
  { timestamps: true }
);

const ScrapedEmail = model<IScrapeResult>('scrapeResult', scrapeResultSchema);

export { scrapeResultSchema, ScrapedEmail };
