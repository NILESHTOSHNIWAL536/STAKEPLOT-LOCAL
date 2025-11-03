const express = require('express');
const { securityMiddleware } = require('./middlewares/security/security');
const { corsMiddleware } = require('./middlewares/security/cors');
const { metricsMiddleware } = require('./middlewares/security/metrics');
const { notFoundHandler, globalErrorHandler } = require('./middlewares/security/errorHandlers');
const { webHook } = require('./utils/webHook');
const apiRoutes = require('./routes');

const app = express();

// Disable X-Powered-By header globally
app.disable('x-powered-by');

// ✅ Apply middlewares
securityMiddleware(app);
corsMiddleware(app);
metricsMiddleware(app);

// ✅ Main routes
app.use('/api', apiRoutes);

// ✅ Health check
app.get('/', (req, res) => {
  res.json({ status: 'healthy', message: 'Server is running' });
});

// ✅ Webhook route
app.post('/FI/Notification', webHook);

// ✅ 404 & Error handlers
app.use(notFoundHandler);
app.use(globalErrorHandler);

module.exports = app;
