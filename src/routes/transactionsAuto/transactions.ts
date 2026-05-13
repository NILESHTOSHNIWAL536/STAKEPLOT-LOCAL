import express from 'express';
import { AuthMiddlewares, validateRequestMiddleware } from '../../middlewares';
import { TransactionAutoController } from '@/controllers';
import {
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
} from '../../validators/transaction-validators';

const router = express.Router();
router.use(express.json());

router.get(
  '/autopays',
  AuthMiddlewares.protect,
  TransactionAutoController.getAutoPays
);

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
router.get('/getTransactions/:page', AuthMiddlewares.protect, validateRequestMiddleware(getSearchedTransactions), TransactionAutoController.getSearchedTransactions);
router.get('/getTransactionsOfUser', AuthMiddlewares.protect, TransactionAutoController.getAllTransactionsOfUser);

router.get('/categorize', AuthMiddlewares.protect, TransactionAutoController.categorizeTransactions);
// **************************************** NEWLY ADDED APIS ****************************************
router.post('/create', AuthMiddlewares.protect, TransactionAutoController.createTransaction);
router.get('/top-five-categories', AuthMiddlewares.protect, TransactionAutoController.getTopFiveCategories);
router.get('/category-wise-spendings', AuthMiddlewares.protect, TransactionAutoController.getCategoryWiseSpendings);
router.get('/budget-transactions', AuthMiddlewares.protect, TransactionAutoController.getBudgetTransactions);
router.get('/get-budget-spents', AuthMiddlewares.protect, TransactionAutoController.getBudgetSpents);
router.put('/:transactionId', AuthMiddlewares.protect, TransactionAutoController.updateTransaction);
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

router.get('/user-details', AuthMiddlewares.protect, TransactionAutoController.getUser);
router.get('/get-banks-linked', AuthMiddlewares.protect, TransactionAutoController.getBanksLinkedAndAccounts);

router.get('/get-banksdebitcredit', AuthMiddlewares.protect, TransactionAutoController.getBankBalanceAndDebitSummary);

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

router.get('/top-three-transactions-of-week', AuthMiddlewares.protect, TransactionAutoController.getTopThreeTransactionsOfWeek);
router.get('/get-income-average-monthly-category-expenses', AuthMiddlewares.protect, TransactionAutoController.getIncomeAndCategorySpent);

// delete complete bank data
router.delete('/:bankId/:accountId', AuthMiddlewares.protect, validateRequestMiddleware(deleteBankAccount), TransactionAutoController.deleteBankAccount);
router.post('/delete', AuthMiddlewares.protect, validateRequestMiddleware(deleteTransactionsSchema), TransactionAutoController.deleteTransactions);

export default router;
