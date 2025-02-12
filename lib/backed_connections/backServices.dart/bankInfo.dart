import 'dart:convert';

import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';

RxString balance = "0".obs;
RxString accountName = "0".obs;

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
  // print("data transactionauto :");

  if (getFlagOfResponse(res)) {
    var data = jsonDecode(res.body);
    data = data['data'];
    //print("data debt ..............................transactionauto....................... :");
    // print(data['Bank']['fipName']);
    // print(data['summaries'][0]['data']['currentBalance']);
    accountName.value = data['Bank']['fipName'];
    balance.value = data['summaries'][0]['data']['currentBalance'].toString();
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
