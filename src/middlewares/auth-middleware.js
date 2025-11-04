const { User, Session } = require('../models');
const jwt = require('jsonwebtoken');
const AppError = require('../utils/errors/app-error');
const { StatusCodes } = require('http-status-codes');
const { ErrorResponse } = require('../utils/common');
const { ServerConfig } = require('../config');

const protect = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      ErrorResponse.error = 'JsonWebTokenError';
      return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
    }

    const [tokenType, token] = authHeader.split(' ');

    if (tokenType === 'Bearer') {
      try {
        const decoded = jwt.verify(token, ServerConfig.JWT_SECRET);
        const user = await User.findOne({ _id: decoded.id }).select('-password');

        if (!user) throw new AppError('User Not found', StatusCodes.UNAUTHORIZED);

        // Check if token is active in the session database
        const session = await Session.findOne({ userId: user._id });
        if (!session) {
          ErrorResponse.error = 'JsonWebTokenError';
          return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
        }

        req.user = user;
        req.user.token = token;
        return next();
      } catch {
        ErrorResponse.error = 'JsonWebTokenError';
        return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
      }
    }
  } catch (error) {
    console.log('Authentication Middleware Error:', error);
    return next(error);
  }
};

module.exports = { protect };
