const { ONE_SIGNAL_CONFIG } = require("../config/oneSignalConfig");
const { sendingNotification } = require("../models");
const logger = require("../utils/common/logger");
// const { sendingNotification, User } = require("../models/index");
// const {
//   getDeviceIdsFriends,
//   getDeviceIdsByUserId,
// } = require("../utils/helpers/getDeviceIds");
const AppError = require("../utils/errors/app-error");
const { StatusCodes } = require("http-status-codes");


async function SendNotification(data, callback) {
  var headers = {
    "Content-Type": "application/json; charset=utf-8",
    Authorization: "Basic " + ONE_SIGNAL_CONFIG.API_KEY,
  };
  var options = {
    host: "onesignal.com",
    port: 443,
    path: "/api/v1/notifications",
    method: "POST",
    headers: headers,
  };
  var https = require("https");

  var req = https.request(options, function (res) {
    res.on("data", function () {
      return callback(null, {});
    });
  });

  req.on("error", function (e) {
    return callback({ message: e });
  });

  req.write(JSON.stringify(data));
  req.end();
}

async function addDevice(userId, deviceInfo) {
  try {
    const {
      deviceId = 'unknown-device-id',
      brand = 'Unknown Brand',
      deviceName = 'Unknown Device',
      model = 'Unknown Model',
      os = 'Unknown OS',
    } = deviceInfo || {};

    const device = deviceInfo?.device || deviceName || 'Unknown Device';
    let notificationDevice = await sendingNotification.findOne({ userId });

    if (!notificationDevice) {
      // If userId doesn't exist, create a new document
      notificationDevice = new sendingNotification({
        userId,
        deviceLogins: [
          { deviceId, brand, device, model, os, loginTime: new Date() },
        ],
      });
    } else {
      // Check if the device already exists in deviceLogins
      const deviceExists = notificationDevice.deviceLogins.some(
        (d) => d.deviceId === deviceId
      );

      if (!deviceExists) {
        // If the device does not exist, add it to deviceLogins
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

    // Save the document
    const savedDocument = await notificationDevice.save();
    return savedDocument;
  } catch (error) {
    throw new AppError(
      `Cannot add new device: ${error}`,
      StatusCodes.INTERNAL_SERVER_ERROR
    );
  }
}

async function SendNotificationToDeviceSpecific(
  id,
  msg,
  deviceIds,
  screen,
  title,
  pic
) {
  const message = {
    app_id: ONE_SIGNAL_CONFIG.APP_ID,
    contents: { en: msg },
    included_segments: ["included_player_ids"],
    include_subscription_ids: deviceIds,
    content_available: true,
    small_icon: "app_icon",
    data: {
      PushTitle: "CUSTOM NOTIFICATION",
      screen: screen,
    },
    headings: { en: title },
    big_picture: pic,
  };
  const response = await SendNotification(message, (error, results) => {
    if (error) logger.error(`error from notification-service: ${error}`);
    else logger.debug(`from sendNotificationToDeviceSpecific: ${results}`);
  });
  return response;
}

module.exports = {
  SendNotification,
  addDevice,
  SendNotificationToDeviceSpecific,
};