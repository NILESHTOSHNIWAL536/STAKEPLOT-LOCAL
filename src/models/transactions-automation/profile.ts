import mongoose, { Schema, Document, Types } from 'mongoose';
import { IProfile, encryptedFieldSchema } from '@/types/bank';

const profileSchema = new Schema<IProfile>({
  holder: {
    type: Map,
    of: encryptedFieldSchema,
    required: true,
  },

  type: {
    type: encryptedFieldSchema,
    required: true,
  },

  accountId: {
    type: Schema.Types.ObjectId,
    ref: 'Account',
    required: true,
  },

  userId: {
    type: Schema.Types.ObjectId,
    
    required: true,
  },

  encryptedDEK: {
    type: String,
    required: true,
  },
});

const Profile = mongoose.model<IProfile>('Profile', profileSchema);
export default Profile;
