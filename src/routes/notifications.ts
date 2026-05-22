import express from 'express';
import { AuthMiddlewares } from '../middlewares';
import { pushNotificationController } from '@/controllers';

const router = express.Router();
router.use(express.json());

router.post('/addDeviceToNotify', AuthMiddlewares.protect, pushNotificationController.addDeviceToNotify);
router.post('/SendNotificationToDevice', AuthMiddlewares.protect, pushNotificationController.SendNotificationToDevice);
router.get('/SendNotification', AuthMiddlewares.protect, pushNotificationController.SendNotification);

export default router;
