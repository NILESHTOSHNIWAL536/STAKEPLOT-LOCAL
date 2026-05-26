import './instrument'; // Sentry MUST be initialized before any other imports
import dotenv from 'dotenv';
import mongoose from 'mongoose';
import app from './app';
import { ServerConfig } from './config';
import { loadSecrets } from './config/secrets';
import logger from './utils/common/logger';
import { initCloudWatchLogs } from './utils/cloud-watch';
import redisClient from './config/redis-config';
import reserveEngine from './services/reserve-engine';

// Loads local .env file in dev; no-op in staging/prod containers (env vars come from docker-compose)
dotenv.config();

const startServer = async (): Promise<void> => {
  try {
    // Must run first — fetches secrets from AWS Secrets Manager and injects into process.env
    await loadSecrets();

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
