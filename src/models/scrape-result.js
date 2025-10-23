const mongoose = require('mongoose');

const scrapeResultSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
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
    banks_checked: { type: [], default: '' },
  },
  { timestamps: true }
);

const ScrapedEmail= mongoose.model('scrapeResult', scrapeResultSchema);
module.exports={scrapeResultSchema,ScrapedEmail};
