import { Application, Request, Response, NextFunction } from 'express';
import express from 'express';
import bodyParser from 'body-parser';
import helmet from 'helmet';
import mongoSanitize from 'express-mongo-sanitize';
import rateLimit from 'express-rate-limit';
import crypto from 'crypto';
import jwt from 'jsonwebtoken';
import { ServerConfig } from '@/config';

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
  const limiter = rateLimit({
    windowMs: ServerConfig.RATE_LIMIT_WINDOW_MS,
    max: ServerConfig.RATE_LIMIT_MAX,
    message: { error: 'Too many requests, please try again later.' },
    // Use the authenticated user id (JWT `sub`) as the key so the limit applies per-user
    // instead of per-proxy IP, which avoids 429s when all traffic is funneled through
    // mobile-backend. Fallback to IP if no/invalid token is present.
    keyGenerator: (req: Request): string => {
      const authHeader = req.headers.authorization;
      if (authHeader?.startsWith('Bearer ')) {
        const token = authHeader.split(' ')[1];
        try {
          const payload = jwt.verify(token, ServerConfig.SERVICE_JWT_SECRET) as jwt.JwtPayload;
          if (payload?.sub) return `user:${payload.sub}`;
        } catch {
          // ignore and fall back to IP
        }
      }
      return req.ip;
    },
    skip: (req: Request) => {
      // Skip rate limit for internal, trusted paths if needed (e.g., batch hydration)
      // Extend this list cautiously to avoid bypassing protection on public endpoints.
      const internalPaths = ['/api/user/internal/users/batch', '/api/internal/health'];
      return internalPaths.includes(req.path);
    },
    standardHeaders: true,
    legacyHeaders: false,
  });

  app.use(limiter);

  // ✅ CSP nonce
  app.use((req: Request, res: Response, next: NextFunction) => {
    res.locals.cspNonce = crypto.randomBytes(16).toString('hex');
    next();
  });

  // ✅ Strict CSP
  app.use(
    helmet.contentSecurityPolicy({
      useDefaults: false,
      directives: {
        'default-src': ["'self'"],
        'script-src': ["'self'"],
        'style-src': ["'self'", (_req, res) => `'nonce-${(res as Response).locals.cspNonce}'`],
        'img-src': ["'self'", 'data:'],
        'font-src': ["'self'"],
        'object-src': ["'none'"],
        'base-uri': ["'self'"],
        'form-action': ["'self'"],
        'frame-ancestors': ["'none'"],
        'upgrade-insecure-requests': [],
      },
    })
  );

  // ✅ Baseline header
  app.use((req: Request, res: Response, next: NextFunction) => {
    res.setHeader('X-Content-Type-Options', 'nosniff');
    next();
  });
}
