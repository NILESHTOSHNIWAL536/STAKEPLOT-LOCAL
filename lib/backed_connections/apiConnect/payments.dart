import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/animated/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/debt_service.dart';
import 'package:flutter_application_code_stakeplot/routes/route_finances.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/route_transactions.dart';
import '../apiAutomations/secure_storage.dart';

void getDebts() async {
 

  final response = await getDataApiCall('${url}/debt/');
 

  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    debtLength.value = obj.length;
    debtsList.clear();
    debtsList.addAll(obj);
  } else {
  }
}

Future<void> fetchDebts() async {
  try {
    var fetchedDebts = await DebtService.fetchDebts();
    if (fetchedDebts.isNotEmpty) {
      debts.assignAll(fetchedDebts);
    } else {
      debts.clear();
    }
    if(!getCreditCardBudgetDebts.value)getCreditCardBudgetDebts.value= debts.isNotEmpty;
  } catch (e) {
    Get.snackbar('Error', 'Failed to fetch debts: $e');
  }
}


getBills() async {
  
  final response = await getDataApiCall('${url}/bill/');
 

  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    billLength.value = obj.length;
    //  billAmount.clear();
    //  billAmount.addAll(obj);
  } else {}
}

bool isZeroAmount(String amount) {
  try {
    double parsed = double.parse(amount.trim().toString());
    return parsed == 0.0 || parsed == 0.00 || parsed == 0;
  } catch (e) {
    return true;
  }
}


void addDebts(context, name, amount, interest, startDate, durations) async {
  
  debtLength.value = 1 + debtLength.value;
  final response = await postDataApiCall('${url}/debt/',
  
    {
      'name': name.toString(),
      'amount': amount,
      'interest': interest.toString(),
      'startDate': startDate.toString(),
      'duration': durations,
    }
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);

    snackBarCalled(context, SnackbarData().debtAdded);
    acceptReset.value = false;

    getDebts();
    Navigator.pop(context);
  } else {
    snackBarCalledfail(context, SnackbarData().debtAddFailed,);
  }
  acceptReset.value = false;
}

void addBillTranscations(
    List<TextEditingController> controller, context) async {
  
  int end = controller.length;

  for (int i = 0; i < end; i += 3) {
    billLength.value += 1;
    String name = controller[i].text;
    String amount = controller[i + 1].text;
    String expenseCategory = controller[i + 2].text;

    final response = await postDataApiCall('${url}/bill/',
     {
        'name': name.toString(),
        'amount': amount,
        'dueDate': expenseCategory.toString(),
      }
    );

    if (getFlagOfResponse(response)) {
      final body = json.decode(response.body);

      acceptReset.value = false;
      snackBarCalled(context, SnackbarData().billAdded,);
      getBills();
      Navigator.pop(context);
    } else {
      snackBarCalledfail(context, SnackbarData().billAddFailed,);
    }
    acceptReset.value = false;
  }
}

void deleteDebts(context, String id, [flag = false]) async {
  
  final response = await deleteDataApiCallBody('${url}/debt/${id}', {});
  
  if (getFlagOfResponse(response)) {
    final body = json.decode(response.body);
    snackBarCalled(context, SnackbarData().debtCleared,);
    debtLength.value--;
    getDebts();
    if (flag) return;
    // Navigator.pushReplacement(
    //           context,
    //           MaterialPageRoute(
    //             builder: (context) => Budget(),
    //           ),
    //       );
  } else {
    snackBarCalledfail(context, SnackbarData().debtClearError,);
  }
}

void deleteAmount(context, String id, String am) async {
 
  final response = await updateDataApiCall2('${url}/debt/${id}',{}
  );
  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
  } else {
    snackBarCalled(context, SnackbarData().debtClearError, Colors.red);
  }
}

void deleteBudget(context, String id) async {
  
  final response = await deleteDataApiCall('${url}/budget/${id}');
  
  if (getFlagOfResponse(response)) {
    snackBarCalled(
        context, SnackbarData().processingBudgetDeletion, Colors.red);
  } else {
    snackBarCalledfail(context, SnackbarData().budgetDeletionError, Colors.red);
  }
}

void clearDebts(context, String id, String amount, String value) async {
  

  var body = {
    'amount': amount,
    'label': "",
    'account': value,
    'category': "",
    'isDebt': true,
    'remainderId': id,
    'merchantId': 'assxx',
  };

  final response = await postDataApiCall(TransactionRoutes.addTransaction, body);
  
  
  if (getFlagOfResponse(response)) {
    snackBarCalled(context, SnackbarData().allDebtsCleared, AppColors.accentColor);
  } else {
    snackBarCalledfail(context, SnackbarData().debterror, Colors.red);
  }
}

void getNewBudget() async {
  
  final response = await getDataApiCall('${url}/budget/');
  

  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    var obj = his['data'];

    budgetList.clear();
    budgetLength.value = obj.length;
    budgetList.addAll(obj);
  } else {}
}

void getUserLend(context) async {
  String urlPath = "${url}/bill/lend";
  var responce = await getDataApiCall(urlPath);

  if (getFlagOfResponse(responce)) {
    var his = jsonDecode(responce.body);
    var userLend = his['data'];
    lendAmountRemainders.clear();
    lendAmountRemainders.addAll(userLend);
    getlendUsers.value = !getlendUsers.value;
  }
}
void sendNotificationsToDevice(id, context, msg,
    [String screen = "/home",
    String title = "",
    String pic = "",
    String message = "",
    String billid = ""]) async {
  String urlPath = "${url}/reminders/sendNotifications/ToDevice";
 

  try {
    final response = await postDataApiCall(urlPath,{
        'id': id,
        'message': msg,
        'screen': screen,
        'title': title,
        'pic': pic,
        "billId": billid
      }
    );

    if (response.statusCode == 429) {
      var data = jsonDecode(response.body);
      snackBarCalledfail(context, data["message"], Colorcodes.red);
      return;
    }
    if (screen == "/remainder" || screen == "/remainders") {
      snackBarCalled(context, message);
    }
  } catch (e) {}
}



Future<String?> getToken() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  var accessToken = SecureStorageService().read("accessToken");
  if (accessToken == null) {
    return null;
  } else {
    return accessToken;
  }
}
