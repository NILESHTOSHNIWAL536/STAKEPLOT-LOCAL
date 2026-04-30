import cron from 'node-cron';
import { getModels } from '../models/index-model';
import CreditCardQueue from '../services/bull-queue-service/queue';

// Cron: Runs every 12 hours
cron.schedule(
  '0 0 */12 * * *',
  async () => {
    try {
      // FETCH user from the DB
      const { UserBankMap } = await getModels();
      const users = await UserBankMap.find().lean();

      for (const user of users) {
        const userId = user.userId;

        // CREATE emailBankMap against userId
        const emailBankMap: { email: string; bankIds: string[] }[] = [];
        for (const mapping of user.mappings || []) {
          if (!mapping.email) continue;
          emailBankMap.push({
            email: mapping.email,
            bankIds: mapping.creditCardIds || [],
          });
        }

        // IF emailBankMap is empty, continue
        if (emailBankMap.length === 0) continue;

        // ADD emailBankMap, userId to the QUEUE
        await CreditCardQueue.add(
          {
            userId,
            emailBankMap,
          },
          {
            jobId: userId.toString(),
            removeOnComplete: true,
            removeOnFail: true,
          }
        );
      }
    } catch (error) {
      console.error('Cron job error:', error);
    }
  },
  {
    timezone: 'Asia/Kolkata',
  }
);
