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
  static String exitCollection(String collectionId) =>
      "$_urlPath/$collectionId/exit";
  static String reopenCollection(String collectionId) =>
      "$_urlPath/$collectionId/reopen";

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

  static String paySplit(String collectionId, String splitId) =>
      "$_urlPath/$collectionId/splits/$splitId/pay";

  static clearPayment(String collectionId, String splitId) =>
      "$_urlPath/$collectionId/splits/$splitId/clear";

  // ===============================
// INVITATION ROUTES (NEW)
// ===============================

// Get pending invitations for current user
  static String getPendingInvitations() => "$_urlPath/invitations/pending";

// Accept invitation
  static String acceptInvitation(String invitationId) =>
      "$_urlPath/invitations/$invitationId/accept";

// Reject invitation
  static String rejectInvitation(String invitationId) =>
      "$_urlPath/invitations/$invitationId/reject";

// Get invitations for a collection
  static String getCollectionInvitations(String collectionId) =>
      "$_urlPath/$collectionId/invitations";

// Cancel specific invitation
  static String cancelInvitation(String collectionId, String invitationId) =>
      "$_urlPath/$collectionId/invitations/$invitationId";

  /// Update member role
  static String updateMemberRole(String collectionId, String userId) =>
      "$_urlPath/$collectionId/members/$userId";

  static String updateMemberLimit(String collectionId) =>
      "$_urlPath/$collectionId/members/limits";

  /// Invite members (bulk)
  static String inviteMember(String collectionId) =>
      "$_urlPath/$collectionId/invitations";
}
