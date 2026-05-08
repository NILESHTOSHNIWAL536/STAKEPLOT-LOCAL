import { createClient, RedisClientType } from "redis";
import logger from "../utils/common/logger";
import dotenv from "dotenv";

dotenv.config();

const redisClient: RedisClientType = createClient({
  socket: {
    host: process.env.REDIS_HOST || "127.0.0.1",
    port: process.env.REDIS_PORT ? Number(process.env.REDIS_PORT) : 6379,
    reconnectStrategy: (retries: number) => Math.min(retries * 50, 2000),
  },
});

// Handle Redis connection errors
redisClient.on("error", (err: Error) => logger.error("Redis Error:", err));
redisClient.on("connect", () => logger.info("Redis Connected!"));
redisClient.on("reconnecting", () => logger.info("Redis Reconnecting..."));

export default redisClient;
