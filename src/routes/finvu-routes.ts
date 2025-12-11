import express from 'express';
import { AuthMiddlewares } from '../middlewares';
import { FinvuController } from '@/controllers';

const router = express.Router();
router.use(express.json());

router.post('/login', AuthMiddlewares.protect, FinvuController.loginAndGetHandleId);
router.post('/fetchData', AuthMiddlewares.protect, FinvuController.fetchTransactions);
router.post('/fetchWeekly', AuthMiddlewares.protect, FinvuController.fetchTransactionsWeekly);
router.post('/fip-details/', AuthMiddlewares.protect, FinvuController.getFipsDetails);

router.get('/fipsmetric', FinvuController.getFipsLatestMetricsAll);
router.get('/status/:id', FinvuController.getStatus);

export default router;
