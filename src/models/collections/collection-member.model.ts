import mongoose, { Schema, Document } from 'mongoose';

export interface ICollectionMember extends Document {
  collectionId: mongoose.Types.ObjectId;
  userId: mongoose.Types.ObjectId;
  role: 'VIEW' | 'CONTRIBUTE';
  joinedAt: Date;
  createdAt: Date;
  updatedAt: Date;
}

const collectionMemberSchema = new Schema<ICollectionMember>({
  collectionId: {
    type: Schema.Types.ObjectId,
    ref: 'Collection',
    required: true,
  },

  userId: {
    type: Schema.Types.ObjectId,
    
    required: true,
  },

  role: {
    type: String,
    enum: ['VIEW', 'CONTRIBUTE'],
    default: 'VIEW',
  },

  joinedAt: { type: Date, default: Date.now },
}, { timestamps: true });

// Optimize query for max collections limit per user
collectionMemberSchema.index({ userId: 1 });
collectionMemberSchema.index({ collectionId: 1, userId: 1 }, { unique: true });

const CollectionMember = mongoose.model<ICollectionMember>('CollectionMember', collectionMemberSchema);

export default CollectionMember;
