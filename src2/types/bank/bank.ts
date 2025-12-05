import { Document, Types } from "mongoose";
import { IEncryptedField } from "./encryptedField";
import { IFiAccountInfo } from "./fiAccountInfo";

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
