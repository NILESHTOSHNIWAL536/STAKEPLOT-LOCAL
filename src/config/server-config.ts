export const ServerConfig = {
  HOST: process.env.HOST || '127.0.0.1',
  PORT: process.env.PORT!,
  JWT_SECRET: process.env.JWT_SECRET!,
  SERVICE_JWT_SECRET: process.env.SERVICE_JWT_SECRET!,
  MONGO_URI: process.env.MONGO_URI!,
  ONE_SIGNAL_ID: process.env.ONE_SIGNAL_ID!,
  ONE_SIGNAL_API_KEY: process.env.ONE_SIGNAL_API_KEY!,
  PREDICT_URL: process.env.PREDICT_URL!,
  MOBILE_BACKEND_URL: process.env.MOBILE_BACKEND_URL || 'http://localhost:5000',
  RATE_LIMIT_MAX: parseInt(process.env.RATE_LIMIT_MAX || '200', 10),
  RATE_LIMIT_WINDOW_MS: parseInt(process.env.RATE_LIMIT_WINDOW_MS || `${15 * 60 * 1000}`, 10),
  SENTRY_DSN: process.env.SENTRY_DSN,
};
