import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/routes/bill_routes.dart';
import 'package:flutter_application_code_stakeplot/routes/route_post.dart';

import '../routes/reminder_routes.dart';

Future<void> getRemainders(context) async {
  String urlPath = ReminderRoutes.getReminders;
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
  var response = await getDataApiCall(SplitRoutes.splitpending);
  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    chatSplitAccount.clear();
    chatSplitAccount.addAll(obj);
    getChatSplit.value = !getChatSplit.value;
  } else {}
}

void approveBill(context, id, type, notifyId) async {
  String urlPath =
      BillRoutes.acceptBill(id: id, accept: type, notificationsId: notifyId);
  var responce = await getDataApiCall(urlPath);
  if (getFlagOfResponse(responce)) {}
}

Future<void> getFoodieFundsDetails(BuildContext context, String id) async {
  String urlPath = ReminderRoutes.getFoodieFunds(id);
  var response = await getDataApiCall(urlPath);
  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    var data = his['data'] ?? {};

    foodieFundsDetailsRemainders.clear();

    // Add the entire data object as a single item (or adjust to extract friends + currentUser)
    foodieFundsDetailsRemainders.add(data);

    foodieFundsDetailsRemainders.refresh();
    getFoodieFundsUsers.value = !getFoodieFundsUsers.value;
  } else {
    snackBarCalledfail(context, SnackbarData().failedToFetchFoodieFundsDetails);
  }
}

void duesPaid(BuildContext context, int index) async {
  final due = dueAmountRemainders[index];
  final dueId = due['_id']?.toString();
  final type = due['type'];

  final apiUrl = ReminderRoutes.requestApproval(type: type, id: dueId ?? "");
  try {
    final response = await updateDataApiCall2(apiUrl, {});
  } catch (e) {
    snackBarCalledfail(context, SnackbarData().errorSettlingDue);
  }
}

void settleAmount(
    BuildContext context, String dueId, String type, String endUser) async {
  final apiUrl = ReminderRoutes.settleReminder(
      type: type, id: dueId); //"$url/reminders/settle/$type/$dueId";
  try {
    var body = {
      'splittedUserId': endUser,
    };
    final response = await updateDataApiCall2(apiUrl, body);
  } catch (e) {
    snackBarCalledfail(context, SnackbarData().errorSettlingDue);
  }
}

void declineAmount(
    BuildContext context, String dueId, String type, String endUser) async {
  try {
    
     final apiUrl = ReminderRoutes.declineRequest(type: type, id: dueId); //"$url/reminders/decline-request/$type/$dueId";
    await updateDataApiCall2(apiUrl, {"splittedUserId": endUser});

  } catch (e) {
    snackBarCalledfail(context, SnackbarData().errorSettlingDue);
  }
}
