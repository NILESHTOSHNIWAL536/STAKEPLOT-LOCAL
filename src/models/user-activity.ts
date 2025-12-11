import mongoose, { Schema, Document } from 'mongoose';

/* ============================
   Subdocument Interfaces
============================ */

interface IDateCount {
  date?: string;
  count: number;
}

interface IPendingPost {
  postId?: string;
  createdAt: Date;
  processed: boolean;
}

/* ============================
   User Activity Interface
============================ */

export interface IUserActivity extends Document {
  userId: string;
  score: number;
  unclaimedCount: number;

  transactionIdList: string[];

  hasReached50: boolean;

  dailyClaimCount: IDateCount[];
  dailyTransaction: IDateCount[];
  dailyTags: IDateCount[];
  dailyBillClears: IDateCount[];

  pendingPosts: IPendingPost[];

  lastActivityDate?: string;
}

/* ============================
   User Activity Schema
============================ */

const UserActivitySchema = new Schema<IUserActivity>({
  userId: {
    type: String,
    required: true,
    unique: true,
  },

  score: {
    type: Number,
    default: 0,
  },

  unclaimedCount: {
    type: Number,
    default: 0,
  },

  transactionIdList: [
    {
      type: String,
    },
  ],

  hasReached50: {
    type: Boolean,
    default: false,
  },

  dailyClaimCount: [
    {
      date: { type: String },
      count: { type: Number, default: 0 },
    },
  ],

  dailyTransaction: [
    {
      date: { type: String },
      count: { type: Number, default: 0 },
    },
  ],

  dailyTags: [
    {
      date: { type: String },
      count: { type: Number, default: 0 },
    },
  ],

  dailyBillClears: [
    {
      date: { type: String },
      count: { type: Number, default: 0 },
    },
  ],

  pendingPosts: [
    {
      postId: { type: String },
      createdAt: { type: Date, default: Date.now },
      processed: { type: Boolean, default: false },
    },
  ],

  lastActivityDate: {
    type: String,
  },
});

/* ============================
   Export Model
============================ */

const UserActivity = mongoose.model<IUserActivity>('UserActivity', UserActivitySchema);

export default UserActivity;
