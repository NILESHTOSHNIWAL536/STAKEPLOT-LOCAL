const dotenv = require("dotenv");
dotenv.config();

module.exports = {
  PORT: process.env.PORT,
  JWT_SECRET: process.env.JWT_SECRET,
  MAIN_MONGO_URI: process.env.MAIN_MONGO_URI,
  EMAIL_MONGO_URI: process.env.EMAIL_MONGO_URI,
  SERVICE_JWT_SECRET: process.env.SERVICE_JWT_SECRET,
  REDIS_URL: process.env.REDIS_URL,
  REDIS_PORT: process.env.REDIS_PORT,
  REDIS_PASSWORD: process.env.REDIS_PASSWORD,
  EMAIL_HOST: process.env.EMAIL_HOST,
  EMAIL_USER: process.env.EMAIL_USER,
  EMAIL_PASSWORD: process.env.EMAIL_PASSWORD,
  OTP_URL: process.env.OTP_URL,
  X_RAPIDAPI_KEY: process.env.X_RAPIDAPI_KEY,
  X_RAPIDAPI_HOST: process.env.X_RAPIDAPI_HOST,
  CLOUDAMQP_URL: process.env.CLOUDAMQP_URL,
  GOOGLE_WEB_CLIENTID: process.env.GOOGLE_WEB_CLIENTID,
  GOOGLE_APP_CLIENTID: process.env.GOOGLE_APP_CLIENTID,
  REVOKE_URI: process.env.REVOKE_URI,
};
