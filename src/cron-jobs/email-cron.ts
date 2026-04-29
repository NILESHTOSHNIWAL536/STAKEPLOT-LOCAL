

import cron from 'node-cron';
import { getModels } from '../models/index-model';
import CreditCardQueue from '../services/bull-queue-service/queue';
    // const EmailScrapingService = require('../services/email-service');
import EmailScrapingService from '../services/email-service';
// Cron: Runs every 12 hours
// cron.schedule('0 0 */12 * * *', async () => {

// cron.schedule('*/10 * * * * *', async () => {
cron.schedule('0 40 17 * * *', async () => {
  try {
    console.log('⏳ Cron triggered at', new Date().toISOString());

    const { UserBankMap } = await getModels();

    const users = await UserBankMap.find().lean();

    for (const user of users) {
      const userId = user.userId;

      const emailBankMap: { email: string; bankIds: string[] }[] = [];

      console.log('👉 Processing user:', userId);

      for (const mapping of user.mappings || []) {
        if (!mapping.email) continue;

        console.log(`   📧 ${mapping.email}`, mapping.creditCardIds);

        emailBankMap.push({
          email: mapping.email,
          bankIds: mapping.creditCardIds || [],
        });
      }

      if (emailBankMap.length === 0) continue;

      console.log(`🚀 Adding job for user ${userId}`);
      console.log('Email-Bank Map:', emailBankMap);

      for (const item of emailBankMap) {
            const { email, bankIds } = item;

            console.log(`📩 Scraping ${email}`, bankIds);

            await EmailScrapingService.scrapeEmailsByBankId(
              userId.toString(),
              bankIds,
              email
            );
          }

      // await CreditCardQueue.add(
      //   {
      //     userId,
      //     emailBankMap, // 🔥 multiple emails inside one job
      //   },
      //   {
      //     jobId: userId.toString(), // ✅ prevent duplicate job per user
      //     removeOnComplete: true,
      //     removeOnFail: true,
      //   }
      // );

    }

    console.log('✅ Cron executed\n');
    console.log('-----------------------------------');

  } catch (error) {
    console.error('❌ Cron job error:', error);
  }
});


// 👇 This empty export forces TS to treat this file as a module
export {};
