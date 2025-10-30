const mongoose = require("mongoose");

const ConsentHandleId = new mongoose.Schema({
    custId: { type: String, required: true },
    handleId: { type: String, required: true },
    userId: { type: mongoose.Types.ObjectId, ref: "User" },
    expiresAt: { 
        type: Date, 
        default: () => new Date(Date.now() + 24 * 60 * 60 * 1000),
        index: { expires: '5d' }
    }
});

const consentHandleId = mongoose.model("ConsentHandleId", ConsentHandleId);
module.exports = consentHandleId;
