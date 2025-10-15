const mongoose = require('mongoose');
const dotenv = require('dotenv');
const app = require('./app');
const connectDatabases = require('./dbConnections');
const { ServerConfig, RedisClient, Logger } = require('./config');
const {getModels}=require('./models/index-model');

dotenv.config();

const startServer = async () => {
  try {
    app.listen(ServerConfig.PORT, '0.0.0.0', async () => {
      Logger.info(`Server running on port: ${ServerConfig.PORT}`);
    });

    await connectDatabases();
    // getModels();
    

    await RedisClient.connect();
  } catch (error) {
    console.error('Server Start Error:', error);
    process.exit(1);
  }
};

startServer();
