import dotenv from 'dotenv';
dotenv.config(); // must run before Sentry.init reads process.env.SENTRY_DSN

import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV || 'development',
  enabled: !!process.env.SENTRY_DSN,

  // Capture 10% of transactions in production, 100% in other envs
  tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0,

  integrations: [
    Sentry.mongooseIntegration(),
    Sentry.redisIntegration(),
    Sentry.httpIntegration({ breadcrumbs: true }),
  ],

  beforeSend(event) {
    // Strip authorization headers from all outgoing Sentry events
    if (event.request?.headers) {
      delete event.request.headers['authorization'];
      delete event.request.headers['cookie'];
    }
    return event;
  },
});
