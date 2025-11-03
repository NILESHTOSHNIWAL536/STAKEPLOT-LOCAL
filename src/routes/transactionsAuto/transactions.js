const express = require('express');
const router = express.Router();
const { AuthMiddlewares, validateRequestMiddleware } = require('../../middlewares');
const { TransactionAutoController } = require('../../controllers');
const {
  categorizeGroupedTransaction,
  verifyPendingTransaction,
  updateTransaction,
  getAllTransactions,
  getSearchedTransactions,
  getAllTransactionsForAccount,
  getTransactionsByDate,
  getRecurringPayments,
  updateOrDeleteRecurringpayment,
  getLoanCalculation,
  getAllCustomTransactions,
  getWholeTransactionsGraph,
  getMonthlyTransactionsHistory,
  getPreviousTransactions,
  deleteBankAccount,
  deleteTransactionsSchema,
} = require('../../validators/transaction-validators');

router.post('/', AuthMiddlewares.protect, TransactionAutoController.createUserDetails);
router.post(
  '/grouped/:groupId/categorize',
  AuthMiddlewares.protect,
  validateRequestMiddleware(categorizeGroupedTransaction),
  TransactionAutoController.categorizeGroupedTransaction
);
router.post(
  '/verify-pending-transaction/:transactionId/:isCorrect',
  AuthMiddlewares.protect,
  validateRequestMiddleware(verifyPendingTransaction),
  TransactionAutoController.verifyPendingTransaction
);
router.patch('/updateTransaction/:transactionId', AuthMiddlewares.protect, validateRequestMiddleware(updateTransaction), TransactionAutoController.updateTransaction);
router.get('/getTransactions/:page', AuthMiddlewares.protect, validateRequestMiddleware(getAllTransactions), TransactionAutoController.getAllTransactions);
router.get(
  '/getTransactions/:page/:search/:isBankAccount',
  AuthMiddlewares.protect,
  validateRequestMiddleware(getSearchedTransactions),
  TransactionAutoController.getSearchedTransactions
);
router.get('/getTransactionsOfUser', AuthMiddlewares.protect, TransactionAutoController.getAllTransactionsOfUser);
router.get(
  '/getTransactionsForAccount/:accountId/:page',
  AuthMiddlewares.protect,
  validateRequestMiddleware(getAllTransactionsForAccount),
  TransactionAutoController.getAllTransactionsForAccount
);
router.get('/categorize', AuthMiddlewares.protect, TransactionAutoController.categorizeTransactions);
// **************************************** NEWLY ADDED APIS ****************************************
router.post("/create", AuthMiddlewares.protect, TransactionAutoController.createTransaction);
router.get("/top-five-categories", AuthMiddlewares.protect, TransactionAutoController.getTopFiveCategories);
router.get('/category-wise-spendings/:categoryNames/:startDate/:endDate', AuthMiddlewares.protect, TransactionAutoController.getCategoryWiseSpendings);
router.get('/budget-transactions/:categoryNames/:groupBy/:startDate/:endDate', AuthMiddlewares.protect, TransactionAutoController.getBudgetTransactions);
router.get('/get-budget-spents/:categories/:startDate/:endDate', AuthMiddlewares.protect, TransactionAutoController.getBudgetSpents);
// ******************************************************************************************************
router.get('/getUserMonthlySpending', AuthMiddlewares.protect, TransactionAutoController.getUserMonthlySpending);
router.get('/get-grouped-transactions', AuthMiddlewares.protect, TransactionAutoController.getGroupedTransactions);
router.get('/pending-for-review-transactions', AuthMiddlewares.protect, TransactionAutoController.getPendingForReviewTransactions);
router.get('/get-day-wise-transactions', AuthMiddlewares.protect, TransactionAutoController.getDayWiseTransactionsSummary);
router.get('/get-day-wise-transactions/:date', AuthMiddlewares.protect, validateRequestMiddleware(getTransactionsByDate), TransactionAutoController.getTransactionsByDate);

// API's related to recurring payments
router.get('/get-recurring-payments/:isActive', AuthMiddlewares.protect, validateRequestMiddleware(getRecurringPayments), TransactionAutoController.getRecurringPayments);
router.patch('/recurring-payments/:id', AuthMiddlewares.protect, validateRequestMiddleware(updateOrDeleteRecurringpayment), TransactionAutoController.updateRecurringPayment);
router.delete('/recurring-payments/:id', AuthMiddlewares.protect, validateRequestMiddleware(updateOrDeleteRecurringpayment), TransactionAutoController.deleteRecurringPayment);

// This API is dummy API to get the transactions for the map (not used by the frontend)
// router.get("/map", (req, res) => detectRecurringPayments('6814781900017d24d5bf4c99'));

// these routes are for the transaction graphs
router.post('/get-loan-calculation', AuthMiddlewares.protect, validateRequestMiddleware(getLoanCalculation), TransactionAutoController.getLoanCalculation);
router.get(
  '/getAllCustomTransactions/:accountId/:type/:value',
  AuthMiddlewares.protect,
  validateRequestMiddleware(getAllCustomTransactions),
  TransactionAutoController.getAllCustomTransactions
);
router.get(
  '/getWholeTransactionsGraph/:type/:value',
  AuthMiddlewares.protect,
  validateRequestMiddleware(getWholeTransactionsGraph),
  TransactionAutoController.getWholeTransactionsGraph
);

router.get('/get-hide-transactions', AuthMiddlewares.protect, TransactionAutoController.getHideTransactions);
router.get('/user-details', AuthMiddlewares.protect, TransactionAutoController.getUser);
router.get('/get-banks-linked', AuthMiddlewares.protect, TransactionAutoController.getBanksLinkedAndAccounts);
router.get(
  '/get-monthly-transactions-history/:accountId/:type/:page',
  AuthMiddlewares.protect,
  validateRequestMiddleware(getMonthlyTransactionsHistory),
  TransactionAutoController.getMonthlyTransactionsHistory
);
router.get(
  '/get-previous-transactions/:date/:accountId',
  AuthMiddlewares.protect,
  validateRequestMiddleware(getPreviousTransactions),
  TransactionAutoController.getPreviousTransactions
);
router.get('/get-headsup-messages', AuthMiddlewares.protect, TransactionAutoController.getHeadsUpMessages);
router.get('/get-money-map-messages', AuthMiddlewares.protect, TransactionAutoController.getMoneyMapMessages);
router.get('/top-three-transactions-of-week', AuthMiddlewares.protect, TransactionAutoController.getTopThreeTransactionsOfWeek);
router.get('/get-income-average-monthly-category-expenses', AuthMiddlewares.protect, TransactionAutoController.getIncomeAndCategorySpent);

// delete complete bank data
router.delete('/:bankId/:accountId', AuthMiddlewares.protect, validateRequestMiddleware(deleteBankAccount), TransactionAutoController.deleteBankAccount);
router.post('/delete', AuthMiddlewares.protect, validateRequestMiddleware(deleteTransactionsSchema), TransactionAutoController.deleteTransactions);

module.exports = router;
