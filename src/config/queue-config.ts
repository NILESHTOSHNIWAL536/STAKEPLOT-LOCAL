import { Queue, QueueEvents } from "bullmq";

// Deferred so process.env.REDIS_PASSWORD is populated by loadSecrets() before connection.
const getConnection = () => ({
  host: process.env.REDIS_HOST || "127.0.0.1",
  port: process.env.REDIS_PORT ? Number(process.env.REDIS_PORT) : 6379,
  password: process.env.REDIS_PASSWORD || undefined,
});

let _queue: Queue<any> | null = null;
let _events: QueueEvents | null = null;

const getQueue = (): Queue<any> => {
  if (!_queue) _queue = new Queue("category-updated", { connection: getConnection() });
  return _queue;
};

const getQueueEvents = (): QueueEvents => {
  if (_events) return _events;
  _events = new QueueEvents("category-updated", { connection: getConnection() });
  _events.on("waiting", () => console.log("📦 Queue is online & waiting for jobs"));
  _events.on("failed", ({ jobId, failedReason }) => console.error(`❌ Job ${jobId} failed:`, failedReason));
  return _events;
};

export const categoryUpdatedQueue = new Proxy({} as Queue<any>, {
  get(_target, prop: string) {
    const q = getQueue();
    const value = (q as any)[prop];
    return typeof value === 'function' ? value.bind(q) : value;
  },
});

export const categoryUpdatedQueueEvents = new Proxy({} as QueueEvents, {
  get(_target, prop: string) {
    const e = getQueueEvents();
    const value = (e as any)[prop];
    return typeof value === 'function' ? value.bind(e) : value;
  },
});
