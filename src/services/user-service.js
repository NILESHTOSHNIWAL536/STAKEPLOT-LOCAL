const { StatusCodes } = require('http-status-codes');
const AppError = require('../utils/errors/app-error');
const {User} = require('../models/');

async function getUserIds() {
    try {
      const users =["690b1a784b3e6c06e5ae1d0c","68fb65919723c63703ce6c4b"]; // await User.find({}).sort({ createdAt: -1 }).select('_id');
      return users.map((user) => user._id.toString());
    } catch (error) {
      throw new AppError(`Cannot get user ids: ${error}`, StatusCodes.NOT_FOUND);
    }
  }

async function getUserInfo() {
  try {
    const userIds = await getUserIds();
    return userIds;
  } catch {
    throw new AppError('Cannot get user ids', StatusCodes.BAD_REQUEST);
  }
}


module.exports = {
  getUserInfo
}