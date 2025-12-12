// const mongoose = require('mongoose');

// const scrapeResultSchema = new mongoose.Schema(
//   {
//     userId: {
//       type: mongoose.Schema.Types.ObjectId,
//       required: true,
//     },
//     category: { type: String, default: '' },
//     amount: { type: String, default: '' },
//     date: { type: String, default: '' },
//     card_number: { type: String, default: '' },
//     transaction_id: { type: String, default: '' },
//     total_due: { type: String, default: '' },
//     mode: { type: String, default: '' },
//     type: { type: String, default: '' },
//     matched_bank: { type: String, default: '' },
//     logo: { type: String, default: '' },
//     bankName: { type: String, default: '' },
//     banks_checked: { type: [], default: '' },
//   },
//   { timestamps: true }
// );

// const ScrapedEmail= mongoose.model('scrapeResult', scrapeResultSchema);
// module.exports={scrapeResultSchema,ScrapedEmail};
import { Schema, model, Types, Document } from 'mongoose';

export interface IScrapeResult extends Document {
  userId: Types.ObjectId;
  category: string;
  amount: string;
  date: string;
  card_number: string;
  transaction_id: string;
  total_due: string;
  mode: string;
  type: string;
  matched_bank: string;
  logo: string;
  bankName: string;
  banks_checked: any[]; // keeping loose as in original
}

const scrapeResultSchema = new Schema<IScrapeResult>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      required: true,
    },
    category: { type: String, default: '' },
    amount: { type: String, default: '' },
    date: { type: String, default: '' },
    card_number: { type: String, default: '' },
    transaction_id: { type: String, default: '' },
    total_due: { type: String, default: '' },
    mode: { type: String, default: '' },
    type: { type: String, default: '' },
    matched_bank: { type: String, default: '' },
    logo: { type: String, default: '' },
    bankName: { type: String, default: '' },
    banks_checked: { type: [String], default: [] },
  },
  { timestamps: true }
);

const ScrapedEmail = model<IScrapeResult>('scrapeResult', scrapeResultSchema);

export { scrapeResultSchema, ScrapedEmail };
