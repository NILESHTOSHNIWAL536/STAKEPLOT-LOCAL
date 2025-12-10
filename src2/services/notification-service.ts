import https from 'https';
import { sendingNotification } from '../models';
import logger from '../utils/common/logger';
import AppError from '../utils/errors/app-error';
import { redisClient } from '@/config';
import { StatusCodes } from 'http-status-codes';
import { Document } from 'mongoose';
import { ServerConfig } from '@/config';
import { Types } from 'mongoose';

// ------------------------------
// TYPES
// ------------------------------

export interface IDeviceInfo {
  deviceId?: string;
  brand?: string;
  deviceName?: string;
  model?: string;
  os?: string;
  device?: string;
}

export interface IOneSignalNotificationPayload {
  app_id: string;
  contents: { en: string };
  included_segments?: string[];
  include_subscription_ids?: string[];
  content_available?: boolean;
  small_icon?: string;
  data?: Record<string, any>;
  headings?: { en: string };
  big_picture?: string;
}

// ------------------------------
// SEND NOTIFICATION TO ONE SIGNAL
// ------------------------------

export async function SendNotification(data: IOneSignalNotificationPayload, callback: (error: any, result?: any) => void): Promise<void> {
  const headers = {
    'Content-Type': 'application/json; charset=utf-8',
    Authorization: 'Basic ' + ServerConfig.ONE_SIGNAL_API_KEY,
  };

  const options = {
    host: 'onesignal.com',
    port: 443,
    path: '/api/v1/notifications',
    method: 'POST',
    headers,
  };

  const req = https.request(options, (res) => {
    res.on('data', () => callback(null, {}));
  });

  req.on('error', (e) => callback({ message: e }));

  req.write(JSON.stringify(data));
  req.end();
}

// ------------------------------
// ADD / UPDATE DEVICE LOGINS
// ------------------------------

export async function addDevice(userId: string | Types.ObjectId, deviceInfo: IDeviceInfo): Promise<Document> {
  try {
    const { deviceId = 'unknown-device-id', brand = 'Unknown Brand', deviceName = 'Unknown Device', model = 'Unknown Model', os = 'Unknown OS' } = deviceInfo || {};

    const device = deviceInfo?.device || deviceName;

    let notificationDevice = await sendingNotification.findOne({ userId });

    if (!notificationDevice) {
      // Create new entry
      notificationDevice = new sendingNotification({
        userId,
        deviceLogins: [{ deviceId, brand, device, model, os, loginTime: new Date() }],
      });
    } else {
      // Update existing entry
      const deviceExists = notificationDevice.deviceLogins.some((d: any) => d.deviceId === deviceId);

      if (!deviceExists) {
        notificationDevice.deviceLogins.push({
          deviceId,
          brand,
          device,
          model,
          os,
          loginTime: new Date(),
        });
      }
    }

    return await notificationDevice.save();
  } catch (error: any) {
    throw new AppError(`Cannot add new device: ${error.message || error}`, StatusCodes.INTERNAL_SERVER_ERROR);
  }
}

// ------------------------------
// SEND NOTIFICATION TO SPECIFIC DEVICES
// ------------------------------

export async function SendNotificationToDeviceSpecific(userId: string, msg: string, deviceIds: string[], screen: string, title: string, pic?: string): Promise<void> {
  const message: IOneSignalNotificationPayload = {
    app_id: ServerConfig.ONE_SIGNAL_ID,
    contents: { en: msg },
    included_segments: ['included_player_ids'],
    include_subscription_ids: deviceIds,
    content_available: true,
    small_icon: 'app_icon',
    data: {
      PushTitle: 'CUSTOM NOTIFICATION',
      screen,
    },
    headings: { en: title },
    big_picture: pic,
  };

  await SendNotification(message, (error, results) => {
    if (error) logger.error(`error from notification-service: ${error}`);
    else logger.debug(`sendNotificationToDeviceSpecific: ${results}`);
  });
}

export default {
  SendNotification,
  addDevice,
  SendNotificationToDeviceSpecific,
};
