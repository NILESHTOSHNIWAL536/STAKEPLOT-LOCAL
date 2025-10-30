const mongoose = require("mongoose");

const transactionSchema = new mongoose.Schema(
  {
    transactionType: {
      type: String,
    },
    amount: {
      type: Number,
    },
    accountId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Account",
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User", // Make sure this matches your user model name
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

const PendingTransaction = mongoose.model(
  "PendingTransaction",
  transactionSchema
);
module.exports = PendingTransaction;
