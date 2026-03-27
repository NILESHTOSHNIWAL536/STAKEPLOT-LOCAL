import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Home_Screen/history/collections/collections_empty_page.dart';
import '../Home_Screen/history/collections/group_collections_page.dart';
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

  // ✅ check if data loaded
  bool get hasCollectionDetails => collectionDetails.value != null;

  // ✅ check transactions empty
  bool get hasTransactions => splitsList.isNotEmpty;

  // ✅ check members
  bool get hasMembers =>
      collectionDetails.value != null &&
      collectionDetails.value!.members.isNotEmpty;

  // =========================
  // GET COLLECTIONS
  // =========================
  Future<void> getCollections() async {
    try {
      isLoading.value = true;

      var response = await getDataApiCall(CollectionsRoute.getCollections);

      print("RAW RESPONSE: ${response.body}");

      if (getFlagOfResponse(response)) {
        var decoded = json.decode(response.body);

        if (decoded['data'] != null && decoded['data'] is List) {
          List list = decoded['data'];

          collectionsList.clear();

          for (var item in list) {
            try {
              collectionsList.add(CollectionModel.fromJson(item));
            } catch (e) {
              print("Model Parse Error: $e");
              print("Bad Item: $item");
            }
          }

          print("FINAL LIST: ${collectionsList.length}");
        } else {
          print("Data is not List ❌: ${decoded['data']}");
        }
      }
    } catch (e) {
      print("getCollections error: $e");
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
      var response =
          await getDataApiCall(CollectionsRoute.getCollectionById(id));
      if (getFlagOfResponse(response)) {
        var data = json.decode(response.body);
        collectionDetails.value = CollectionDetailsModel.fromJson(data['data']);
        selectedCollection.value = collectionDetails.value?.collection;
        await getSplits(id);
        await getBalances(id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CollectionDetailsPage(
              title: collectionDetails.value!.collection.name,
              hasTransactions: true,
            ),
          ),
        );
      }
    } catch (e) {
      print("getCollectionById error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // REFRESH COLLECTION DATA
  // =========================
  /// Reloads collection details, splits, and balances in one shot.
  Future<void> refreshCollectionData(String collectionId) async {
    try {
      isLoading.value = true;
      final response =
          await getDataApiCall(CollectionsRoute.getCollectionById(collectionId));
      if (getFlagOfResponse(response)) {
        final data = json.decode(response.body);
        collectionDetails.value = CollectionDetailsModel.fromJson(data['data']);
        selectedCollection.value = collectionDetails.value?.collection;
      }
      await getSplits(collectionId);
      await getBalances(collectionId);
    } catch (e) {
      print("refreshCollectionData error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // CREATE COLLECTION (simple)
  // =========================
  Future<void> createCollection({
    required String name,
    required String type,
    String description = "",
  }) async {
    var body = {
      "name": name,
      "type": type,
      "description": description,
    };

    await postDataApiCall(CollectionsRoute.createCollection, body);
    await getCollections();
  }

  // =========================
  // CREATE COLLECTION + ADD MEMBERS
  // =========================
  /// Creates a collection then adds friends as members.
  /// [friends] is a list of {"friendId": ..., "role": ...} maps.
  /// Returns the new collection ID, or null on failure.
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
      };
      if (expiryAt != null) body["expiryAt"] = expiryAt;

      final createRes =
          await postDataApiCall(CollectionsRoute.createCollection, body);

      if (!getFlagOfResponse(createRes)) {
        print("❌ createCollection failed: ${createRes.body}");
        return null;
      }

      final resData = json.decode(createRes.body);
      final newId = resData["data"]["_id"] as String;

      // Add members only for shared collections
      if (friends.isNotEmpty) {
        final memberRes = await postDataApiCall(
          CollectionsRoute.addMember(newId),
          {"friends": friends},
        );
        if (!getFlagOfResponse(memberRes)) {
          print("⚠️ addMember failed: ${memberRes.body}");
        }
      }

      await getCollections();
      return newId;
    } catch (e) {
      print("createCollectionWithMembers error: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // DELETE COLLECTION
  // =========================
  Future<void> deleteCollection(String id) async {
    await deleteDataApiCall(CollectionsRoute.deleteCollection(id));
    collectionsList.removeWhere((e) => e.id == id);
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
      print("getSplits error: $e");
    } finally {
      isSplitLoading.value = false;
    }
  }

  // =========================
  // GET AVAILABLE TRANSACTIONS
  // =========================
  Future<void> getAllCollectionsTransactions() async {
    try {
      isSplitLoading.value = true;

      var response = await getDataApiCall(
          CollectionsRoute.getAvailableTransactions(
              collectionDetails.value!.collection.id));

      if (getFlagOfResponse(response)) {
        var data = json.decode(response.body);
        List<TransactionModel> modalObj =
            TransactionModel.listFromJson(data["data"]["transactions"]);
        AllTransactions.clear();
        AllTransactions.addAll(modalObj);
        await getSplits(collectionDetails.value!.collection.id);
      }
    } catch (e) {
      print("getAllCollectionsTransactions error: $e");
    } finally {
      isSplitLoading.value = false;
    }
  }

  // =========================
  // ADD TRANSACTION + SPLIT
  // =========================
  Future<void> addTransaction({
    required String collectionId,
    required List<String> transactionIds,
    required String splitType,
    List<dynamic>? customSplits,
    BuildContext? context,
  }) async {
    var body = <String, dynamic>{
      "transactionIds": transactionIds,
      "splitType": splitType,
    };

    if (splitType == "CUSTOM" && customSplits != null) {
      body["customSplits"] = customSplits;
    }

    var response = await postDataApiCall(
        CollectionsRoute.addTransaction(collectionId), body);

    if (getFlagOfResponse(response)) {
      // Reset selection state
      selectedTransactions.clear();
      SeletedTransactionsList.clear();
      // Refresh all collection data
      await refreshCollectionData(collectionId);
      // Pop all split screens back to dashboard
      if (context != null && context.mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } else {
      print("❌ addTransaction failed: ${response.body}");
      Get.snackbar(
        "Error",
        "Failed to add transaction. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // =========================
  // UPDATE SPLIT
  // =========================
  Future<void> updateSplit({
    required String collectionId,
    required String splitId,
    required List<Map<String, dynamic>> customSplits,
  }) async {
    var body = {
      "customSplits": customSplits,
    };

    await updateDataApiCall2(
      CollectionsRoute.updateSplit(collectionId, splitId),
      body,
    );

    await getSplits(collectionId);
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
      print("getBalances error: $e");
    } finally {
      isBalanceLoading.value = false;
    }
  }
}
