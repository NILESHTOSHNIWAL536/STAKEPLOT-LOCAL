const mongoose = require("mongoose");

const UserActivity = new mongoose.Schema({
  userId: { type: String, required: true, unique: true },
  score: { type: Number, default: 0 },
  unclaimedCount: { type: Number, default: 0 },
  transactionIdList: [{ type: String }],
  hasReached50: { type: Boolean, default: false },
  dailyClaimCount: [
    {
      date: { type: String },
      count: { type: Number, default: 0 },
    },
  ],
  dailyTransaction: [
    {
      date: { type: String },
      count: { type: Number, default: 0 },
    },
  ],
  dailyTags: [
    {
      date: { type: String },
      count: { type: Number, default: 0 },
    },
  ],
  dailyBillClears: [
    {
      date: { type: String },
      count: { type: Number, default: 0 },
    },
  ],
  pendingPosts: [
    {
      postId: { type: String },
      createdAt: { type: Date, default: Date.now },
      processed: { type: Boolean, default: false },
    },
  ],

  lastActivityDate: { type: String },
});

// TTL Indexes (must be declared like this in schema setup)
// UserActivity.index({ "dailyTransaction.expiresAt": 1 }, { expireAfterSeconds: 0 });
// UserActivity.index({ "dailyTags.expiresAt": 1 }, { expireAfterSeconds: 0 });
// UserActivity.index({ "dailyBillClears.expiresAt": 1 }, { expireAfterSeconds: 0 });
// UserActivity.index({ "pendingPosts.expiresAt": 1 }, { expireAfterSeconds: 0 });
// UserActivity.index({ "pendingPosts.expiresAt": 1 }, { expireAfterSeconds: 0 });

module.exports = mongoose.model("UserActivity", UserActivity);
