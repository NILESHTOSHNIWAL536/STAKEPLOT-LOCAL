import { sendingNotification, UserActivity } from '@/models';
import { Types } from "mongoose";
import axios from 'axios';
import { ServerConfig } from '@/config';
import jwt from 'jsonwebtoken';

// ---- Interfaces for minimal typing ---- //

interface IFriend {
  _id: string;
}

interface IDeviceLogin {
  deviceId: string;
}

interface INotificationDocument {
  userId: string;
  deviceLogins: IDeviceLogin[];
}

interface IUserActivity {
  userId: string;
}

// ---- Functions ---- //

async function fetchUserFromGateway(id: string): Promise<any> {
  const internalToken = jwt.sign(
    { aud: 'mobile-backend' },
    ServerConfig.SERVICE_JWT_SECRET,
    { expiresIn: '1m' }
  );
  try {
    const res = await axios.get(`${ServerConfig.MOBILE_BACKEND_URL}/api/v1/internal/users/${id}`, {
      headers: { authorization: `Bearer ${internalToken}` },
    });
    return res.data;
  } catch (error) {
    return null;
  }
}

export async function getFriendsWithUserId(id: string): Promise<string[]> {
  const user = await fetchUserFromGateway(id);
  if (!user || !user.friendsList) return [];

  const friendsList = user.friendsList as IFriend[];
  const deviceIds: string[] = friendsList.map((friend) => friend._id);

  return deviceIds;
}

export async function getDeviceIdsFriends(id: string): Promise<string[]> {
  const user = await fetchUserFromGateway(id);
  if (!user || !user.friendsList) return [];

  const friendsList = user.friendsList as IFriend[];
  const deviceIds: string[] = [];

  for (const friend of friendsList) {
    const friendNotification = (await sendingNotification.findOne({ userId: friend._id }).lean()) as INotificationDocument | null;

    if (friendNotification?.deviceLogins) {
      for (const device of friendNotification.deviceLogins) {
        deviceIds.push(device.deviceId);
      }
    }
  }

  return deviceIds;
}

export async function getDeviceIdsByUserId(userId: string | Types.ObjectId): Promise<string[]> {
  const deviceIds: string[] = [];

  const friendNotification = (await sendingNotification.findOne({ userId }).lean()) as INotificationDocument | null;

  if (!friendNotification) return [];

  for (const device of friendNotification.deviceLogins) {
    deviceIds.push(device.deviceId);
  }

  return deviceIds;
}

export async function getDeviceIdsofCupons(): Promise<string[]> {
  try {
    const users = (await UserActivity.find({ unclaimedCount: { $gt: 0 } }, { userId: 1, _id: 0 }).lean()) as IUserActivity[];

    const userIds = [...new Set(users.map((u) => u.userId))];

    let allDeviceIds: string[] = [];

    for (const userId of userIds) {
      if (userId !== 'deviceData.value') {
        const deviceIds = await getDeviceIdsByUserId(userId);
        allDeviceIds.push(...deviceIds);
      }
    }

    const uniqueDeviceIds = [...new Set(allDeviceIds)];
    return uniqueDeviceIds;
  } catch (error) {
    return [];
  }
}
