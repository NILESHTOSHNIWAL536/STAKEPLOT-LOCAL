const apiClient = require('./apiClient');
const redisClient = require('../../config/redis-config');
const logger = require('../common/logger');

const baseUrl = process.env.FINVU_URL;
const headers = { rid: process.env.FINVU_RID, ts: process.env.FINVU_TS, channelId: process.env.FINVU_CHANNEL_ID };

async function generateToken() {
  try {
    const loginResponse = await apiClient.post(`${baseUrl}/User/Login`, null, {
      header: headers,
      body: {
        userId: process.env.FINVU_USER_ID,
        password: process.env.FINVU_PASSWORD,
      },
    });

    if (loginResponse.status !== 200 && loginResponse.status !== 201) return { message: 'Login failed' };

    const token = `Bearer ${loginResponse.data.body.token}`;
    const cacheKey = 'auth_token';
    const cachedData = await redisClient.get(cacheKey);
    if (cachedData) {
      return cachedData;
    }
    logger.debug(`token from the generateToken ${token}`);
    const cacheToken = await redisClient.setEx(cacheKey, 24 * 60 * 60, token);
    logger.debug(`cachedToken from generateToken: ${cacheToken}`);

    return token;
  } catch (error) {
    return error;
  }
}

module.exports = generateToken;
