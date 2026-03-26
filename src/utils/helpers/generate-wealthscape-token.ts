import axios from 'axios';
import redisClient from '../../config/redis-config';
import logger from '../common/logger';

const WEALTHSCAPE_BASE_URL = process.env.WEALTHSCAPE_BASE_URL as string;
const CACHE_KEY = 'wealthscape_channel_token';

/**
 * Generates a Wealthscape channel token (server-to-server).
 * POST /pfm/api/v2/channel-token
 * Token is valid for 24 hours; cached in Redis.
 */
async function generateWealthscapeToken(): Promise<string> {
  try {
    const cached = await redisClient.get(CACHE_KEY);
    if (cached) return cached;

    const response = await axios.post(
      `${WEALTHSCAPE_BASE_URL}/pfm/api/v2/channel-token`,
      {
        userId: process.env.WEALTHSCAPE_USER_ID,
        password: process.env.WEALTHSCAPE_PASSWORD,
      },
      { headers: { 'Content-Type': 'application/json' } }
    );

    const token: string = response.data.token;
    const bearerToken = `Bearer ${token}`;

    // Cache for 23 h 55 min (just under 24 h to avoid stale tokens)
    await redisClient.setEx(CACHE_KEY, 23 * 60 * 60 + 55 * 60, bearerToken);
    logger.debug('Wealthscape channel token generated and cached.');

    return bearerToken;
  } catch (error: any) {
    logger.error(`Error generating Wealthscape channel token: ${error.message}`);
    throw error;
  }
}

/**
 * Force-refresh the channel token (bypass cache).
 */
export async function refreshWealthscapeToken(): Promise<string> {
  await redisClient.del(CACHE_KEY);
  return generateWealthscapeToken();
}

export default generateWealthscapeToken;
