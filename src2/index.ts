import mongoose from 'mongoose';
import dotenv from 'dotenv';
import app from './app.js';
import { ServerConfig } from './config/index.js';
import logger from './utils/common/logger.js';
import { initCloudWatchLogs } from './utils/cloud-watch.js';
import redisClient from './config/redis-config.js';
import initCategoryWatcher from './config/categoryWatcher.js';

dotenv.config({ path: `./config/.env.${process.env.NODE_ENV}` });

const startServer = async (): Promise<void> => {
  try {
    const server = app.listen(ServerConfig.PORT, '0.0.0.0', async () => {
      logger.info(`Server running on port: ${ServerConfig.PORT}`);
    });

    await mongoose.connect(ServerConfig.MONGO_URI);
    await initCloudWatchLogs();
    await redisClient.connect();
    initCategoryWatcher();
    await import('./utils/cron-jobs.js');
  } catch (error) {
    console.error('Server Start Error:', error);
    process.exit(1);
  }
};

startServer();
