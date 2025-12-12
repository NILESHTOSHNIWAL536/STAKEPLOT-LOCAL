// const { required } = require('joi');
// const mongoose = require('mongoose');

// const googleAuthSchema = new mongoose.Schema(
//   {
//     userId: {
//       type: mongoose.Schema.Types.ObjectId,
//       required: true,
//     },
//     refreshToken: {
//       encryptedData: { type: String, required: true },
//       iv: { type: String, required: true },
//       authTag: { type: String, required: true },
//     },
//   },
//   { timestamps: true }
// );

// googleAuthSchema.index({ userId: 1 }, { unique: true });
// const GoogleAuth = mongoose.model('googleAuth', googleAuthSchema);
// module.exports={GoogleAuth,googleAuthSchema};
import { Schema, model, Types, Document } from 'mongoose';

export interface IEncryptedToken {
  encryptedData: string;
  iv: string;
  authTag: string;
}

export interface IGoogleAuth extends Document {
  userId: Types.ObjectId;
  refreshToken: IEncryptedToken;
}

const googleAuthSchema = new Schema<IGoogleAuth>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      required: true,
    },
    refreshToken: {
      encryptedData: { type: String, required: true },
      iv: { type: String, required: true },
      authTag: { type: String, required: true },
    },
  },
  { timestamps: true }
);

googleAuthSchema.index({ userId: 1 }, { unique: true });

const GoogleAuth = model<IGoogleAuth>('googleAuth', googleAuthSchema);

export { GoogleAuth, googleAuthSchema };
