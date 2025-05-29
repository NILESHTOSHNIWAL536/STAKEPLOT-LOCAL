import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/number_picker.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transactionHistoryScreen.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

void getAck() async {
  var response = await getDataApiCall('${url}/user/newNotifications');
  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    hasGetNewNotifications.value = obj != 0;
  }
}

void setPasswordApiCalled(context, String password) async {
  if (password == "00") {
    snackBarCalledfail(context, SnackbarData().pinSetFail00, Colors.red);
    return; // Exit the function without setting the PIN
  }

  var urlPath = '${url}/user/cupertino/';
  final response = await postDataApiCall(urlPath, {
    'pin': password.toString(),
  });

  if (getFlagOfResponse(response))
  {
    cupertinoPin.value = password;
    snackBarCalled(context, SnackbarData().pinSetSuccess, Colors.black);
  } else {
    snackBarCalled(context, SnackbarData().pinSetFail, Colors.red);
  }
  Navigator.pop(context);
}

// Lock flag to prevent duplicate API calls
bool _isVerifyingPin = false;

// Debounce timer (optional, if you want to debounce the API call)
Timer? _verifyDebounce;

/// Call this function instead of [pinPasswordVerify] to apply debounce
void pinPasswordVerifyDebounced(
    String password, BuildContext context, Function setBack) {
  if (_verifyDebounce?.isActive ?? false) _verifyDebounce?.cancel();

  _verifyDebounce = Timer(const Duration(milliseconds: 800), () {
    pinPasswordVerify(password, context, setBack);
  });
}

/// Main PIN verification function with locking and error handling
void pinPasswordVerify(
    String password, BuildContext context, Function setBack) async {
  if (_isVerifyingPin) return; // Prevent multiple calls
  _isVerifyingPin = true;

  try {
    final response = await getDataApiCall("${url}/user/cupertino/$password");

    if (response.statusCode == 200) {
      hideBackAccountPassword.value = true;

      // Auto-hide after 5 seconds
      Timer(const Duration(seconds: 5), () {
        hideBackAccountPassword.value = false;

        // Reset values
        firstDigit.value = 0;
        secondDigit.value = 0;
        digitLoad.value = !digitLoad.value;

        setBack(); // Callback
      });
    } else
     {
      var errorResponse = jsonDecode(response.body);
      
      AttemptCount.value = (errorResponse['count'] ?? 0) >4;
      hideBackAccountPassword.value = false;

    }
  } catch (e) {
    hideBackAccountPassword.value = false;
  } finally {
    _isVerifyingPin = false;
  }
}

void PinPasswordVerify2(password, context, Function setBack) async {
  var response = await getDataApiCall("${url}/user/cupertino/${password}");

  if (response.statusCode == 200 || response.statusCode == 200) {
    hideBackAccountPassword.value = true;
    Timer(Duration(seconds: 5), () {
      hideBackAccountPassword.value = false;

      firstDigit.value = 0;
      secondDigit.value = 0;
      digitLoad.value = !digitLoad.value;
      setBack();
    });
  } else {
    hideBackAccountPassword.value = false;
  }
}

void seletedBankUpdateInfo(id, context) async {
  var response = await getDataApiCall("${url}/user/selectedBank/${id}");
  if (response.statusCode == 200 || response.statusCode == 200) {
  } else {}
}

void getAllTransaction(context) async {
  var response = await getDataApiCall(
      "${url}/transactionauto/getTransactions/${currentPage}/empty/-");
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

void getInsights(context, String id) async {
  var response = await getDataApiCall("${url}/budget/get-insights/$id");
  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    inSights.clear();
    inSights.addAll(obj);
    getHistory.value = !getHistory.value;
  } else {}
}

void getHiddenTransactions(context) async {
  var response =
      await getDataApiCall("${url}/transactionauto/get-hide-transactions");
  if (response.statusCode == 200) {
    var her = jsonDecode(response.body);
    var obj = her['data'];
    hiddentrasactionsHistory.clear();
    hiddentrasactionsHistory.addAll(obj);
    getHiddenHistory.value = !getHiddenHistory.value;
  } else {}
}

Future<void> getAllTransactionHistory(
    BuildContext context, bool flag, bool isYearView,
    {bool isRefreshing = false}) async {
  if (isLoadingMore.value) return; // Prevent multiple API calls
  loadingDelay.value = true;
  try {
    isLoadingMore.value = true;
    String type = isYearView
        ? selectedYear.value.toString()
        : selectedYear.value.toString() +
            "-" +
            selectedMonth.value.toString().padLeft(2, '0');
    String text =
        searchController.text.trim() == "" ? "empty" : searchController.text;
    String urlPath = flag
        ? "${url}/transactionauto/get-monthly-transactions-history/${accountId.value}/${type}/${currentPage}"
        : "${url}/transactionauto/getTransactions/${currentPage}/${text}/${accountIdPdf.value.isEmpty ? "-" : accountIdPdf.value}";

    var response = await getDataApiCall(urlPath);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var obj = data['data'];
      print("data for history_________$obj");

      if (obj != null && obj is List<dynamic>) {
        if (isRefreshing) {
          transactionsHistory.clear(); // Clear only on refresh
        }

        transactionsHistory.addAll(obj);

        // Stop loading indicator if no more transactions exist
        if (obj.isEmpty || obj.length < 20) {
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
      } else {
        snackBarCalled(context, SnackbarData().noTransactionData);
      }
    }
  } catch (e) {}

  loadingDelay.value = false;
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

bool isCurrentYear(String date, int y) {
  try {
    DateTime parsedDate = DateTime.parse(date); // Parse the date string
    return parsedDate.year == y; // Compare year
  } catch (e) {
    return false; // Return false if parsing fails
  }
}

bool isCurrentMonth(String date, int m) {
  try {
    DateTime parsedDate = DateTime.parse(date);
    return parsedDate.month == m; // Compare month
  } catch (e) {
    return false;
  }
}

void getChatsSplitAccounts(context, String id) async {
  var response = await getDataApiCall("${url}/split/pending-user");
  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    chatSplitAccount.clear();
    chatSplitAccount.addAll(obj);
    getChatSplit.value = !getChatSplit.value;
  } else {}
}
