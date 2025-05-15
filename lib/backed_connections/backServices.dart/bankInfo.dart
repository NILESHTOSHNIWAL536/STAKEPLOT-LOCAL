import 'dart:convert';

import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';

RxString balance = "0".obs;
RxString accountName = "Bank Name : ".obs;
RxString accountNo = "XXXXXXXX".obs;
RxString selectedBank = "".obs;

void getCategoryData() async {
  var res = await getDataApiCall("${url}/transactionauto/categorize");
  if (getFlagOfResponse(res)) {
    var data = jsonDecode(res.body);
    print("data: $data");
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
    totalDebitThisMonth.value = data["data"]['totalDebitThisMonth'];
    print("categoriesList for month : $categoriesList");
    print("frequentPayments for month : $frequentPayments");
     print("moreDrasticChange for month : $moreDrasticChange");

    //week
    categoriesListWeek.addAll(data["data"]['week']['categorized']);
    frequentPaymentsWeek.addAll(data["data"]['week']['frequentPayments']);
    moreDrasticChangeWeek.addAll(data["data"]['week']['moreDrasticChange']);
 totalDebitThisWeek.value = data["data"]['week']['totalDebitThisMonth'];
  print("categoriesListWeek for month : $categoriesListWeek");
    print("frequentPaymentsWeek for month : $frequentPaymentsWeek");
     print("moreDrasticChangeWeek for month : $moreDrasticChangeWeek");
      print("totalDebitThisWeek for month : $totalDebitThisWeek");

    categoriesList.refresh();
    frequentPayments.refresh();
    moreDrasticChange.refresh();

    categoriesListWeek.refresh();
    frequentPaymentsWeek.refresh();
    moreDrasticChangeWeek.refresh();

    setDonectChat.value = !setDonectChat.value;
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
