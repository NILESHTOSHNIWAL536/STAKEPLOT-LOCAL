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
    bank: { type: String, default: '' },
    logo: { type: String, default: '' },
    bankName: { type: String, default: '' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('scrapeResult', scrapeResultSchema);
