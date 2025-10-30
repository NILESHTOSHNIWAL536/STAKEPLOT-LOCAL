const { Notification } = require("../models");
const CrudRepository = require("./crud-repository");

class notificationRepository extends CrudRepository {
  constructor() {
    super(Notification);
  }
  async createNotification(data){
    const response = await Notification.create(data)
    return response
  }

  async getNotifications(query){
    const response = await Notification.find(query).sort({ createdAt: -1 })
    return response
  }

  async deleteNotifications(query){
        try {
          const response = await Notification.findOneAndDelete(query);
          if (response) {
              return { success: true, message: "Notification deleted", data: response };
          } else {
              return { success: false, message: "No matching notification found" };
          }
      } catch (error) {
          return { success: false, message: "Error deleting notification", error: error.message };
      }
  }

  async deletAllNotification(userId){
    try{
      const response = await Notification.deleteMany({userId: userId});
      if (response) {
        return { success: true, message: "Notification deleted", data: response };
      } else {
        return { success: false, message: "No matching notification found" };
      }
    }catch (error) {
      return { success: false, message: "Error deleting notification", error: error.message };
    }
  }
}

module.exports = notificationRepository;
