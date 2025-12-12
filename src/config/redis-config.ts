// const { createClient } = require('redis');

// const redisClient = createClient({
//   socket: {
//     host: process.env.REDIS_HOST || '127.0.0.1',
//     port: process.env.REDIS_PORT || 6379,
//     reconnectStrategy: (retries) => Math.min(retries * 50, 2000),
//   },
//   password: process.env.REDIS_PASSWORD || null,
// });

// // Handle Redis connection errors
// redisClient.on('error', (err) => console.error('Redis Error:', err));
// redisClient.on('connect', () => console.log('Redis Connected!'));
// redisClient.on('reconnecting', () => console.log('Redis Reconnecting...'));

// module.exports = redisClient;


import { createClient, RedisClientType } from 'redis';

const redisClient: RedisClientType = createClient({
  socket: {
    host: process.env.REDIS_HOST || '127.0.0.1',
    port: Number(process.env.REDIS_PORT) || 6379,
    reconnectStrategy: (retries) => Math.min(retries * 50, 2000),
  },
  password: process.env.REDIS_PASSWORD || undefined,
});

// Handle Redis connection events
redisClient.on('error', (err) => console.error('Redis Error:', err));
redisClient.on('connect', () => console.log('Redis Connected!'));
redisClient.on('reconnecting', () => console.log('Redis Reconnecting...'));

export default redisClient;
