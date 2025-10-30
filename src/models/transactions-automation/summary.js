const mongoose = require("mongoose");

const encryptedFieldSchema = {
  type: {
    encryptedData: String,
    iv: String,
    authTag: String,
  },
  _id: false
};

const summarySchema = new mongoose.Schema({
  accountId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Account',
    required: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  data: {
    type: Map,
    of: encryptedFieldSchema,
    required: true
  },
  encryptedDEK: {
    type: String,
    required: true
  }
});

const Summary = mongoose.model('Summary', summarySchema);
module.exports = Summary
