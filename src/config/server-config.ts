// Getters ensure values are read from process.env at access time, not at module-load time.
// This is required so that loadSecrets() (called in startServer) can inject secrets before they're used.
export const ServerConfig = {
  get HOST() { return process.env.HOST || '127.0.0.1'; },
  get PORT() { return process.env.PORT!; },
  get JWT_SECRET() { return process.env.JWT_SECRET!; },
  get SERVICE_JWT_SECRET() { return process.env.SERVICE_JWT_SECRET!; },
  get MONGO_URI() { return process.env.MONGO_URI!; },
  get ONE_SIGNAL_ID() { return process.env.ONE_SIGNAL_ID!; },
  get ONE_SIGNAL_API_KEY() { return process.env.ONE_SIGNAL_API_KEY!; },
  get PREDICT_URL() { return process.env.PREDICT_URL!; },
  get MOBILE_BACKEND_URL() { return process.env.MOBILE_BACKEND_URL || 'http://localhost:5000'; },
  get RATE_LIMIT_MAX() { return parseInt(process.env.RATE_LIMIT_MAX || '200', 10); },
  get RATE_LIMIT_WINDOW_MS() { return parseInt(process.env.RATE_LIMIT_WINDOW_MS || `${15 * 60 * 1000}`, 10); },
  get SENTRY_DSN() { return process.env.SENTRY_DSN; },
};
