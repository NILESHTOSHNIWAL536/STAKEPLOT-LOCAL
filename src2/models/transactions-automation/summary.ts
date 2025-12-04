import mongoose, { Schema, Document, Types } from "mongoose";

/* ============================
   Encrypted Field Type
============================ */

interface IEncryptedField {
  encryptedData: string;
  iv: string;
  authTag: string;
}

const encryptedFieldSchema = {
  type: {
    encryptedData: String,
    iv: String,
    authTag: String,
  },
  _id: false,
};

/* ============================
   Summary Interface
============================ */

export interface ISummary extends Document {
  accountId: Types.ObjectId;
  userId: Types.ObjectId;
  data: Map<string, IEncryptedField>;
  encryptedDEK: string;
}

/* ============================
   Summary Schema
============================ */

const summarySchema = new Schema<ISummary>({
  accountId: {
    type: Schema.Types.ObjectId,
    ref: "Account",
    required: true,
  },

  userId: {
    type: Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },

  data: {
    type: Map,
    of: encryptedFieldSchema,
    required: true,
  },

  encryptedDEK: {
    type: String,
    required: true,
  },
});

/* ============================
   Export Model
============================ */

const Summary = mongoose.model<ISummary>("Summary", summarySchema);
export default Summary;
