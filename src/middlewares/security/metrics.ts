import { Application, Request, Response, NextFunction } from 'express';
import { sendMetric, logRequest } from '../../utils/cloud-watch';

export function metricsMiddleware(app: Application): void {
  // ✅ CloudWatch metrics
  app.use(async (req: Request, res: Response, next: NextFunction) => {
    try {
      await sendMetric(req.path, req.method, res.statusCode);
    } catch (error) {
      console.error('CloudWatch metric error:', error);
    }
    next();
  });

  // ✅ Request logging
  app.use((req: Request, res: Response, next: NextFunction) => {
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
