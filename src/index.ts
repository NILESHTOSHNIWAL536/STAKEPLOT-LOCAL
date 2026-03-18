import mongoose from 'mongoose';
import dotenv from 'dotenv';
import app from './app';
import { ServerConfig } from './config';
import logger from './utils/common/logger';
import { initCloudWatchLogs } from './utils/cloud-watch';
import redisClient from './config/redis-config';

dotenv.config({ path: `./config/.env.${process.env.NODE_ENV}` });

const startServer = async (): Promise<void> => {
  try {
    const port = parseInt(ServerConfig.PORT || '5000', 10);
    const server = app.listen(port, ServerConfig.HOST || '127.0.0.1', async () => {
      logger.info(`Server running on port: ${port}`);
    });

    await mongoose.connect(ServerConfig.MONGO_URI!);
    await initCloudWatchLogs();
    await redisClient.connect();
    // await import('./utils/cron-jobs');
  } catch (error) {
    console.error('Server Start Error:', error);
    process.exit(1);
  }
};

startServer();
