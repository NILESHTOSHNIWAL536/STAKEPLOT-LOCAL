const jwt = require('jsonwebtoken');
const AppError = require('../utils/app-error');
const { StatusCodes } = require('http-status-codes');
const { ErrorResponse } = require('../utils/api-response');
const { ServerConfig } = require('../config');
const {User}=require('../models/user-model');
const {Session}=require('../models/session-model');

const protect = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      ErrorResponse.error = 'JsonWebTokenError';
      return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
    }

    const token = authHeader.split(' ')[1];

    try {
      const decoded = jwt.verify(token, ServerConfig.JWT_SECRET);
      const mainDB = global.mainDB;

      const user = await  mainDB.model('User').findOne({ _id: decoded.id }).select('-password');
       console.log('User Found:', user);
      if (!user) throw new AppError('User Not found', StatusCodes.UNAUTHORIZED);

      // Check if token is active in the session database
      const session = await mainDB.model('Session').findOne({ userId: user._id, token });
      if (!session) {
        ErrorResponse.error = 'JsonWebTokenError';
        return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
      }

      req.user = user;
      req.user.token = token;
      return next();
    } catch(error)
    {
      ErrorResponse.error = 'JsonWebTokenError';
      return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
    }
  } catch {
    ErrorResponse.error = 'AuthenticationError';
    return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
  }
};

module.exports = { protect };
