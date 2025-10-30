const mongoose = require("mongoose");

const recurringPaymentSchema = new mongoose.Schema(
  {
    recentMostTransactionId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "BankTransaction",
      required: true,
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    merchant: {
      type: String,
      required: true,
    },
    frequency: {
      type: String,
      enum: ["daily", "weekly", "monthly", "quarterly", "biannual"],
      required: true,
    },
    amount: {
      type: Number,
      required: true,
    },
    recentMostTransactionTimestamp: {
      type: Date,
      required: true,
    },
    nextReminderAt: {
      type: Date,
      required: true,
    },
    narration: {
      type: String,
    },
    source: {
      type: String,
    },
    recentMostTwoOccurrences: {
      type: [Date],
      validate: [(array) => array.length <= 2, "Must contain at most 2 dates"],
    },
    occurrencesCount: {
      type: Number,
      default: 1,
      min: 1,
    },
    isActive: {
      type: Boolean,
      default: false,
    },
    isDaily: {
      type: Boolean,
      default: false
    }
  },
  {
    timestamps: true,
  }
);

recurringPaymentSchema.index({ nextReminderAt: 1 });

module.exports = mongoose.model("RecurringPayment", recurringPaymentSchema);
