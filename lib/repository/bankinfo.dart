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
import '../model/bank_model.dart';
import '../model/fips_metric_model.dart';

import '../routes/route_finvu.dart';

BankInfoController get bankInfoController {
  if (!Get.isRegistered<BankInfoController>()) {
    Get.put(BankInfoController(), permanent: true);
  }
  return Get.find<BankInfoController>();
}

RxList<BankAccountModel> get bankAccountLinkedList =>
    bankInfoController.bankAccountLinkedList;
RxList<FipsMetric> get fipsMetricList => bankInfoController.fipsMetricList;
RxList<ConsentInfoModel> get consentAndHandleDetails =>
    bankInfoController.consentAndHandleDetails;
RxMap get bankImagemap => bankInfoController.bankImagemap;

class BankInfoController extends GetxController {
  final RxList<BankAccountModel> bankAccountLinkedList =
      <BankAccountModel>[].obs;
  final RxList<FipsMetric> fipsMetricList = <FipsMetric>[].obs;
  final RxList<ConsentInfoModel> consentAndHandleDetails =
      <ConsentInfoModel>[].obs;
  final RxMap bankImagemap = {}.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasLoadedLocalData = false.obs;

  Future<void>? _bankAccountsRequest;
  Future<void>? _fipAccountInfoRequest;

  Future<void> getBankAccounts({bool refresh = false}) {
    if (!refresh && _bankAccountsRequest != null) {
      return _bankAccountsRequest!;
    }

    _bankAccountsRequest = _getBankAccounts(refresh: refresh).whenComplete(() {
      _bankAccountsRequest = null;
    });
    return _bankAccountsRequest!;
  }

  Future<void> _getBankAccounts({bool refresh = false}) async {
    isLoading.value = true;

    if (!hasLoadedLocalData.value && bankAccountLinkedList.isEmpty) {
      await BankStorage.loadBankDataFromHive();
      hasLoadedLocalData.value = true;
    }

    try {
      final response =
          await getDataApiCall(BankTransactionRoutes.getBanksLinkedAndAccounts);
      if (getFlagOfResponse(response)) {
        storeDataLocal(response);
        addBankApiCall();
        unawaited(BankStorage.cacheBankDataLocally());
      } else {
        addBankApiCall(fetchFipInfo: false);
      }
    } catch (e) {
      if (bankAccountLinkedList.isEmpty) {
        await BankStorage.loadBankDataFromHive();
      }
      addBankApiCall(fetchFipInfo: false);
    } finally {
      isLoading.value = false;
      isBankLoading.value = false;
      loadBanks.value = false;
    }
  }

  void storeDataLocal(response) {
    final his = jsonDecode(response.body);
    final data = his['data'];
    final List<BankAccountModel> accounts = [];
    final List<ConsentInfoModel> consents = [];
    final Set<String> consentKeys = {};

    FipIdsConnected.clear();

    if (data is! List) {
      _replaceBankData(accounts, consents);
      return;
    }

    for (final bank in data) {
      if (bank is! Map) continue;

      final bankAccounts =
          bank['accounts'] is List ? bank['accounts'] as List : const [];

      if (bank['consentId'] != null && bank['consendHandleId'] != null) {
        final key = '${bank['consentId']}_${bank['consendHandleId']}';
        if (consentKeys.add(key)) {
          final firstAccount =
              bankAccounts.isNotEmpty && bankAccounts.first is Map
                  ? bankAccounts.first as Map
                  : const {};

          consents.add(
            ConsentInfoModel(
              consentId: bank['consentId']?.toString() ?? '',
              consendHandleId: bank['consendHandleId']?.toString() ?? '',
              sessionId: bank['sessionId']?.toString() ?? '',
              custId: bank['custId']?.toString() ?? '',
              lastFetch: firstAccount['lastFetch']?.toString() ?? '',
              nextFetch: firstAccount['nextFetch']?.toString() ?? '',
              fetchCount:
                  int.tryParse(firstAccount['fetchCount']?.toString() ?? '0') ??
                      0,
              accountId: firstAccount['accountId']?.toString() ?? '',
              bankName: bank['bankName']?.toString() ?? 'BankName',
              fipId: bank['fipId']?.toString() ?? 'fipId',
            ),
          );
        }
      }

      for (final account in bankAccounts) {
        if (account is! Map) continue;

        final profile = account['profile'] is Map &&
                (account['profile'] as Map)['holder'] is Map
            ? (account['profile'] as Map)['holder'] as Map
            : const {};

        final currentAccountId = account['accountId']?.toString() ?? '';
        if (accountId.value.isEmpty && currentAccountId.isNotEmpty) {
          accountId.value = currentAccountId;
        }
        final maskedAccNumber = (account['maskedAccNumber'] ??
                account['maskedAccountNumber'] ??
                account['accountNumber'] ??
                '')
            .toString();
        if (maskedAccNumber.isNotEmpty) FipIdsConnected.add(maskedAccNumber);

        accounts.add(
          BankAccountModel(
            bankId: bank['bankId']?.toString() ?? '',
            bankName: bank['bankName']?.toString() ?? '',
            bankLogo: (bank['bankLogo'] ?? bankImage).toString(),
            fipId: bank['fipId']?.toString() ?? '',
            consentId: bank['consentId']?.toString() ?? '',
            consendHandleId: bank['consendHandleId']?.toString() ?? '',
            sessionId: bank['sessionId']?.toString() ?? '',
            custId: bank['custId']?.toString() ?? '',
            accountId: currentAccountId,
            maskedAccNumber: maskedAccNumber,
            type: account['type']?.toString() ?? '',
            currentBalance:
                double.tryParse(account['currentBalance']?.toString() ?? '0') ??
                    0.0,
            lastFetch: account['lastFetch']?.toString() ?? "",
            nextFetch: account['nextFetch']?.toString() ?? "",
            fetchCount:
                int.tryParse(account['fetchCount']?.toString() ?? '0') ?? 0,
            name: profile['name']?.toString() ?? "",
            pan: profile['pan']?.toString() ?? "",
            dob: profile['dob']?.toString() ?? "",
            mobile: profile['mobile']?.toString() ?? "",
            address: profile['address']?.toString() ?? "",
            ifscCode: account['ifscCode']?.toString() ?? "0",
            branchAddress: account['branchAddress']?.toString() ?? "0",
          ),
        );
      }
    }

    _replaceBankData(accounts, consents);
  }

  void _replaceBankData(
    List<BankAccountModel> accounts,
    List<ConsentInfoModel> consents,
  ) {
    bankAccountLinkedList
      ..clear()
      ..addAll(accounts);
    consentAndHandleDetails
      ..clear()
      ..addAll(consents);
    hasLoadedLocalData.value = true;
    _ensureSelectedAccount();
  }

  void storeBankDataApi({int? selectedIndex}) {
    isBankLinked.value = bankAccountLinkedList.isNotEmpty;
    _ensureSelectedAccount(selectedIndex: selectedIndex);
    loadBanks.value = false;
    loadBalance.toggle();
  }

  void _ensureSelectedAccount({int? selectedIndex}) {
    if (bankAccountLinkedList.isEmpty) {
      accountId.value = "";
      userController.selectedBank.value = "";
      return;
    }

    var index = selectedIndex ?? scrollBankPage.value;
    if (index < 0 || index >= bankAccountLinkedList.length) index = 0;

    var selected = bankAccountLinkedList[index];
    if (accountId.value.isNotEmpty) {
      selected = bankAccountLinkedList.firstWhere(
        (item) => item.accountId == accountId.value,
        orElse: () => selected,
      );
      index = bankAccountLinkedList.indexOf(selected);
    }

    scrollBankPage.value = index;
    accountId.value = selected.accountId;
    userController.selectedBank.value = selected.accountId;
    LastFetchDate.value = selected.lastFetch;
    nextFecthDate.value = selected.nextFetch;
    fetchCount.value = selected.fetchCount.toString();
    BankName.value = selected.bankName;
    BankUrl.value = selected.bankLogo;
  }

  void selectBankAccount(int index, [BuildContext? context]) {
    if (index < 0 || index >= bankAccountLinkedList.length) return;
    final account = bankAccountLinkedList[index];
    accountId.value = account.accountId;
    userController.selectedBank.value = account.accountId;
    LastFetchDate.value = account.lastFetch;
    nextFecthDate.value = account.nextFetch;
    fetchCount.value = account.fetchCount.toString();
    BankName.value = account.bankName;
    BankUrl.value = account.bankLogo;
    scrollBankPage.value = index;
    if (context != null) calledFunctionToFetchData(context);
  }

  void addBankApiCall({bool fetchFipInfo = true}) {
    storeBankDataApi();
    if (fetchFipInfo) unawaited(getFipAccountInfo());
  }

  Future<void> getWeeklyfetchData(
    consentId,
    consendHandleId,
    sessionId,
    custId,
    last,
    bankName,
    fipId,
    fetchCount,
    accountId,
  ) async {
    final String apiUrl = FinvuRoutes.fetchWeekly;
    final String userUrl = UserRoutes.updateFetchStatus;

    final body = {
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

    try {
      markBankFetchStarted(consendHandleId, bankName);
      await updateDataApiCall2(userUrl, {
        "fetchInProgress": true,
        "fetchHandleId": consendHandleId,
        "fetchConsentId": consentId,
        "fetchBankName": bankName,
      });
      await postDataApiCall(apiUrl, body);
    } catch (e) {
      markBankFetchCompleted(consendHandleId);
      await updateDataApiCall2(userUrl, {
        "fetchInProgress": false,
        "fetchHandleId": consendHandleId,
        "fetchConsentId": consentId,
        "fetchBankName": bankName,
      });
    }
  }

  Future<void> calledFunctionToFetchData(context) async {
    if (accountId.value.isEmpty) {
      getGraphData.value = false;
      await getBankAccounts();
    }

    if (accountId.value.isEmpty) return;

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
    if (_fipAccountInfoRequest != null) return _fipAccountInfoRequest!;
    _fipAccountInfoRequest = _getFipAccountInfo(testing, token).whenComplete(
      () => _fipAccountInfoRequest = null,
    );
    return _fipAccountInfoRequest!;
  }

  Future<void> _getFipAccountInfo(bool testing, String token) async {
    try {
      final List<String> fipIds = [];
      final Map<String, String> bankNameMap = {};

      for (final d in bankAccountLinkedList) {
        if (d.fipId.isEmpty || fipIds.contains(d.fipId)) continue;
        fipIds.add(d.fipId);
        bankNameMap[d.fipId] = d.bankName;
      }

      if (fipIds.isEmpty) return;
      String urlPath = FinvuRoutes.getFipDetails;
      final body = {"fipIds": fipIds};

      final response = (!testing
          ? await postDataApiCall(urlPath, body)
          : await postDataApiCallToken(urlPath, body, token));
      if (getFlagOfResponse(response)) {
        final data = jsonDecode(response.body)['data'];

        final List<FipsMetric> list = data is List
            ? data
                .map((item) => FipsMetric.fromJson(
                    item, bankNameMap[item['fip_id']] ?? ""))
                .toList()
            : [];

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
        fipsMetricList
          ..clear()
          ..addAll(list);
        unawaited(FipsMetricLocalStorage.saveFipsMetricsToHive());
      }
    } catch (e) {
      unawaited(FipsMetricLocalStorage.loadFipsMetricsFromHive());
    }
  }
}

Future<void> getBankAccounts() => bankInfoController.getBankAccounts();
void storeDataLocal(response) => bankInfoController.storeDataLocal(response);
void storeBankDataApi() => bankInfoController.storeBankDataApi();
void addBankApiCall() => bankInfoController.addBankApiCall();
Future<void> getWeeklyfetchData(consentId, consendHandleId, sessionId, custId,
        last, bankName, fipId, fetchCount, accountId) =>
    bankInfoController.getWeeklyfetchData(consentId, consendHandleId, sessionId,
        custId, last, bankName, fipId, fetchCount, accountId);
Future<void> calledFunctionToFetchData(context) =>
    bankInfoController.calledFunctionToFetchData(context);
Future<void> getFipAccountInfo([bool testing = false, String token = ""]) =>
    bankInfoController.getFipAccountInfo(testing, token);

void setPasswordApiCalled(context, String password) async {
  if (password == "00") {
    snackBarCalledfail(
      context,
      SnackbarData().pinSetFail00,
    );
    return; // Exit the function without setting the PIN
  }

  var urlPath = UserRoutes.cupertino;
  final response = await postDataApiCall(urlPath, {
    'pin': password.toString(),
  });

  if (getFlagOfResponse(response)) {
    userController.cupertinoPin.value = password;
    _showBalanceTemporarily();

    snackBarCalled(
      context,
      SnackbarData().pinSetSuccess,
    );
  } else {
    snackBarCalledfail(context, SnackbarData().pinSetFail);
  }
  Navigator.pop(context);
}

// Lock flag to prevent duplicate API calls
bool _isVerifyingPin = false;

// Debounce timer (optional, if you want to debounce the API call)
Timer? _verifyDebounce;
Timer? _balanceRevealTimer;

void _showBalanceTemporarily({VoidCallback? onHidden}) {
  _balanceRevealTimer?.cancel();
  hideBackAccountPassword.value = true;
  _balanceRevealTimer = Timer(const Duration(seconds: 5), () {
    hideBackAccountPassword.value = false;
    onHidden?.call();
  });
}

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
    final response = await getDataApiCall('${UserRoutes.cupertino}$password');

    if (response.statusCode == 200) {
      _showBalanceTemporarily(onHidden: () {
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

// Future<void> getQuickCheck({
//   required String view,
//   int? month,
//   required int year,
// }) async {
//   try {
//     final String url = view == 'monthly'
//         ? "${BankTransactionRoutes.getQuickCheck}"
//             "?view=monthly&month=${month ?? DateTime.now().month}&year=$year"
//         : "${BankTransactionRoutes.getQuickCheck}"
//             "?view=yearly&year=$year";

//     final response = await getDataApiCall(url);

//     if (!getFlagOfResponse(response)) return;

//     final decoded = jsonDecode(response.body);
//     final data = decoded['data'];

//     // 🔹 BANKS LIST
//     quickCheckBanks.value =
//         (data['banks'] ?? []).map<Map<String, dynamic>>(
//           (b) => Map<String, dynamic>.from(b),
//         ).toList();

//     // 🔹 COMBINED DATA (USED FOR "All")
//     final combined = data['combined'] ?? {};
//     final percentages = combined['percentages'] ?? {};
// quickCheckCurrentBalance.value =
//         (combined['currentBalance'] ?? 0).toDouble();
//     quickCheckCredit.value = (combined['credit'] ?? 0).toDouble();
//     quickCheckDebit.value = (combined['debit'] ?? 0).toDouble();
//     quickCheckOutstanding.value =
//         (combined['outstanding'] ?? 0).toDouble();

//     quickCheckCreditPercent.value =
//         (percentages['creditPercent'] ?? 0).toDouble();
//     quickCheckDebitPercent.value =
//         (percentages['debitPercent'] ?? 0).toDouble();
//     quickCheckOutstandingPercent.value =
//         (percentages['outstandingPercent'] ?? 0).toDouble();
//   } catch (e) {

//   }
// }

// final Rxn<QuickCheckModel> quickCheck = Rxn<QuickCheckModel>();
// Future<void> getQuickCheck({
//   required String view,
//   int? month,
//   required int year,
// }) async {
//   try {
//     final String url = view == 'monthly'
//         ? "${BankTransactionRoutes.getQuickCheck}"
//             "?view=monthly&month=${month ?? DateTime.now().month}&year=$year"
//         : "${BankTransactionRoutes.getQuickCheck}"
//             "?view=yearly&year=$year";

//     final response = await getDataApiCall(url);

//     if (!getFlagOfResponse(response)) return;

//     final decoded = jsonDecode(response.body);
//     final data = decoded['data'];

//     // ✅ SINGLE SOURCE OF TRUTH
//     quickCheck.value = QuickCheckModel.fromJson(data);

//   } catch (e, st) {
//   }
// }
