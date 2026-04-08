import express from 'express';
import transactionRoutes from './transaction-routes';
import notificationApiOneSignal from './notifications';
import transactionAuto from './transactionsAuto/transactions';
import finvuRoutes from './finvu-routes';
import customCategory from './transactionsAuto/custom-category-routes';
import wealthscapeRoutes from './wealthscape-routes';
import collectionRoutes from './collection-routes';
import reserveRoutes from './reserve-routes';
import webHook from '@/utils/webHook';

const router = express.Router();

router.post('/FI/Notification', webHook);

router.use('/notify', notificationApiOneSignal);
router.use('/transaction', transactionRoutes);
router.use('/transactionauto', transactionAuto);
router.use('/custom', customCategory);
router.use('/finvu', finvuRoutes);
router.use('/wealthscape', wealthscapeRoutes);
router.use('/collections', collectionRoutes);
router.use('/reserve', reserveRoutes);

export default router;
