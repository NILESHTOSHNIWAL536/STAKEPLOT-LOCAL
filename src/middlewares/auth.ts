// const jwt = require('jsonwebtoken');
// const AppError = require('../utils/app-error');
// const { StatusCodes } = require('http-status-codes');
// const { ErrorResponse } = require('../utils/api-response');
// const { ServerConfig } = require('../config');
// const { User } = require('../models/user-model');
// const { Session } = require('../models/session-model');

// const protect = async (req, res, next) => {
//   try {
//     const authHeader = req.headers.authorization;
//     if (!authHeader) {
//       ErrorResponse.error = 'JsonWebTokenError';
//       return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
//     }

//     const token = authHeader.split(' ')[1];

//     try {
//       const decoded = jwt.verify(token, ServerConfig.JWT_SECRET);
//       const mainDB = global.mainDB;

//       const users = await mainDB.model('User').find({ _id: decoded.id }).select('-password');
//       const user = users[0];
//       if (!user) throw new AppError('User Not found', StatusCodes.UNAUTHORIZED);

//       // Check if token is active in the session database
//       const sessions = await mainDB.model('Session').find({ userId: user._id, token });
//       const session = sessions[0];

//       if (!session) {
//         ErrorResponse.error = 'JsonWebTokenError';
//         return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
//       }

//       req.user = user;
//       req.user.token = token;
//       return next();
//     } catch (err) {
//       if (err.name === 'TokenExpiredError') {
//         ErrorResponse.error = 'TokenExpiredError';
//         return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
//       }
//       if (err.name === 'JsonWebTokenError') {
//         ErrorResponse.error = 'JsonWebTokenError';
//         return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
//       }
//       return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
//     }
//   } catch (error) {
//     ErrorResponse.error = 'AuthenticationError';
//     return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
//   }
// };

// module.exports = { protect };

import { Request, Response, NextFunction } from 'express';
import jwt, { JwtPayload } from 'jsonwebtoken';
import { StatusCodes } from 'http-status-codes';
import AppError from '../utils/app-error';
import { ErrorResponse } from '../utils/api-response';
import { ServerConfig } from '../config';

interface DecodedToken extends JwtPayload {
  id: string;
}

export const protect = async (
  req: Request & { user?: any },
  res: Response,
  next: NextFunction
): Promise<Response | void> => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      ErrorResponse.error = 'JsonWebTokenError';
      return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
    }

    const token = authHeader.split(' ')[1];

    try {
      const decoded = jwt.verify(
        token,
        ServerConfig.JWT_SECRET
      ) as DecodedToken;

      const mainDB = (global as any).mainDB;

      const users = await mainDB
        .model('User')
        .find({ _id: decoded.id })
        .select('-password');

      const user = users[0];

      if (!user) {
        throw new AppError('User Not found', StatusCodes.UNAUTHORIZED);
      }

      // Check if token is active in the session database
      const sessions = await mainDB
        .model('Session')
        .find({ userId: user._id, token });

      const session = sessions[0];

      if (!session) {
        ErrorResponse.error = 'JsonWebTokenError';
        return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
      }

      (req as any).user = user;
      (req as any).user.token = token;

      return next();
    } catch (err: any) {
      if (err.name === 'TokenExpiredError') {
        ErrorResponse.error = 'TokenExpiredError';
        return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
      }
      if (err.name === 'JsonWebTokenError') {
        ErrorResponse.error = 'JsonWebTokenError';
        return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
      }
      return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
    }
  } catch (error) {
    ErrorResponse.error = 'AuthenticationError';
    return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
  }
};
