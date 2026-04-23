import './instrument'; // Sentry MUST be initialized before any other imports
import mongoose from 'mongoose';
import dotenv from 'dotenv';
dotenv.config();
import app from './app';
import { ServerConfig } from './config';
import logger from './utils/common/logger';
import { initCloudWatchLogs } from './utils/cloud-watch';
import redisClient from './config/redis-config';
import reserveEngine from './services/reserve-engine';


const startServer = async (): Promise<void> => {
  try {
    const port = parseInt(ServerConfig.PORT, 10);
    const server = app.listen(port, '0.0.0.0', async () => {
      logger.info(`Server running on port: ${port}`);
    });

    await mongoose.connect(ServerConfig.MONGO_URI!);
    await initCloudWatchLogs();
    await redisClient.connect();
    await reserveEngine.scheduleExistingReserves();
    // await import('./utils/cron-jobs');
  } catch (error) {
    console.error('Server Start Error:', error);
    process.exit(1);
  }
};

startServer();
