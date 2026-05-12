// function notFoundHandler(req, res) {
//   res.status(404).json({
//     error: 'Not Found',
//     message: 'The requested resource does not exist',
//   });
// }

// function globalErrorHandler(err, req, res, next) {
//   res.setHeader('X-Content-Type-Options', 'nosniff');

//   console.error('[ERROR]', {
//     message: err.message,
//     stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
//     path: req.path,
//     method: req.method,
//     ip: req.ip,
//   });

//   const statusCode = err.statusCode || 500;
//   res.status(statusCode).json({
//     error: statusCode === 500 ? 'Internal Server Error' : err.message,
//     ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
//   });
// }

// module.exports = { notFoundHandler, globalErrorHandler };

import { Request, Response, NextFunction } from 'express';
import * as Sentry from '@sentry/node';
import crypto from 'crypto';

export function notFoundHandler(req: Request, res: Response): Response {
  return res.status(404).json({
    error: 'Not Found',
    message: 'The requested resource does not exist',
  });
}

export function globalErrorHandler(
  err: any,
  req: Request,
  res: Response,
  _next: NextFunction
): Response {
  res.setHeader('X-Content-Type-Options', 'nosniff');

  const statusCode = err.statusCode || err.status || err.response?.status || 500;
  const errorReference = crypto.randomUUID();

  // Only report unexpected server errors to Sentry — skip known client errors
  if (statusCode >= 500) {
    Sentry.captureException(err, {
      extra: { path: req.path, method: req.method, errorReference },
    });
  }

  console.error('[ERROR]', {
    errorReference,
    message: err.message,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined,
    path: req.path,
    method: req.method,
    ip: req.ip,
  });

  return res.status(statusCode).json({
    error: statusCode >= 500 ? 'Internal Server Error' : err.message,
    errorReference,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
}
