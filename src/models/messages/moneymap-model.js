const mongoose = require("mongoose");

const moneyMapSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  insights: {
    type: [String],
    required: true,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  welcomeMessages: {
    type: [String],
    required: true,
  }
});

const moneyMap = mongoose.model("moneyMap", moneyMapSchema);
module.exports = moneyMap;
