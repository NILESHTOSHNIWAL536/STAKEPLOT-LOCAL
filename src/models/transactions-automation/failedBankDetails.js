const mongoose = require("mongoose");


const FailedTransactionSchema = new mongoose.Schema({
    custId: String,
    userId: String,
    fipId: String,
    consentId: String,
    consendHandleId: String,
    bankName: String,
    accountId: String,
    fetchCount: String,
    FROM: Date,
    retryCount: { type: Number, default: 0 }
  });

const FailedTransaction = mongoose.model('FailedTransaction', FailedTransactionSchema);
  

module.exports = FailedTransaction;
