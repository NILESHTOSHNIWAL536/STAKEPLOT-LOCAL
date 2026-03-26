import mongoose, { Schema, Document } from 'mongoose';

export interface ICollection extends Document {
  name: string;
  type: 'PERSONAL' | 'SHARED';
  ownerId: mongoose.Types.ObjectId;
  description: string;
  expiryAt?: Date;
  status: 'ACTIVE' | 'CLOSED';
  totalAmount: number;
  createdAt: Date;
  updatedAt: Date;
}

const collectionSchema = new Schema<ICollection>({
  name: { type: String, required: true },

  type: {
    type: String,
    enum: ['PERSONAL', 'SHARED'],
    required: true,
  },

  ownerId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },

  description: { type: String, default: '' },

  expiryAt: { type: Date },

  status: {
    type: String,
    enum: ['ACTIVE', 'CLOSED'],
    default: 'ACTIVE',
  },

  totalAmount: {
    type: Number,
    default: 0, // for quick summary
  },
}, { timestamps: true });

// Optimize query for counting total collections
collectionSchema.index({ ownerId: 1, status: 1 });

const Collection = mongoose.model<ICollection>('Collection', collectionSchema);

export default Collection;
