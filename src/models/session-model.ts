// const mongoose = require('mongoose');

// const sessionSchema = new mongoose.Schema({
//   userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
//   token: { type: String, required: true },
//   deviceInfo: { type: Object, required: true },
//   createdAt: { type: Date, default: Date.now },
// });

// const Session = mongoose.model('Session', sessionSchema);
// module.exports = { sessionSchema, Session };
import { Schema, model, Types, Document } from 'mongoose';

export interface ISession extends Document {
  userId: Types.ObjectId;
  token: string;
  deviceInfo: Record<string, any>;
  createdAt: Date;
}

const sessionSchema = new Schema<ISession>({
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  token: { type: String, required: true },
  deviceInfo: { type: Object, required: true },
  createdAt: { type: Date, default: Date.now },
});

const Session = model<ISession>('Session', sessionSchema);

export { sessionSchema, Session };
