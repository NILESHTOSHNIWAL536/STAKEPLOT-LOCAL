const { StatusCodes } = require('http-status-codes');
const AppError = require('../utils/errors/app-error');
const {User} = require('../models/');

async function getUserInfo() {
  try {
    const userIds = await User.find({}).sort({ createdAt: -1 }).select('_id');
    return userIds;
  } catch {
    throw new AppError('Cannot get user ids', StatusCodes.BAD_REQUEST);
  }
}


module.exports = {
  getUserInfo
}