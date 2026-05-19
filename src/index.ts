// const mongoose = require('mongoose');
// const dotenv = require('dotenv');
// const app = require('./app');
// const connectDatabases = require('./dbConnections');
// const { ServerConfig, RedisClient, Logger } = require('./config');
// const {getModels}=require('./models/index-model');

// dotenv.config();

// const startServer = async () => {
//   try {
//     app.listen(ServerConfig.PORT, '0.0.0.0', async () => {
//       Logger.info(`Server running on port: ${ServerConfig.PORT}`);
//     });

//     await connectDatabases();
//     // getModels();
  
//     await RedisClient.connect();
//     require("./cron-jobs/");
//   } catch (error) {
//     console.error('Server Start Error:', error);
//     process.exit(1);
//   }
// };

// startServer();

import './instrument'; // Sentry MUST be initialized before any other imports
import dotenv from 'dotenv';
import app from './app';
import connectDatabases from './dbConnections';
import { ServerConfig, RedisClient, Logger } from './config';
import { loadSecrets } from './config/secrets';
import './cron-jobs';

// Loads local .env file in dev; no-op in staging/prod containers (env vars come from docker-compose)
dotenv.config();

const startServer = async (): Promise<void> => {
  try {
    // Must run first — fetches secrets from AWS Secrets Manager and injects into process.env
    await loadSecrets();

    app.listen(ServerConfig.PORT, '0.0.0.0', () => {
      Logger.info(`Server running on port: ${ServerConfig.PORT}`);
    });

    // Connect both MongoDB databases
    await connectDatabases();
    // getModels?.();

    // Connect Redis (if configured)
    if (RedisClient && typeof RedisClient.connect === 'function') {
      await RedisClient.connect();
    }

    // Load cron jobs (TS style dynamic import)
    
  } catch (error) {
    Logger.error('Server Start Error:', error);
    process.exit(1);
  }
};

startServer();
