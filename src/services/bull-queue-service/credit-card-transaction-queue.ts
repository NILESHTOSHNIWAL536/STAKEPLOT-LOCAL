import CreditCardQueue from './queue';
import EmailScrapingService from '../../services/email-service';
console.log(' Worker started (bull queue)');

CreditCardQueue.process(async (job) => {
  const { userId, emailBankMap } = job.data;
  console.log(`Processing user ${userId}`);

  try {
    for (const item of emailBankMap) {
      const { email, bankIds } = item;
    }
  } catch (error) {
    throw error;
  }
});

export default CreditCardQueue;
