const mongoose = require("mongoose");

const encryptedFieldSchema = {
    type: {
        encryptedData: String,
        iv: String,
        authTag: String,
    },
    _id: false
};

// Account Schema
const accountSchema = new mongoose.Schema({
    linkedAccRef: {
        ...encryptedFieldSchema,
        required: true,
        unique: true
    },
    type: {
        ...encryptedFieldSchema,
        enum: ['term_deposit', 'recurring_deposit', 'deposit'],
        required: true
    },
    maskedAccNumber: {
        ...encryptedFieldSchema,
        required: true
    },
    version: {
        ...encryptedFieldSchema,
        required: true
    },
    schemaLocation: {
        ...encryptedFieldSchema,
    },
    startDate: {
        type: Date,
        required: false
    },
    endDate: {
        type: Date,
        required: false
    },
    bankId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Bank',
        required: true
    },
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    fetchCount:{
        type: Number,
        default: 1
    },
    nextFetch: {
        type: Date,
    },
    lastFetch: {
        type: Date,
    },
    encryptedDEK: {
        type: String,
        required: true
    }
});

module.exports = mongoose.model('Account', accountSchema);
