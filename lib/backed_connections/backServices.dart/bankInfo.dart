import 'dart:convert';

import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';

RxString balance = "0".obs;
RxString accountName = "Bank Name : ".obs;
RxString accountNo = "XXXXXXXX".obs;

void getCategoryData() async {
  var res = await getDataApiCall("${url}/transactionauto/categorize");

  if (getFlagOfResponse(res)) {
    var data = jsonDecode(res.body);

    categoriesList.clear();
    categoriesList.addAll(data["data"]);
    categoriesList.refresh();
    setDonectChat.value = !setDonectChat.value;
    processChartData();
  }
}

void getSummary() async {
  var res = await getDataApiCall("${url}/transactionauto/user-details");
  if (getFlagOfResponse(res)) {
    var data = jsonDecode(res.body);
    data = data['data'];
    accountName.value = data['Bank']['fipName'];
    accountNo.value = data['accounts'][0]['accounts']['maskedAccNumber'] ?? 0;
    balance.value = data['summaries'][1]['data']['currentBalance'].toString();
  }
}

void getdebts() async {
  Map<String, dynamic> body = {};
  print("data debt ..............................transactionauto....................... :");
  var res = await postDataApiCall("${url}/debt",body);
  print("data debt ..............................transactionauto....................... :");

  if (getFlagOfResponse(res)) {
    var data = jsonDecode(res.body);
    print(data);
    data = data['data'];

  }
}
