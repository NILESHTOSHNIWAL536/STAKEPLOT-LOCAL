import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Home_Screen/history/collections/collections_empty_page.dart';
import '../Home_Screen/history/collections/trip/screens/trip_dashboard_screen.dart';
import '../backed_connections/apiAutomations/curd.dart';
import '../model/TransactionModel.dart';
import '../model/collections_model.dart';
import '../routes/route_collections.dart';

class CollectionsController extends GetxController {
  // =========================
  // LOADING STATES
  // =========================
  RxBool isLoading = false.obs;
  RxBool isSplitLoading = false.obs;
  RxBool isBalanceLoading = false.obs;
  RxBool isMemberLoading = false.obs;

  // =========================
  // DATA
  // =========================
  RxList<CollectionModel> collectionsList = <CollectionModel>[].obs;
  Rx<CollectionModel?> selectedCollection = Rx<CollectionModel?>(null);
  Rx<CollectionDetailsModel?> collectionDetails =
      Rx<CollectionDetailsModel?>(null);

  RxList<SplitModel> splitsList = <SplitModel>[].obs;
  RxList<BalanceModel> balancesList = <BalanceModel>[].obs;

  RxList<CollectionTransactionModel> availableTransactions =
      <CollectionTransactionModel>[].obs;

  RxList<TransactionModel> AllTransactions = <TransactionModel>[].obs;
  RxList<TransactionModel> SeletedTransactionsList = <TransactionModel>[].obs;
  RxList<String> selectedTransactions = <String>[].obs;

  // ✅ Computed helpers
  bool get hasCollectionDetails => collectionDetails.value != null;
  bool get hasTransactions => splitsList.isNotEmpty;
  bool get hasMembers =>
      collectionDetails.value != null &&
      collectionDetails.value!.members.isNotEmpty;

  // =========================
  // GET COLLECTIONS LIST
  // =========================
  Future<void> getCollections() async {
    try {
      isLoading.value = true;

      var response = await getDataApiCall(CollectionsRoute.getCollections);

      if (getFlagOfResponse(response)) {
        var decoded = json.decode(response.body);

        if (decoded['data'] != null && decoded['data'] is List) {
          List list = decoded['data'];
          collectionsList.clear();

          for (var item in list) {
            try {
              collectionsList.add(CollectionModel.fromJson(item));
            } catch (e) {
              debugPrint("CollectionModel parse error: $e — item: $item");
            }
          }
        }
      }
    } catch (e) {
      debugPrint("getCollections error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // GET COLLECTION BY ID
  // =========================
  Future<void> getCollectionById(String id, BuildContext context) async {
    try {
      isLoading.value = true;
      splitsList.clear();
      balancesList.clear();
      AllTransactions.clear();

      var response =
          await getDataApiCall(CollectionsRoute.getCollectionById(id));
      if (getFlagOfResponse(response)) {
        var data = json.decode(response.body);
        collectionDetails.value =
            CollectionDetailsModel.fromJson(data['data']);
        selectedCollection.value = collectionDetails.value?.collection;

        // Load splits and balances in parallel
        await Future.wait([
          getSplits(id),
          getBalances(id),
          getAllCollectionsTransactions(),
        ]);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CollectionDetailsPage(
              title: collectionDetails.value!.collection.name,
              hasTransactions: splitsList.isNotEmpty,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("getCollectionById error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // CREATE COLLECTION
  // =========================
  Future<bool> createCollection({
    required String name,
    required String type,
    String description = "",
    String? expiryAt,
  }) async {
    try {
      var body = {
        "name": name,
        "type": type,
        "description": description,
        if (expiryAt != null) "expiryAt": expiryAt,
      };

      var response =
          await postDataApiCall(CollectionsRoute.createCollection, body);
      if (getFlagOfResponse(response)) {
        await getCollections();
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

      var body = {"friends": friends};
      var response = await postDataApiCall(
          CollectionsRoute.addMember(collectionId), body);

      if (getFlagOfResponse(response)) {
        // Refresh collection details to get updated members list
        var detailsResponse =
            await getDataApiCall(CollectionsRoute.getCollectionById(collectionId));
        if (getFlagOfResponse(detailsResponse)) {
          var data = json.decode(detailsResponse.body);
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
  // DELETE COLLECTION
  // =========================
  Future<void> deleteCollection(String id, {BuildContext? context}) async {
    try {
      var response =
          await deleteDataApiCall(CollectionsRoute.deleteCollection(id));
      if (getFlagOfResponse(response)) {
        collectionsList.removeWhere((e) => e.id == id);
        collectionDetails.value = null;
        selectedCollection.value = null;
        splitsList.clear();
        balancesList.clear();

        if (context != null && context.mounted) {
          // Pop back to collections list (pop 2 screens: settings modal + detail page)
          Navigator.popUntil(context, (route) => route.isFirst);
        }
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

      var response =
          await getDataApiCall(CollectionsRoute.getSplits(collectionId));

      if (getFlagOfResponse(response)) {
        var data = json.decode(response.body);
        splitsList.value =
            (data['data'] as List).map((e) => SplitModel.fromJson(e)).toList();
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
  Future<void> getAllCollectionsTransactions({int page = 1, int limit = 20}) async {
    try {
      isSplitLoading.value = true;

      if (collectionDetails.value == null) return;

      var response = await getDataApiCall(
          CollectionsRoute.getAvailableTransactions(
              collectionDetails.value!.collection.id,
              page: page,
              limit: limit));

      if (getFlagOfResponse(response)) {
        var data = json.decode(response.body);
        List<TransactionModel> modalObj =
            TransactionModel.listFromJson(data["data"]["transactions"]);
        AllTransactions.clear();
        AllTransactions.addAll(modalObj);
      }
    } catch (e) {
      debugPrint("getAllCollectionsTransactions error: $e");
    } finally {
      isSplitLoading.value = false;
    }
  }

  // =========================
  // ADD TRANSACTION + SPLIT
  // =========================
  Future<bool> addTransaction({
    required String collectionId,
    required List<String> transactionIds,
    required String splitType,
    List<dynamic>? customSplits,
  }) async {
    try {
      var body = {
        "transactionIds": transactionIds,
        "splitType": splitType,
        if (splitType == "CUSTOM" && customSplits != null)
          "customSplits": customSplits,
      };

      var response = await postDataApiCall(
          CollectionsRoute.addTransaction(collectionId), body);

      if (getFlagOfResponse(response)) {
        // Refresh all data after successful transaction add
        await Future.wait([
          getSplits(collectionId),
          getBalances(collectionId),
          getAllCollectionsTransactions(),
        ]);
        return true;
      }
    } catch (e) {
      debugPrint("addTransaction error: $e");
    }
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
      var body = {"customSplits": customSplits};

      var response = await updateDataApiCall2(
        CollectionsRoute.updateSplit(collectionId, splitId),
        body,
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

      var response =
          await getDataApiCall(CollectionsRoute.getBalances(collectionId));

      if (getFlagOfResponse(response)) {
        var data = json.decode(response.body);
        balancesList.value = (data['data'] as List)
            .map((e) => BalanceModel.fromJson(e))
            .toList();
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
  /// Call this after any mutation (add transaction, update split) to refresh
  /// the dashboard's splits, balances, and available transactions.
  Future<void> refreshDashboard(String collectionId) async {
    await Future.wait([
      getSplits(collectionId),
      getBalances(collectionId),
      getAllCollectionsTransactions(),
    ]);
  }
}
