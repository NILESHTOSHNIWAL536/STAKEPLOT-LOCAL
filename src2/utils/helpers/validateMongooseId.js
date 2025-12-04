const mongoose = require("mongoose");

function validateMongooseId(userId) {
    const userObjectId = new mongoose.Types.ObjectId(userId);
    if (userObjectId) return userObjectId;
    return userId;
}

module.exports = validateMongooseId;