const { pushNotificationController } = require('../controllers');
import { protect } from '../middlewares/auth-middleware';
const express = require('express');
const router = express.Router();

router.post('/addDeviceToNotify', protect, pushNotificationController.addDeviceToNotify);
router.post('/SendNotificationToDevice', protect, pushNotificationController.SendNotificationToDevice);
router.get('/SendNotification', protect, pushNotificationController.SendNotification);
module.exports = router;
