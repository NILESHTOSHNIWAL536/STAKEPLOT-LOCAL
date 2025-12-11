import { Notification } from '../models';
import CrudRepository from './crud-repository';
import { INotification } from '@/models/notification-model';
import { Types } from 'mongoose';

class NotificationRepository extends CrudRepository<typeof Notification> {
  constructor() {
    super(Notification);
  }

  // ----------------------------------------------------
  // CREATE NOTIFICATION
  // ----------------------------------------------------
  async createNotification(data: Partial<INotification>): Promise<INotification> {
    const response = await Notification.create(data);
    return response as INotification;
  }

  // ----------------------------------------------------
  // GET NOTIFICATIONS
  // ----------------------------------------------------
  async getNotifications(query: Record<string, any>): Promise<INotification[]> {
    const response = await Notification.find(query).sort({ createdAt: -1 });
    return response as INotification[];
  }

  // ----------------------------------------------------
  // DELETE A SINGLE NOTIFICATION
  // ----------------------------------------------------
  async deleteNotifications(query: Record<string, any>) {
    try {
      const response = await Notification.findOneAndDelete(query);

      if (response) {
        return {
          success: true,
          message: 'Notification deleted',
          data: response,
        };
      }

      return {
        success: false,
        message: 'No matching notification found',
      };
    } catch (error: any) {
      return {
        success: false,
        message: 'Error deleting notification',
        error: error.message,
      };
    }
  }

  // ----------------------------------------------------
  // DELETE ALL NOTIFICATIONS FOR A USER
  // ----------------------------------------------------
  async deleteAllNotification(userId: string | Types.ObjectId) {
    try {
      const response = await Notification.deleteMany({ userId });

      if (response) {
        return {
          success: true,
          message: 'Notifications deleted',
          data: response,
        };
      }

      return {
        success: false,
        message: 'No matching notifications found',
      };
    } catch (error: any) {
      return {
        success: false,
        message: 'Error deleting notifications',
        error: error.message,
      };
    }
  }
}

export default NotificationRepository;
