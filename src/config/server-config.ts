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
};
