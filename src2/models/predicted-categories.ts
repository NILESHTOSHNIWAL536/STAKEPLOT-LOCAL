import mongoose, { Schema, Document } from 'mongoose';

/* ============================
   Selected Category Interface
============================ */

interface ISelectedCategory {
  category: string;
  percentage?: number;
}

/* ============================
   Selected Category Schema
============================ */

const selectedCategorySchema = new Schema<ISelectedCategory>(
  {
    category: { type: String, required: true },
    percentage: { type: Number },
  },
  { _id: false }
);

/* ============================
   Predicted Categories Interface
============================ */

export interface IPredictedCategories extends Document {
  narration: string;
  selectedCategory: ISelectedCategory;
  predictedCategories: ISelectedCategory[];
}

/* ============================
   Predicted Categories Schema
============================ */

const predictedCategoriesSchema = new Schema<IPredictedCategories>(
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

/* ============================
   Export Model
============================ */

const PredictedCategories = mongoose.model<IPredictedCategories>('predictedCategories', predictedCategoriesSchema);

export default PredictedCategories;
