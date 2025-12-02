import 'dart:convert';

import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

Future<void> getRemainders(context) async {
  String urlPath = "${url}/reminders";
  var responce = await getDataApiCall(urlPath);
  if (getFlagOfResponse(responce)) {
    var his = jsonDecode(responce.body);
    var userDue = his['data']['payables'] ?? [];
    var userDue2 = his['data']['owed'] ?? [];
    dueAmountRemainders.clear();
    lendAmountRemainders.clear();
    dueAmountRemainders.addAll(userDue); //payables
    lendAmountRemainders.addAll(userDue2); //owed
    dueAmountRemainders.refresh();
    lendAmountRemainders.refresh();
    getdueUsers.value = !getdueUsers.value;
  } else {}
}

void getChatsSplitAccounts(context, String id) async {
  var response = await getDataApiCall("${url}/split/pending-user");
  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    chatSplitAccount.clear();
    chatSplitAccount.addAll(obj);
    getChatSplit.value = !getChatSplit.value;
  } else {}
}