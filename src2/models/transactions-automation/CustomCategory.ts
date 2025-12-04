import mongoose, { Schema, Document, Types } from 'mongoose';

/* ============================
   Category Sub Document Type
============================ */

interface ICategoryItem {
  name: string;
  imageUrl: string;
  narration: string;
}

/* ============================
   Custom Category Interface
============================ */

export interface IUserCustomCategories extends Document {
  userId: Types.ObjectId;
  categories: ICategoryItem[];
  createdAt: Date;
  updatedAt: Date;
}

/* ============================
   Custom Category Schema
============================ */

const customCategorySchema = new Schema<IUserCustomCategories>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },

    categories: [
      {
        name: {
          type: String,
          required: true,
        },

        imageUrl: {
          type: String,
          required: true,
        },

        narration: {
          type: String,
          required: true,
        },
      },
    ],
  },
  { timestamps: true }
);

/* ============================
   Export Model
============================ */

const UserCustomCategories = mongoose.model<IUserCustomCategories>('UserCustomCategories', customCategorySchema);

export default UserCustomCategories;
