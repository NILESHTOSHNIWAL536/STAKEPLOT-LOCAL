import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';
import '../Home_Screen/ManuallyTransactions/collections_manualtransactions.dart';
import '../Home_Screen/history/collections/collections_HomePage.dart';
import '../Home_Screen/history/collections/trip/screens/shared_dashboard_screen.dart';
import '../Home_Screen/history/transactionHistoryScreen.dart';
import '../Utils/durations_range.dart';
import '../Utils/navigateTo.dart';
import '../Utils/socket_connect.dart';
import '../backed_connections/apiAutomations/curd.dart';
import '../components/shared_utils.dart';
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
  RxString selectedCollectionId = ''.obs;
  RxBool canAddTransactions = true.obs;

  // =========================
  // DATA
  // =========================
  final RxList<CollectionModel> collectionsList = <CollectionModel>[].obs;
  final Rx<CollectionModel?> selectedCollection = Rx<CollectionModel?>(null);
  final Rx<CollectionDetailsModel?> collectionDetails =
      Rx<CollectionDetailsModel?>(null);

  final RxList<SplitModel> splitsList = <SplitModel>[].obs;
  final RxList<BalanceModel> balancesListPay = <BalanceModel>[].obs;
  // final RxList<BalanceModel> balancesList = <BalanceModel>[].obs;
  final RxList<BalanceModel> balancesListReceive = <BalanceModel>[].obs;
  final RxDouble totalToPay = 0.0.obs;
  final RxDouble totalToReceive = 0.0.obs;

  final RxList<CollectionTransactionModel> availableTransactions =
      <CollectionTransactionModel>[].obs;

  final RxSet<String> selectedUserIds = <String>{}.obs;

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

  // =========================
  // GET COLLECTION BY ID
  // =========================
  Future<void> getCollectionById(String id, BuildContext context,
      [bool forceRefresh = false]) async {
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

      if (forceRefresh) {
        isLoading.value = false;
        _isFetchingDetails = false;
        return;
      }

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

      balancesListReceive.clear();
      balancesListPay.clear();
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
        "friends": friends
      };
      final createRes =
          await postDataApiCall(CollectionsRoute.createCollection, body);

      if (!getFlagOfResponse(createRes)) {
        final resData = json.decode(createRes.body);
        snackBarCalledfail(
            context,
            resData["error"] ??
                "Failed to create collection. Please try again.");
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
  Future<void> deleteCollection(
      String id, BuildContext context, String type) async {
    try {
      String url = type == "exit"
          ? CollectionsRoute.exitCollection(id)
          : CollectionsRoute.deleteCollection(id);

      final response = await deleteDataApiCall(url);

      if (getFlagOfResponse(response)) {
        /// Batch clear
        collectionDetails.value = null;
        selectedCollection.value = null;
        splitsList.clear();
        balancesListPay.clear();
        balancesListReceive.clear();
        collectionsList.removeWhere((e) => e.id == id);
        AppNavigator.pushReplacement(context, TransactionHistoryScreen());
      }
    } catch (e) {
      debugPrint("deleteCollection error: $e");
    }
  }

  Future<void> reopenCollections(String id, BuildContext context) async {
    try {
      String url = CollectionsRoute.reopenCollection(id);

      final response = await updateDataApiCall(url);

      if (getFlagOfResponse(response)) {
        /// Batch clear
        collectionDetails.value = null;
        selectedCollection.value = null;
        splitsList.clear();
        balancesListPay.clear();
        balancesListReceive.clear();
        collectionsList.removeWhere((e) => e.id == id);
        AppNavigator.pushReplacement(context, TransactionHistoryScreen());
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
    required bool clearn,
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
    final data = json.decode(response.body);
    if (getFlagOfResponse(response)) {
      selectedTransactions.clear();
      SeletedTransactionsList.clear();
      selectedCollectionId.value = "";
      await refreshCollectionData(collectionId);
      emitCollectionsOnSocket(
          "collection", {"id": collectionId, "action": "update"});
      snackBarCalled(context, data['message'] ?? "Added Success!");

      if (clearn) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
      Navigator.pop(context);
      return true;
    } else if (response.statusCode == 400) {
      snackBarCalledfail(context, data['error']);
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
        // final data = json.decode(response.body)['data'];

        // List<BalanceModel> tempList = [];

        // /// ✅ TO PAY
        // final toPayList = data['toPay'] as List? ?? [];
        // for (var item in toPayList) {
        //   tempList.add(BalanceModel.fromJson(item, "toPay"));
        // }

        // /// ✅ TO RECEIVE
        // final toReceiveList = data['toReceive'] as List? ?? [];
        // for (var item in toReceiveList) {
        //   tempList.add(BalanceModel.fromJson(item, "toReceive"));
        // }

        final dataJson = json.decode(response.body)['data'];

        final balanceData = BalanceDataModel.fromJson(dataJson);
        // balancesList.assignAll(tempList);

        /// 🔥 If you want single combined list
        // List<BalanceModel> combinedList = [
        //   ...balanceData.toPay,
        //   ...balanceData.toReceive,
        // ];

        // /// ✅ Store
        // balancesList.clear();
        // balancesList.assignAll(combinedList);

        balancesListPay.clear();
        balancesListReceive.clear();

        balancesListPay.addAll(balanceData.toPay);
        balancesListReceive.addAll(balanceData.toReceive);

        /// Optional totals
        totalToPay.value = balanceData.totalToPay;
        totalToReceive.value = balanceData.totalToReceive;
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
    bool active = false,
    required BuildContext context,
  }) async {
    try {
      final body = <String, dynamic>{
        if (name != null) "name": name,
        if (duration != null) "expiryAt": getIsoDateFromDuration(duration),
        "active": active
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
            status: active ? "ACTIVE" : old.status,
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
            members: collectionDetails.value?.collection.members ?? [],
          );

          collectionDetails.value = CollectionDetailsModel(
            collection: collectionsList[idx],
            members: collectionDetails.value?.members ?? [],
            transactions: collectionDetails.value?.transactions ?? [],
          );
          if (active) {
            collectionsController.collectionDetails.value?.collection.status =
                "ACTIVE";
          }
          emitCollectionsOnSocket("collection", {"id": id, "action": "update"});
        }

        return true;
      } else {
        snackBarCalledfail(
            context, json.decode(response.body)['error'] ?? "Error");
      }
    } catch (e) {
      debugPrint("updateCollection error: $e");
    }
    return false;
  }

  // =========================
  // CLOSE COLLECTION
  // =========================
  Future<bool> closeCollection(String id, BuildContext context) async {
    try {
      final response =
          await updateDataApiCall(CollectionsRoute.closeCollection(id));

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
            members: collectionDetails.value?.collection.members ?? [],
          );
          AppNavigator.pushReplacement(context, TransactionHistoryScreen());
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

  Future<void> acceptInvitation(
      String invitationId, BuildContext context) async {
    try {
      final response = await postDataApiCall(
        CollectionsRoute.acceptInvitation(invitationId),
        {},
      );

      if (getFlagOfResponse(response)) {
        invitationsList.removeWhere((e) => e.id == invitationId);

        /// Refresh collections also
        await getCollections(forceRefresh: true);

        // AppNavigator.pushReplacementNamed(context, '/Collections');
      }
    } catch (e) {
      debugPrint("acceptInvitation error: $e");
    }
  }

  void emitCollectionsOnSocket(String type, jsonData) {
    final socket = SocketService().getSocket();
    socket.emit(type, jsonData);
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

  Future<void> updateMemberLimit(
      {required dynamic body, required BuildContext context}) async {
    try {
      String collectionId =
          collectionsController.collectionDetails.value!.collection.id;
      final response = await updateDataApiCall2(CollectionsRoute.updateMemberLimit(collectionId),{"limits": body},);

      if (getFlagOfResponse(response)) {
        await refreshCollectionData(collectionId);
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("updateMemberRole error: $e");
    }
  }

  void clearAllData() {
    /// 🔥 MAIN DATA
    selectedTab.value = "All";
    collectionsList.clear();
    selectedCollection.value = null;
    collectionDetails.value = null;

    /// 🔥 LISTS
    splitsList.clear();
    balancesListPay.clear();
    balancesListReceive.clear();
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
        final list =
            TransactionModel.listFromJson(data["data"]["transactions"]);
        AllTransactions.addAll(list);
      }
    } catch (e) {
      debugPrint("getAllCollectionsTransactions error: $e");
    } finally {
      isSplitLoading.value = false;
    }
  }

  void socketMessage(dynamic data, BuildContext context) {
    if (data == null || data['type'] == null) return;

    final type = data['type'];

    if (type == "splitUpdate") {
      getSplits(collectionDetails.value!.collection.id);
      getBalances(collectionDetails.value!.collection.id);
      if (data["data"]["collection"]['collectionDetails']['collection'] != null)
        updateCollectionByIdSocket(
            data["data"]["collection"]['collectionDetails']);
      return;
    }

    if (type == "AcceptInvitation") {
      getCollectionById(data['collectionId'], context, true);
      return;
    }
    if (type == "updatedMember") {
      var collection = data["data"]["members"];
      _updateMember(collection);
      return;
    }

    final collectionData = data['data']?['collection'];

    if (collectionData == null) return;

    final id = collectionData['_id'];

    switch (type) {
      case "nameUpdate":
        _updateCollectionField(id, name: collectionData['name']);
        break;

      case "descriptionUpdate":
        _updateCollectionField(id, description: collectionData['description']);
        break;

      case "expiryUpdate":
        _updateCollectionField(
          id,
          expiryAt: collectionData['expiryAt'],
        );
        break;

      case "update":
        refreshCollectionData(id); // fallback
        break;

      default:
        refreshCollectionData(id);
    }
  }

  void updateCollectionByIdSocket(collection) {
    try {
      final details = CollectionDetailsModel.fromJson(collection);
      collectionDetails.value = details;
      selectedCollection.value = details.collection;
    } catch (e) {
      appLog(e);
    }
  }

  void _updateCollectionField(
    String id, {
    String? name,
    String? description,
    String? expiryAt,
  }) {
    /// ✅ Update collectionDetails
    if (collectionDetails.value?.collection.id == id) {
      final old = collectionDetails.value!;

      collectionDetails.value = CollectionDetailsModel(
        collection: CollectionModel(
          id: old.collection.id,
          name: name ?? old.collection.name,
          type: old.collection.type,
          ownerId: old.collection.ownerId,
          description: description ?? old.collection.description,
          expiryAt: expiryAt != null
              ? DateTime.tryParse(expiryAt)
              : old.collection.expiryAt,
          status: old.collection.status,
          totalAmount: old.collection.totalAmount,
          totalCredit: old.collection.totalCredit,
          totalDebit: old.collection.totalDebit,
          outStandingAmount: old.collection.outStandingAmount,
          members: old.collection.members,
        ),
        members: old.members,
        transactions: old.transactions,
      );
    }

    /// ✅ Update collectionsList
    final index = collectionsList.indexWhere((e) => e.id == id);

    if (index != -1) {
      final old = collectionsList[index];

      collectionsList[index] = CollectionModel(
        id: old.id,
        name: name ?? old.name,
        type: old.type,
        ownerId: old.ownerId,
        description: description ?? old.description,
        expiryAt: expiryAt != null ? DateTime.tryParse(expiryAt) : old.expiryAt,
        status: old.status,
        totalAmount: old.totalAmount,
        totalCredit: old.totalCredit,
        totalDebit: old.totalDebit,
        outStandingAmount: old.outStandingAmount,
        members: old.members,
      );
    }
  }

  void clearSplit(String splitId, double amount) async {
    try {
      String id = collectionDetails.value!.collection.id;
      final response = await postDataApiCall(
        CollectionsRoute.paySplit(id, splitId),
        {"amount": amount},
      );
      if (getFlagOfResponse(response)) {
        getBalances(id);
      }
    } catch (e) {
      debugPrint("rejectInvitation error: $e");
    }
  }

  void clearSplitAmountComplete(
      String splitId, double amount, String playerId) async {
    try {
      String id = collectionDetails.value!.collection.id;
      final response = await postDataApiCall(
        CollectionsRoute.clearPayment(id, splitId),
        {"amount": amount, "payerId": playerId},
      );
      if (getFlagOfResponse(response)) {
        getBalances(id);
      }
    } catch (e) {
      debugPrint("rejectInvitation error: $e");
    }
  }

  void _updateMember(dynamic memberData) {
    if (memberData == null) return;

    final memberId = memberData["_id"];

    /// ✅ Update collectionDetails.members
    if (collectionDetails.value != null) {
      final oldDetails = collectionDetails.value!;

      final members = List<MemberModel>.from(oldDetails.members);

      final index = members.indexWhere((m) => m.id == memberId);

      if (index != -1) {
        final old = members[index];

        members[index] = MemberModel(
          id: old.id,
          collectionId: old.collectionId,
          userId: old.userId,
          name: memberData["user"]?["name"] ?? old.name,
          role: memberData["role"] ?? old.role,
          setAmount: (memberData["limitAmount"] ?? old.setAmount).toString(),
          amountSpend: old.amountSpend, // unchanged
        );
      } else {
        /// 🔥 If new member (optional)
        members.add(MemberModel(
          id: memberData["_id"],
          collectionId: memberData["collectionId"],
          userId: memberData["userId"],
          name: memberData["user"]?["name"] ?? "",
          role: memberData["role"] ?? "VIEW",
          setAmount: (memberData["limitAmount"] ?? 0).toString(),
          amountSpend: "0",
        ));
      }

      /// 🔥 Reassign (VERY IMPORTANT)
      collectionDetails.value = CollectionDetailsModel(
        collection: oldDetails.collection,
        members: members,
        transactions: oldDetails.transactions,
      );
    }
  }

  Future<void> splitManulaTansactions(String transactionId, context) async {
    final List<Map<String, dynamic>> members =
        collectionDetails.value!.members.where((e) {
      final text = controllersList[e.userId]?.text;
      final value = double.tryParse(text ?? '');
      return value != null && value > 0;
    }).map((e) {
      return {
        "userId": e.userId,
        "amount": double.parse(controllersList[e.userId]!.text),
      };
    }).toList();

    await addTransaction(
        collectionId: selectedCollectionId.value,
        transactionIds: [transactionId],
        splitType: "CUSTOM",
        context: context,
        customSplits: members,
        clearn: false);

    controllersList.clear();
  }

  Future<void> fetchCollectionMembers(String collectionId) async {
    //   try {
    //     setState(() => isCollectionLoading = true);

    //     var response = await getDataApiCall(
    //       CollectionsRoute.getCollectionById(collectionId),
    //     );

    //     if (getFlagOfResponse(response)) {
    //       var data = json.decode(response.body);

    //       setState(() {
    //         collectionMembers = data['data']['members'] ?? [];

    //         // ✅ ADD THIS
    //         memberAmounts.clear();

    //         double total =
    //             double.tryParse(_amountController.text.toString()) ?? 0;

    //         if (collectionMembers.isNotEmpty && total > 0) {
    //           double split = total / collectionMembers.length;

    //           for (var m in collectionMembers) {
    //             memberAmounts[m['user']['id']] = split;
    //           }
    //         }
    //       });
    //     }
    //   } catch (e) {
    //     debugPrint("fetchCollectionMembers error: $e");
    //   } finally {
    //     setState(() => isCollectionLoading = false);
    //   }
  }
}
