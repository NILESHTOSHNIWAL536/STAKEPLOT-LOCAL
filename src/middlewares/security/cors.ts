// // middlewares/cors.js
// const cors = require('cors');

// const corsOptions = {
//   origin: function (origin, callback) {
//     const allowedOrigins = ['https://stakeplot.com'];

//     if (process.env.NODE_ENV === 'development') {
//       allowedOrigins.push('http://localhost:3000', 'http://localhost:3001');
//     }

//     if (!origin || allowedOrigins.includes(origin)) {
//       callback(null, true);
//     } else {
//       console.warn(`[SECURITY] Blocked CORS request from: ${origin}`);
//       callback(new Error('Not allowed by CORS'));
//     }
//   },
//   methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
//   allowedHeaders: ['Content-Type', 'Authorization'],
//   credentials: true,
//   maxAge: 600,
// };

// function corsMiddleware(app) {
//   app.use(cors(corsOptions));

//   // Graceful CORS error handling
//   app.use((err, req, res, next) => {
//     if (err.message === 'Not allowed by CORS') {
//       return res.status(403).json({
//         error: 'CORS Error',
//         message: 'Origin not allowed',
//       });
//     }
//     next(err);
//   });
// }

// module.exports = { corsMiddleware };
import cors, { CorsOptions } from 'cors';
import { Application, Request, Response, NextFunction } from 'express';

const corsOptions: CorsOptions = {
  origin(origin: string | undefined, callback: (err: Error | null, allow?: boolean) => void) {
    const allowedOrigins = ['https://stakeplot.com'];

    if (process.env.NODE_ENV === 'development') {
      allowedOrigins.push('http://localhost:3000', 'http://localhost:3001');
    }

    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      console.warn(`[SECURITY] Blocked CORS request from: ${origin}`);
      callback(new Error('Not allowed by CORS'));
    }
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 600,
};

export function corsMiddleware(app: Application): void {
  app.use(cors(corsOptions));

  // Graceful CORS error handling
  app.use(
    (
      err: Error,
      req: Request,
      res: Response,
      next: NextFunction
    ): Response | void => {
      if (err.message === 'Not allowed by CORS') {
        return res.status(403).json({
          error: 'CORS Error',
          message: 'Origin not allowed',
        });
      }
      next(err);
    }
  );
}
