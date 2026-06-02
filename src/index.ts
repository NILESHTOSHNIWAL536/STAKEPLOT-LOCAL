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
import dns from 'dns';
import { ServerConfig, RedisClient, Logger } from './config';
import { loadSecrets } from './config/secrets';

// Loads local .env file in dev; no-op in staging/prod containers (env vars come from docker-compose)
dotenv.config();

const startServer = async (): Promise<void> => {
  try {
    // Must run first — fetches secrets from AWS Secrets Manager and injects into process.env
    await loadSecrets();

    app.listen(ServerConfig.PORT, '0.0.0.0', () => {
      Logger.info(`Server running on port: ${ServerConfig.PORT}`);
    });

    // Force Google DNS
    dns.setServers(["8.8.8.8", "8.8.4.4"]);

    // Connect both MongoDB databases
    await connectDatabases();
    // getModels?.();

    // Connect Redis (if configured)
    if (RedisClient && typeof RedisClient.connect === 'function') {
      await RedisClient.connect();
    }

    // Imported here (not at top level) so Bull queue gets REDIS_PASSWORD after loadSecrets() runs
    await import('./cron-jobs');

  } catch (error) {
    Logger.error('Server Start Error:', error);
    process.exit(1);
  }
};

startServer();
