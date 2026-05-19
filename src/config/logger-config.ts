// const winston = require('winston');
// const moment = require('moment-timezone');

// const transports = [new winston.transports.Console(), new winston.transports.File({ filename: 'logs/debug.log' })];

// // Only add CloudWatch transport in production
// if (process.env.NODE_ENV === 'production') {
//   const WinstonCloudWatch = require('winston-cloudwatch');

//   transports.push(
//     new WinstonCloudWatch({
//       logGroupName: 'Mobile-Server',
//       logStreamName: `NodeApp-${new Date().toISOString().split('T')[0]}`,
//       awsRegion: process.env.AWS_REGION,
//     })
//   );
// }

// const logger = winston.createLogger({
//   level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
//   format: winston.format.combine(
//     winston.format.timestamp({
//       format: () => moment().tz('Asia/Kolkata').format('YYYY-MM-DD HH:mm:ss'),
//     }),
//     winston.format.printf(({ timestamp, level, message, ...meta }) => {
//       let msg = typeof message === 'object' ? JSON.stringify(message, null, 2) : message;
//       if (Object.keys(meta).length) {
//         msg += ` | meta: ${JSON.stringify(meta, null, 2)}`;
//       }
//       return `[${timestamp}] ${level.toUpperCase()}: ${msg}`;
//     })
//   ),
//   transports,
// });

// module.exports = logger;
import winston, { Logger as WinstonLogger, transport } from 'winston';
import moment from 'moment-timezone';

// Base transports: console + file
const transportsList: transport[] = [
  new winston.transports.Console(),
  new winston.transports.File({ filename: 'logs/debug.log' }),
];

// Only add CloudWatch transport in production
if (process.env.NODE_ENV === 'production') {
  // No types for winston-cloudwatch -> use require with any
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const WinstonCloudWatch = require('winston-cloudwatch') as any;

  transportsList.push(
    new WinstonCloudWatch({
      logGroupName: 'Mobile-Server',
      logStreamName: `NodeApp-${new Date().toISOString().split('T')[0]}`,
      awsRegion: process.env.AWS_REGION,
    })
  );
}

const Logger: WinstonLogger = winston.createLogger({
  level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
  format: winston.format.combine(
    winston.format.timestamp({
      format: () => moment().tz('Asia/Kolkata').format('YYYY-MM-DD HH:mm:ss'),
    }),
    winston.format.printf(({ timestamp, level, message, ...meta }) => {
      let msg =
        typeof message === 'object'
          ? JSON.stringify(message, null, 2)
          : (message as string);

      if (Object.keys(meta).length) {
        msg += ` | meta: ${JSON.stringify(meta, null, 2)}`;
      }

      return `[${timestamp}] ${String(level).toUpperCase()}: ${msg}`;
    })
  ),
  transports: transportsList,
});

export default Logger;
