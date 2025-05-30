import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:get/get.dart';

RxString balance = "0".obs;
RxString accountName = "Bank Name : ".obs;
RxString accountNo = "XXXXXXXX".obs;
RxString selectedBank = "".obs;

void getCategoryData() async {
  var res = await getDataApiCall("${url}/transactionauto/categorize");
  if (getFlagOfResponse(res)) {
    try {
      var data = jsonDecode(res.body);

      categoriesList.clear();
      frequentPayments.clear();
      moreDrasticChange.clear();

      categoriesListWeek.clear();
      frequentPaymentsWeek.clear();
      moreDrasticChangeWeek.clear();

      //month

      categoriesList.addAll(data["data"]['categorized']);
      frequentPayments.addAll(data["data"]['frequentPayments']);
      moreDrasticChange.addAll(data["data"]['moreDrasticChange']);

      totalDebitThisMonth.value = double.parse(
          doubleToFixed(data["data"]['totalDebitThisMonth'].toString()));

      categoriesListWeek.addAll(data["data"]['week']['categorized']);
      frequentPaymentsWeek.addAll(data["data"]['week']['frequentPayments']);
      moreDrasticChangeWeek.addAll(data["data"]['week']['moreDrasticChange']);
      totalDebitThisWeek.value = double.parse(doubleToFixed(
          data["data"]['week']['totalDebitThisMonth'].toString()));

      categoriesList.refresh();
      frequentPayments.refresh();
      moreDrasticChange.refresh();

      categoriesListWeek.refresh();
      frequentPaymentsWeek.refresh();
      moreDrasticChangeWeek.refresh();

      setDonectChat.value = !setDonectChat.value;
    } catch (e) {
      print(e);
    }
    processChartData();
  }
}

void getSummary() async {
  var res = await getDataApiCall("${url}/transactionauto/user-details");
  if (getFlagOfResponse(res)) {
    var data = jsonDecode(res.body);
    data = data['data'];
    accountName.value = data['Bank'][0]['fipName'];
    accountNo.value = data['accounts'][0]['accounts']['maskedAccNumber'] ?? 0;
    balance.value = data['summaries'][0]['data']['currentBalance'].toString();
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

void deleteUserAccount(BuildContext context) async {
  try {
    var response = await deleteDataApiCall("${url}/user");

    if (response.statusCode == 200) {
      print("User account deleted successfully.");
    } else {
      print(
          "Failed to delete user account. Status code: ${response.statusCode}");
    }
  } catch (e, stackTrace) {
    print("Error occurred while deleting user account: $e");
    print("Stack trace: $stackTrace");
  }
  clearStackLocalInfo();
  clearStack(context);
}
