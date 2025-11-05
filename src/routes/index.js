const express = require('express');
const transactionRoutes = require('./transaction-routes');
const notificationApiOneSignal = require('./notifications');
const transactionAuto = require('./transactionsAuto/transactions');
const finvuRoutes = require('./finvu-routes');
const customCategory = require('./transactionsAuto/customCategoryRoutes');

const router = express.Router();``

router.use('/notify', notificationApiOneSignal);
router.use('/transaction', transactionRoutes);
router.use('/transactionauto', transactionAuto);
router.use('/finvu', finvuRoutes);

module.exports = router;
