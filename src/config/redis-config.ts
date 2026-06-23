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
import ServerConfig from './server-config';

let _instance: RedisClientType | null = null;

// Proxy so all existing call sites (redisClient.del(), etc.) work unchanged.
// The real client is created inside connect() — after loadSecrets() has injected
// REDIS_PASSWORD into process.env — not at module-import time.
const redisClient = new Proxy({} as RedisClientType, {
  get(_target, prop: string) {
    if (prop === 'connect') {
      return async () => {
        if (_instance?.isOpen) return;

        _instance = createClient({
          socket: {
            host: '127.0.0.1',
            port:  6379,
            reconnectStrategy: (retries) => Math.min(retries * 50, 2000),
          },
          // password: ServerConfig.REDIS_PASSWORD || undefined,
        });
        _instance.on('error', (err) => console.error(`Redis Error: ${err.message}`));
        _instance.on('connect', () => console.log('Redis Connected!'));
        _instance.on('reconnecting', () => console.log('Redis Reconnecting...'));
        await _instance.connect();
      };
    }
    if (!_instance) throw new Error(`Redis not connected — call connect() before accessing '${prop}'`);
    const value = (_instance as any)[prop];
    return typeof value === 'function' ? value.bind(_instance) : value;
  },
});

export default redisClient;
