import { Document, Types } from "mongoose";
import { IEncryptedField } from "./encryptedField";

export interface IProfile extends Document {
  holder: Map<string, IEncryptedField>;
  type: IEncryptedField;

  accountId: Types.ObjectId;
  userId: Types.ObjectId;

  encryptedDEK: string;
}
