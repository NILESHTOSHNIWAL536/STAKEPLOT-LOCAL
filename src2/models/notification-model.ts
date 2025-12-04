import mongoose, { Schema, Document, Types } from "mongoose";

/* ============================
   Notification Interface
============================ */

export interface INotification extends Document {
  notificationMessage: Record<string, any>;
  userId: Types.ObjectId;
  acknowledged: boolean;
  createdAt: Date;
  updatedAt: Date;
}

/* ============================
   Notification Schema
============================ */

const NotificationSchema = new Schema<INotification>(
  {
    notificationMessage: {
      type: Object,
      required: true,
    },

    userId: {
      type: Schema.Types.ObjectId,
      required: true,
      ref: "User",
    },

    acknowledged: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
  }
);

/* ============================
   Export Model
============================ */

const Notification = mongoose.model<INotification>(
  "notification",
  NotificationSchema
);

export default Notification;
