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
    
    categoriesList.clear();
    frequentPayments.clear();
    moreDrasticChange.clear();

    categoriesList.addAll(data["data"]['categorized']);
    frequentPayments.addAll(data["data"]['frequentPayments']);
    moreDrasticChange.addAll(data["data"]['moreDrasticChange']);
  
    categoriesList.refresh();
    frequentPayments.refresh();
    moreDrasticChange.refresh();

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
