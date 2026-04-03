import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';
import '../Home_Screen/history/collections/collections_HomePage.dart';
import '../Home_Screen/history/collections/trip/screens/shared_dashboard_screen.dart';
import '../Home_Screen/history/transactionHistoryScreen.dart';
import '../Utils/durations_range.dart';
import '../backed_connections/apiAutomations/curd.dart';
import '../model/TransactionModel.dart';
import '../model/collections_model.dart';
import '../routes/route_collections.dart';

class CollectionsController extends GetxController {
  // =========================
  // LOADING STATES
  // =========================
  final RxBool isLoading = false.obs;
  final RxBool isSplitLoading = false.obs;
  final RxBool isBalanceLoading = false.obs;
  final RxBool isMemberLoading = false.obs;

  // =========================
  // DATA
  // =========================
  final RxList<CollectionModel> collectionsList = <CollectionModel>[].obs;
  final Rx<CollectionModel?> selectedCollection = Rx<CollectionModel?>(null);
  final Rx<CollectionDetailsModel?> collectionDetails =
      Rx<CollectionDetailsModel?>(null);

  final RxList<SplitModel> splitsList = <SplitModel>[].obs;
  final RxList<BalanceModel> balancesList = <BalanceModel>[].obs;

  final RxList<CollectionTransactionModel> availableTransactions =
      <CollectionTransactionModel>[].obs;

  final RxList<TransactionModel> AllTransactions = <TransactionModel>[].obs;
  final RxList<TransactionModel> SeletedTransactionsList =
      <TransactionModel>[].obs;
  final RxList<String> selectedTransactions = <String>[].obs;

  /// Prevent duplicate concurrent fetches
  bool _isFetchingCollections = false;
  bool _isFetchingDetails = false;

  // ✅ Computed helpers
  bool get hasCollectionDetails => collectionDetails.value != null;
  bool get hasTransactions => splitsList.isNotEmpty;
  bool get hasMembers =>
      collectionDetails.value != null &&
      collectionDetails.value!.members.isNotEmpty;

  final RxList<InvitationModel> invitationsList = <InvitationModel>[].obs;
  final RxBool isInvitationLoading = false.obs;

  MemberModel? currentUser;

  MemberModel? get currentUserInCollection {
    if (collectionDetails.value == null) return null;
    return collectionDetails.value!.members
        .firstWhereOrNull((m) => m.id == userController.userId);
  }

  // =========================
  // GET COLLECTIONS LIST
  // =========================
  Future<void> getCollections({bool forceRefresh = false}) async {
    /// Skip if already loading or has data and not forced
    if (_isFetchingCollections) return;
    if (!forceRefresh && collectionsList.isNotEmpty) return;

    _isFetchingCollections = true;
    try {
      isLoading.value = true;

      final response = await getDataApiCall(CollectionsRoute.getCollections);

      if (getFlagOfResponse(response)) {
        final decoded = json.decode(response.body);
        if (decoded['data'] is List) {
          final list = decoded['data'] as List;
          final parsed = <CollectionModel>[];
          for (final item in list) {
            try {
              parsed.add(CollectionModel.fromJson(item, {}));
            } catch (e) {
              debugPrint("CollectionModel parse error: $e — item: $item");
            }
          }

          /// Batch update — single UI rebuild
          collectionsList.clear();
          collectionsList.assignAll(parsed);
        }
      }
    } catch (e) {
      debugPrint("getCollections error: $e");
    } finally {
      isLoading.value = false;
      _isFetchingCollections = false;
    }
  }

  
  Future<void> getCollectionById(String id, BuildContext context) async {
    if (_isFetchingDetails) return;
    _isFetchingDetails = true;

    try {
      isLoading.value = true;
      collectionDetails.value = null;

      final response =
          await getDataApiCall(CollectionsRoute.getCollectionById(id));

      if (!getFlagOfResponse(response)) return;

      final data = json.decode(response.body);
      final details = CollectionDetailsModel.fromJson(data['data']);
      collectionDetails.value = details;
      selectedCollection.value = details.collection;
      currentUser = details.members.firstWhereOrNull(
        (m) =>
            m.userId.toString().trim() ==
            userController.userId.toString().trim(),
      );
      splitsList.clear();
      await getSplits(id);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CollectionDetailsPage(
            title: details.collection.name,
            type: details.collection.type,
            hasTransactions: details.collection.type == "SHARED"
                ? splitsList.isNotEmpty
                : details.transactions.isNotEmpty,
          ),
        ),
      );

      balancesList.clear();
      AllTransactions.clear();

      /// Load splits and balances in parallel — much faster
      await Future.wait([
        getBalances(id),
        getAllCollectionsTransactions(),
      ]);

      if (!context.mounted) return;
    } catch (e) {
      debugPrint("getCollectionById error: $e");
    } finally {
      isLoading.value = false;
      _isFetchingDetails = false;
    }
  }

  // =========================
  // REFRESH COLLECTION DATA
  // =========================
  Future<void> refreshCollectionData(String collectionId) async {
    try {
      final response = await getDataApiCall(
          CollectionsRoute.getCollectionById(collectionId));

      if (getFlagOfResponse(response)) {
        final data = json.decode(response.body);
        final details = CollectionDetailsModel.fromJson(data['data']);
        collectionDetails.value = details;
        selectedCollection.value = details.collection;
        AllTransactions.clear();
        await Future.wait([
          getSplits(collectionId),
          getBalances(collectionId),
        ]);
      }
    } catch (e) {
      debugPrint("refreshCollectionData error: $e");
    }
  }

  // =========================
  // CREATE COLLECTION (simple)
  // =========================
  Future<bool> createCollection({
    required String name,
    required String type,
    String description = "",
    String? expiryAt,
  }) async {
    try {
      final body = <String, dynamic>{
        "name": name,
        "type": type,
        "description": description,
        if (expiryAt != null) "expiryAt": getIsoDateFromDuration(expiryAt),
      };

      final response =
          await postDataApiCall(CollectionsRoute.createCollection, body);

      if (getFlagOfResponse(response)) {
        await getCollections(forceRefresh: true);
        return true;
      }
    } catch (e) {
      debugPrint("createCollection error: $e");
    }
    return false;
  }

  // =========================
  // ADD MEMBERS
  // =========================
  Future<bool> addMembers({
    required String collectionId,
    required List<Map<String, dynamic>> friends,
  }) async {
    try {
      isMemberLoading.value = true;

      final response = await postDataApiCall(
        CollectionsRoute.addMember(collectionId),
        {"friends": friends},
      );

      if (getFlagOfResponse(response)) {
        final detailsResponse = await getDataApiCall(
            CollectionsRoute.getCollectionById(collectionId));

        if (getFlagOfResponse(detailsResponse)) {
          final data = json.decode(detailsResponse.body);
          collectionDetails.value =
              CollectionDetailsModel.fromJson(data['data']);
          selectedCollection.value = collectionDetails.value?.collection;
        }
        return true;
      }
    } catch (e) {
      debugPrint("addMembers error: $e");
    } finally {
      isMemberLoading.value = false;
    }
    return false;
  }

  // =========================
  // CREATE COLLECTION + ADD MEMBERS
  // =========================
  Future<String?> createCollectionWithMembers({
    required String name,
    required String type,
    String description = "",
    String? expiryAt,
    required List<Map<String, dynamic>> friends,
    required BuildContext context,
  }) async {
    try {
      isLoading.value = true;

      final body = <String, dynamic>{
        "name": name,
        "type": type.toUpperCase(),
        "description": description,
        if (expiryAt != null) "expiryAt": getIsoDateFromDuration(expiryAt),
      };

      final createRes =
          await postDataApiCall(CollectionsRoute.createCollection, body);

      if (!getFlagOfResponse(createRes)) {
        debugPrint("❌ createCollection failed: ${createRes.body}");
        return null;
      }

      final resData = json.decode(createRes.body);
      final newId = resData["data"]["_id"] as String;

      if (friends.isNotEmpty) {
        final memberRes = await postDataApiCall(
          CollectionsRoute.addMember(newId),
          {"friends": friends},
        );
        if (!getFlagOfResponse(memberRes)) {
          debugPrint("⚠️ addMember failed: ${memberRes.body}");
        }
      }

      await getCollections(forceRefresh: true);
      return newId;
    } catch (e) {
      debugPrint("createCollectionWithMembers error: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // DELETE COLLECTION
  // =========================
  Future<void> deleteCollection(String id, BuildContext context) async {
    try {
      final response =
          await deleteDataApiCall(CollectionsRoute.deleteCollection(id));

      if (getFlagOfResponse(response)) {
        /// Batch clear
        collectionDetails.value = null;
        selectedCollection.value = null;
        splitsList.clear();
        balancesList.clear();
        collectionsList.removeWhere((e) => e.id == id);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const TransactionHistoryScreen(),
          ),
        );
      }
    } catch (e) {
      debugPrint("deleteCollection error: $e");
    }
  }

  // =========================
  // GET SPLITS
  // =========================
  Future<void> getSplits(String collectionId) async {
    try {
      isSplitLoading.value = true;

      final response =
          await getDataApiCall(CollectionsRoute.getSplits(collectionId));

      if (getFlagOfResponse(response)) {
        final data = json.decode(response.body);
        final list =
            (data['data'] as List).map((e) => SplitModel.fromJson(e)).toList();
        splitsList.assignAll(list);
      }
    } catch (e) {
      debugPrint("getSplits error: $e");
    } finally {
      isSplitLoading.value = false;
    }
  }

  // =========================
  // GET AVAILABLE TRANSACTIONS
  // =========================
  Future<void> getAllCollectionsTransactionsq(
      {int page = 1, int limit = 20}) async {
    try {
      isSplitLoading.value = true;

      if (collectionDetails.value == null) return;

      final response = await getDataApiCall(
        CollectionsRoute.getAvailableTransactions(
          collectionDetails.value!.collection.id,
          page: page,
          limit: limit,
        ),
      );

      if (getFlagOfResponse(response)) {
        final data = json.decode(response.body);
        final list =
            TransactionModel.listFromJson(data["data"]["transactions"]);
        AllTransactions.assignAll(list);
      }
    } catch (e) {
      debugPrint("getAllCollectionsTransactions error: $e");
    } finally {
      isSplitLoading.value = false;
    }
  }

  // =========================
  // ADD TRANSACTION (PERSONAL)
  // =========================
  Future<bool> addTransactionToPersonal({
    required String collectionId,
    required List<String> transactionIds,
    BuildContext? context,
  }) async {
    final response = await postDataApiCall(
      CollectionsRoute.addTransaction(collectionId),
      {"transactionIds": transactionIds, "splitType": "PERSONAL"},
    );

    if (getFlagOfResponse(response)) {
      selectedTransactions.clear();
      SeletedTransactionsList.clear();
      await refreshCollectionData(collectionId);
      if (context != null && context.mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
      return true;
    }

    debugPrint("❌ addTransactionToPersonal failed: ${response.body}");
    Get.snackbar(
      "Error",
      "Failed to add transaction. Please try again.",
      snackPosition: SnackPosition.BOTTOM,
    );
    return false;
  }

  // =========================
  // ADD TRANSACTION (SHARED)
  // =========================
  Future<bool> addTransaction({
    required String collectionId,
    required List<String> transactionIds,
    required String splitType,
    List<dynamic>? customSplits,
    required BuildContext context,
    bool isFixedBill = false,
  }) async {
    final body = <String, dynamic>{
      "transactionIds": transactionIds,
      "isFixedBill": isFixedBill,
      "splitType": splitType,
      if (splitType == "CUSTOM" && customSplits != null)
        "customSplits": customSplits,
    };

    final response = await postDataApiCall(
        CollectionsRoute.addTransaction(collectionId), body);

    if (getFlagOfResponse(response)) {
      selectedTransactions.clear();
      SeletedTransactionsList.clear();
      await refreshCollectionData(collectionId);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => const TransactionHistoryScreen(),
      //   ),
      // );

      return true;
    }

    debugPrint("❌ addTransaction failed: ${response.body}");
    Get.snackbar(
      "Error",
      "Failed to add transaction. Please try again.",
      snackPosition: SnackPosition.BOTTOM,
    );
    return false;
  }

  // =========================
  // UPDATE SPLIT
  // =========================
  Future<void> updateSplit({
    required String collectionId,
    required String splitId,
    required List<Map<String, dynamic>> customSplits,
  }) async {
    try {
      final response = await updateDataApiCall2(
        CollectionsRoute.updateSplit(collectionId, splitId),
        {"customSplits": customSplits},
      );

      if (getFlagOfResponse(response)) {
        await getSplits(collectionId);
      }
    } catch (e) {
      debugPrint("updateSplit error: $e");
    }
  }

  // =========================
  // GET BALANCES
  // =========================
  Future<void> getBalances(String collectionId) async {
    try {
      isBalanceLoading.value = true;

      final response =
          await getDataApiCall(CollectionsRoute.getBalances(collectionId));

      if (getFlagOfResponse(response)) {
        final data = json.decode(response.body)['data'];

        List<BalanceModel> tempList = [];

        /// ✅ TO PAY
        final toPayList = data['toPay'] as List? ?? [];
        for (var item in toPayList) {
          tempList.add(BalanceModel.fromJson(item, "toPay"));
        }

        /// ✅ TO RECEIVE
        final toReceiveList = data['toReceive'] as List? ?? [];
        for (var item in toReceiveList) {
          tempList.add(BalanceModel.fromJson(item, "toReceive"));
        }

        balancesList.assignAll(tempList);
      }
    } catch (e) {
      debugPrint("getBalances error: $e");
    } finally {
      isBalanceLoading.value = false;
    }
  }

  // =========================
  // REFRESH DASHBOARD
  // =========================
  Future<void> refreshDashboard(String collectionId) async {
    await Future.wait([
      getSplits(collectionId),
      getBalances(collectionId),
      getAllCollectionsTransactions(),
    ]);
  }

  // =========================
  // UPDATE COLLECTION
  // =========================
  Future<bool> updateCollection({
    required String id,
    String? name,
    String? duration,
  }) async {
    try {
      final body = <String, dynamic>{
        if (name != null) "name": name,
        if (duration != null) "expiryAt": getIsoDateFromDuration(duration),
      };

      final response =
          await updateDataApiCall2(CollectionsRoute.updateCollection(id), body);

      if (getFlagOfResponse(response)) {
        /// Update local list item without full re-fetch for instant UI update
        final data = json.decode(response.body)['data'];

        final idx = collectionsList.indexWhere((e) => e.id == id);
        if (idx != -1 && name != null) {
          final old = collectionsList[idx];
          collectionsList[idx] = CollectionModel(
            id: old.id,
            name: name,
            type: old.type,
            ownerId: old.ownerId,
            description: old.description,
            expiryAt: data['expiryAt'] != null
                ? DateTime.parse(data['expiryAt'])
                : null,
            status: old.status,
            totalAmount: collectionDetails.value?.collection.totalAmount ??
                old.totalAmount ??
                0,
            totalCredit: collectionDetails.value?.collection.totalCredit ??
                old.totalCredit ??
                0,
            totalDebit: collectionDetails.value?.collection.totalDebit ??
                old.totalDebit ??
                0,
            outStandingAmount:
                collectionDetails.value?.collection.outStandingAmount ??
                    old.outStandingAmount ??
                    0,
          );

          collectionDetails.value = CollectionDetailsModel(
            collection: collectionsList[idx],
            members: collectionDetails.value?.members ?? [],
            transactions: collectionDetails.value?.transactions ?? [],
          );
        }

        return true;
      }
    } catch (e) {
      debugPrint("updateCollection error: $e");
    }
    return false;
  }

  // =========================
  // CLOSE COLLECTION
  // =========================
  Future<bool> closeCollection(String id) async {
    try {
      final response =
          await updateDataApiCallPut(CollectionsRoute.closeCollection(id));

      if (getFlagOfResponse(response)) {
        /// Update status locally — no full reload needed
        final idx = collectionsList.indexWhere((e) => e.id == id);
        if (idx != -1) {
          final old = collectionsList[idx];
          collectionsList[idx] = CollectionModel(
            id: old.id,
            name: old.name,
            type: old.type,
            ownerId: old.ownerId,
            description: old.description,
            expiryAt: old.expiryAt,
            status: "closed",
            totalAmount: collectionDetails.value?.collection.totalAmount ??
                old.totalAmount ??
                0,
            totalCredit: collectionDetails.value?.collection.totalCredit ??
                old.totalCredit ??
                0,
            totalDebit: collectionDetails.value?.collection.totalDebit ??
                old.totalDebit ??
                0,
            outStandingAmount:
                collectionDetails.value?.collection.outStandingAmount ??
                    old.outStandingAmount ??
                    0,
          );
        }
        return true;
      }
    } catch (e) {
      debugPrint("closeCollection error: $e");
    }
    return false;
  }

  Future<void> getPendingInvitations() async {
    try {
      isInvitationLoading.value = true;

      final response = await getDataApiCall(
        CollectionsRoute.getPendingInvitations(),
      );

      if (getFlagOfResponse(response)) {
        final data = json.decode(response.body);

        final list = (data['data']['invitations'] as List? ?? [])
            .map((e) => InvitationModel.fromJson(e))
            .toList();

        invitationsList.assignAll(list);
      }
    } catch (e) {
      debugPrint("getPendingInvitations error: $e");
    } finally {
      isInvitationLoading.value = false;
    }
  }

  Future<void> acceptInvitation(String invitationId) async {
    try {
      final response = await postDataApiCall(
        CollectionsRoute.acceptInvitation(invitationId),
        {},
      );

      if (getFlagOfResponse(response)) {
        invitationsList.removeWhere((e) => e.id == invitationId);

        /// Refresh collections also
        await getCollections(forceRefresh: true);
      }
    } catch (e) {
      debugPrint("acceptInvitation error: $e");
    }
  }

  Future<void> rejectInvitation(String invitationId) async {
    try {
      final response = await postDataApiCall(
        CollectionsRoute.rejectInvitation(invitationId),
        {},
      );

      if (getFlagOfResponse(response)) {
        invitationsList.removeWhere((e) => e.id == invitationId);
      }
    } catch (e) {
      debugPrint("rejectInvitation error: $e");
    }
  }

  // =========================
// UPDATE MEMBER ROLE
// =========================
  Future<void> updateMemberRole({
    required String collectionId,
    required String userId,
    required dynamic body,
  }) async {
    try {
      final response = await updateDataApiCall2(
        CollectionsRoute.updateMemberRole(collectionId, userId),
        body,
      );

      if (getFlagOfResponse(response)) {
        await refreshCollectionData(collectionId);
      }
    } catch (e) {
      debugPrint("updateMemberRole error: $e");
    }
  }

  void clearAllData() {
    /// 🔥 MAIN DATA
    collectionsList.clear();
    selectedCollection.value = null;
    collectionDetails.value = null;

    /// 🔥 LISTS
    splitsList.clear();
    balancesList.clear();
    availableTransactions.clear();
    AllTransactions.clear();
    SeletedTransactionsList.clear();
    selectedTransactions.clear();

    /// 🔥 INVITATIONS
    invitationsList.clear();

    /// 🔥 FLAGS
    isLoading.value = false;
    isSplitLoading.value = false;
    isBalanceLoading.value = false;
    isMemberLoading.value = false;
    isInvitationLoading.value = false;

    /// 🔥 CURRENT USER
    currentUser = null;

    debugPrint("✅ CollectionsController fully cleared");
  }

  Future<void> getAllCollectionsTransactions(
      {int page = 1, int limit = 20}) async {
    try {
      isSplitLoading.value = true;

      if (collectionDetails.value == null) return;

      final response = await getDataApiCall(
        CollectionsRoute.getAvailableTransactions(
          collectionDetails.value!.collection.id,
          page: page,
          limit: limit,
        ),
      );

      if (getFlagOfResponse(response)) {
        final data = json.decode(response.body);
        final list = TransactionModel.listFromJson(data["data"]["transactions"]);
        AllTransactions.addAll(list);
      }
    } catch (e) {
      debugPrint("getAllCollectionsTransactions error: $e");
    } finally {
      isSplitLoading.value = false;
    }
  }
}
