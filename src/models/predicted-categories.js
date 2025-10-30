const mongoose = require("mongoose");

const selectedCategorySchema = new mongoose.Schema(
  {
    category: { type: String, required: true },
    percentage: Number,
  },
  { _id: false }
);

const predictedCategoriesSchema = new mongoose.Schema(
  {
    narration: { type: String, required: true },
    selectedCategory: {
      type: selectedCategorySchema,
      required: true,
    },
    predictedCategories: {
      type: [selectedCategorySchema],
      required: true,
    },
  },
  { versionKey: false }
);

module.exports = mongoose.model(
  "predictedCategories",
  predictedCategoriesSchema
);
