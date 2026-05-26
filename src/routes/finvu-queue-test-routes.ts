/**
 * STAGING / TEST ONLY
 * Mounted at /api/finvu-queue
 */
import express from 'express';
import { AuthMiddlewares } from '../middlewares';
import { triggerQueuedFetch } from '@/controllers/finvu-queue-test-controller';

const router = express.Router();

// POST /api/finvu-queue/trigger  { sessionId }
router.post('/trigger', AuthMiddlewares.protect, triggerQueuedFetch);

export default router;
