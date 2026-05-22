import mongoose, { Schema, Document, Types } from 'mongoose';

/* ============================
   Device Login Interface
============================ */

interface IDeviceLogin {
  deviceId?: string;
  brand?: string;
  device?: string;
  model?: string;
  os?: string; // e.g., 'Android', 'iOS'
  loginTime: Date;
}

/* ============================
   Sending Notification Interface
============================ */

export interface ISendingNotification extends Document {
  userId: Types.ObjectId;
  deviceLogins: IDeviceLogin[];
}

/* ============================
   Notification Device Schema
============================ */

const NotificationDeviceSchema = new Schema<ISendingNotification>({
  userId: {
    type: Schema.Types.ObjectId,
    required: true,
    
  },

  deviceLogins: [
    {
      deviceId: { type: String },
      brand: { type: String },
      device: { type: String },
      model: { type: String },
      os: { type: String }, // e.g., 'Android', 'iOS'
      loginTime: { type: Date, default: Date.now }, // Track when the device was logged in
    },
  ],
});

/* ============================
   Export Model
============================ */

const SendingNotification = mongoose.model<ISendingNotification>('SendingNotification', NotificationDeviceSchema);

export default SendingNotification;
