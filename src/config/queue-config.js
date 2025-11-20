const { Queue } = require("bullmq");

const REDIS_HOST = process.env.REDIS_HOST;
const REDIS_PORT = Number(process.env.REDIS_PORT);
const REDIS_PASSWORD = process.env.REDIS_PASSWORD;

const categoryUpdatedQueue = new Queue("category-updated", {
  connection: {
    host: REDIS_HOST,
    port: REDIS_PORT,
    password: REDIS_PASSWORD,
  },
});

categoryUpdatedQueue.on("ready", () => {
  console.log("📦 Queue client connected");
});

categoryUpdatedQueue.on("error", (err) => {
  console.error("❌ Queue connection error:", err);
});

module.exports = categoryUpdatedQueue;
