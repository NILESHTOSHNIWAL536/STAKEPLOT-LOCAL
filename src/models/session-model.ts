import mongoose, { Schema, Document, Types } from 'mongoose';

/* ============================
   Session Interface
============================ */

export interface ISession extends Document {
  userId: Types.ObjectId;
  deviceInfo: Record<string, any>;
  token?: string;
  createdAt: Date;
}

/* ============================
   Session Schema
============================ */

const sessionSchema = new Schema<ISession>({
  userId: {
    type: Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },

  deviceInfo: {
    type: Object,
    required: true,
  },

  token: {
    type: String,
    required: false,
  },

  createdAt: {
    type: Date,
    default: Date.now,
  },
});

/* ============================
   Export Model
============================ */

const Session = mongoose.model<ISession>('Session', sessionSchema);
export default Session;
