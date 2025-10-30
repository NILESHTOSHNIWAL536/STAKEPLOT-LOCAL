const mongoose = require('mongoose');

const headsUpSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    insights: {
        type: [String],
        required: true
    },
    updatedAt: {
        type: Date,
        default: Date.now
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

const HeadsUp = mongoose.model('HeadsUp', headsUpSchema);
module.exports = HeadsUp;