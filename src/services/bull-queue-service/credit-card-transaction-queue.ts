import CreditCardQueue from './queue';
import EmailScrapingService from '../../services/email-service';
console.log(' Worker started (bull queue)');

CreditCardQueue.process(async (job) => {
  const { userId, emailBankMap } = job.data;
  console.log(`Processing user ${userId}`);

  try {
    for (const item of emailBankMap) {
      const { email, bankIds } = item;
      console.log(`Scraping for the email: ${email} with bankIds: ${bankIds}`);
      await EmailScrapingService.scrapeEmailsByBankId(userId.toString(), bankIds, email);
    }

    console.log(`Done for user ${userId}`);
  } catch (error) {
    console.error(`Error processing user ${userId}:`, error);
    throw error;
  }
});

export default CreditCardQueue;
