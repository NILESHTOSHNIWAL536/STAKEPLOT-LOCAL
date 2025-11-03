const { notificationTracker } = require("../models/index");
const mongoose = require("mongoose");

const NotificationMiddleware = async (req, res, next) => {
  try {    
    const { id: receiverId, screen, billId } = req.body;
    const type = req.body.type || "generic";
    const today = new Date().toISOString().slice(0, 10);

    // ✅ Only run for /remainder screen
    if (screen !== "/remainder") {
      return next();
    }

    // Check if receiverId or billId is invalid or placeholder (e.g. "Loading...")
    if (!receiverId || receiverId === "Loading..." || !mongoose.Types.ObjectId.isValid(receiverId)) {
      console.warn("Invalid receiverId:", receiverId);
      return res.status(200).json({ message: "Notification skipped: invalid receiver" });
    }

    // Check if billId is invalid or empty
    if (!billId || !mongoose.Types.ObjectId.isValid(billId)) {
      console.warn("Invalid billId:", billId);
      return res.status(200).json({ message: "Notification skipped: invalid billId" });
    }

    // Proceed with checking the notificationTracker
    const tracker = await notificationTracker.findOne({
      userId: new mongoose.Types.ObjectId(receiverId),
      // billId: billId ? billId.trim() : null,
      billId: typeof billId === "string" ? billId.trim() : billId,
      date: today,
      type: typeof type === "string" ? type.trim() : type,
    });

    if (tracker && tracker.count >= 2) {
      return res.status(429).json({ message: "Notification limit reached for this bill today" });
    }

    req.notificationTracker = tracker;
    req.notificationMeta = { userId: receiverId, billId, date: today, type };
    next();
  } catch (err) {
    console.error("Error in NotificationMiddleware:", err);
    return res.status(500).json({ message: "Internal server error" });
  }
};

module.exports = NotificationMiddleware;