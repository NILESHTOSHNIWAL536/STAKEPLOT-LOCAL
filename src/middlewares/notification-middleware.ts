import { Request, Response, NextFunction } from 'express';
import mongoose from 'mongoose';
import { notificationTracker } from '../models';

export interface NotificationRequest extends Request {
  notificationTracker?: any;
  notificationMeta?: {
    userId: string;
    billId: string;
    date: string;
    type: string;
  };
}

export const NotificationMiddleware = async (
  req: NotificationRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { id: receiverId, screen, billId } = req.body;
    const type: string = req.body.type || 'generic';
    const today = new Date().toISOString().slice(0, 10);

    // ✅ Only run for /remainder screen
    if (screen !== '/remainder') {
      next();
      return;
    }

    // ✅ Validate receiverId
    if (
      !receiverId ||
      receiverId === 'Loading...' ||
      !mongoose.Types.ObjectId.isValid(receiverId)
    ) {
      console.warn('Invalid receiverId:', receiverId);
      res.status(200).json({
        message: 'Notification skipped: invalid receiver',
      });
      return;
    }

    // ✅ Validate billId
    if (!billId || !mongoose.Types.ObjectId.isValid(billId)) {
      console.warn('Invalid billId:', billId);
      res.status(200).json({
        message: 'Notification skipped: invalid billId',
      });
      return;
    }

    // ✅ Check tracker
    const tracker = await notificationTracker.findOne({
      userId: new mongoose.Types.ObjectId(receiverId),
      billId: typeof billId === 'string' ? billId.trim() : billId,
      date: today,
      type: typeof type === 'string' ? type.trim() : type,
    });

    if (tracker && tracker.count >= 2) {
      res.status(429).json({
        message: 'Notification limit reached for this bill today',
      });
      return;
    }

    req.notificationTracker = tracker;
    req.notificationMeta = {
      userId: receiverId,
      billId,
      date: today,
      type,
    };

    next();
  } catch (err) {
    console.error('Error in NotificationMiddleware:', err);
    res.status(500).json({
      message: 'Internal server error',
    });
  }
};
