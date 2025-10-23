const Queue = require('bull');
const EmailScrapingService = require('../email-service');

// Load Redis config from .env or fallback
const REDIS_HOST = process.env.REDIS_HOST || '127.0.0.1';
const REDIS_PORT = process.env.REDIS_PORT || 6379;
const REDIS_PASSWORD = process.env.REDIS_PASSWORD || '';

// Create the Bull queue with Redis credentials
const CreditCardQueue = new Queue('email-scraping', {
  redis: {
    host: REDIS_HOST,
    port: REDIS_PORT,
    password: REDIS_PASSWORD,
  },
});

CreditCardQueue.process(async (job) => {
  const { userId, bankIds } = job.data;
  try {
    //  new Promise((resolve) => setTimeout(resolve, 4000));
    await EmailScrapingService.scrapeEmailsByBankId(userId, bankIds);
  } catch (error) {
    console.error(`Error processing user ${userId}:`, error);
  }
});

module.exports = CreditCardQueue;
