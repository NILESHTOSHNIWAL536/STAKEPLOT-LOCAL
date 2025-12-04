import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/home_screen_state/home_page.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd_with_token.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/bankServices/nextFetch.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/components/shared_utils.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/repository/finance_repository.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';
import 'package:flutter_application_code_stakeplot/routes/route_transactions.dart';
import 'package:get/get.dart';
import '../Hive_localstorage/apisCall/bank_apis.dart';
import '../Hive_localstorage/apisCall/fipmetric_apis.dart';
import '../Home_Screen/banksCardsSlider.dart';
import '../Utils/snackBar.dart';
import '../loginservices/login.dart';
import '../model/fips_metric_model.dart';
import '../routes/route_finvu.dart';

RxList bankAccountLinkedList = [].obs;
RxList<FipsMetric> fipsMetricList = <FipsMetric>[].obs;
RxList consentAndHandleDetails = [].obs;
RxMap bankImagemap = {}.obs;

Future<void> getBankAccounts() async {
  try {
    var response =
        await getDataApiCall(BankTransactionRoutes.getBanksLinkedAndAccounts);
    if (getFlagOfResponse(response)) {
      storeDataLocal(response);
    }
    addBankApiCall();
    unawaited(BankStorage.cacheBankDataLocally());
  } catch (e) {
    unawaited(BankStorage.loadBankDataFromHive());
    addBankApiCall();
  }
  isBankLoading.value = false;
}

void storeDataLocal(response) {
  var his = jsonDecode(response.body);
  consentAndHandleDetails.clear();
  bankAccountLinkedList.clear();
  FipIdsConnected.clear();
  his['data'].forEach((bank) {
    if (bank['consentId'] != null && bank['consendHandleId'] != null) {
      if (!consentAndHandleDetails.any((item) =>
          item['consentId'] == bank['consentId'] &&
          item['consendHandleId'] == bank['consendHandleId'])) {
        consentAndHandleDetails.add({
          "consentId": bank['consentId'],
          "consendHandleId": bank['consendHandleId'],
          "sessionId": bank['sessionId'],
          "custId": bank['custId'],
          'lastFetch': bank['accounts'][0]['lastFetch'] ?? "",
          'nextFetch': bank['accounts'][0]['nextFetch'] ?? "",
          'fetchCount': bank['accounts'][0]['fetchCount'] ?? "0",
          'accountId': bank['accounts'][0]['accountId'] ?? "accountId",
          'bankName': bank['bankName'] ?? "BankName",
          'fipId': bank['fipId'] ?? "fipId",
        });
      }
    }
    bank['accounts'].forEach((account) {
      var profile = account['profile']?['holder'] ?? {};
      if (accountId.value == "") accountId.value = account['accountId'];
      FipIdsConnected.add(account['maskedAccNumber']);
      bankAccountLinkedList.add({
        'bankId': bank['bankId'],
        'bankName': bank['bankName'],
        'bankLogo': bank['bankLogo'] ?? bankImage,
        'fipId': bank['fipId'],
        'accountId': account['accountId'],
        'maskedAccNumber': account['maskedAccNumber'],
        'type': account['type'],
        'currentBalance': account['currentBalance'],
        'lastFetch': account['lastFetch'] ?? "",
        'nextFetch': account['nextFetch'] ?? "",
        'fetchCount': account['fetchCount'] ?? "0",
        'name': profile['name'] ?? "0",
        'pan': profile['pan'] ?? "0",
        'dob': profile['dob'] ?? "0",
        'mobile': profile['mobile'] ?? "0",
        'address': profile['address'] ?? "0",
        'ifscCode': account['ifscCode'] ?? "0",
        'branchAddress': account['branchAddress'] ?? "0",
      });
    });
  });
}

void storeBankDataApi() async {
  isBankLinked.value = bankAccountLinkedList.isNotEmpty;
  if (bankAccountLinkedList.isNotEmpty) {
    // isBankLinked.value = true;
    LastFetchDate.value = bankAccountLinkedList[0]['lastFetch'].toString();
    nextFecthDate.value = bankAccountLinkedList[0]['nextFetch'].toString();

    fetchCount.value = bankAccountLinkedList[0]['fetchCount'].toString();
    BankName.value = bankAccountLinkedList[0]['bankName'].toString();
    BankUrl.value = bankAccountLinkedList[0]['bankLogo'].toString();
  }
  loadBanks.value = false;
  await Future.delayed(Duration(seconds: 1));
  loadBalance.value = !loadBalance.value;
}

void addBankApiCall() {
  storeBankDataApi();
  getFipAccountInfo();
}

void getWeeklyfetchData(consentId, consendHandleId, sessionId, custId, last,
    bankName, fipId, fetchCount, accountId) async {
  final String apiUrl = FinvuRoutes.fetchWeekly;
  final String userUrl = UserRoutes.updateFetchStatus;

  var body = {
    'handleId': consendHandleId,
    'custId': custId,
    'consentId': consentId,
    'sessionId': sessionId,
    'userId': userController.userId.value,
    'isCron': false,
    'FROM': last,
    'bankName': bankName,
    'fipId': fipId,
    'fetchCount': fetchCount,
    'accountId': accountId,
  };

  var userBody = {
    "fetchInProgress": true,
  };

  try {
    await updateDataApiCall2(userUrl, userBody);
    await postDataApiCall(apiUrl, body);
  } catch (e) {
    isFected.value = false;
    await updateDataApiCall2(userUrl, {
      "fetchInProgress": false,
    });
  }
}

void calledFunctionToFetchData(context) async {
  if (accountId.value.isEmpty) {
    getGraphData.value = false;
    await getBankAccounts();
  }

  if (selectedButton.value == "Month") {
    getWeeklyGraphAndCustomDateGraph(getFormattedDate(), context);
  } else if (selectedButton.value == "Week") {
    getWeeklyGraphAndCustomDateGraph(getCurrentWeek(), context,
        weekORmonth: 'Week');
  } else {
    getWeeklyGraphAndCustomDateGraph(getFormattedDate(), context,
        weekORmonth: 'Custom');
  }
}

Future<void> getFipAccountInfo(
    [bool testing = false, String token = ""]) async {
  try {
    List<String> fipIds = [];
    Map<String, String> bankNameMap = new Map();
    bankAccountLinkedList.forEach((d) {
      fipIds.add(d["fipId"]);
      bankNameMap[d["fipId"]] = d['bankName'];
    });

    if (fipIds.isEmpty) return;
    String urlPath = FinvuRoutes.getFipDetails;
    var body = {"fipIds": fipIds};

    var response = (!testing
        ? await postDataApiCall(urlPath, body)
        : await postDataApiCallToken(urlPath, body, token));
    if (getFlagOfResponse(response)) {
      var data = jsonDecode(response.body)['data'];

      fipsMetricList.clear();
      List<FipsMetric> list = (data as List)
          .map((item) =>
              FipsMetric.fromJson(item, bankNameMap[item['fip_id']] ?? ""))
          .toList();

      if (list.isEmpty) {
        list.add(FipsMetric(
            timestamp: DateTime(2027),
            fipId: fipIds.isEmpty ? "" : fipIds.first,
            eventName: "",
            BankName: BankName.value,
            latencyAvgMs: 100,
            successPercent: 100,
            timeoutPercent: 10,
            accNotFoundPercent: 10,
            serverErrorPercent: 10,
            clientErrorPercent: 10,
            latencyP99Ms: 10,
            latencyP95Ms: 10,
            latencyP50Ms: 10));
      }
      fipsMetricList.addAll(list);
      unawaited(FipsMetricLocalStorage.saveFipsMetricsToHive());
    }
  } catch (e) {
    unawaited(FipsMetricLocalStorage.loadFipsMetricsFromHive());
  }
}


void setPasswordApiCalled(context, String password) async {
  if (password == "00") {
    snackBarCalledfail(context, SnackbarData().pinSetFail00,);
    return; // Exit the function without setting the PIN
  }

  var urlPath = UserRoutes.cupertino;
  final response = await postDataApiCall(urlPath, {
    'pin': password.toString(),
  });

  if (getFlagOfResponse(response)) {
    userController.cupertinoPin.value = password;
    hideBackAccountPassword.value = false;

    snackBarCalled(context, SnackbarData().pinSetSuccess,);
  } else {
    snackBarCalledfail(context, SnackbarData().pinSetFail);
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
    final response = await getDataApiCall(UserRoutes.cupertino + "$password");

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
      return;
    } else {
      var errorResponse = jsonDecode(response.body);

      userController.cupertinoAttemptCount.value =
          (errorResponse['count'] ?? 0) > 4;
      if (userController.cupertinoAttemptCount.value) {
        snackBarCalledfail(context, SnackbarData().maxLimitSetFail);
      }
      hideBackAccountPassword.value = false;
    }
  } catch (e) {
    hideBackAccountPassword.value = false;
  } finally {
    _isVerifyingPin = false;
  }
}

