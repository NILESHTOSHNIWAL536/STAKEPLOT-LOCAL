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
   Account Interface
============================ */

export interface IAccount extends Document {
  linkedAccRef: IEncryptedField;
  type: IEncryptedField;
  maskedAccNumber: IEncryptedField;
  version: IEncryptedField;
  schemaLocation?: IEncryptedField;

  startDate?: Date;
  endDate?: Date;

  bankId: Types.ObjectId;
  userId: Types.ObjectId;

  fetchCount: number;
  nextFetch?: Date;
  lastFetch?: Date;

  encryptedDEK: string;
}

/* ============================
   Account Schema
============================ */

const accountSchema = new Schema<IAccount>({
  linkedAccRef: {
    ...encryptedFieldSchema,
    required: true,
    unique: true,
  },

  type: {
    ...encryptedFieldSchema,
    enum: ["term_deposit", "recurring_deposit", "deposit"],
    required: true,
  },

  maskedAccNumber: {
    ...encryptedFieldSchema,
    required: true,
  },

  version: {
    ...encryptedFieldSchema,
    required: true,
  },

  schemaLocation: {
    ...encryptedFieldSchema,
  },

  startDate: {
    type: Date,
    required: false,
  },

  endDate: {
    type: Date,
    required: false,
  },

  bankId: {
    type: Schema.Types.ObjectId,
    ref: "Bank",
    required: true,
  },

  userId: {
    type: Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },

  fetchCount: {
    type: Number,
    default: 1,
  },

  nextFetch: {
    type: Date,
  },

  lastFetch: {
    type: Date,
  },

  encryptedDEK: {
    type: String,
    required: true,
  },
});

/* ============================
   Export Model
============================ */

const Account = mongoose.model<IAccount>("Account", accountSchema);
export default Account;
