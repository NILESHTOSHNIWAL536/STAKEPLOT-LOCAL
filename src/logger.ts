// const { createLogger, format, transports } = require('winston');
// const { combine, timestamp, printf, colorize } = format;

// const logFormat = printf(({ level, message, timestamp }) => {
//   return `${timestamp} [${level}]: ${message}`;
// });

// const Logger = createLogger({
//   level: 'info',
//   format: combine(
//     colorize(),
//     timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
//     logFormat
//   ),
//   transports: [
//     new transports.Console(),
//     new transports.File({ filename: 'logs/error.log', level: 'error' }),
//     new transports.File({ filename: 'logs/combined.log' })
//   ],
// });

// module.exports = Logger;
import { createLogger, format, transports, Logger as WinstonLogger } from 'winston';

const { combine, timestamp, printf, colorize } = format;

const logFormat = printf(({ level, message, timestamp }) => {
  return `${timestamp} [${level}]: ${message}`;
});

const Logger: WinstonLogger = createLogger({
  level: 'info',
  format: combine(
    colorize(),
    timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    logFormat
  ),
  transports: [
    new transports.Console(),
    new transports.File({ filename: 'logs/error.log', level: 'error' }),
    new transports.File({ filename: 'logs/combined.log' }),
  ],
});

export default Logger;
