import mongoose, { Schema, Document } from 'mongoose';

export interface ISplitItem {
  userId: mongoose.Types.ObjectId;
  amount: number;
}

export interface ISplit extends Document {
  collectionId: mongoose.Types.ObjectId;
  transactionIds: mongoose.Types.ObjectId[];
  paidBy: mongoose.Types.ObjectId;
  splits: ISplitItem[];
  splitType: 'EQUAL' | 'CUSTOM';
  createdAt: Date;
  updatedAt: Date;
}

const splitSchema = new Schema<ISplit>({
  collectionId: {
    type: Schema.Types.ObjectId,
    ref: 'Collection',
    required: true,
  },

  transactionIds: [
    {
      type: Schema.Types.ObjectId,
      ref: 'BankTransaction',
      required: true,
    }
  ],

  paidBy: {
    type: Schema.Types.ObjectId,

    required: true,
  },

  splits: [
    {
      userId: {
        type: Schema.Types.ObjectId,

      },
      amount: Number,
      _id: false
    },
  ],

  splitType: {
    type: String,
    enum: ['EQUAL', 'CUSTOM'],
  },
}, { timestamps: true });

splitSchema.index({ collectionId: 1, transactionIds: 1 });
splitSchema.index({ paidBy: 1 });
splitSchema.index({ 'splits.userId': 1 }); // to quickly get what user owes across splits

const Split = mongoose.model<ISplit>('Split', splitSchema);

export default Split;
