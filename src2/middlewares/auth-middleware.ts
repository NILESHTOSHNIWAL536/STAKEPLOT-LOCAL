import { Request, Response, NextFunction } from 'express';
import jwt, { JwtPayload } from 'jsonwebtoken';
import { StatusCodes } from 'http-status-codes';

import { User, Session } from '../models';
import AppError from '../utils/errors/app-error.js';
import { ErrorResponse } from '../utils/common/index.js';
import { ServerConfig } from '../config/index.js';

/**
 * Extend Express Request to safely attach user
 */
export interface AuthenticatedRequest extends Request {
  user?: any & { token?: string };
}

interface DecodedToken extends JwtPayload {
  id: string;
}

export const protect = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
      ErrorResponse.error = 'JsonWebTokenError';
      res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
      return;
    }

    const [tokenType, token] = authHeader.split(' ');

    if (tokenType === 'Bearer') {
      try {
        const decoded = jwt.verify(
          token,
          ServerConfig.JWT_SECRET
        ) as DecodedToken;

        const user = await User.findOne({ _id: decoded.id }).select('-password');

        if (!user) {
          throw new AppError('User Not found', StatusCodes.UNAUTHORIZED);
        }

        // ✅ Check active session
        const session = await Session.findOne({ userId: user._id });

        if (!session) {
          ErrorResponse.error = 'JsonWebTokenError';
          res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
          return;
        }

        req.user = user;
        req.user.token = token;

        next();
        return;
      } catch {
        ErrorResponse.error = 'JsonWebTokenError';
        res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
        return;
      }
    }
  } catch (error) {
    console.log('Authentication Middleware Error:', error);
    next(error);
  }
};
