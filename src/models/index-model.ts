import { Connection, Model } from 'mongoose';
import { googleAuthSchema, IGoogleAuth } from './google-auth';
import { scrapeResultSchema, IScrapeResult } from './scrape-result';
import { IUserBankMap, userBankMapSchema } from './user-bankmap';

export interface IModels {
  GoogleAuth: Model<IGoogleAuth>;
  ScrapedEmail: Model<IScrapeResult>;
  UserBankMap: Model<IUserBankMap>;
}

export async function getModels(): Promise<IModels> {
  const mainDB = (global as any).mainDB as Connection | undefined;
  const emailDB = (global as any).emailDB as Connection | undefined;

  if (!mainDB || !emailDB) {
    throw new Error('Database not connected yet!');
  }

  // Prevent OverwriteModelError
  const GoogleAuthModel = emailDB.models.googleAuth || emailDB.model<IGoogleAuth>('googleAuth', googleAuthSchema);

  const ScrapedEmailModel = emailDB.models.scrapeResult || emailDB.model<IScrapeResult>('scrapeResult', scrapeResultSchema);

  const UserBankMap = emailDB.models.userBankMap || emailDB.model<IUserBankMap>('userBankMap', userBankMapSchema);

  return {
    GoogleAuth: GoogleAuthModel,
    ScrapedEmail: ScrapedEmailModel,
    UserBankMap: UserBankMap,
  };
}
