import 'index_route.dart';

class CollectionsRoute {
  // ✅ Base URL
  static final String _urlPath = "${API.BankApiUrl}/collections";

  // Create Collection
  static String createCollection = _urlPath;

  // Get All Collections
  static String getCollections = _urlPath;

  // Get Collection By ID
  static String getCollectionById(String collectionId) =>
      "$_urlPath/$collectionId";

  static String getAllTransactionsCollectionById(String collectionId) =>
      "$_urlPath/$collectionId/all-transactions";

  // Delete Collection
  static String deleteCollection(String collectionId) =>
      "$_urlPath/$collectionId";

  // Add Member
  static String addMember(String collectionId) =>
      "$_urlPath/$collectionId/members";

  static String addTransaction(String collectionId) =>
      "$_urlPath/$collectionId/transactions";
  static String addTransactionToPersonal(String collectionId) =>
      "$_urlPath/$collectionId/transactions/personal";

  // Update Split
  static String updateSplit(String collectionId, String splitId) =>
      "$_urlPath/$collectionId/splits/$splitId";

  // Get All Available Transactions (GET with query params)
  static String getAvailableTransactions(
    String collectionId, {
    int page = 1,
    int limit = 20,
  }) =>
      "$_urlPath/$collectionId/available-transactions?page=$page&limit=$limit";

  // Get All Splits (GET)
  static String getSplits(String collectionId) =>
      "$_urlPath/$collectionId/splits";

  // Get Balances (GET)
  static String getBalances(String collectionId) =>
      "$_urlPath/$collectionId/balances";

  static String updateCollection(String collectionId) =>
      "$_urlPath/$collectionId/updateCollections";
  static String closeCollection(String collectionId) =>
      "$_urlPath/$collectionId/closeCollection";
      
}
