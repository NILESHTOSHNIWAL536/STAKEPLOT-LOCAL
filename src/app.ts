import express, { Application, Request, Response } from 'express';
import * as Sentry from '@sentry/node';
import { securityMiddleware } from './middlewares/security/security';
import { corsMiddleware } from './middlewares/security/cors';
import { metricsMiddleware } from './middlewares/security/metrics';
import { notFoundHandler, globalErrorHandler } from './middlewares/security/errorHandlers';
import webHook from './utils/webHook';
import apiRoutes from './routes';
import * as WealthscapeController from './controllers/wealthscape-controller';

const app: Application = express();

// ✅ Must come before any middleware using req.ip
app.set('trust proxy', 1);

// Disable X-Powered-By header globally
app.disable('x-powered-by');

// ✅ Apply middlewares
corsMiddleware(app);
securityMiddleware(app);
metricsMiddleware(app);

// ✅ Routes
app.use('/api', apiRoutes);

app.get('/', (req: Request, res: Response) => {
  res.json({ status: 'healthy', message: 'Server is running' });
});

// ✅ Wealthscape webhooks
app.post('/Wealthscape/Notification', WealthscapeController.handleConsentNotification);
app.post('/Wealthscape/DataReady', WealthscapeController.handleDataReadyNotification);

// ✅ Error handling — Sentry must come before custom handlers
Sentry.setupExpressErrorHandler(app);
app.use(notFoundHandler);
app.use(globalErrorHandler);

export default app;
