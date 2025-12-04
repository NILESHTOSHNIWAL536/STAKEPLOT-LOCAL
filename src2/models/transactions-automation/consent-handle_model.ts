import mongoose, { Schema, Document, Types } from "mongoose";

/* ============================
   ConsentHandleId Interface
============================ */

export interface IConsentHandleId extends Document {
  custId: string;
  handleId: string;
  userId?: Types.ObjectId;
  expiresAt: Date;
}

/* ============================
   ConsentHandleId Schema
============================ */

const ConsentHandleIdSchema = new Schema<IConsentHandleId>({
  custId: {
    type: String,
    required: true,
  },

  handleId: {
    type: String,
    required: true,
  },

  userId: {
    type: Schema.Types.ObjectId,
    ref: "User",
  },

  expiresAt: {
    type: Date,
    default: () => new Date(Date.now() + 24 * 60 * 60 * 1000), // 24 hours
    index: { expires: "5d" }, // TTL index: auto-delete after 5 days
  },
});

/* ============================
   Export Model
============================ */

const ConsentHandleId = mongoose.model<IConsentHandleId>(
  "ConsentHandleId",
  ConsentHandleIdSchema
);

export default ConsentHandleId;
