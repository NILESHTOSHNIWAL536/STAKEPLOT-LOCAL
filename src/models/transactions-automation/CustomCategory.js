const mongoose = require("mongoose");

const customCategorySchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
    unique: true
  },
  categories: [
    {
      name: {
        type: String,
        required: true
      },
      imageUrl: {
        type: String,
        required: true
      },
      narration: { type: String, required: true }
    }
  ]
}, { timestamps: true });

module.exports = mongoose.model("UserCustomCategories", customCategorySchema);
