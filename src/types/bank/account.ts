import { Document, Types } from "mongoose";
import { IEncryptedField } from "./encryptedField";

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
