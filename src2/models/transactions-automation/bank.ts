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
   FI Account Info Interface
============================ */

interface IFiAccountInfo {
  accountRefNo: IEncryptedField;
  linkRefNo: IEncryptedField;
}

const fiAccountInfoSchema = new Schema<IFiAccountInfo>({
  accountRefNo: {
    ...encryptedFieldSchema,
    required: true,
  },
  linkRefNo: {
    ...encryptedFieldSchema,
    required: true,
  },
});

/* ============================
   Bank Interface
============================ */

export interface IBank extends Document {
  fipId: IEncryptedField;
  fipName: IEncryptedField;
  custId: IEncryptedField;
  consentId: IEncryptedField;
  consentHandleId: IEncryptedField;

  fiAccountInfo: IFiAccountInfo[];

  userId: Types.ObjectId;
  encryptedDEK: string;
}

/* ============================
   Bank Schema
============================ */

const bankSchema = new Schema<IBank>({
  fipId: {
    ...encryptedFieldSchema,
    required: true,
  },

  fipName: {
    ...encryptedFieldSchema,
    required: true,
  },

  custId: {
    ...encryptedFieldSchema,
    required: true,
  },

  consentId: {
    ...encryptedFieldSchema,
    required: true,
  },

  consentHandleId: {
    ...encryptedFieldSchema,
    required: true,
  },

  fiAccountInfo: {
    type: [fiAccountInfoSchema],
    required: true,
  },

  userId: {
    type: Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },

  encryptedDEK: {
    type: String,
    required: true,
  },
});

/* ============================
   Compound Index
============================ */

bankSchema.index(
  { fipId: 1, consentHandleId: 1, userId: 1 },
  { unique: true }
);

/* ============================
   Export Model
============================ */

const Bank = mongoose.model<IBank>("Bank", bankSchema);
export default Bank;
