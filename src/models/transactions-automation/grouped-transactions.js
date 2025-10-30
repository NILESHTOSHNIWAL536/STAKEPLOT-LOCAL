const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const groupedTransactionSchema = new Schema({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  groupKey: {
    type: String,
    required: true,
  },
  transactions: [{
    type: Schema.Types.ObjectId,
    ref: 'BankTransaction',
    required: true
  }],
  narrationPattern: {
    type: String,
    required: true
  },
  totalAmount: {
    type: Number,
    required: true
  },
  count: {
    type: Number,
    required: true
  },
  suggestedCategory: {
    type: String,
    default: 'Untagged'
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

// Update `updatedAt` before saving
groupedTransactionSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

groupedTransactionSchema.index({ userId: 1, groupKey: 1 }, { unique: true });
const GroupedTransaction = mongoose.model('GroupedTransaction', groupedTransactionSchema);

module.exports = GroupedTransaction;