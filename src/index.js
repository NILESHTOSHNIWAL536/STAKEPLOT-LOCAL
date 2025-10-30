const mongoose = require("mongoose");
const dotenv = require("dotenv");
const app = require("./app");
const { ServerConfig } = require("./config");
const logger = require("./utils/common/logger");
const WebSocketService = require("./services/websocket-service");
const { initCloudWatchLogs } = require("./utils/cloud-watch");
const redisClient = require("./config/redis-config");

dotenv.config({ path: `./config/.env.${process.env.NODE_ENV}` });

const startServer = async () => {
  try {
    const server = app.listen(ServerConfig.PORT, "0.0.0.0", async () => {
      logger.info(`Server running on port: ${ServerConfig.PORT}`);
    });

    await mongoose.connect(ServerConfig.MONGO_URI);
    await WebSocketService.initialize(server);
    await initCloudWatchLogs();
    // await redisClient.connect();
    // require("./utils/cron-jobs");
  } catch (error) {
    console.error("Server Start Error:", error);
    process.exit(1);
  }
};

startServer();
