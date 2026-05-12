import { Request, Response, NextFunction } from 'express';
import jwt, { JwtPayload } from 'jsonwebtoken';
import { StatusCodes } from 'http-status-codes';
import { AuthUser } from '@/types/user/user';
import AppError from '@/utils/errors/app-error';
import { ErrorResponse } from '@/utils/common';
import { ServerConfig } from '@/config';

interface DecodedToken extends JwtPayload {
  sub: string;
  aud?: string | string[];
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

    let decoded: JwtPayload | string;

    try {
      if (!ServerConfig.SERVICE_JWT_SECRET) {
        throw new Error('SERVICE_JWT_SECRET missing from configuration');
      }

      // Internal-only auth: token is minted by mobile-backend
      decoded = jwt.verify(token, ServerConfig.SERVICE_JWT_SECRET);
    } catch {
      ErrorResponse.error = 'JsonWebTokenError';
      res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
      return;
    }

    // Ensure decoded token is an object & contains sub (user id)
    if (typeof decoded !== 'object' || !decoded || typeof (decoded as any).sub !== 'string') {
      ErrorResponse.error = 'JsonWebTokenError';
      res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
      return;
    }

    const payload = decoded as DecodedToken;

    // Audience restriction (defense-in-depth)
    const aud = payload.aud;
    const okAud =
      aud === 'bank-service' || (Array.isArray(aud) && aud.includes('bank-service'));
    if (!okAud) {
      throw new AppError('Invalid token audience', StatusCodes.UNAUTHORIZED);
    }

    // Attach user to request
    req.user = { _id: payload.sub, token } as AuthUser;

    next();
  } catch (error) {
    next(error);
  }
};
