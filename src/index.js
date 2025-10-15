const mongoose = require('mongoose');
const dotenv = require('dotenv');
const app = require('./app');
const { userSchema } = require('./models/user-model');
const { sessionSchema } = require('./models/session-model');
const { ServerConfig, RedisClient, Logger } = require('./config');
dotenv.config();

const startServer = async () => {
  try {
    app.listen(ServerConfig.PORT, '0.0.0.0', async () => {
      Logger.info(`Server running on port: ${ServerConfig.PORT}`);
    });

    const connectDatabases = async () => {
      const mainDB = await mongoose.createConnection(ServerConfig.MAIN_MONGO_URI, {
        useNewUrlParser: true,
        useUnifiedTopology: true,
      });

      const emailDB = await mongoose.createConnection(ServerConfig.EMAIL_MONGO_URI, {
        useNewUrlParser: true,
        useUnifiedTopology: true,
      });

      mainDB.model('User', userSchema);
      mainDB.model('Session', sessionSchema);

      Logger.info('Connected to both databases');
      global.mainDB = mainDB; // ✅ make globally available
      global.emailDB = emailDB;

      return { mainDB, emailDB };
    };
    connectDatabases();

    await RedisClient.connect();
  } catch (error) {
    console.error('Server Start Error:', error);
    process.exit(1);
  }
};

startServer();
