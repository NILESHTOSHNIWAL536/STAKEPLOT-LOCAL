import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

bool getFlagOfResponse(response) {
  if (response.statusCode == 200 || response.statusCode == 201) return true;
  return false;
}

void getAutoMationsTransactions() async {
  var response = await getDataApiCall("${url}/transactionauto/");
  if (getFlagOfResponse(response)) {
    trasactionsData.clear();
    var his = jsonDecode(response.body);

    trasactionsData.addAll(his['allTransactions']['categorized_transactions']);
    changeTrasactiondata();
  } else {}
}

void changeTrasactiondata() async {
  List allTransactions = [];
  //  for (var category in trasactionsData)
  //  {
  //       allTransactions.addAll(category["transactions"]);
  //  }
  for (var category in trasactionsData) {
    String categoryId = category['_id'];
    String categoryName = category['category'];

    for (var transaction in category['transactions']) {
      transaction['categoryId'] = categoryId;
      transaction['categoryName'] = categoryName;
      allTransactions.add(transaction);
    }
  }
  allTransactions.sort((a, b) => DateTime.parse(b["transactionTimestamp"])
      .compareTo(DateTime.parse(a["transactionTimestamp"])));
  listOfRecentTrasactionsData.clear();
  listOfRecentTrasactionsData.addAll(allTransactions);
}

void getAutoMationsTransactionsMonthly() async {
  var response = await getDataApiCall(
      "${url}/transactionauto/getalltransactionsbymonth/${getCurrentMonth()}");
  trasactionsDataMonthlyCredit.clear();
  trasactionsDataMonthlyDebit.clear();

  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    List<double> creditTransactions = List<double>.filled(32, 0);
    List<double> debitTransactions = List<double>.filled(32, 0);

    his['data']['debitTransactions'].forEach((element) {
      int index = int.parse(element['day'].toString());
      double amount = double.parse(element['amount'].toString());
      debitTransactions[index] = amount;
      maxDC = max(amount, maxDC);
      minDC = min(amount, maxDC);
    });
    his['data']['creditTransactions'].forEach((element) {
      int index = int.parse(element['day'].toString());
      double amount = double.parse(element['amount'].toString());
      creditTransactions[index] = amount;
      maxDC = max(amount, maxDC);
      minDC = min(amount, maxDC);
    });

    trasactionsDataMonthlyDebit.addAll(debitTransactions);
    trasactionsDataMonthlyCredit.addAll(creditTransactions);
    // getMaxAndMin();
  }
}

void getAutoMationsTransactionsWeekly() async {
  String week = getCurrentWeek();
  var response = await getDataApiCall(
      "${url}/transactionauto/getalltransactionbyweek/${week}");
  trasactionsDataCreditWeekly.clear();
  trasactionsDataDebitWeekly.clear();
  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    List creditTransactions = his['data'][week]['creditTransactions'];
    List debitTransactions = his['data'][week]['debitTransactions'];

    creditTransactions.forEach((element) {
      trasactionsDataCreditWeekly.add(element['amount']);
    });
    debitTransactions.forEach((element) {
      trasactionsDataDebitWeekly.add(element['amount']);
    });

    // getMaxAndMin();
  }
}

void getAutoMationsTransactionsCustom(date, context) async {
  var response = await getDataApiCall(
      "${url}/transactionauto/getalltransactionsbycustom/${date}");
  trasactionsDataCreditWeekly.clear();
  trasactionsDataDebitWeekly.clear();
  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);

    Map data = his['data']['transactions'];
    if (his['data']['transactions'].isEmpty) return;
    his['data']['transactions'].forEach((key, value) {
      //data[key]=value;
    });

    List<String> labels = [];
    List<double> debitList = [];
    List<double> creditList = [];
    List<String> l1 = date.toString().split("/");
    DateTime startDate = DateTime.parse(l1[0]);
    DateTime endDate = DateTime.parse(l1[1]);

    // Loop through the date range

    for (DateTime currentDate = startDate;
        currentDate.isBefore(endDate.add(Duration(days: 1)));
        currentDate = currentDate.add(Duration(days: 1))) {
      String dateString = currentDate.toIso8601String().split('T')[0];

      if (data.containsKey(dateString)) {
        double b1 = double.parse(data[dateString]?['debit'].toString() ?? "0");
        double b2 = double.parse(data[dateString]?['credit'].toString() ?? "0");
        debitList.add(b1);
        creditList.add(b2);
        maxDC = max(max(b1, b2), maxDC);
      } else {
        debitList.add(0);
        creditList.add(0);
      }
    }

    trasactionsDataCustomCredit.clear();
    trasactionsDataCustomDebit.clear();
    trasactionsDataCustomLabel.clear();
    trasactionsDataCustomCredit.addAll(debitList);
    trasactionsDataCustomDebit.addAll(creditList);
    trasactionsDataCustomLabel.addAll(labels);
  }
}

Future<http.Response> getDataApiCall(urlPath) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  var accessToken = pref.getString("accessToken");
  final response = await http.get(
    Uri.parse(urlPath),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
  return response;
}

Future<http.Response> updateDataApiCall(urlPath) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  var accessToken = pref.getString("accessToken");

  final response = await http.patch(Uri.parse(urlPath),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode({}));
  return response;
}

String getCurrentMonth() {
  DateTime now = DateTime.now();
  String year = now.year.toString();
  String month = now.month.toString().padLeft(2, '0'); // Ensures two digits
  return '$year-$month';
}

String getCurrentWeek() {
  final now = DateTime.now();
  final year = now.year;
  final weekNumber = _getWeekNumber(now);
  return '$year-W${weekNumber.toString().padLeft(2, '0')}';
}

// Function to calculate the week number
int _getWeekNumber(DateTime date) {
  final firstDayOfYear = DateTime(date.year, 1, 1);
  final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
  final weekNumber = ((daysSinceFirstDay + firstDayOfYear.weekday) / 7).ceil();
  return weekNumber;
}

void getUserBankData(context) async {
  String urlPath = "${url}/transactionauto/userDetails/";
  var responce = await getDataApiCall(urlPath);

  if (getFlagOfResponse(responce)) {
    //  Navigator.pop(context);
  }
}

void updateTheTagOfTarnsactions(
    source_category, destination_category, transactionId, context) async {
  //  updateTransaction/:source_category/:destination_category/:transactionId
  String urlPath =
      "${url}/transactionauto/updateTransaction/${source_category}/${destination_category}/${transactionId}";

  var responce = await getDataApiCall(urlPath);

  if (getFlagOfResponse(responce)) {
    getAutoMationsTransactions();
    Navigator.pop(context);
  }
}

void hideTransactions(
    source_category, destination_category_name, transactionId, context) async {
  String urlPath =
      "${url}/transactionauto/hideTransaction/${source_category}/${destination_category_name}/${transactionId}";
  var responce = await getDataApiCall(urlPath);
  if (getFlagOfResponse(responce)) {
    getAutoMationsTransactions();
  }
}

void unHideTransactions(
    source_category, destination_category_name, transactionId, context) async {
  String urlPath =
      "${url}/transactionauto/unHideTransaction/${source_category}/${destination_category_name}/${transactionId}";
  var responce = await getDataApiCall(urlPath);

  if (getFlagOfResponse(responce)) {
    getAutoMationsTransactions();
    getHideTransactions(context);
  }
}

void getHideTransactions(context) async {
  String urlPath = "${url}/transactionauto/getHideTransaction/";
  var response = await getDataApiCall(urlPath);

  // printData(response, context);
  if (getFlagOfResponse(response)) {
    trasactionsHideData.clear();
    var his = jsonDecode(response.body);
    trasactionsHideData
        .addAll(his['allTransactions']['categorized_transactions']);
  }
}

void addTransaction(String amount, String subCategory, String categories,
    BuildContext context, String dropdownValue,
    [bool isSplit = false]) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  var body = {
    'amount': amount.toString(),
    'category': categories.toString().toLowerCase(),
    'label': subCategory.toString(),
    'account': dropdownValue.toString(),
    'room': {},
    'isSplit': isSplit,
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
    if (!isSplit) snackBarCalled(context, "Added Trasactions!", Colors.black);
    getTransaction(context);
  } else {
    snackBarCalled(context, "can't Add Trasactions!", Colors.red);
  }
}

void getTransaction(context) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  final response = await http.get(
    Uri.parse('${url}/transaction/history'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
  printData(response, context);
  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    trasactionsHistory.clear();
    trasactionsHistory.addAll(obj);
    print("transactions -------------------------------------------------");
    print(trasactionsHistory);
    print("transactions -------------------------------------------------");
  } else {}
}
