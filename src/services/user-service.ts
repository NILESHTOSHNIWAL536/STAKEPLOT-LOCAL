import { StatusCodes } from 'http-status-codes';
import AppError from '../utils/errors/app-error';
import { User } from '../models';
import { Types } from 'mongoose';

// Define return type (array of _id objects)
interface UserId {
  _id: Types.ObjectId;
}

export async function getUserInfo(): Promise<UserId[]> {
  try {
    const userIds = await User.find({}).sort({ createdAt: -1 }).select('_id').lean(); // optional: returns plain objects instead of Mongoose docs

    return userIds as UserId[];
  } catch (error) {
    throw new AppError('Cannot get user ids', StatusCodes.BAD_REQUEST);
  }
}

export default {
  getUserInfo,
};
