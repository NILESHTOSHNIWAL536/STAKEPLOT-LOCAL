const mongoose = require("mongoose")

const NotificationSchema = new mongoose.Schema({
    notificationMessage: {
        type: Object,
        required: true
    },
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        required: true
    },
    acknowledged: {
        type: Boolean,
        default: false
    }
}, {
    timestamps: true
})

const notification = mongoose.model('notification', NotificationSchema)
module.exports = notification