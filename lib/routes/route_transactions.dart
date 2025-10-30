import '../backed_connections/apis_connect.dart';

class BankTransactionRoutes {
  static final String _urlPath = "$url/transactionauto";

  // Create user details
  static String createUserDetails = "$_urlPath/";

  // Grouped transactions
  static String categorizeGroupedTransaction({required String groupId}) => "$_urlPath/grouped/$groupId/categorize";

  // Verify pending transaction
  static String verifyPendingTransaction({required String transactionId,required bool isCorrect}) =>
      "$_urlPath/verify-pending-transaction/$transactionId/$isCorrect";

  // Update transaction
  static String updateTransaction({required String transactionId}) => "$_urlPath/updateTransaction/$transactionId";

  // Get all transactions (paginated)
  static String getTransactions({required int page}) => "$_urlPath/getTransactions/$page";

  // Get searched transactions
  static String getSearchedTransactions({required int page,required String search,required bool isBankAccount}) =>
      "$_urlPath/getTransactions/$page/$search/$isBankAccount";

  // All transactions of user
  static String getTransactionsOfUser = "$_urlPath/getTransactionsOfUser";

  // Get transactions for specific account
  static String getTransactionsForAccount({required String accountId,required int page}) =>
      "$_urlPath/getTransactionsForAccount/$accountId/$page";

  // Categorize transactions
  static String categorizeTransactions = "$_urlPath/categorize";

  // Monthly spending
  static String getUserMonthlySpending = "$_urlPath/getUserMonthlySpending";

  // Grouped transactions list
  static String getGroupedTransactions = "$_urlPath/get-grouped-transactions";

  // Pending review
  static String getPendingForReviewTransactions = "$_urlPath/pending-for-review-transactions";

  // Day-wise transactions
  static String getDayWiseTransactionsSummary = "$_urlPath/get-day-wise-transactions";

  // Day-wise transactions by date
  static String getTransactionsByDate({required String date}) => "$_urlPath/get-day-wise-transactions/$date";

  // Recurring payments
  static String getRecurringPayments({required bool isActive}) => "$_urlPath/get-recurring-payments/$isActive";
  static String updateRecurringPayment({required String id}) => "$_urlPath/recurring-payments/$id";
  static String deleteRecurringPayment({required String id}) => "$_urlPath/recurring-payments/$id";

  // Loan calculation
  static String getLoanCalculation = "$_urlPath/get-loan-calculation";

  // Custom & graph data
  static String getAllCustomTransactions({required String accountId,required String type,required String value}) =>
      "$_urlPath/getAllCustomTransactions/$accountId/$type/$value";

  static String getWholeTransactionsGraph({required String type,required String value}) =>
      "$_urlPath/getWholeTransactionsGraph/$type/$value";

  // Hide transactions
  static String getHideTransactions = "$_urlPath/get-hide-transactions";

  // User details
  static String getUserDetails = "$_urlPath/user-details";

  // Banks linked
  static String getBanksLinkedAndAccounts = "$_urlPath/get-banks-linked";

  // Monthly history
  static String getMonthlyTransactionsHistory({required String accountId,required String type,required int page}) =>
      "$_urlPath/get-monthly-transactions-history/$accountId/$type/$page";

  // Previous transactions
  static String getPreviousTransactions({required String date,required String accountId}) =>
      "$_urlPath/get-previous-transactions/$date/$accountId";

  // Heads-up & money map
  static String getHeadsUpMessages = "$_urlPath/get-headsup-messages";
  static String getMoneyMapMessages = "$_urlPath/get-money-map-messages";

  // Top 3 transactions of the week
  static String getTopThreeTransactionsOfWeek = "$_urlPath/top-three-transactions-of-week";

  // Income & category spent
  static String getIncomeAndCategorySpent = "$_urlPath/get-income-average-monthly-category-expenses";

  // Delete bank data
  static String deleteBankAccount({required String bankId, required String accountId}) => "$_urlPath/$bankId/$accountId";

  // Delete transactions
  static String deleteTransactions = "$_urlPath/delete";
}


class TransactionRoutes 
{
  static final String _urlPath = url + "/transaction";
  static String updateAndDelete = "$_urlPath/";
  static String addTransaction = "$_urlPath/add";
  static String getAll = "$_urlPath/all";
  static String storeBankUrl = "$_urlPath/storeBankUrl";
  static String groupedTransactions = "$_urlPath/groupedTransactions";
  static String updateGroupTransactions = "$_urlPath/updateGroupTransactions";
  static String updateheadsupmoneymap = "$_urlPath/headsup-moneymap";
}
