import { createClient, RedisClientType } from "redis";
import logger from "../utils/common/logger";

let _instance: RedisClientType | null = null;

// Proxy so all existing call sites work unchanged.
// Real client created inside connect() — after loadSecrets() has injected
// REDIS_PASSWORD into process.env — not at module-import time.
const redisClient = new Proxy({} as RedisClientType, {
  get(_target, prop: string) {
    if (prop === 'connect') {
      return async () => {
        _instance = createClient({
          socket: {
            host: process.env.REDIS_HOST || "127.0.0.1",
            port: process.env.REDIS_PORT ? Number(process.env.REDIS_PORT) : 6379,
            reconnectStrategy: (retries: number) => Math.min(retries * 50, 2000),
          },
          password: process.env.REDIS_PASSWORD || undefined,
        });
        _instance.on("error", (err: Error) => logger.error("Redis Error:", err));
        _instance.on("connect", () => logger.info("Redis Connected!"));
        _instance.on("reconnecting", () => logger.info("Redis Reconnecting..."));
        await _instance.connect();
      };
    }
    if (!_instance) throw new Error(`Redis not connected — call connect() before accessing '${prop}'`);
    const value = (_instance as any)[prop];
    return typeof value === 'function' ? value.bind(_instance) : value;
  },
});

export default redisClient;
