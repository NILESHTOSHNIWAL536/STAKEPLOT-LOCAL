import CreditCardQueue from './queue';
import EmailScrapingService from '../../services/email-service';

CreditCardQueue.process(async (job) => {
  const { userId, emailBankMap } = job.data as { userId: string; emailBankMap: Array<{ email: string; bankIds: string[] }> };
  try {
    for (const item of emailBankMap) {
      const { email, bankIds } = item;
      await EmailScrapingService.scrapeEmailsByBankId(userId.toString(), bankIds, email);
    }
  } catch (error) {
    throw error;
  }
});

export default CreditCardQueue;
