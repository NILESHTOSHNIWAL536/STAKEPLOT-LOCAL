const { required } = require('joi');
const mongoose = require('mongoose');

const googleAuthSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
    },
    refreshToken: {
      encryptedData: { type: String, required: true },
      iv: { type: String, required: true },
      authTag: { type: String, required: true },
    },
  },
  { timestamps: true }
);

googleAuthSchema.index({ userId: 1 }, { unique: true });
module.exports = mongoose.model('googleAuth', googleAuthSchema);
