const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const transactionRuleSchema = new Schema({
  userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true
  },
  narrationPattern: {
    type: String,
    required: true
  },
  amount: {
    type: Number,
    index: true
  },
  category: {
    type: String,
    required: true
  },
  subcategory: {
    type: String,
    default: ''
  },
  source: {
    type: String,
    enum: ['manual', 'group'],
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
});

transactionRuleSchema.index({ userId: 1, narrationPattern: 1, amount: 1 }); // Compound index for fast lookups

module.exports = mongoose.model('TransactionRule', transactionRuleSchema);