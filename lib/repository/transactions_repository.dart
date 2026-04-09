
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/repository/group_Api.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/transactions_apis.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/weeklyPopUp.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionHistoryScreen.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter_application_code_stakeplot/repository/budget_apis.dart';
import 'package:flutter_application_code_stakeplot/repository/clearstack.dart';
import 'package:flutter_application_code_stakeplot/routes/route_transactions.dart';
import 'package:get/get.dart';

import '../Constants/app_styles.dart';
import '../controllers/transactions_controller.dart';
import 'bankinfo.dart';





void updateFromResponse(Map<String, dynamic> obj) {
  // Clear existing data
  try {
    matchedKeywords.clear();
    lastWeekjson.clear();
    lastmonthjson.clear();
    matchedKeywords.addAll(List<String>.from(
        (obj['matchedKeywords'] ?? []).map((e) => e.toString())));
    lastWeekjson.addAll(obj['lastWeek'] ?? {});
    lastmonthjson.addAll(obj['lastMonth'] ?? {});
  } catch (e) {}
}

void extractTransaction(bool isYearView, List obj) {
  if (isYearView) {
    getTransactionByYear(obj, selectedYear.value);
  } else {
    getTransactionByMonth(obj, selectedMonth.value);
  }
}

void getTransactionByYear(List obj, y) {
  obj.forEach((ele) {
    if (isCurrentYear(ele['transactionTimestamp'], y)) {
      transactionsHistory.add(ele);
    }
  });
}

void getTransactionByMonth(List obj, y) {
  obj.forEach((ele) {
    if (isCurrentMonth(ele['transactionTimestamp'], y)) {
      transactionsHistory.add(ele);
    }
  });
}
void getAllTransaction(context) async {
  var response = await getDataApiCall(
      BankTransactionRoutes.getSearchedTransactions(
          page: currentPage, search: "empty", isBankAccount: "-"));
  expire(response, context);
  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    currentPage = 2;
    if (transactionsHistory.length < 20) {
      isLoadingMore.value = true;
    } else {
      isLoadingMore.value = false;
    }
    transactionsHistory.clear();
    transactionsHistory.addAll(obj);
    reloadHistory.value = !reloadHistory.value;
  } else {}
}



void getHiddenTransactions(context) async {
  var response =
      await getDataApiCall(BankTransactionRoutes.getHideTransactions);
  if (response.statusCode == 200) {
    var her = jsonDecode(response.body);
    var obj = her['data'];
    hiddentrasactionsHistory.clear();
    List<TransactionModel> modalObj = TransactionModel.listFromJson(obj);
    hiddentrasactionsHistory.addAll(modalObj);
    getHiddenHistory.value = !getHiddenHistory.value;
  } else {}
}

Future<void> getTopThreeTransactions(BuildContext context,
    WeeklyPopupController controller, String userId) async {
  try {
    // Include userId in the API call (adjust endpoint as per your API)
    var response = await getDataApiCall(
        "${BankTransactionRoutes.getTopThreeTransactionsOfWeek}?userId=$userId");
    if (response.statusCode == 200) {
      var her = jsonDecode(response.body);
      var obj = her['data'];
      controller.topThreeTransactions.clear();
      List<TransactionModel> modalObj = TransactionModel.listFromJson(obj);
      controller.topThreeTransactions.addAll(modalObj);
      getTopThreeHistory.value = !getTopThreeHistory.value;
    } else {}
  } catch (e) {}
}

Future<List<Map<String, dynamic>>> getDayWiseTransactions(context) async {
  var response =
      await getDataApiCall(BankTransactionRoutes.getDayWiseTransactionsSummary);

  if (response.statusCode == 200) {
    var her = jsonDecode(response.body);
    var obj = her['data'];
    if (obj is List) {
      return List<Map<String, dynamic>>.from(obj);
    }
  }
  return [];
}

Future<List<Map<String, dynamic>>> getDayWiseTransactionsForDate(
    context, String date) async {
  var response = await getDataApiCall(
    BankTransactionRoutes.getTransactionsByDate(date: date),
  );

  if (response.statusCode == 200) {
    var her = jsonDecode(response.body);
    var obj = her['data'];
    if (obj is List) {
      return List<Map<String, dynamic>>.from(obj);
    }
  }
  return [];
}

Future<void> getAllTransactionHistory(
    BuildContext context, bool flag, bool isYearView,
    {bool isRefreshing = false}) async {
        // final tx = Get.find<TransactionController>();
  if (isLoadingMore.value) return; // Prevent multiple API calls
  loadingDelay.value = true;
  try {
    isLoadingMore.value = true;
    String type = isYearView
        ? selectedYear.value.toString()
        : selectedYear.value.toString() +
            "-" +
            selectedMonth.value.toString().padLeft(2, '0');
    // searchTextController.value = tx.searchController.text.trim();
    // String text = tx.searchController.text.trim() == ""
    //     ? "empty"
    //     : (tx.searchController.text == "cash" ? "Cash" : tx.searchController.text);
    searchTextController.value = tnxSearchController.text.trim();
    String text = tnxSearchController.text.trim() == ""
        ? "empty"
        : (tnxSearchController.text == "cash" ? "Cash" : tnxSearchController.text);
    String urlPath = flag
        ? BankTransactionRoutes.getMonthlyTransactionsHistory(
            accountId: accountId.value,
            type: type,
            page: currentPage,
          )
        : BankTransactionRoutes.getSearchedTransactions(
           page: currentPage,
  search: text,
            isBankAccount: (accountSelected.value.isEmpty ||
                    bankAccountLinkedList.length == 1 ||
                    text.toLowerCase() == "cash")
                ? (text.toLowerCase() == "cash" ? "Cash" : "-")
                : accountSelected.value,
          );

    bool hasAmount = minController.text.trim().isNotEmpty &&
        maxController.text.trim().isNotEmpty &&
        checkRangeofAmount(context, false);

    bool hasDate = startDateController.text.trim().isNotEmpty &&
        endDateController.text.trim().isNotEmpty &&
        checkRangeofDate(context, false);

    var response = (flag || (!hasAmount && !hasDate))
        ? await getDataApiCall(urlPath)
        : await getTransactionsWithAmount(
            urlPath: urlPath,
            minAmount: hasAmount ? minController.text : "",
            maxAmount: hasAmount ? maxController.text : "",
            startDate: hasDate ? startDateController.text : "",
            endDate: hasDate ? endDateController.text : "",
          );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);      
      var obj = data['data'];
      if (obj != null) {
        if (isRefreshing) {
          transactionsHistory.clear(); // Clear only on refresh
        }

        List<TransactionModel> transactions =
            TransactionModel.listFromJson(obj['transactions']);

        if (!flag) {
          updateFromResponse(obj);
        }

        transactionsHistory.addAll(transactions);
        // Stop loading indicator if no more transactions exist
        if (obj['transactions'].isEmpty || obj['transactions'].length < 20) {
          hasMoreData = false;
          isLoadingMore.value = true;
          havingMoreData.value = false;
        } else {
          havingMoreData.value = true;
          isLoadingMore.value = false;
          currentPage++;
        }

        await Future.delayed(const Duration(seconds: 1));
        if (flag) {
          loadChatdataOnChnage.value = !loadChatdataOnChnage.value;
        }
        getHistory.value = !getHistory.value;
        unawaited(TransactionStorage.cacheTransactionsLocally());
      } else {
        snackBarCalled(context, SnackbarData().noTransactionData);
      }
    }
  } catch (e) {
    TransactionStorage.loadTransactionsFromHive();
  }

  loadingDelay.value = false;
}


void updateTheTagOfTransactions2(
    category, subCategory, transactionId, context, index) async {
  String urlPath = BankTransactionRoutes.updateTransaction(transactionId: transactionId);
  final budgetController = Get.find<BudgetController>();
  var response = await updateDataApiCall2(urlPath, {
    'category': category,
    'subcategory': subCategory,
  });
  if (getFlagOfResponse(response)) {
    Navigator.pop(context);
    reloadHistory.value = !reloadHistory.value;
    updateCatAndMoneyMap(context);
    budgetController.getBudget();
  } else {}
}


// this is used for updating the tag of transactions with predictions
Future<void> updateThePredictedTransactions(
  String category,
  String subCategory,
  String transactionId,
  BuildContext context,
  int index,
  TransactionModel transaction,
) async {
  String urlPath = BankTransactionRoutes.updateTransaction(transactionId: transactionId);

  // Construct selectedCategory
  final selectedCategory = {
    'category': category,
    'percentage': transaction.predictions != null
        ? _getPredictionScore(transaction.predictions!, category)
        : 0.0,
  };

  // Construct predictedCategories as a list of maps
  final predictedCategories = transaction.predictions != null
      ? transaction.predictions!.entries
          .map((entry) => {
                'category': entry.category,
                'percentage': entry.score,
              })
          .toList()
      : [];

  try {
    var response = await updateDataApiCall2(urlPath, {
      'category': category,
      'subcategory': subCategory,
      'selectedCategory': selectedCategory,
      'predictedCategories': predictedCategories,
    });

    if (getFlagOfResponse(response)) {
      // Update already applied optimistically, just show success
      snackBarCalled(context, "Transaction tagged as $category");
    } else {
      throw Exception(" update failed");
    }
  } catch (e) {
    // Rethrow to handle reversion in the caller
    rethrow;
  }
}

// Helper function to get the prediction score for a category
double _getPredictionScore(Predictions predictions, String category) {
  final entry = predictions.entries.firstWhere(
    (entry) => entry.category == category,
    orElse: () => PredictionEntry(category: category, score: 0.0),
  );
  return entry.score;
}

void updateTheTagOfTarnsactionsGroup(
    category, subCategory, grpId, context, index) async {

  String urlPath = BankTransactionRoutes.categorizeGroupedTransaction(groupId: grpId);

  var body = {
    'category': category,
    'subcategory': subCategory,
    "removedTransactions": removedGrpItemsList,
  };

  var response = await postDataApiCall(urlPath, body);

  if (getFlagOfResponse(response)) {
    getAllTransaction(context);
    reloadHistory.value = !reloadHistory.value;
    Navigator.pop(context);
    Navigator.pop(context);
    removedGrpItemsList.clear();
    lengthOfTransactions.value = false;
    setGroupTransactions.value = false;
    getGroupTransactions();
  } else {}
}



void getHideTransactions(context) async {
  String urlPath = BankTransactionRoutes.getHideTransactions;
  var response = await getDataApiCall(urlPath);
  if (getFlagOfResponse(response)) {
    trasactionsHideData.clear();
    var his = jsonDecode(response.body);
    trasactionsHideData
        .addAll(his['allTransactions']['categorized_transactions']);
  }
}




Future<void> hideTransaction(
    int index, bool hidden, BuildContext context, String id) async {
  final transaction = transactionsHistory[index];
  final apiUrl = BankTransactionRoutes.updateTransaction(transactionId: id);
  try {
    final response = await updateDataApiCall2(apiUrl, {"Hidden": hidden});
    // Debug print
    if (getFlagOfResponse(response)) {
      if (hidden) {
        hiddenTransactions.add(transaction);
        transactionsHistory.removeAt(index);
        transactionsHistory.refresh();
        snackBarCalled(context, SnackbarData().transactionHiddenSuccess);
      } else {
        hiddentrasactionsHistory.removeAt(index);
        hideTransactionReload.value = !hideTransactionReload.value;
        hiddentrasactionsHistory.refresh();
      }
    } else {
      snackBarCalledfail(context, SnackbarData().transactionHideFailed);
    }
  } catch (e) {
    snackBarCalledfail(context, SnackbarData().errorHidingTransaction);
  }
}

Future<void> excludeCashFlowTransaction(
    int index, bool isExcluded, BuildContext context, String id) async {
   final apiUrl = BankTransactionRoutes.updateTransaction(transactionId: id);
  try {
    final response =  await updateDataApiCall2(apiUrl, {"isExcluded": isExcluded});
    if (getFlagOfResponse(response)) {
      (transactionsHistory[index]).isExcluded = isExcluded;
      transactionsHistory.refresh();
    } 
  } catch (e) {
  }
}



void getAllAutoTransactions() async {
  var res = await getDataApiCall(BankTransactionRoutes.getPendingForReviewTransactions);
  if (getFlagOfResponse(res))
   {
    var data = jsonDecode(res.body);
    data = data['data'];
    autoTransactionList.clear();
    autoTransactionList.addAll(data);
    autoTransactionList.refresh();
    setAutoTransactions.value = true;
  }
}


void updateTransactionsBalanceOut(context,transactionId,int index,double amount)async
{
  var res =await postDataApiCall("${TransactionRoutes.updateGroupTransactions}/${transactionId}",{
      "amount":(amount).abs()
  });

  if(getFlagOfResponse(res))
  {
              (transactionsHistory[index]).balanceOut = (amount).abs();
              (transactionsHistory[index]).isBalanceOut = true;
              transactionsHistory.refresh();       
  }
}

Future<void> addTagToTransactions(context,transactionId,bool flag,int index)async
{

   var res =await postDataApiCall(BankTransactionRoutes.verifyPendingTransaction(transactionId: transactionId, isCorrect: flag),{
      "flag":flag
   });
  
  if(getFlagOfResponse(res))
  {
    autoTransactionList.removeAt(index);
    autoTransactionList.refresh();
    currentPage=1;
    getAllTransaction(context);
  }
}



void onChanedAutoTransactionStatus(context)async
{
     currentPage=1;
     isLoadingMore.value=false;
     transactionsHistory.clear();
     getAllTransactionHistory(context,false,false, isRefreshing: true);
}


Future<void> getCustomCategory(context)async
{
  var res = await getDataApiCall(BankTransactionRoutes.customCategory);
  if(getFlagOfResponse(res))
  {
    var data = jsonDecode(res.body);
    data = data['categories'];
    customCategoryList.clear();
    customCategoryList.addAll(data);
    customCategoryList.refresh();
    updateCusTagList();
    // Extract used imageUrls from category list
  }
}

void postCustomCategory(context,name,urlPath,narr)async
{
  var body =
  {
    "name":name,
    "imageUrl":urlPath,
    "narration":narr
  };
  
  var res = await postDataApiCall(BankTransactionRoutes.customCategory,body);

  if(getFlagOfResponse(res))
  {
    var data = jsonDecode(res.body);
    data = data["data"]['categories'];
    customCategoryList.clear();
    customCategoryList.addAll(data);
    customCategoryList.refresh();
    updateCusTagList();
    LoadTag.value=!LoadTag.value;
    custom=getthelist();
    Navigator.pop(context);
    snackBarCalled(context, SnackbarData().categoryAdded, );
  }

}


void updateCusTagList(){
   List<String> usedImages = customCategoryList
        .map((e) => (e['imageUrl'] ?? '').toString())
        .toList();

    // Filter unused from tag list
    List<String> unusedImages = customTagList
        .where((img) => !usedImages.contains(img))
        .toList();

    customCategoryUnUsedList.clear();
    customCategoryUnUsedList.addAll(unusedImages);
}
