// const dotenv = require("dotenv");
// dotenv.config();

// module.exports = {
//   PORT: process.env.PORT,
//   JWT_SECRET: process.env.JWT_SECRET,
//   MAIN_MONGO_URI: process.env.MAIN_MONGO_URI,
//   EMAIL_MONGO_URI: process.env.EMAIL_MONGO_URI,
//   SERVICE_JWT_SECRET: process.env.SERVICE_JWT_SECRET,
//   REDIS_URL: process.env.REDIS_URL,
//   REDIS_PORT: process.env.REDIS_PORT,
//   REDIS_PASSWORD: process.env.REDIS_PASSWORD,
//   EMAIL_HOST: process.env.EMAIL_HOST,
//   EMAIL_USER: process.env.EMAIL_USER,
//   EMAIL_PASSWORD: process.env.EMAIL_PASSWORD,
//   OTP_URL: process.env.OTP_URL,
//   X_RAPIDAPI_KEY: process.env.X_RAPIDAPI_KEY,
//   X_RAPIDAPI_HOST: process.env.X_RAPIDAPI_HOST,
//   CLOUDAMQP_URL: process.env.CLOUDAMQP_URL,
//   GOOGLE_WEB_CLIENTID: process.env.GOOGLE_WEB_CLIENTID,
//   GOOGLE_APP_CLIENTID: process.env.GOOGLE_APP_CLIENTID,
//   REVOKE_URI: process.env.REVOKE_URI,
// };
import dotenv from 'dotenv';

dotenv.config();

export interface IServerConfig {
  PORT: number;
  JWT_SECRET: string;
  MAIN_MONGO_URI: string;
  EMAIL_MONGO_URI: string;
  SERVICE_JWT_SECRET: string;
  REDIS_HOST: string;
  REDIS_URL: string;
  REDIS_PORT: number;
  REDIS_PASSWORD: string;
  EMAIL_HOST: string;
  EMAIL_USER: string;
  EMAIL_PASSWORD: string;
  OTP_URL: string;
  X_RAPIDAPI_KEY: string;
  X_RAPIDAPI_HOST: string;
  CLOUDAMQP_URL: string;
  GOOGLE_WEB_CLIENTID: string;
  GOOGLE_APP_CLIENTID: string;
  REVOKE_URI: string;
  MOBILE_BACKEND_URL: string;
  SENTRY_DSN: string | undefined;
}

// Getters ensure values are read from process.env at access time, not at module-load time.
// This is required so that loadSecrets() (called in startServer) can inject secrets before they're used.
const ServerConfig: IServerConfig = {
  get PORT() { return Number(process.env.PORT) || 3000; },
  get JWT_SECRET() { return process.env.JWT_SECRET ?? ''; },
  get MAIN_MONGO_URI() { return process.env.MAIN_MONGO_URI ?? ''; },
  get EMAIL_MONGO_URI() { return process.env.EMAIL_MONGO_URI ?? ''; },
  get SERVICE_JWT_SECRET() { return process.env.SERVICE_JWT_SECRET ?? ''; },
  get REDIS_URL() { return process.env.REDIS_URL ?? ''; },
  get REDIS_HOST() { return process.env.REDIS_HOST ?? ''; },
  get REDIS_PORT() { return Number(process.env.REDIS_PORT) || 6379; },
  get REDIS_PASSWORD() { return process.env.REDIS_PASSWORD ?? ''; },
  get EMAIL_HOST() { return process.env.EMAIL_HOST ?? ''; },
  get EMAIL_USER() { return process.env.EMAIL_USER ?? ''; },
  get EMAIL_PASSWORD() { return process.env.EMAIL_PASSWORD ?? ''; },
  get OTP_URL() { return process.env.OTP_URL ?? ''; },
  get X_RAPIDAPI_KEY() { return process.env.X_RAPIDAPI_KEY ?? ''; },
  get X_RAPIDAPI_HOST() { return process.env.X_RAPIDAPI_HOST ?? ''; },
  get CLOUDAMQP_URL() { return process.env.CLOUDAMQP_URL ?? ''; },
  get GOOGLE_WEB_CLIENTID() { return process.env.GOOGLE_WEB_CLIENTID ?? ''; },
  get GOOGLE_APP_CLIENTID() { return process.env.GOOGLE_APP_CLIENTID ?? ''; },
  get REVOKE_URI() { return process.env.REVOKE_URI ?? ''; },
  get MOBILE_BACKEND_URL() { return process.env.MOBILE_BACKEND_URL ?? 'http://localhost:5000'; },
  get SENTRY_DSN() { return process.env.SENTRY_DSN; },
};

export default ServerConfig;
