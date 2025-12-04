import winston from "winston";
import moment from "moment-timezone";
import type { transport } from "winston";

// ✅ Base transports
const transports: transport[] = [
  new winston.transports.Console(),
  new winston.transports.File({ filename: "logs/debug.log" }),
];

// ✅ Only add CloudWatch transport in production
if (process.env.NODE_ENV === "production") {
  // Dynamic import keeps dev builds clean
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const WinstonCloudWatch = require("winston-cloudwatch");

  transports.push(
    new WinstonCloudWatch({
      logGroupName: "Mobile-Server",
      logStreamName: `NodeApp-${new Date().toISOString().split("T")[0]}`,
      awsRegion: process.env.AWS_REGION as string,
    })
  );
}

// ✅ Logger instance
export const logger = winston.createLogger({
  level: process.env.NODE_ENV === "production" ? "info" : "debug",

  format: winston.format.combine(
    winston.format.timestamp({
      format: (): string =>
        moment().tz("Asia/Kolkata").format("YYYY-MM-DD HH:mm:ss"),
    }),

    winston.format.printf(
      ({ timestamp, level, message, ...meta }: winston.Logform.TransformableInfo) => {
        let msg =
          typeof message === "object"
            ? JSON.stringify(message, null, 2)
            : String(message);

        if (Object.keys(meta).length) {
          msg += ` | meta: ${JSON.stringify(meta, null, 2)}`;
        }

        return `[${timestamp}] ${level.toUpperCase()}: ${msg}`;
      }
    )
  ),

  transports,
});
