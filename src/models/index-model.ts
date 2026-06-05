import { Connection, Model } from 'mongoose';
import { googleAuthSchema, IGoogleAuth } from './google-auth';
import { scrapeResultSchema, IScrapeResult } from './scrape-result';
import { IUserBankMap, userBankMapSchema } from './user-bankmap';
import { IStatementPassword, statementPasswordSchema } from './statement-password';
import {
  IPendingStatementExtraction,
  pendingStatementExtractionSchema,
} from './pending-statement-extraction';

export interface IModels {
  GoogleAuth: Model<IGoogleAuth>;
  ScrapedEmail: Model<IScrapeResult>;
  UserBankMap: Model<IUserBankMap>;
  StatementPassword: Model<IStatementPassword>;
  PendingStatementExtraction: Model<IPendingStatementExtraction>;
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
  const StatementPassword = emailDB.models.statementPassword || emailDB.model<IStatementPassword>('statementPassword', statementPasswordSchema);
  const PendingStatementExtraction =
    emailDB.models.pendingStatementExtraction ||
    emailDB.model<IPendingStatementExtraction>(
      'pendingStatementExtraction',
      pendingStatementExtractionSchema
    );

  return {
    GoogleAuth: GoogleAuthModel,
    ScrapedEmail: ScrapedEmailModel,
    UserBankMap: UserBankMap,
    StatementPassword,
    PendingStatementExtraction,
  };
}
