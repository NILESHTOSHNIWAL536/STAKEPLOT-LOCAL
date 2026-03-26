import 'dart:convert';
import 'package:get/get.dart';

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
  RxList<Transaction> SeletedTransactionsList = <Transaction>[].obs;
  RxList<String> selectedTransactions = <String>[].obs;

  // ✅ check if data loaded
  bool get hasCollectionDetails => collectionDetails.value != null;

// ✅ check transactions empty
  bool get hasTransactions =>
      collectionDetails.value != null &&
      collectionDetails.value!.transactions.isNotEmpty;

// ✅ check members
  bool get hasMembers =>
      collectionDetails.value != null &&
      collectionDetails.value!.members.isNotEmpty;

// ✅ check splits
  bool get hasSplits =>
      collectionDetails.value != null &&
      collectionDetails.value!.splits.isNotEmpty;

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

        // 🔥 SAFETY CHECK
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
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // GET COLLECTION BY ID
  // =========================
  Future<void> getCollectionById(String id) async {
    try {
      isLoading.value = true;

      var response =
          await getDataApiCall(CollectionsRoute.getCollectionById(id));

      if (getFlagOfResponse(response)) {
        var data = json.decode(response.body);
        collectionDetails.value = CollectionDetailsModel.fromJson(data['data']);
      }
    } catch (e) {
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // CREATE COLLECTION
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
      print(e);
    } finally {
      isSplitLoading.value = false;
    }
  }

  Future<void> getAllCollectionsTransactions() async {
    try {
      isSplitLoading.value = true;

      var response = await getDataApiCall(
          CollectionsRoute.getAvailableTransactions(
              collectionDetails.value!.collection.id));

      if (getFlagOfResponse(response)) {
        var data = json.decode(response.body);
        print(data);
        print(data["data"]["transactions"]);

        // splitsList.value = TransactionModel().listFromJson();
        List<TransactionModel> modalObj =
            TransactionModel.listFromJson(data["data"]["transactions"]);
        AllTransactions.clear();
        AllTransactions.addAll(modalObj);
      }
    } catch (e) {
      print(e);
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
  }) async {
    var body = {
      "transactionIds": transactionIds,
      "splitType": splitType,
    };

    if (splitType == "CUSTOM") {
      body["customSplits"] = customSplits ?? [];
    }

    await postDataApiCall(CollectionsRoute.addTransaction(collectionId), body);

    await getSplits(collectionId);
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
      print(e);
    } finally {
      isBalanceLoading.value = false;
    }
  }
}
