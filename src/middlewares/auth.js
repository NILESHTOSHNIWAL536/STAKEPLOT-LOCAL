const jwt = require('jsonwebtoken');
const AppError = require('../utils/app-error');
const { StatusCodes } = require('http-status-codes');
const { ErrorResponse } = require('../utils/api-response');
const { ServerConfig } = require('../config');
const { User } = require('../models/user-model');
const { Session } = require('../models/session-model');

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

      const users = await mainDB.model('User').find({ _id: decoded.id }).select('-password');
      const user = users[0];
      if (!user) throw new AppError('User Not found', StatusCodes.UNAUTHORIZED);

      // Check if token is active in the session database
      const sessions = await mainDB.model('Session').find({ userId: user._id, token });
      const session = sessions[0];

      if (!session) {
        ErrorResponse.error = 'JsonWebTokenError';
        return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
      }

      req.user = user;
      req.user.token = token;
      return next();
    } catch (err) {
      console.log(err);
      if (err.name === 'TokenExpiredError') {
        ErrorResponse.error = 'TokenExpiredError';
        return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
      }
      if (err.name === 'JsonWebTokenError') {
        ErrorResponse.error = 'JsonWebTokenError';
        return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
      }
      //  console.log(err);
      return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
    }
  } catch (error) {
    console.log(error);
    ErrorResponse.error = 'AuthenticationError';
    return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
  }
};

module.exports = { protect };
