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
   Profile Interface
============================ */

export interface IProfile extends Document {
  holder: Map<string, IEncryptedField>;
  type: IEncryptedField;
  accountId: Types.ObjectId;
  userId: Types.ObjectId;
  encryptedDEK: string;
}

/* ============================
   Profile Schema
============================ */

const profileSchema = new Schema<IProfile>({
  holder: {
    type: Map,
    of: encryptedFieldSchema,
    required: true,
  },

  type: {
    ...encryptedFieldSchema,
    required: true,
  },

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

  encryptedDEK: {
    type: String,
    required: true,
  },
});

/* ============================
   Export Model
============================ */

const Profile = mongoose.model<IProfile>("Profile", profileSchema);
export default Profile;
