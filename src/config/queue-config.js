const Queue = require('bull');

// Load Redis config from .env or fallback
const REDIS_HOST = process.env.REDIS_HOST || '127.0.0.1';
const REDIS_PORT = process.env.REDIS_PORT || 6379;
const REDIS_PASSWORD = process.env.REDIS_PASSWORD || '';

const categoryUpdatedQueue = new Queue('category-updated', {
  redis: {
    host: REDIS_HOST,
    port: REDIS_PORT,
    password: REDIS_PASSWORD,
  },
});

module.exports = categoryUpdatedQueue;
