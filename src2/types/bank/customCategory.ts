import { Document, Types } from 'mongoose';

interface ICategoryItem {
  name: string;
  imageUrl: string;
  narration: string;
}

export interface IUserCustomCategories extends Document {
  userId: Types.ObjectId;
  categories: ICategoryItem[];
  createdAt: Date;
  updatedAt: Date;
}
