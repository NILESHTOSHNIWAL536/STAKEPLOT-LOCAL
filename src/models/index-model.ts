// const { userSchema } = require("./user-model");
// const { sessionSchema } = require("./session-model");
// const { googleAuthSchema } = require("./google-auth");
// const { scrapeResultSchema } = require("./scrape-result");

// // Export functions to get models AFTER DB is connected
// async function getModels() {
//   if (!global.mainDB || !global.emailDB) {
//     throw new Error("Database not connected yet!");
//   }

//   return {
//     User: global.mainDB.model("User", userSchema),
//     Session: global.mainDB.model("Session",sessionSchema),
//     GoogleAuth: global.emailDB.model("googleAuth",googleAuthSchema),
//     ScrapedEmail: global.emailDB.model("scrapeResult",scrapeResultSchema),
//   };
// }

// module.exports = { getModels };


 import { Connection, Model } from 'mongoose';
import { googleAuthSchema, IGoogleAuth } from './google-auth';
import { scrapeResultSchema, IScrapeResult } from './scrape-result';

export interface IModels {
  GoogleAuth: Model<IGoogleAuth>;
  ScrapedEmail: Model<IScrapeResult>;
}

export async function getModels(): Promise<IModels> {
  // 👇 Cast global.mainDB / emailDB so TS stops complaining
  const mainDB = (global as any).mainDB as Connection | undefined;
  const emailDB = (global as any).emailDB as Connection | undefined;

  if (!mainDB || !emailDB) {
    throw new Error('Database not connected yet!');
  }

  return {
    // TS now knows mainDB is a Connection, and we cast result Models
    GoogleAuth: emailDB.model('googleAuth', googleAuthSchema) as Model<IGoogleAuth>,
    ScrapedEmail: emailDB.model('scrapeResult', scrapeResultSchema) as Model<IScrapeResult>,
  };
}
