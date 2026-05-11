// const express = require('express');
// const { securityMiddleware } = require('./middlewares/security/security');
// const { corsMiddleware } = require('./middlewares/security/cors');
// const { notFoundHandler, globalErrorHandler } = require('./middlewares/security/errorHandlers');
// const emailRoutes = require('./routes/email-routes');

// const app = express();

// // Disable X-Powered-By header globally
// app.disable('x-powered-by');

// // ✅ Apply middlewares
// securityMiddleware(app);
// corsMiddleware(app);

// // ✅ Main routes
// app.use('/api', emailRoutes);

// // ✅ Health check
// app.get('/', (req, res) => {
//   res.json({ status: 'healthy', message: 'Server is running' });
// });

// // ✅ 404 & Error handlers
// app.use(notFoundHandler);
// app.use(globalErrorHandler);

// module.exports = app;
import express, { Application, Request, Response } from 'express';
import * as Sentry from '@sentry/node';
import { securityMiddleware } from './middlewares/security/security';
import { corsMiddleware } from './middlewares/security/cors';
import { notFoundHandler, globalErrorHandler } from './middlewares/security/errorHandlers';
import emailRoutes from './routes/email-routes';

const app: Application = express();

// Disable X-Powered-By header globally
app.disable('x-powered-by');

// ✅ Apply middlewares
securityMiddleware(app);
corsMiddleware(app);

// ✅ Main routes
app.use('/api', emailRoutes);

// ✅ Health check
app.get('/', (req: Request, res: Response) => {
  res.json({ status: 'healthy', message: 'Server is running' });
});

// ✅ 404 & Error handlers — Sentry must come before custom handlers
Sentry.setupExpressErrorHandler(app);
app.use(notFoundHandler);
app.use(globalErrorHandler);

export default app;
