import express from 'express';
import { InsightController } from '@/controllers';
import { AuthMiddlewares } from '@/middlewares';

const router = express.Router();
router.use(express.json());

router.get('/catalog', AuthMiddlewares.protect, InsightController.getCatalog);
router.get('/summary', AuthMiddlewares.protect, InsightController.getSummary);
router.get('/categories', AuthMiddlewares.protect, InsightController.getCategories);
router.get('/merchants', AuthMiddlewares.protect, InsightController.getMerchants);
router.get('/time-patterns', AuthMiddlewares.protect, InsightController.getTimePatterns);
router.get('/payment-modes', AuthMiddlewares.protect, InsightController.getPaymentModes);
router.get('/cash-vs-bank', AuthMiddlewares.protect, InsightController.getCashVsBank);
router.get('/recurring', AuthMiddlewares.protect, InsightController.getRecurring);
router.get('/anomalies', AuthMiddlewares.protect, InsightController.getAnomalies);
router.get('/action-items', AuthMiddlewares.protect, InsightController.getActionItems);
router.get('/daily-trend', AuthMiddlewares.protect, InsightController.getDailyTrend);
router.get('/largest-transactions', AuthMiddlewares.protect, InsightController.getLargestTransactions);
router.get('/balance-trend', AuthMiddlewares.protect, InsightController.getBalanceTrend);
router.get('/spend-velocity', AuthMiddlewares.protect, InsightController.getSpendVelocity);
router.get('/category-health', AuthMiddlewares.protect, InsightController.getCategoryHealth);
router.get('/income-sources', AuthMiddlewares.protect, InsightController.getIncomeSources);
router.get('/upcoming-expense-prediction', AuthMiddlewares.protect, InsightController.getUpcomingExpensePrediction);

export default router;
