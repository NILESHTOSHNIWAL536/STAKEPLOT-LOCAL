import mongoose, { Schema, Document } from 'mongoose';

/**
 * Tracks individual payment records when a debtor (payer) settles their
 * share in a split with the creditor (receiver/paidBy of the split).
 *
 * Either side can create a record:
 *  - Payer (X) calls "pay"   → records that X paid Y some amount
 *  - Receiver (Y) calls "clear" → records that Y received payment from X
 *
 * Multiple partial payments are supported; balance is:
 *   splitItem.amount - SUM(paidAmount where splitId + payerId + receiverId match)
 */
export interface ISplitPayment extends Document {
  collectionId: mongoose.Types.ObjectId;
  splitId: mongoose.Types.ObjectId;
  payerId: mongoose.Types.ObjectId;      // the debtor  (person listed in split.splits[i])
  receiverId: mongoose.Types.ObjectId;   // the creditor (split.paidBy)
  splitAmount: number;                   // original split item amount (snapshot for reference)
  paidAmount: number;                    // amount settled in this single payment record
  initiatedBy: mongoose.Types.ObjectId; // who created this record (payer or receiver)
  note?: string;
  createdAt: Date;
  updatedAt: Date;
}

const splitPaymentSchema = new Schema<ISplitPayment>(
  {
    collectionId: {
      type: Schema.Types.ObjectId,
      ref: 'Collection',
      required: true,
    },
    splitId: {
      type: Schema.Types.ObjectId,
      ref: 'Split',
      required: true,
    },
    payerId: {
      type: Schema.Types.ObjectId,
      required: true,
    },
    receiverId: {
      type: Schema.Types.ObjectId,
      required: true,
    },
    splitAmount: {
      type: Number,
      required: true,
    },
    paidAmount: {
      type: Number,
      required: true,
      min: 0.01,
    },
    initiatedBy: {
      type: Schema.Types.ObjectId,
      required: true,
    },
    note: {
      type: String,
    },
  },
  { timestamps: true }
);

// Quick lookup of all payments for a specific split debt
splitPaymentSchema.index({ splitId: 1, payerId: 1, receiverId: 1 });
// Quick lookup of all payments within a collection
splitPaymentSchema.index({ collectionId: 1 });
// For querying what a user owes/receives across a collection
splitPaymentSchema.index({ collectionId: 1, payerId: 1 });
splitPaymentSchema.index({ collectionId: 1, receiverId: 1 });

const SplitPayment = mongoose.model<ISplitPayment>('SplitPayment', splitPaymentSchema);

export default SplitPayment;
