const mongoose = require("mongoose");

const encryptedFieldSchema = {
    type: {
        encryptedData: String,
        iv: String,
        authTag: String,
    },
    _id: false
};

const profileSchema = new mongoose.Schema({
    holder: {
        type: Map,
        of: encryptedFieldSchema,
        required: true
    },
    type: {
        ...encryptedFieldSchema,
        required: true
    },
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
    encryptedDEK: {
        type: String,
        required: true
    }
});

module.exports = mongoose.model('Profile', profileSchema);