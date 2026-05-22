import { Request, Response, NextFunction } from 'express';
import * as Sentry from '@sentry/node';

export function notFoundHandler(req: Request, res: Response): void {
  res.status(404).json({
    error: 'Not Found',
    message: 'The requested resource does not exist',
  });
}

export function globalErrorHandler(
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
): void {
  res.setHeader('X-Content-Type-Options', 'nosniff');

  const statusCode: number = err.statusCode || 500;

  // Only report unexpected server errors to Sentry — skip known client errors
  if (statusCode >= 500) {
    Sentry.captureException(err, {
      extra: { path: req.path, method: req.method },
    });
  }

  console.error('[ERROR]', {
    message: err.message,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
    path: req.path,
    method: req.method,
    ip: req.ip,
  });

  res.status(statusCode).json({
    error: statusCode === 500 ? 'Internal Server Error' : err.message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
}
