// // const Queue = require('bull');
// const EmailScrapingService = require('../email-service');

// // // Load Redis config from .env or fallback
// // const REDIS_HOST = process.env.REDIS_HOST || '127.0.0.1';
// // const REDIS_PORT = process.env.REDIS_PORT || 6379;
// // const REDIS_PASSWORD = process.env.REDIS_PASSWORD || '';

// // // Create the Bull queue with Redis credentials
// // const CreditCardQueue = new Queue('email-scraping', {
// //   redis: {
// //     host: REDIS_HOST,
// //     port: REDIS_PORT,
// //     password: REDIS_PASSWORD,
// //   },
// // });

// // CreditCardQueue.process(async (job) => {
// //   const { userId, bankIds } = job.data;
// //   try {
// //     //  new Promise((resolve) => setTimeout(resolve, 4000));
// //     await EmailScrapingService.scrapeEmailsByBankId(userId, bankIds);
// //   } catch (error) {
// //     console.error(`Error processing user ${userId}:`, error);
// //   }
// // });

// // module.exports = CreditCardQueue;

// import Queue from 'bull';
// import EmailScrapingService from '../email-service';

// const REDIS_HOST = process.env.REDIS_HOST || '127.0.0.1';
// const REDIS_PORT = Number(process.env.REDIS_PORT) || 6379;
// const REDIS_PASSWORD = process.env.REDIS_PASSWORD || '';

// const CreditCardQueue = new Queue('email-scraping', {
//   redis: {
//     host: REDIS_HOST,
//     port: REDIS_PORT,
//     password: REDIS_PASSWORD,
//   },
// });

// CreditCardQueue.process(async (job) => {
//   const { userId, emailBankMap } = job.data as {
//     userId: string;
//     emailBankMap: { email: string; bankIds: string[] }[];
//   };

//   console.log(`🚀 Processing user ${userId}`);


//   try {
//     for (const item of emailBankMap) {
//       const { email, bankIds } = item;

//       console.log(`📩 Scraping ${email}`, bankIds,userId);

      // await EmailScrapingService.scrapeEmailsByBankId(
      //   userId,
      //   bankIds,
      //   email
      // );
    // }

//     console.log(`✅ Done for user ${userId}`);

//   } catch (error) {
//     console.error(`❌ Error processing user ${userId}:`, error);
//     throw error; // 🔥 required for retry
//   }
// });

// export default CreditCardQueue;

import CreditCardQueue from './queue';
console.log('🔥 Worker started (bull queue)'); // 👈 ADD THIS

CreditCardQueue.process(async (job) => {
  const { userId, emailBankMap } = job.data;

  console.log(`🚀 Processing user ${userId}`);

  try {
    for (const item of emailBankMap) {
      const { email, bankIds } = item;
    }
  } catch (error) {
    throw error;
  }
});

export default CreditCardQueue;