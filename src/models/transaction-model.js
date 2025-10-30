const mongoose = require("mongoose");
const { categories } = require("../utils/common/enums");
const transactionSchema = new mongoose.Schema(
  {
    amount: {
      type: Number,
      required: [true, "Please add transaction amount"],
    },
    account: {
      type: String,
      required: [true, "Account is required"],
    },
    category: {
      type: String,
      enum: categories,
      required: [true, "Please choose appropriate category"],
    },
    label: {
      type: String,
    },
    room: {
      type: Object,
      default: {},
    },
    merchantId: {
      type: String,
      default: null
    },
    isBill: {
      type: Boolean,
      default: false,
    },
    isScheduledPayment: {
      type: Boolean,
      default: false,
    },
    isDebt: {
      type: Boolean,
      default: false,
    },
    isSplit: {
      type: Boolean,
      default: false,
    },
    isRoomBill: {
      type: Boolean,
      default: false
    },
    remainderId: {
      type: mongoose.Schema.Types.ObjectId,
      default: null
    }
  },
  {
    timestamps: true,
  }
);

const manualTransactionSchema = new mongoose.Schema({
  Transactions: {
    type: [transactionSchema],
    required: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
  }
})

const Transaction = mongoose.model("manualTransaction", manualTransactionSchema);
module.exports = Transaction;