import 'dart:convert';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';

import '../routes/route_transactions.dart';

RxList groupTransactionList = [].obs;
RxList autoTransactionList = [].obs;
RxList removedGrpItemsList = [].obs;
RxBool reloadremovedTransactions = false.obs;
RxBool lengthOfTransactions = false.obs;
RxBool setGroupTransactions = false.obs;
RxBool setAutoTransactions = false.obs;

void getGroupTransactions() async {
  var res = await getDataApiCall(
    BankTransactionRoutes.getGroupedTransactions,
  );
  if (getFlagOfResponse(res)) {
    var data = jsonDecode(res.body);
    data = data['data'];
    groupTransactionList.clear();
    groupTransactionList.addAll(data);
    groupTransactionList.refresh();
    setGroupTransactions.value = true;
  }
}
