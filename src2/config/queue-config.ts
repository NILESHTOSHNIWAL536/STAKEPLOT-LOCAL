import { Queue, QueueEvents } from "bullmq";
import dotenv from "dotenv";

dotenv.config();

const REDIS_HOST: string = process.env.REDIS_HOST || "127.0.0.1";
const REDIS_PORT: number = process.env.REDIS_PORT
  ? Number(process.env.REDIS_PORT)
  : 6379;

const REDIS_PASSWORD: string | undefined =
  process.env.REDIS_PASSWORD || undefined;

export const categoryUpdatedQueue = new Queue("category-updated", {
  connection: {
    host: REDIS_HOST,
    port: REDIS_PORT,
    password: REDIS_PASSWORD,
  },
});

// ✅ Queue events are handled here (TYPE SAFE)
const categoryUpdatedQueueEvents = new QueueEvents("category-updated", {
  connection: {
    host: REDIS_HOST,
    port: REDIS_PORT,
    password: REDIS_PASSWORD,
  },
});

categoryUpdatedQueueEvents.on("waiting", () => {
  console.log("📦 Queue is online & waiting for jobs");
});

categoryUpdatedQueueEvents.on("failed", ({ jobId, failedReason }) => {
  console.error(`❌ Job ${jobId} failed:`, failedReason);
});
