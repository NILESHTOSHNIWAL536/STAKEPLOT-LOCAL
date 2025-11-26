import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/finora_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/init_hive.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/hive_storage.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/routes/route_transactions.dart';
import 'package:get/get.dart';


RxString balance = "0".obs;
RxString accountName = "Bank Name : ".obs;
RxString accountNo = "XXXXXXXX".obs;
RxString selectedBank = "".obs;


void getCategoryData(context) async {
  try {
    // API call inside try
    var res = await getDataApiCall(BankTransactionRoutes.categorizeTransactions);

    if (getFlagOfResponse(res)) {
    
      var data = jsonDecode(res.body);
      
      categoriesList.clear();
     
      frequentPayments.clear();
      moreDrasticChange.clear();
      categoriesListWeek.clear();
      frequentPaymentsWeek.clear();
      moreDrasticChangeWeek.clear();
      // spendingsOnCategories.clear();
      // throw Error();
      
    
      categoriesList.addAll(
        (data["data"]['categorized'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
      );
      

     

      // frequentPayments.addAll(data["data"]['frequentPayments']);
      // moreDrasticChange.addAll(data["data"]['moreDrasticChange']);
      frequentPayments.addAll(
        (data["data"]['frequentPayments'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
      );

      moreDrasticChange.addAll(
        (data["data"]['moreDrasticChange'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
      );

      totalDebitThisMonth.value = double.parse(
          doubleToFixed(data["data"]['totalDebitThisMonth'].toString()));

      categoriesListWeek.addAll(
        (data["data"]['week']['categorized'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
      );
      frequentPaymentsWeek.addAll(
        (data["data"]['week']['frequentPayments'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
      );
      moreDrasticChangeWeek.addAll(
        (data["data"]['week']['moreDrasticChange'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
      );

      // Refresh reactive lists
      categoriesList.refresh();
      frequentPayments.refresh();
      moreDrasticChange.refresh();
      categoriesListWeek.refresh();
      frequentPaymentsWeek.refresh();
      moreDrasticChangeWeek.refresh();
      isFinoraVisible.value = !isFinoraVisible.value;
      setDonectChat.value = !setDonectChat.value;
      processChartData();
      await CategoryStorage.cacheCardInsightsDataLocally();
    }
  } catch (e)
  {
    await CategoryStorage.loadCardInsightsDataFromHive();
  }
}



void getdebts() async {
  Map<String, dynamic> body = {};
  var res = await postDataApiCall("${url}/debt", body);
  if (getFlagOfResponse(res)) {
    var data = jsonDecode(res.body);
    data = data['data'];
  }
}

Future<bool> deleteUserAccount(BuildContext context, String msg) async {
  try {
    var body = {
      // 'password':password,
      'reason': msg,
    };
    var response = await deleteDataApiCallBody("${url}/user", body);

    if (getFlagOfResponse(response)) {
      clearStackLocalInfo();
      logoutUserFromDevice(context);
    } else if (response.statusCode == 400) {
      var res = jsonDecode(response.body);
      snackBarCalledfail(
          context, res['error']['explanation'] ?? "Password incorrect");
      return false;
    }
  } catch (e) {
    snackBarCalledfail(context, "error while deleting");
    return false;
  }

  return true;
}

void deleteBankAccount(
    {required String bankid,
    required String AccountId,
    required BuildContext context}) async {
  var res =
      await deleteDataApiCall(BankTransactionRoutes.deleteBankAccount(bankId: bankid, accountId: AccountId),);
  if (getFlagOfResponse(res)) {
    accountId.value = "";
    clearSpecificBox(HiveStorage.transactionsBoxName);
    clearSpecificBox(HiveStorage.cardInsightsBoxName);
    clearSpecificBox(HiveStorage.bankAccountsBoxName);
    clearSpecificBox(HiveStorage.financeBoxName);
    clearSpecificBox(HiveStorage.autoPayBoxName);
    getBankAccounts();
    getCategoryData(context);
    clearGraph();
    getWeeklyGraphAndCustomDateGraph(getFormattedDate(), context,isSplashScreen: true);
    
    Navigator.of(context).pop();
    bankAccountLinkedList.refresh();
    
  }
}
