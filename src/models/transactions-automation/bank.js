const mongoose = require("mongoose");

const encryptedFieldSchema = {
    type: {
        encryptedData: String,
        iv: String,
        authTag: String,
    },
    _id: false
};

const fiAccountInfoSchema = new mongoose.Schema({
    accountRefNo: {
        ...encryptedFieldSchema,
        required: true,
    },
    linkRefNo: {
        ...encryptedFieldSchema,
        required: true,
    },
});

const bankSchema = new mongoose.Schema({
    fipId: {
        ...encryptedFieldSchema,
        required: true,
    },
    fipName: {
        ...encryptedFieldSchema,
        required: true,
    },
    custId: {
        ...encryptedFieldSchema,
        required: true,
    },
    consentId: {
        ...encryptedFieldSchema,
        required: true,
    },
    consentHandleId: {
        ...encryptedFieldSchema,
        required: true,
    },
    fiAccountInfo: {
        type: [fiAccountInfoSchema],
        required: true,
    },
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    encryptedDEK: {
        type: String,
        required: true
    }
});

const Bank = mongoose.model('Bank', bankSchema);
module.exports = Bank;