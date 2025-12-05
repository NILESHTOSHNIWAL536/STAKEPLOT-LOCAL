import apiClient from './apiClient';
import redisClient from '../../config/redis-config';
import logger from '../common/logger';

const baseUrl = process.env.FINVU_URL as string;

const headers = {
  rid: process.env.FINVU_RID as string,
  ts: process.env.FINVU_TS as string,
  channelId: process.env.FINVU_CHANNEL_ID as string,
};

interface LoginResponseBody {
  token: string;
}

interface LoginResponse {
  body: LoginResponseBody;
}

export async function generateToken(): Promise<string | { message: string } | unknown> {
  try {
    const loginResponse = await apiClient.post<LoginResponse>(`${baseUrl}/User/Login`, null, {
      header: headers,
      body: {
        userId: process.env.FINVU_USER_ID,
        password: process.env.FINVU_PASSWORD,
      },
    });

    if (loginResponse.status !== 200 && loginResponse.status !== 201) {
      return { message: 'Login failed' };
    }

    const token = `Bearer ${loginResponse.data.body.token}`;

    const cacheKey = 'auth_token';
    const cachedData = await redisClient.get(cacheKey);

    if (cachedData) {
      return cachedData;
    }

    logger.debug(`Token generated: ${token}`);

    const cacheToken = await redisClient.setEx(cacheKey, 24 * 60 * 60, token);
    logger.debug(`Cached token: ${cacheToken}`);

    return token;
  } catch (error) {
    logger.error('Error generating FINVU token', error);
    return error;
  }
}

export default generateToken;
