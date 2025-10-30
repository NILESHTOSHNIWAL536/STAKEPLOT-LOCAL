const redisClient = require("../config/redis-config");
const logger = require("../utils/common/logger");
const { Chat } = require("../models/index");


class WebSocketService {
  constructor() {
    this.io = null;
    this.initialized = false;
  }

  async initialize(server) {
    const io = require("socket.io")(server);
    this.io = io;

    io.on("connection", async (socket) => {

      socket.on("registerUser", async (userId) => {
        await redisClient.set(`socket:${userId}`, socket.id);
      });

      socket.on("addUserToSocket", async (userId) => {
        await redisClient.set(`socket:${userId}`, socket.id);
      });

      socket.on("disconnect", async () => {
        const keys = await redisClient.keys("socket:*");
        for (const key of keys) {
          if ((await redisClient.get(key)) === socket.id) {
            await redisClient.del(key);
            logger.debug(`User disconnected: ${key}`);
            break;
          }
        }
      });

      // This socket is used to loading chats
      socket.on("LoadCharts", async (msg) => { socket.to(msg.roomId).emit("LoadCharts", msg); });

      // When a client joins a room => make sure, the roomId is added to socket
      socket.on("joinRoom", (roomId) => { socket.join(roomId) });

      // On message, emit the message to the roomId
      socket.on("message", async (msg) => {
          // This emits message to the roomId
          socket.to(msg.roomId).emit("message", msg);

          // Create and store the chat message
          const data = {
            messageType: msg.messageType,
            receiver: msg.receiver,
            sender: msg.sender,
            message: msg.message,
            image: msg.image,
            poll: msg.poll,
            post: msg.post,
            split: msg.split,
            seen: false,
            isMasked: msg.isMasked
          };
          const chatMessage = new Chat(data);
          await chatMessage.save(); 
      });

    });
    this.initialized = true;
  }

  async sendMessage(userId, event, data) {
    const socketId = await redisClient.get(`socket:${userId}`);
    if (socketId && this.io) {
      this.io.to(socketId).emit(event, data);
    } else {
      logger.debug(`User ${userId} not connected`);
    }
  }
}

module.exports = new WebSocketService();