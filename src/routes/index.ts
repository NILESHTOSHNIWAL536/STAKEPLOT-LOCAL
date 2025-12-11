import express from 'express';
import transactionRoutes from './transaction-routes';
import notificationApiOneSignal from './notifications';
import transactionAuto from './transactionsAuto/transactions';
import finvuRoutes from './finvu-routes';
import customCategory from './transactionsAuto/custom-category-routes';

const router = express.Router();

router.use('/notify', notificationApiOneSignal);
router.use('/transaction', transactionRoutes);
router.use('/transactionauto', transactionAuto);
router.use('/custom', customCategory);
router.use('/finvu', finvuRoutes);

export default router;
