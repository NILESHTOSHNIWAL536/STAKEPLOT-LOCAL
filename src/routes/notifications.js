const { pushNotificationController } = require('../controllers');
const { AuthMiddlewares } = require('../middlewares');
const express = require('express');
const router = express.Router();

router.post('/addDeviceToNotify', AuthMiddlewares.protect, pushNotificationController.addDeviceToNotify);
router.post('/SendNotificationToDevice', AuthMiddlewares.protect, pushNotificationController.SendNotificationToDevice);
router.get('/SendNotification', AuthMiddlewares.protect, pushNotificationController.SendNotification);
module.exports = router;

