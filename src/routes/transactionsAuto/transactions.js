const express = require("express");
const router = express.Router();
const { AuthMiddlewares, validateRequestMiddleware } = require("../../../middlewares/index");
const transactionController = require("../../../controllers/transaction-automation/transaction-controller");
const { categorizeGroupedTransaction, verifyPendingTransaction, updateTransaction, getAllTransactions, getSearchedTransactions, getAllTransactionsForAccount, getTransactionsByDate, getRecurringPayments, updateOrDeleteRecurringpayment, getLoanCalculation, getAllCustomTransactions, getWholeTransactionsGraph, getMonthlyTransactionsHistory, getPreviousTransactions, deleteBankAccount, deleteTransactionsSchema} = require("../../../validators/transaction-validators");
// const detectRecurringPayments = require("../../../utils/helpers/detect-recurring-payments");


router.post("/", AuthMiddlewares.protect, transactionController.createUserDetails);
router.post("/grouped/:groupId/categorize", AuthMiddlewares.protect, validateRequestMiddleware(categorizeGroupedTransaction), transactionController.categorizeGroupedTransaction);
router.post("/verify-pending-transaction/:transactionId/:isCorrect", AuthMiddlewares.protect, validateRequestMiddleware(verifyPendingTransaction), transactionController.verifyPendingTransaction);
router.patch("/updateTransaction/:transactionId", AuthMiddlewares.protect, validateRequestMiddleware(updateTransaction), transactionController.updateTransaction);
router.get("/getTransactions/:page", AuthMiddlewares.protect, validateRequestMiddleware(getAllTransactions), transactionController.getAllTransactions);
router.get("/getTransactions/:page/:search/:isBankAccount", AuthMiddlewares.protect, validateRequestMiddleware(getSearchedTransactions) ,transactionController.getSearchedTransactions);
router.get("/getTransactionsOfUser", AuthMiddlewares.protect, transactionController.getAllTransactionsOfUser);
router.get("/getTransactionsForAccount/:accountId/:page", AuthMiddlewares.protect, validateRequestMiddleware(getAllTransactionsForAccount), transactionController.getAllTransactionsForAccount);
router.get("/categorize", AuthMiddlewares.protect, transactionController.categorizeTransactions);
router.get("/getUserMonthlySpending", AuthMiddlewares.protect, transactionController.getUserMonthlySpending);
router.get("/get-grouped-transactions", AuthMiddlewares.protect, transactionController.getGroupedTransactions);
router.get("/pending-for-review-transactions", AuthMiddlewares.protect, transactionController.getPendingForReviewTransactions);
router.get("/get-day-wise-transactions", AuthMiddlewares.protect, transactionController.getDayWiseTransactionsSummary);
router.get("/get-day-wise-transactions/:date", AuthMiddlewares.protect, validateRequestMiddleware(getTransactionsByDate), transactionController.getTransactionsByDate);


// API's related to recurring payments
router.get("/get-recurring-payments/:isActive", AuthMiddlewares.protect, validateRequestMiddleware(getRecurringPayments),transactionController.getRecurringPayments);
router.patch("/recurring-payments/:id", AuthMiddlewares.protect, validateRequestMiddleware(updateOrDeleteRecurringpayment),transactionController.updateRecurringPayment);
router.delete("/recurring-payments/:id", AuthMiddlewares.protect, validateRequestMiddleware(updateOrDeleteRecurringpayment), transactionController.deleteRecurringPayment);

// This API is dummy API to get the transactions for the map (not used by the frontend)
// router.get("/map", (req, res) => detectRecurringPayments('6814781900017d24d5bf4c99'));

// these routes are for the transaction graphs
router.post("/get-loan-calculation", AuthMiddlewares.protect, validateRequestMiddleware(getLoanCalculation), transactionController.getLoanCalculation);
router.get("/getAllCustomTransactions/:accountId/:type/:value", AuthMiddlewares.protect, validateRequestMiddleware(getAllCustomTransactions), transactionController.getAllCustomTransactions);
router.get("/getWholeTransactionsGraph/:type/:value", AuthMiddlewares.protect, validateRequestMiddleware(getWholeTransactionsGraph), transactionController.getWholeTransactionsGraph);

router.get("/get-hide-transactions", AuthMiddlewares.protect, transactionController.getHideTransactions);
router.get("/user-details", AuthMiddlewares.protect, transactionController.getUser);
router.get("/get-banks-linked", AuthMiddlewares.protect, transactionController.getBanksLinkedAndAccounts);
router.get("/get-monthly-transactions-history/:accountId/:type/:page", AuthMiddlewares.protect,validateRequestMiddleware(getMonthlyTransactionsHistory), transactionController.getMonthlyTransactionsHistory);
router.get("/get-previous-transactions/:date/:accountId", AuthMiddlewares.protect, validateRequestMiddleware(getPreviousTransactions),transactionController.getPreviousTransactions);
router.get("/get-headsup-messages", AuthMiddlewares.protect, transactionController.getHeadsUpMessages);
router.get("/get-money-map-messages", AuthMiddlewares.protect, transactionController.getMoneyMapMessages);
router.get("/top-three-transactions-of-week", AuthMiddlewares.protect, transactionController.getTopThreeTransactionsOfWeek);
router.get("/get-income-average-monthly-category-expenses", AuthMiddlewares.protect, transactionController.getIncomeAndCategorySpent);


// delete complete bank data
router.delete("/:bankId/:accountId", AuthMiddlewares.protect, validateRequestMiddleware(deleteBankAccount), transactionController.deleteBankAccount);
router.post("/delete", AuthMiddlewares.protect, validateRequestMiddleware(deleteTransactionsSchema) ,transactionController.deleteTransactions);

module.exports = router; 