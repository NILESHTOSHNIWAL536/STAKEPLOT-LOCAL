const { getFriendsWithUserId } = require("../helpers/getDeviceIds");
const WebSocketService = require("../../services/websocket-service"); //   ../services/websocket-service");

async function sendWebSocketMessageForPost(userId, body, type) {
  try {
    const friendsList = await getFriendsWithUserId(userId);

    for (const friendId of friendsList) {
      try {
        WebSocketService.sendMessage(friendId, "addUserToSocket", {
          type: type,
          data: body,
        });
      } catch (e) {
        console.log(e);
      }
    }
  } catch (error) {
  }
}

async function sendWebSocketMessageToUserId(userId, body, type) {
  try {
    WebSocketService.sendMessage(userId, "addUserToSocket", {
      type: type,
      data: body,
    });
  } catch (error) {
  }
}

module.exports = {
  sendWebSocketMessageForPost,
  sendWebSocketMessageToUserId,
};
