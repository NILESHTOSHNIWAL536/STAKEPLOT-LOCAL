import express, { Application, Request, Response } from 'express';
import { securityMiddleware } from './middlewares/security/security.js';
import { corsMiddleware } from './middlewares/security/cors.js';
import { metricsMiddleware } from './middlewares/security/metrics.js';
import {
  notFoundHandler,
  globalErrorHandler
} from './middlewares/security/errorHandlers.js';
import webHook from './utils/webHook.ts';
import apiRoutes from './routes/index.js';

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

app.post('/FI/Notification', webHook);

// ✅ Error handling
app.use(notFoundHandler);
app.use(globalErrorHandler);

export default app;
