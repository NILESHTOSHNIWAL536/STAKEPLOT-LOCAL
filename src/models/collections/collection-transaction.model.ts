import mongoose, { Schema, Document } from 'mongoose';

export interface ICollectionTransaction extends Document {
  collectionId: mongoose.Types.ObjectId;
  transactionId: mongoose.Types.ObjectId;
  addedBy: mongoose.Types.ObjectId;
  amount: number;
  createdAt: Date;
  updatedAt: Date;
}

const collectionTransactionSchema = new Schema<ICollectionTransaction>({
  collectionId: {
    type: Schema.Types.ObjectId,
    ref: 'Collection',
    required: true,
  },

  transactionId: {
    type: Schema.Types.ObjectId,
    ref: 'BankTransaction',
    required: true,
  },

  addedBy: {
    type: Schema.Types.ObjectId,
    
    required: true,
  },

  amount: {
    type: Number,
    required: true,
  },
}, { timestamps: true });

// One transaction can only belong to a specific collection once
collectionTransactionSchema.index({ collectionId: 1, transactionId: 1 }, { unique: true });

const CollectionTransaction = mongoose.model<ICollectionTransaction>('CollectionTransaction', collectionTransactionSchema);

export default CollectionTransaction;
