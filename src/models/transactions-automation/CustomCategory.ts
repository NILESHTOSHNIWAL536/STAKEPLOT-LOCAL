import mongoose, { Schema, Document, Types } from 'mongoose';
import { IUserCustomCategories } from '@/types/bank';

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
