// dbConnections.js
const mongoose = require('mongoose');
const { ServerConfig } = require('./config');
const { userSchema } = require('./models/user-model');
const { sessionSchema } = require('./models/session-model');
const { scrapeResultSchema } = require('./models/scrape-result');
const { googleAuthSchema } = require('./models/google-auth');
const Logger = require('./logger');

// const connectDatabases = async () => {
//   const mainDB = await mongoose.createConnection(ServerConfig.MAIN_MONGO_URI, {
//     useNewUrlParser: true,
//     useUnifiedTopology: true,
//   });

//   const emailDB = await mongoose.createConnection(ServerConfig.EMAIL_MONGO_URI, {
//     useNewUrlParser: true,
//     useUnifiedTopology: true,
//   });

//   return { mainDB, emailDB };
// };

function connectDatabases() {
  return new Promise((resolve, reject) => {
    const mainDB = mongoose.createConnection(ServerConfig.MAIN_MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    const emailDB = mongoose.createConnection(ServerConfig.EMAIL_MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    mainDB.once("open", () => {
      global.mainDB = mainDB;
      global.mainDB.model("User", userSchema);
      global.mainDB.model("Session", sessionSchema);
      global.User= global.mainDB.model("User");
      global.Session= global.mainDB.model("Session");
      Logger.info("✅ Connected to mainDB");
    });

    emailDB.once("open", () => {
      global.emailDB = emailDB;
      global.emailDB.model("googleAuth", googleAuthSchema);
      global.emailDB.model("scrapeResult", scrapeResultSchema);
      Logger.info("✅ Connected to emailDB");
    });

    mainDB.once("open", () => {
      emailDB.once("open", () => resolve({ mainDB, emailDB }));
    });

    mainDB.on("error", reject);
    emailDB.on("error", reject);
  });
}


module.exports = connectDatabases;
