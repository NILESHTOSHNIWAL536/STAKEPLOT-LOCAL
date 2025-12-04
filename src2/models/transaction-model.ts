import mongoose, { Schema, Document, Types } from 'mongoose';
import { categories } from '../utils/common/enums';

/* ============================
   Transaction Item Interface
============================ */

interface IManualTransactionItem {
  amount: number;
  account: string;
  category: (typeof categories)[number];
  label?: string;
  room?: Record<string, any>;
  merchantId?: string | null;

  isBill: boolean;
  isScheduledPayment: boolean;
  isDebt: boolean;
  isSplit: boolean;
  isRoomBill: boolean;

  remainderId?: Types.ObjectId | null;
}

/* ============================
   Embedded Transaction Schema
============================ */

const transactionSchema = new Schema<IManualTransactionItem>(
  {
    amount: {
      type: Number,
      required: [true, 'Please add transaction amount'],
    },

    account: {
      type: String,
      required: [true, 'Account is required'],
    },

    category: {
      type: String,
      enum: categories,
      required: [true, 'Please choose appropriate category'],
    },

    label: {
      type: String,
    },

    room: {
      type: Object,
      default: {},
    },

    merchantId: {
      type: String,
      default: null,
    },

    isBill: {
      type: Boolean,
      default: false,
    },

    isScheduledPayment: {
      type: Boolean,
      default: false,
    },

    isDebt: {
      type: Boolean,
      default: false,
    },

    isSplit: {
      type: Boolean,
      default: false,
    },

    isRoomBill: {
      type: Boolean,
      default: false,
    },

    remainderId: {
      type: Schema.Types.ObjectId,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

/* ============================
   Manual Transaction Interface
============================ */

export interface IManualTransaction extends Document {
  Transactions: IManualTransactionItem[];
  userId?: Types.ObjectId;

  createdAt: Date;
  updatedAt: Date;
}

/* ============================
   Manual Transaction Schema
============================ */

const manualTransactionSchema = new Schema<IManualTransaction>({
  Transactions: {
    type: [transactionSchema],
    required: true,
  },

  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
  },
});

/* ============================
   Export Model
============================ */

const ManualTransaction = mongoose.model<IManualTransaction>('manualTransaction', manualTransactionSchema);

export default ManualTransaction;
