// dbConnections.js
const mongoose = require('mongoose');
const { ServerConfig } = require('./config');
const Logger = require('./logger');

const connectDatabases = async () => {
  const mainDB = await mongoose.createConnection(ServerConfig.MAIN_MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });

  const emailDB = await mongoose.createConnection(ServerConfig.EMAIL_MONGO_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  });

  Logger.info('Connected to both databases');
  return { mainDB, emailDB };
};

module.exports = connectDatabases;
