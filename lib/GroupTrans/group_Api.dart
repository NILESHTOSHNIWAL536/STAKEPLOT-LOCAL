import 'dart:convert';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';

RxList groupTransactionList = [].obs;
RxList removedGrpItemsList = [].obs;
RxBool reloadremovedTransactions = false.obs;
RxBool lengthOfTransactions = false.obs;
RxBool setGroupTransactions = false.obs;

void getGroupTransactions() async {
  var res =
      await getDataApiCall("${url}/transactionauto/get-grouped-transactions");
  print("group transactions ${res.body}");
  if (getFlagOfResponse(res)) {
    var data = jsonDecode(res.body);
    data = data['data'];
    groupTransactionList.clear();
    groupTransactionList.addAll(data);
    groupTransactionList.refresh();
    setGroupTransactions.value = true;
  }
}
