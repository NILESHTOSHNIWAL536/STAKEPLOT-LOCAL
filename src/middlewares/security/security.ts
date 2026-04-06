import { Application, Request, Response, NextFunction } from 'express';
import express from 'express';
import bodyParser from 'body-parser';
import helmet from 'helmet';
import mongoSanitize from 'express-mongo-sanitize';
import rateLimit from 'express-rate-limit';
import crypto from 'crypto';

export function securityMiddleware(app: Application): void {
  // ✅ Body parsers
  app.use(express.json({ limit: '5mb' }));
  app.use(bodyParser.json({ limit: '5mb' }));
  app.use(bodyParser.urlencoded({ limit: '5mb', extended: true }));

  // ✅ Helmet (security headers)
  app.use(
    helmet({
      crossOriginResourcePolicy: { policy: 'same-origin' },
    })
  );

  app.use(helmet.noSniff());
  app.use(helmet.hidePoweredBy());

  if (process.env.NODE_ENV === 'production') {
    app.use(
      helmet.hsts({
        maxAge: 31536000,
        includeSubDomains: true,
        preload: true,
      })
    );
  }

  // ✅ NoSQL injection prevention
  app.use(
    mongoSanitize({
      replaceWith: '_',
      onSanitize: ({ req, key }: { req: Request; key: string }) => {
        console.warn(
          `[SECURITY] NoSQL injection attempt blocked: ${key} from IP: ${req.ip}`
        );
      },
    })
  );

  // ✅ Rate limiter
  // const limiter = rateLimit({
  //   windowMs: 15 * 60 * 1000,
  //   max: 200,
  //   message: { error: 'Too many requests, please try again later.' },
  // });

  // app.use(limiter);

  // ✅ CSP nonce
  app.use((req: Request, res: Response, next: NextFunction) => {
    res.locals.cspNonce = crypto.randomBytes(16).toString('hex');
    next();
  });

  // ✅ Strict CSP
  // app.use(
  //   helmet.contentSecurityPolicy({
  //     useDefaults: false,
  //     directives: {
  //       'default-src': ["'self'"],
  //       'script-src': ["'self'"],
  //       'style-src': ["'self'", (_req, res) => `'nonce-${res.locals.cspNonce}'`],
  //       'img-src': ["'self'", 'data:'],
  //       'font-src': ["'self'"],
  //       'object-src': ["'none'"],
  //       'base-uri': ["'self'"],
  //       'form-action': ["'self'"],
  //       'frame-ancestors': ["'none'"],
  //       'upgrade-insecure-requests': [],
  //     },
  //   })
  // );

  // ✅ Baseline header
  app.use((req: Request, res: Response, next: NextFunction) => {
    res.setHeader('X-Content-Type-Options', 'nosniff');
    next();
  });
}
