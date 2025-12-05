import { IUser } from '@/models/user-model';

export interface AuthUser extends IUser {
  token: string;
}
