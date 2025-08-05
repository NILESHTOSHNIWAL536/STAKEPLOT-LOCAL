import 'dart:convert';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/nextFetch.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:get/get.dart';

RxList bankAccountLinkedList = [].obs;
RxList consentAndHandleDetails = [].obs;
RxMap bankImagemap = {}.obs;

Future<void> getBankAccounts() async {
  var response =
      await getDataApiCall("${url}/transactionauto/get-banks-linked/");
  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    consentAndHandleDetails.clear();
    bankAccountLinkedList.clear();

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
          });
        }
      }
      bank['accounts'].forEach((account) {
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
        });
      });
    });
  }
  addBankApiCall();
}

void addBankApiCall() {
  if (bankAccountLinkedList.isNotEmpty) {
    LastFetchDate.value = bankAccountLinkedList[0]['lastFetch'].toString();
    nextFecthDate.value = bankAccountLinkedList[0]['nextFetch'].toString();
    fetchCount.value = bankAccountLinkedList[0]['fetchCount'].toString();
    BankName.value = bankAccountLinkedList[0]['bankName'].toString();
    BankUrl.value = bankAccountLinkedList[0]['bankLogo'].toString();
    isBankLinked.value = true;
  }
  loadBanks.value = false;
  loadBalance.value = !loadBalance.value;
}

void getWeeklyfetchData(
    consentId, consendHandleId, sessionId, custId, last) async {
  final String apiUrl = "${url}/finvu/fetchWeekly";
  final String userUrl = "${url}/user/updateFetchStatus";
  var body = {
    'handleId': consendHandleId,
    'custId': custId,
    'consentId': consentId,
    'sessionId': sessionId,
    'userId': userController.userId.value,
    'isCron': false,
    'FROM': last,
  };

  var userBody = {
    "fetchInProgress": true,
  };

  try {
    await updateDataApiCall2(userUrl, userBody);
    await postDataApiCall(apiUrl, body);
  } catch (e) {}
}

void calledFunctionToFetchData(context) async {
  if (accountId.value.isEmpty) {
    getGraphData.value = false;
    await getBankAccounts();
  }

  if (selectedButton.value == "Month") {
    getAutoMationsTransactionsCustom(getFormattedDate(), context);
  } else if (selectedButton.value == "Week") {
    getAutoMationsTransactionsCustom(getCurrentWeek(), context, 'Week');
  } else {
    getAutoMationsTransactionsCustom(getFormattedDate(), context, 'Custom');
  }
}
