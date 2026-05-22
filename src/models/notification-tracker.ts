import { Schema, model, Document, Types } from 'mongoose';

export interface INotificationTracker extends Document {
  userId: Types.ObjectId;
  billId: Types.ObjectId;
  date: string;
  count: number;
  type: string;
}

const notificationTrackerSchema = new Schema<INotificationTracker>({
  userId: { type: Schema.Types.ObjectId, required: true, },
  billId: { type: Schema.Types.ObjectId, required: true },
  date: { type: String, required: true },
  count: { type: Number, default: 1 },
  type: { type: String, default: 'generic' },
});

// Create compound unique index
notificationTrackerSchema.index({ userId: 1, billId: 1, date: 1, type: 1 }, { unique: true });

const NotificationTracker = model<INotificationTracker>('notificationTracker', notificationTrackerSchema);

export default NotificationTracker;
