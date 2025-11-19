const { Queue } = require("bullmq");

console.log("Queue Config Loaded");
console.log("REDIS_HOST:", process.env.REDIS_HOST);
console.log("REDIS_PORT:", process.env.REDIS_PORT);
console.log("REDIS_PASSWORD:", process.env.REDIS_PASSWORD);

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
