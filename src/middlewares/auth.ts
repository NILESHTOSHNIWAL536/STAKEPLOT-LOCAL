import { Request, Response, NextFunction } from 'express';
import jwt, { JwtPayload } from 'jsonwebtoken';
import { StatusCodes } from 'http-status-codes';
import AppError from '../utils/app-error';
import { ErrorResponse } from '../utils/api-response';
import { ServerConfig } from '../config';

interface DecodedToken extends JwtPayload {
  sub?: string;
  aud?: string | string[];
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

    const [tokenType, token] = authHeader.split(' ');
    if (tokenType !== 'Bearer' || !token) {
      ErrorResponse.error = 'JsonWebTokenError';
      return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
    }

    try {
      if (!ServerConfig.SERVICE_JWT_SECRET) {
        throw new Error('SERVICE_JWT_SECRET missing from configuration');
      }

      // Internal-only auth: token is minted by mobile-backend
      const decoded = jwt.verify(
        token,
        ServerConfig.SERVICE_JWT_SECRET
      ) as DecodedToken;

      if (!decoded || typeof decoded !== 'object' || typeof decoded.sub !== 'string') {
        throw new AppError('Invalid token', StatusCodes.UNAUTHORIZED);
      }

      const aud = decoded.aud;
      const okAud = aud === 'email-service' || (Array.isArray(aud) && aud.includes('email-service'));
      if (!okAud) {
        throw new AppError('Invalid token audience', StatusCodes.UNAUTHORIZED);
      }


      (req as any).user = { _id: decoded.sub, token };
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
