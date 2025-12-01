const express = require('express');
const { securityMiddleware } = require('./middlewares/security/security');
const { corsMiddleware } = require('./middlewares/security/cors');
const { metricsMiddleware } = require('./middlewares/security/metrics');
const { notFoundHandler, globalErrorHandler } = require('./middlewares/security/errorHandlers');
const webHook  = require('./utils/webHook');
const apiRoutes = require('./routes');

const app = express();

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
app.get('/', (req, res) => res.json({ status: 'healthy', message: 'Server is running' }));
app.post('/FI/Notification', webHook);

// ✅ Error handling
app.use(notFoundHandler);
app.use(globalErrorHandler);

module.exports = app;
