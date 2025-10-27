const { userSchema } = require("./user-model");
const { sessionSchema } = require("./session-model");
const { googleAuthSchema } = require("./google-auth");
const { scrapeResultSchema } = require("./scrape-result");

// Export functions to get models AFTER DB is connected
async function getModels() {
  if (!global.mainDB || !global.emailDB) {
    throw new Error("Database not connected yet!");
  }

  return {
    User: global.mainDB.model("User", userSchema),
    Session: global.mainDB.model("Session",sessionSchema),
    GoogleAuth: global.emailDB.model("googleAuth",googleAuthSchema),
    ScrapedEmail: global.emailDB.model("scrapeResult",scrapeResultSchema),
  };
}

module.exports = { getModels };
