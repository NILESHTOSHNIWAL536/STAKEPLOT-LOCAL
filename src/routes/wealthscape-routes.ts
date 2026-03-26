import express from 'express';
import { AuthMiddlewares } from '../middlewares';
import * as WealthscapeController from '@/controllers/wealthscape-controller';

const router = express.Router();
router.use(express.json());

// ── Consent flow ──────────────────────────────
router.post('/init-consent', AuthMiddlewares.protect, WealthscapeController.initConsent);
router.post('/multi-consent', AuthMiddlewares.protect, WealthscapeController.initMultiConsent);

// ── Account data ──────────────────────────────
router.get('/accounts/:uniqueIdentifier', AuthMiddlewares.protect, WealthscapeController.getLinkedAccounts);
router.post('/account-data', AuthMiddlewares.protect, WealthscapeController.fetchAndStoreAccountData);
router.get('/account-data/:uniqueIdentifier', AuthMiddlewares.protect, WealthscapeController.getStoredAccountData);

// ── Session management ────────────────────────
router.get('/sessions', AuthMiddlewares.protect, WealthscapeController.getUserSessions);

export default router;
