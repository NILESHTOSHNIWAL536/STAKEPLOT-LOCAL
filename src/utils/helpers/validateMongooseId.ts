import mongoose from 'mongoose';

/**
 * Validates a string and converts it to a MongoDB ObjectId if valid.
 * Returns the original string if it's not a valid ObjectId.
 */
export function validateMongooseId(userId: string): mongoose.Types.ObjectId | string {
  if (mongoose.Types.ObjectId.isValid(userId)) {
    return new mongoose.Types.ObjectId(userId);
  }

  return userId;
}
