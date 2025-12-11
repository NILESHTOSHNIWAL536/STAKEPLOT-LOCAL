import { Request, Response, NextFunction } from 'express';
import { ServerConfig } from '@/config';
import pushNotificationService from '../services/notification-service';
import { StatusCodes } from 'http-status-codes';
import { SuccessResponse, ErrorResponse } from '../utils/common';
import { getDeviceIdsByUserId } from '../utils/helpers/getDeviceIds';
import { notificationTracker } from '../models';
import { IUser } from '@/models/user-model';
/* ---------------------------------------------
   Custom Types for Extended Request Properties
----------------------------------------------*/

// interface NotificationMeta {
//   userId: string;
//   date: string | Date;
//   type: string;
// }

// interface NotificationTrackerDoc extends Document {
//   userId: string;
//   billId?: string;
//   date: string | Date;
//   type: string;
//   count: number;
// }

interface CustomRequest extends Request {
  notificationMeta?: any;
  notificationTracker?: any;
}

/* ---------------------------------------------
   OneSignal Message Type
----------------------------------------------*/
interface OneSignalMessage {
  app_id: string;
  contents: { en: string };
  included_segments?: string[];
  include_subscription_ids?: string[];
  content_available?: boolean;
  small_icon?: string;
  data?: Record<string, any>;
}

/* ---------------------------------------------
   Send notification to all users (7 PM daily)
----------------------------------------------*/
export const SendNotification = async (): Promise<void> => {
  const messages = [
    "You're one step away from staying on top of things.",
    'One tap today can make a big difference later.',
    "It's a good day to get a quick update on your finances.",
    "You chill, we track. But checking in won't hurt.",
  ];

  const msg = messages[Math.floor(Math.random() * messages.length)];

  const message: OneSignalMessage = {
    app_id: ServerConfig!.ONE_SIGNAL_ID,
    contents: { en: msg },
    included_segments: ['All'],
    content_available: true,
    small_icon: 'app_icon',
    data: { PushTitle: 'CUSTOM NOTIFICATION' },
  };

  pushNotificationService.SendNotification(message, () => {});
};

/* ---------------------------------------------
   Send notification to specified device list
----------------------------------------------*/
export const SendNotificationToDevice = async (req: Request, res: Response, next: NextFunction) => {
  const message: OneSignalMessage = {
    app_id: ServerConfig!.ONE_SIGNAL_ID,
    contents: { en: req.body.message },
    included_segments: ['included_player_ids'],
    include_subscription_ids: req.body.devices,
    content_available: true,
    small_icon: 'ic_notification_icon',
    data: {
      PushTitle: 'CUSTOM NOTIFICATION',
      screen: '/home',
    },
  };

  pushNotificationService.SendNotification(message, (error: any, results: any) => {
    if (error) return next(error);
    return res.status(200).send({ message: 'Success', data: results });
  });
};

/* ---------------------------------------------
   Add device for push notifications
----------------------------------------------*/
export const addDeviceToNotify = async (req: Request, res: Response) => {
  try {
    const messages = await pushNotificationService.addDevice(req.user._id, req.body);
    SuccessResponse.data = messages;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error: any) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
};

/* ---------------------------------------------
   Send custom message to specific user
----------------------------------------------*/
export const SendNotificationToDeviceWithThisMessage = async (req: CustomRequest, res: Response) => {
  try {
    const { id: msgReceiverId, message, screen = '/home', title = '', pic = '', billId } = req.body;

    // Fetch device tokens
    const deviceIds = await getDeviceIdsByUserId(msgReceiverId);

    // Send push notification
    await pushNotificationService.SendNotificationToDeviceSpecific(msgReceiverId, message, deviceIds, screen, title, pic);

    /* If middleware provided metadata → update tracking */
    if (req.notificationMeta) {
      const { userId: receiverId, date, type } = req.notificationMeta;

      if (req.notificationTracker) {
        req.notificationTracker.count += 1;
        await req.notificationTracker.save();
      } else {
        await notificationTracker.create({
          userId: receiverId,
          billId,
          date,
          type,
          count: 1,
        });
      }
    }

    res.status(200).send({ message: 'Notification sent successfully' });
  } catch (error) {
    console.error('Notification error:', error);
    return res.status(500).json({ error: 'Something went wrong' });
  }
};
