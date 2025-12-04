const { ONE_SIGNAL_CONFIG } = require("../config/oneSignalConfig");
const pushNotificationService = require("../services/notification-service");
const { StatusCodes } = require("http-status-codes");
const { SuccessResponse, ErrorResponse } = require("../utils/common");
const {getDeviceIdsByUserId} = require("../utils/helpers/getDeviceIds");
const { notificationTracker } = require("../models/index");

// send notification to all users at 7:00 PM every day
exports.SendNotification = async () => {
    const messages = [
      "You're one step away from staying on top of things.",
      "One tap today can make a big difference later.",
      "It's a good day to get a quick update on your finances.",
      "You chill, we track. But checking in won't hurt."
    ];
    
    const msg = messages[Math.floor(Math.random() * messages.length)];
    var message = {
      app_id: ONE_SIGNAL_CONFIG.APP_ID,
      contents: { en: msg },
      included_segments: ["All"],
      content_available: true,
      small_icon: "app_icon",
      data: {
        PushTitle: "CUSTOM NOTIFICATION",
      },
    };
    pushNotificationService.SendNotification(message, (error, results) => {});
};

exports.SendNotificationToDevice = async (req, res, next) => {
  var message = {
    app_id: ONE_SIGNAL_CONFIG.APP_ID,
    contents: { en: req.body.message },
    included_segments: ["included_player_ids"],
    include_subscription_ids: req.body.devices,
    content_available: true,
    small_icon: "ic_notification_icon",
    data: {
      PushTitle: "CUSTOM NOTIFICATION",
      "screen": "/home"
    },
  };

  pushNotificationService.SendNotification(message, (error, results) => {
    if (error) {
      return next(error);
    }
    return res.status(200).send({
      message: "Success",
      data: results,
    });
  });

};

exports.SendNotificationToDeviceSpecific = async (req, res) => {
  try {
    const id = req.user._id;
    const response = await pushNotificationService.SendNotificationToDeviceSpecific(id, req.user, "Something fishy is happening in the application, Go have look");
    res.status(200).send(response);
  } catch (error) {
    console.error(error);
    ErrorResponse.error = error;
    return res.status(error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR).json(ErrorResponse);
  }
}

exports.addDeviceToNotify = async (req, res) => {
  try {
    const messages = await pushNotificationService.addDevice(req.user._id, req.body);
    SuccessResponse.data = messages;
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    ErrorResponse.error = error;
    const statusCode = error.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
    return res.status(statusCode).json(ErrorResponse);
  }
}

exports.SendNotificationToDeviceWithThisMessage = async (req, res) => {
  try {
    const msgReceiverId = req.body.id;
    const message = req.body.message;
    const screen = req.body.screen || "/home";
    const title = req.body.title || "";
    const pic = req.body.pic || "";
    const billId = req.body.billId;

    // Send the push notification
    const deviceIds = await getDeviceIdsByUserId(msgReceiverId);
    await pushNotificationService.SendNotificationToDeviceSpecific(
      msgReceiverId,
      message,
      deviceIds,
      screen,
      title,
      pic
    );

    // Optional tracking logic: only run if middleware set this
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
          count: 1
        });
      }
    }

    res.status(200).send({ message: "Notification sent successfully" });
  } catch (error) {
    console.error("Notification error:", error);
    return res.status(500).json({ error: "Something went wrong" });
  }
};

