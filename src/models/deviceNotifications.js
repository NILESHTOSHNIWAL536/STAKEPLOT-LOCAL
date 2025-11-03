const mongoose = require("mongoose");

const NotificationDevice = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: "User",
  },
  deviceLogins: [
    {
      deviceId: { type: String},
      brand: { type: String},
      device: { type: String },
      model: { type: String,},
      os: { type: String }, // e.g., 'Android', 'iOS'
      loginTime: { type: Date, default: Date.now }, // Track when the device was logged in
    },
  ],
});

module.exports = mongoose.model("SendingNotification", NotificationDevice);
