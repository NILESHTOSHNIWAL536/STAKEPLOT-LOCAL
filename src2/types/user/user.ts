import { IUser } from '@/models/user-model';
import { Types } from 'mongoose';

export interface AuthUser extends IUser {
  token: string;
  _id: Types.ObjectId | string
}

