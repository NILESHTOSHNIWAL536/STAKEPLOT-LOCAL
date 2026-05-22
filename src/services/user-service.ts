import { StatusCodes } from 'http-status-codes';
import AppError from '../utils/errors/app-error';
import { Types } from 'mongoose';
import axios from 'axios';
import { ServerConfig } from '../config';
import jwt from 'jsonwebtoken';

// Define return type (array of _id objects)
interface UserId {
  _id: Types.ObjectId;
}

export async function getUserInfo(): Promise<UserId[]> {
  try {
    const internalToken = jwt.sign(
      { aud: 'mobile-backend' },
      ServerConfig.SERVICE_JWT_SECRET,
      { expiresIn: '1m' }
    );

    const gatewayUrl = ServerConfig.MOBILE_BACKEND_URL || 'http://localhost:5000';
    const response = await axios.get(`${gatewayUrl}/api/v1/internal/users/ids`, {
      headers: { authorization: `Bearer ${internalToken}` },
    });

    // mobile-backend will return an array of user IDs
    return response.data;
  } catch (error: any) {
    console.error('getUserInfo error:', error?.response?.data || error.message);
    throw new AppError('Cannot get user ids', StatusCodes.BAD_REQUEST);
  }
}

export async function hydrateUsers(userIds: string[] | Types.ObjectId[]): Promise<any[]> {
  if (!userIds || userIds.length === 0) return [];

  const uniqueIds = Array.from(new Set(userIds.filter(id => id && Types.ObjectId.isValid(id))));
  if (uniqueIds.length === 0) return [];

  try {
    const internalToken = jwt.sign(
      { aud: 'mobile-backend' },
      ServerConfig.SERVICE_JWT_SECRET,
      { expiresIn: '1m' }
    );

    const gatewayUrl = ServerConfig.MOBILE_BACKEND_URL || 'http://localhost:5000';
    const response = await axios.post(`${gatewayUrl}/api/v1/user/internal/users/batch`,
      { userIds: uniqueIds },
      { headers: { authorization: `Bearer ${internalToken}` } }
    );

    return response.data;
  } catch (error: any) {
    console.error('hydrateUsers error:', error?.response?.data || error.message);
    return []; // Return empty array or fallback to just IDs if hydration fails
  }
}

export default {
  getUserInfo,
  hydrateUsers,
};
