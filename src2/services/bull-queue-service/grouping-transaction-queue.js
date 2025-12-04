const Queue = require('bull');
const saveGroupedTransactions = require("../../utils/helpers/saveGroupedTransactions");


// Load Redis config from .env or fallback
const REDIS_HOST = process.env.REDIS_HOST || '127.0.0.1';
const REDIS_PORT = process.env.REDIS_PORT || 6379;
const REDIS_PASSWORD = process.env.REDIS_PASSWORD || '';

// Create the Bull queue with Redis credentials
const groupingQueue = new Queue('transaction-grouping', {
  redis: {
    host: REDIS_HOST,
    port: REDIS_PORT,
    password: REDIS_PASSWORD,
  }
});

groupingQueue.process(async (job) => {
  const { userId } = job.data;
  try {
    await saveGroupedTransactions(userId);
  } catch (error) {
    console.error(`Error processing user ${userId}:`, error);
  }
});

module.exports = groupingQueue;
