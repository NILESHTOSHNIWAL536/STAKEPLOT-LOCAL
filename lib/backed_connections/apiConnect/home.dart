import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/number_picker.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';
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

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    cupertinoPin.value = password;
    snackBarCalled(context, " Pin set successfully!", Colors.black);
  } else {
    snackBarCalled(context, "can't set pin!", Colors.red);
  }
  Navigator.pop(context);
}

void PinPasswordVerify(password, context, Function setBack) async {
  var response = await getDataApiCall("${url}/user/cupertino/${password}");

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

void seletedBankUpdateInfo(id, context) async {
  var response = await getDataApiCall("${url}/user/selectedBank/${id}");
  if (response.statusCode == 200 || response.statusCode == 200) {
  } else {}
}


void getAllTransaction(context) async {
  var response =
      await getDataApiCall("${url}/transactionauto/getTransactions/1");
  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    trasactionsHistory.clear();
    trasactionsHistory.addAll(obj);
    getHistory.value = !getHistory.value;
  } else {}
}

void getInsights(context,String id) async {
 
  var response = await getDataApiCall(
    //String t="679b6ea12af555d641c5da61";
      "${url}/budget/get-insights/$id");
  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    var obj = his['data'];

    inSights.clear();
    inSights.addAll(obj);
    getHistory.value = !getHistory.value;
  } else {}
}

void getHiddenTransactions(context) async {
  var response =
      await getDataApiCall("${url}/transactionauto/get-hide-transactions");
  if (response.statusCode == 200) {
    var her = jsonDecode(response.body);
    var obj = her['data'];
    hiddentrasactionsHistory.clear();
    hiddentrasactionsHistory.addAll(obj);
    getHiddenHistory.value = !getHiddenHistory.value;
  } else {}
}

// List<dynamic> transactionsHistory = [];


// void getAllTransactionHistory( BuildContext context, bool flag, bool isYearView) async {
//   try {
//     var response = await getDataApiCall(flag
//         ? "${url}/transactionauto/getTransactions/2"
//         : "${url}/transactionauto/getTransactions/1");
//     if (response.statusCode == 200) {
//       var his = jsonDecode(response.body);

//       var obj = his['data'];

//       transactionsHistory.clear();
//       if (obj != null && obj is List<dynamic>) {
//         if (flag) {
//           extractTransaction(isYearView, obj);
//         } else {
//           transactionsHistory.addAll(obj);
//         }

//         getHistory.value = !getHistory.value;
//       } else {

//         snackBarCalled(context, "No transaction data available");
//       }
//     } else {}
//   } catch (e) {
   
//   }
// }


Future<void> getAllTransactionHistory(BuildContext context,bool flag,bool  isYearView,{bool isRefreshing = false}) async {
  if (isLoadingMore.value) return; // Prevent multiple API calls

  try {
    isLoadingMore.value = true;
    // /get-monthly-transactions-history/:accountId/:type/:page
    String type= isYearView ? selectedYear.value.toString(): selectedYear.value.toString()+"-"+selectedMonth.value.toString().padLeft(2, '0');
    String urlPath= flag? "${url}/transactionauto/get-monthly-transactions-history/${accountId.value}/${type}/$currentPage":"${url}/transactionauto/getTransactions/$currentPage";
 
    var response = await getDataApiCall(urlPath);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      var obj = data['data'];
      if (obj != null && obj is List<dynamic>) 
      {
       
            if (isRefreshing) {
              transactionsHistory.clear(); // Clear only on refresh
            }
         
            transactionsHistory.addAll(obj);


        // Stop loading indicator if no more transactions exist
        if (obj.isEmpty || obj.length<20) {
          hasMoreData = false;
          isLoadingMore.value=false;
        } else {
          currentPage++; // Increment page count for next load
        }
         await Future.delayed(const Duration(seconds: 1));
        if(flag){
          loadChatdataOnChnage.value=!loadChatdataOnChnage.value;
        }
        getHistory.value = !getHistory.value;
      } else {
        snackBarCalled(context, "No transaction data available");
      }
    }
  } catch (e) {
   
  } finally {
    isLoadingMore.value = false;
  }
}


void extractTransaction(bool isYearView, List obj) {
  if (isYearView) {
    getTransactionByYear(obj, selectedYear.value);
  } else {
    getTransactionByMonth(obj, selectedMonth.value);
  }
}

void getTransactionByYear(List obj, y) {
  obj.forEach((ele) {
    if (isCurrentYear(ele['transactionTimestamp'], y)) {
      transactionsHistory.add(ele);
    }
  });
}

void getTransactionByMonth(List obj, y) {
  obj.forEach((ele) {
    if (isCurrentMonth(ele['transactionTimestamp'], y)) {
      transactionsHistory.add(ele);
    }
  });
}

bool isCurrentYear(String date, int y) {
  try {
    DateTime parsedDate = DateTime.parse(date); // Parse the date string
    return parsedDate.year == y; // Compare year
  } catch (e) {
    return false; // Return false if parsing fails
  }
}

bool isCurrentMonth(String date, int m) {
  try {
    DateTime parsedDate = DateTime.parse(date);
    return parsedDate.month == m; // Compare month
  } catch (e) {
    return false;
  }
}
