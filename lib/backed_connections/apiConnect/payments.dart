import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/success_post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void getDebts() async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.get(
    Uri.parse('${url}/debt/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    debtLength.value = obj.length;
    debtsList.clear();
    debtsList.addAll(obj);
  } else {
    //  //print("Error while getting data");
  }
}

void getBudget() async {
  String urlPath = "${url}/budget/";
  try {
    var responce = await getDataApiCall(urlPath);
    if (getFlagOfResponse(responce)) {
      var his = jsonDecode(responce.body);
      var obj = his['data'];
      budgetList.clear();
      budgetList.addAll(obj);
      budgetLength.value = obj.length;
    }
  } catch (e) {}
}

void getBudget2() async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.get(
    Uri.parse('${url}/budget/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );

  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    budgetList.clear();
    budgetList.addAll(obj);
    budgetLength.value = obj.length;
  } else {}
}

getBills() async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.get(
    Uri.parse('${url}/bill/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    billLength.value = obj.length;
    //  billAmount.clear();
    //  billAmount.addAll(obj);
  } else {}
}

getPayments() async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.get(
    Uri.parse('${url}/payment/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    paymentLength.value = obj.length;
    // payment.clear();
    // payment.addAll(obj);
  } else {}
}

void addBudget(BuildContext context, String name, String amount,
    List expenseCategory, String budgetPeriod) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  var body = {
    'name': name.toString(),
    'amount': amount.toString(),
    'categoryBudgets': expenseCategory,
    'budgetPeriod': budgetPeriod.toString(),
  };

  final response = await http.post(
    Uri.parse('${url}/budget/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": accessToken.toString(),
    },
    body: jsonEncode(body),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    getBudget();
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);
   
    snackBarCalled(context, "You have successfully added a new budget!");
   
  } else {
    snackBarCalled(context, "Failed to add the budget!", Colors.red);
  }

  acceptReset.value = false;
}

void budgetUpdate(context, name, amount, expenseCategory, budgetType,
    budgetPeriod, id) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.post(
    Uri.parse('${url}/budget/edit/${id}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      'name': name.toString(),
      'amount': amount.toString(),
      'expenseCategories': expenseCategory,
      'budgetType': budgetType.toString(),
      'budgetPeriod': budgetPeriod.toString(),
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);

    snackBarCalled(context, "Your budget has been updated successfully!");
    // Navigator.pushNamed(context, '/BudgetCheck');
    Navigator.pop(context);
    Navigator.pop(context);

    //  Navigator.push(
    //                         context,
    //                         PageTransition(
    //                           type: PageTransitionType.fade,
    //                           alignment: Alignment.bottomRight,
    //                           duration: Durations.long1,

    //                           child:const BudgetCheck(),
    //                           isIos: true,
    //                         ),
    // );
  } else {
    snackBarCalled(context, "Unable to update the budget!", Colors.red);
  }
}

void addDebts(context, name, amount, interest, startDate, durations) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  debtLength.value = 1 + debtLength.value;
  final response = await http.post(
    Uri.parse('${url}/debt/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      'name': name.toString(),
      'amount': amount,
      'interest': interest.toString(),
      'startDate': startDate.toString(),
      'duration': durations,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);

    snackBarCalled(context, "Debt has been successfully added!");
    acceptReset.value = false;
    //  Navigator.pushNamed(context, '/DebtsBillAmoutDisplay');

    //  SchedulePaymentsDisplay

    //   Navigator.pop(context);
    getDebts();
    Navigator.pop(context);

    //    Navigator.pushReplacement(
    //                         context,
    //                         PageTransition(
    //                           type: PageTransitionType.bottomToTop,
    //                           alignment: Alignment.bottomRight,
    //                           duration: Durations.long1,

    //                           child:const Budget(),
    //                           isIos: true,
    //  ));

    //  Navigator.push(
    //                         context,
    //                         PageTransition(
    //                           type: PageTransitionType.bottomToTop,
    //                           alignment: Alignment.bottomRight,
    //                           duration: Durations.long1,

    //                           child:DebtsBillAmoutDisplay(),
    //                           isIos: true,
    //  ));
  } else {
    snackBarCalled(context, "Failed to add the debt!", Colors.red);
  }
  acceptReset.value = false;
}

void addBillTranscations(
    List<TextEditingController> controller, context) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  int end = controller.length;

  for (int i = 0; i < end; i += 3) {
    billLength.value += 1;
    String name = controller[i].text;
    String amount = controller[i + 1].text;
    String expenseCategory = controller[i + 2].text;

    final response = await http.post(
      Uri.parse('${url}/bill/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode({
        'name': name.toString(),
        'amount': amount,
        'dueDate': expenseCategory.toString(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);

      acceptReset.value = false;
      snackBarCalled(
          context, "Bill has been successfully added!", Colors.black);
      getBills();
      Navigator.pop(context);
    } else {
      snackBarCalled(context, "Unable to add the bill!", Colors.red);
    }
    acceptReset.value = false;
  }
}

void addPaymentTranscations(
    List<TextEditingController> controller, context) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  int end = controller.length;

  // paymentLength.value += (end/3) as int;

  for (int i = 0; i < end; i += 3) {
    paymentLength.value += 1;
    String name = controller[i].text;
    String amount = controller[i + 1].text;
    String expenseCategory = controller[i + 2].text;

    final response = await http.post(
      Uri.parse('${url}/payment/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode({
        'name': name.toString(),
        'amount': amount,
        'date': expenseCategory.toString(),
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);
      acceptReset.value = false;
      snackBarCalled(
          context, "Payment has been successfully added!", Colors.black);

      getPayments();
      //  Navigator.pushNamed(context, '/bsDisplay');
      Navigator.pop(context);
    } else {
      snackBarCalled(context, "Unable to add the payment!", Colors.red);
    }
    acceptReset.value = false;
    // Navigator.pushNamed(context, '/SchedulePaymentsDisplay');
  }

  // Navigator.pop(context);
}

void deleteDebts(context, String id, [flag = false]) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  final response = await http.delete(
    Uri.parse('${url}/debt/${id}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({}),
  );
  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    snackBarCalled(context, "Debts have been cleared!", Colors.black);
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
    snackBarCalled(
        context, "An error occurred while closing the debts!", Colors.red);
  }
}

void deleteAmount(context, String id, String am) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  final response = await http.patch(
    Uri.parse('${url}/debt/${id}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({}),
  );
  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
  } else {
    snackBarCalled(
        context, "An error occurred while closing the debts!", Colors.red);
  }
}

void updateBill(context, String path, String objectId) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  String pathUrl = '${url}/${path}/${objectId}';

  final response = await http.patch(
    Uri.parse(pathUrl),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      'markAsComplete': true,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    getBills();
    getPayments();
    snackBarCalled(context, "${path} is paid!", Colors.black);
  } else {
    snackBarCalled(context, "An error occurred during the update!", Colors.red);
  }
}

void deleteBudget(context, String id) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.delete(
    Uri.parse('${url}/budget/${id}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
  if (response.statusCode == 200 || response.statusCode == 201) {
    snackBarCalled(context, "Processing budget deletion...", Colors.red);
  } else {
    snackBarCalled(
        context, "Error occurred while deleting the budget!", Colors.red);
  }
}

void clearDebts(context, String id, String amount, String value) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  var body = {
    'amount': amount,
    'label': "",
    'account': value,
    'category': "",
    'isDebt': true,
    'remainderId': id,
    'merchantId': 'assxx',
  };

  final response = await http.post(
    Uri.parse('${url}/transaction/add'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode(body),
  );
  if (response.statusCode == 200) {
    final body = json.decode(response.body);
    snackBarCalled(
        context, "All debts for this month have been cleared!", Colors.black);
    //  Navigator.pushReplacementNamed(context, '/home');
  } else {
    snackBarCalled(context, "can't add trasactions!", Colors.red);
  }
}

void getNewBudget() async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.get(
    Uri.parse('${url}/budget/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );

  if (response.statusCode == 200) {
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

void sendNotificationsToDevice(id, context, msg,[String screen="/home",String title="",String pic="",String message="",String billid=""]) async {
  String urlPath = "${url}/reminders/sendNotifications/ToDevice";
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

   try{
  final response = await http.post(
    Uri.parse('${urlPath}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      'id': id,
      'message': msg,
      'screen':screen,
      'title':title,
      'pic':pic,
      "billId":billid
    }),
  );

   printData(response);
   if(response.statusCode==429){
       var data=jsonDecode(response.body);
       snackBarCalled(context, data["message"],Colorcodes.red);
       return;
   }

   if(screen=="/remainder")
   {
              snackBarCalled(context, message);
   }

   }catch(e){
   
  }
}

void getTopFiveCater() async {
  String urlPath = "${url}/budget/top-five-categories/";
  try {
    var responce = await getDataApiCall(urlPath);
    if (getFlagOfResponse(responce)) {
      var his = jsonDecode(responce.body);
      categoriesSeleted.clear();
      categoriesSeleted.addAll(his['data']);
      getCategories.value = !getCategories.value;
    }
  } catch (e) {}
}

Future<String?> getToken() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  var accessToken = pref.getString("accessToken");
  if (accessToken == null) {
    return null;
  } else {
    return accessToken;
  }
}
 