import cors, { CorsOptions } from 'cors';
import { Application, Request, Response, NextFunction } from 'express';

const corsOptions: CorsOptions = {
  origin: function (origin, callback) {
    const allowedOrigins: string[] = ['https://stakeplot.com'];

    if (process.env.NODE_ENV === 'development') {
      allowedOrigins.push('http://localhost:3000', 'http://localhost:3001', "http://172.21.151.54:3000");
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

  // ✅ Graceful CORS error handling
  app.use(
    (err: Error, req: Request, res: Response, next: NextFunction) => {
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
