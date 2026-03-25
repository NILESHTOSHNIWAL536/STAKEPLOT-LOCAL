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

  // Delete Collection
  static String deleteCollection(String collectionId) =>
      "$_urlPath/$collectionId";

  // Add Member
  static String addMember(String collectionId) => "$_urlPath/$collectionId/members";

  static String addTransaction(String collectionId) => "$_urlPath/$collectionId/transactions";

  // Update Split
  static String updateSplit(String collectionId, String transactionId) => "$_urlPath/$collectionId/transactions/$transactionId/splits";
}