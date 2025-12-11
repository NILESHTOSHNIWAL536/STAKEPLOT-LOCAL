import { Request, Response, NextFunction } from 'express';
import jwt, { JwtPayload } from 'jsonwebtoken';
import { StatusCodes } from 'http-status-codes';
import { AuthUser } from '@/types/user/user';
import { User, Session } from '@/models';
import AppError from '@/utils/errors/app-error';
import { ErrorResponse } from '@/utils/common';
import { ServerConfig } from '@/config';

interface DecodedToken extends JwtPayload {
  id: string;
}

export const protect = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader) {
      ErrorResponse.error = 'JsonWebTokenError';
      res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
      return;
    }

    const [tokenType, token] = authHeader.split(' ');

    if (tokenType !== 'Bearer' || !token) {
      ErrorResponse.error = 'JsonWebTokenError';
      res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
      return;
    }

    if (!ServerConfig.JWT_SECRET) {
      throw new Error('JWT_SECRET missing from configuration');
    }

    let decoded: JwtPayload | string;

    try {
      decoded = jwt.verify(token, ServerConfig.JWT_SECRET);
    } catch {
      ErrorResponse.error = 'JsonWebTokenError';
      res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
      return;
    }

    // 🔍 Ensure decoded token is an object & contains id
    if (typeof decoded !== 'object' || !decoded || typeof decoded.id !== 'string') {
      ErrorResponse.error = 'JsonWebTokenError';
      res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
      return;
    }

    const payload = decoded as DecodedToken;

    const user = await User.findOne({ _id: payload.id }).select('-password');

    if (!user) {
      throw new AppError('User Not found', StatusCodes.UNAUTHORIZED);
    }

    const session = await Session.findOne({ userId: user._id });

    if (!session) {
      ErrorResponse.error = 'JsonWebTokenError';
      res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
      return;
    }

    // Attach user to request
    req.user = user as AuthUser;
    req.user.token = token;

    next();
  } catch (error) {
    console.log('Authentication Middleware Error:', error);
    next(error);
  }
};
