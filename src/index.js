const mongoose = require('mongoose');
const dotenv = require('dotenv');
const app = require('./app');
const { ServerConfig, RedisClient, Logger } = require('./config');
dotenv.config();

const startServer = async () => {
  try {
    app.listen(ServerConfig.PORT, '0.0.0.0', async () => {
      Logger.info(`Server running on port: ${ServerConfig.PORT}`);
    });

    const mainDB = await mongoose.connect(ServerConfig.MAIN_MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    const emailDB = await mongoose.createConnection(ServerConfig.EMAIL_MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    global.MainDB = mainDB;
    global.EmailDB = emailDB;
    await RedisClient.connect();
  } catch (error) {
    console.error('Server Start Error:', error);
    process.exit(1);
  }
};

startServer();
