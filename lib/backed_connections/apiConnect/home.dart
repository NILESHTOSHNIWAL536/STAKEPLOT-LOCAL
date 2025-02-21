import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/number_picker.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void getAck() async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  // https://stakeplot.in/api/v1/post/feed
  final response = await http.get(
    Uri.parse('${url}/user/newNotifications'),
    // Uri.parse('https://stakeplot.in/api/v1/post/all'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    hasGetNewNotifications.value = obj != 0;
    print("hasGetNewNotifications.value----------------");
    print(hasGetNewNotifications.value);
  } else {}
}

void getTraget() async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  final response = await http.get(
    Uri.parse('https://stakeplot.in/api/v1/target/insights'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );

  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    var obj = his['data'];

    targetString.value = obj;
  } else {}
}

void addTargets(context, String aim, String amount, String targetDate) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.post(
    Uri.parse('${url}/target/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      'aim': aim.toString(),
      'amount': amount,
      'targetDate': targetDate.toString(),
    }),
  );
  //printData(response,context);
  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    snackBarCalled(context, " Add Traget!", Colors.black);
    getTraget();
    Navigator.pushNamed(context, '/home');
  } else {
    snackBarCalled(context, "can't Add Traget!", Colors.red);
  }
}

void setPasswordApiCalled(context, String password) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.post(
    Uri.parse('${url}/user/cupertino/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      'pin': password.toString(),
    }),
  );

  printData(response, context);
  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    cupertinoPin.value = password;
    snackBarCalled(context, " Set Pin success!", Colors.black);
  } else {
    snackBarCalled(context, "can't Set pin!", Colors.red);
  }
  Navigator.pop(context);
}

void PinPasswordVerify(password, context, Function setBack) async {
  var response = await getDataApiCall("${url}/user/cupertino/${password}");
  printData(response, context);
  if (response.statusCode == 200 || response.statusCode == 200) {
    hideBackAccountPassword.value = true;
    Timer(Duration(seconds: 5), () {
      hideBackAccountPassword.value = false;

      firstDigit.value = 0;
      secondDigit.value = 0;
      digitLoad.value = !digitLoad.value;
      setBack();
    });
  } else {
    hideBackAccountPassword.value = false;
  }
}

// void getAllTransaction(context) async {
//   var response = await getDataApiCall("${url}/transaction/all");
//   if (response.statusCode == 200) {
//     var his = jsonDecode(response.body);
//     var obj = his['data'];
//     print("trasactionsHistory,,,,,,,,");
//     print(trasactionsHistory);
//     trasactionsHistory.clear();
//     trasactionsHistory.addAll(obj);
//     print(trasactionsHistory);
//     getHistory.value = !getHistory.value;
//   } else {}
// }
void getAllTransaction(context) async {
  var response = await getDataApiCall("${url}/transactionauto/getTransactions/1");
  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    //print("trasactionsHistory,,,,,,,,");
    print(response.body);
    trasactionsHistory.clear();
    trasactionsHistory.addAll(obj);
    getHistory.value = !getHistory.value;
  } else {}
}

void getHiddenTransactions(context) async {
  var response = await getDataApiCall("${url}/transactionauto/get-hide-transactions");
  if (response.statusCode == 200) {
    var her = jsonDecode(response.body);
    var obj = her['data'];
    print(" .................Hidden trasactions History,,,,,,,,");
    print(response.body);
    hiddentrasactionsHistory.clear();
    hiddentrasactionsHistory.addAll(obj);
    getHiddenHistory.value = !getHiddenHistory.value;
  } else {}
}


