const { sendMetric, logRequest } = require('../../utils/cloud-watch');

function metricsMiddleware(app) {
  // ✅ CloudWatch metrics
  app.use(async (req, res, next) => {
    try {
      await sendMetric(req.path, req.method);
    } catch (error) {
      console.error('CloudWatch metric error:', error);
    }
    next();
  });

  // ✅ Request logging
  app.use((req, res, next) => {
    const startTime = Date.now();
    res.on('finish', async () => {
      const duration = Date.now() - startTime;
      try {
        await logRequest({
          method: req.method,
          path: req.path,
          duration,
          statusCode: res.statusCode,
          ip: req.ip,
        });
      } catch (error) {
        console.error('CloudWatch logging error:', error);
      }
    });
    next();
  });
}

module.exports = { metricsMiddleware };
