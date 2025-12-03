import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/finora_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/init_hive.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/hive_storage.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/repository/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/repository/finance_repository.dart';
import 'package:flutter_application_code_stakeplot/repository/finora_repository.dart';
import 'package:flutter_application_code_stakeplot/routes/route_transactions.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';
import 'package:get/get.dart';

import '../../components/shared_utils.dart';
import '../../repository/bankinfo.dart';


RxString balance = "0".obs;
RxString accountName = "Bank Name : ".obs;
RxString accountNo = "XXXXXXXX".obs;
RxString selectedBank = "".obs;


Future<bool> deleteUserAccount(BuildContext context, String msg) async {
  try {
    var body = {
      // 'password':password,
      'reason': msg,
    };
    var response = await deleteDataApiCallBody(UserRoutes.deleteUser, body);

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
