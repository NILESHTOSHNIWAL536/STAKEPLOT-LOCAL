/**
 * STAGING / TEST ONLY
 *
 * Triggers a delayed finvu fetch job via the Bull queue.
 * Use this instead of waiting for the real Finvu webhook during local/staging testing.
 *
 * Flow:
 *   1. Call POST /api/finvu-queue/trigger  with { sessionId }
 *   2. Server looks up finvuData from Redis cache → DB fallback
 *   3. Job is enqueued with a 12-second delay
 *   4. Worker picks it up, fetches bank data, runs all downstream logic
 */

import { Request, Response } from 'express';
import redisClient from '@/config/redis-config';
import { Finvu } from '@/models';
import { enqueueFinvuFetch, FinvuFetchJobData } from '@/services/bull-queue-service/finvu-fetch-queue';
import logger from '@/utils/common/logger';

export async function triggerQueuedFetch(req: Request, res: Response): Promise<Response> {
  const { sessionId } = req.body as { sessionId?: string };

  if (!sessionId) {
    return res.status(400).json({ error: 'sessionId is required' });
  }

  try {
    // Cache-first lookup — mirrors the real webhook logic
    const cached = await redisClient.get(`finvu:${sessionId}`);
    let finvuData: FinvuFetchJobData | null = null;

    if (cached) {
      try {
        finvuData = JSON.parse(cached) as FinvuFetchJobData;
      } catch {
        logger.error('[FinvuQueueTest] Redis JSON parse failed');
      }
    }

    // DB fallback
    if (!finvuData) {
      const doc = await Finvu.findOne({ sessionId }).lean();
      if (doc) {
        finvuData = {
          sessionId: doc.sessionId,
          custId: doc.custId,
          consentId: doc.consentId,
          handleId: doc.handleId,
          isUpdate: doc.isUpdate ?? false,
          userId: String(doc.userId),
        };
      }
    }

    if (!finvuData) {
      return res.status(404).json({
        error: 'Session not found in Redis cache or DB. Make sure fetchData was called first.',
      });
    }

    await enqueueFinvuFetch(finvuData);

    logger.info(`[FinvuQueueTest] Queued fetch for session ${sessionId}`);

    return res.status(202).json({
      message: 'Fetch job queued',
      sessionId,
      delaySeconds: 12,
      note: 'Bank data will be fetched and processed in ~12 seconds',
    });
  } catch (error: any) {
    logger.error(`[FinvuQueueTest] Error queuing job: ${error.message}`);
    return res.status(500).json({ error: error.message });
  }
}
