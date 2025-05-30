import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/categoriseSpending.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/manual_transaction.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/animated/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/finance_chart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:week_of_year/week_of_year.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

double getDouble(data) {
  return double.parse(data.toString());
}

// Functions to fetch the data
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
  //       allTransactions.addAll(category["transactions"]);trasactionsData
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

void getAutoMationsTransactionsCustom(date, context,
    [weekORmonth = 'month', String? endDate]) async {
  if (accountId.value.trim().toString() == "") return;

  String urlPath = endDate != null && weekORmonth == 'Custom'
      ? "$url/transactionauto/getAllCustomTransactions/${accountId.value}/${weekORmonth.toLowerCase()}/$date,${getNextDay(endDate)}"
      : "$url/transactionauto/getAllCustomTransactions/${accountId.value}/${weekORmonth.toLowerCase()}/$date";
  var response = await getDataApiCall(urlPath);
  
  trasactionsDataDebitWeekly.clear();

  List<String> labelsLocal = [];
  List<double> debitList = [];
  List<double> creditList = [];

  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    transactionChatGraph.clear();

    try {
      Map data = his['data']['result'];
      try {
        String nulldata = (his['data']['debitChangePercentage']).toString();
        totalDebitValuePercent.value =
            double.parse(nulldata == "null" ? "0" : nulldata);
        totalDebitValue.value =
            double.parse((his['data']['totalDebit']).toString());
      } catch (e) {}

      maxYValue.value =
          double.parse((his['data']['maxAmount'] ?? 500.0).toString());

      if (maxYValue.value == 0) maxYValue.value = 500.0;

      if (weekORmonth == 'Custom' && endDate != null) {
        DateTime startDate = DateTime.parse(date);
        DateTime end = DateTime.parse(endDate);

        // Generate date labels in "MMM d" format
        labelsLocal = [];
        int daysDiff = end.difference(startDate).inDays;
        debitList = List.filled(daysDiff + 1, 0.0);
        creditList = List.filled(daysDiff + 1, 0.0);

        for (int i = 0; i <= daysDiff; i++) {
          DateTime currentDate = startDate.add(Duration(days: i));
          String formattedDate = DateFormat('MMM d').format(currentDate);
          labelsLocal.add(formattedDate);
        }

        data.forEach((key, value) {
          DateTime txDate = DateTime.parse(key);
          if (txDate.isAfter(startDate.subtract(Duration(days: 1))) &&
              txDate.isBefore(end.add(Duration(days: 1)))) {
            int index = txDate.difference(startDate).inDays;
            if (index >= 0 && index < debitList.length) {
              debitList[index] = getDouble(value['debit']);
              creditList[index] = getDouble(value['credit']);
            }
          }
        });

      } else {
        // Keep original logic for non-custom cases
        data.forEach((key, value) {
          String label = weekORmonth == 'Custom'
              ? key.toString()
              : key.toString().substring(key.toString().length - 2);
          labelsLocal.add(label);
          debitList.add(getDouble(value['debit']));
          creditList.add(getDouble(value['credit']));
        });
       
      }
    } catch (e) {
      maxYValue.value = 500.0;
      if (labelsLocal.isEmpty) {
        if (weekORmonth == 'Custom' && endDate != null) {
          DateTime startDate = DateTime.parse(date);
          DateTime end = DateTime.parse(endDate);
          int daysDiff = end.difference(startDate).inDays;
          debitList = List.filled(daysDiff + 1, 0.0);
          creditList = List.filled(daysDiff + 1, 0.0);

          for (int i = 0; i <= daysDiff; i++) {
            DateTime currentDate = startDate.add(Duration(days: i));
            String formattedDate = DateFormat('MMM d').format(currentDate);
            labelsLocal.add(formattedDate);
          }
        } else {
          labelsLocal =
              weekORmonth == 'Week' ? getWeekDays() : getDaysInMonth(date);
          debitList = List.filled(labelsLocal.length, 0.0);
          creditList = List.filled(labelsLocal.length, 0.0);
        }
      }
    }

    if (selectedButton.value == 'Week') {
      labelsLocal = getWeekDays();
      if (debitList.length < 7) {
        debitList = List.filled(7, 0.0)
          ..setRange(0, debitList.length, debitList);
        creditList = List.filled(7, 0.0)
          ..setRange(0, creditList.length, creditList);
      }
    }

    transactionChatGraph['debited'] = debitList;
    transactionChatGraph['credited'] = creditList;

    getGraphData.value = false;
    labels.assignAll(labelsLocal);
    getGraphData.value = true;
  } else {
    if (weekORmonth == 'Custom' && endDate != null) {
      DateTime startDate = DateTime.parse(date);
      DateTime end = DateTime.parse(endDate);
      int daysDiff = end.difference(startDate).inDays;
      debitList = List.filled(daysDiff + 1, 0.0);
      creditList = List.filled(daysDiff + 1, 0.0);

      for (int i = 0; i <= daysDiff; i++) {
        DateTime currentDate = startDate.add(Duration(days: i));
        String formattedDate = DateFormat('MMM d').format(currentDate);
        labelsLocal.add(formattedDate);
      }
      transactionChatGraph['debited'] = debitList;
      transactionChatGraph['credited'] = creditList;
    }
    getGraphData.value = true;
  }
}

String getNextDay(String endDate) {
  // Parse the input date string
  DateTime date = DateTime.parse(endDate);
  // Add one day
  DateTime nextDay = date.add(Duration(days: 1));
  // Return formatted as YYYY-MM-DD
  return nextDay.toIso8601String().split('T')[0];
}

List<String> getWeekDays() {
  return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
}

List<String> getDaysInMonth(String yearMonth) {
  List<String> days = [];
  List<String> parts = yearMonth.split('-');
  if (parts.length != 2) return days;

  int year = int.tryParse(parts[0]) ?? 0;
  int month = int.tryParse(parts[1]) ?? 0;
  if (year == 0 || month == 0) return days;

  int daysInMonth = DateTime(year, month + 1, 0).day;

  for (int i = 1; i <= daysInMonth; i++) {
    days.add('${i.toString().padLeft(2, '0')}');
  }

  return days;
}

String getCurrentMonth() {
  DateTime now = DateTime.now();
  String year = now.year.toString();
  String month = now.month.toString().padLeft(2, '0'); // Ensures two digits
  return '$year-$month';
}

String getCurrentWeek() {
  final now = DateTime.now().subtract(Duration(days: 7));
  final year = now.year;
  String s = '$year-W${now.weekOfYear.toString().padLeft(2, '0')}';
  return s;
}

String getCurrentWeekoverall() {
  final now = DateTime.now();
  final year = now.year;
  String s = '$year-W${now.weekOfYear.toString().padLeft(2, '0')}';
  return s;
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
  }
}


void updateTheTagOfTarnsactions(
    category, subCategory, transactionId, context, index) async {
  String urlPath = "${url}/transactionauto/updateTransaction/${transactionId}";
  var response = await updateDataApiCall2(urlPath, {
    'category': category,
    'subcategory': subCategory,
  });

  if (getFlagOfResponse(response)) {
    Navigator.pop(context);
    reloadHistory.value = !reloadHistory.value;
  } else {}
}

void updateTheTagOfTarnsactionsGroup(
    category, subCategory, grpId, context, index) async {
  String urlPath = "${url}/transactionauto/grouped/${grpId}/categorize";

  var body = {
    'category': category,
    'subcategory': subCategory,
    "removedTransactions": removedGrpItemsList,
  };

  var response = await postDataApiCall(urlPath, body);

  if (getFlagOfResponse(response)) {
    getAllTransaction(context);
    reloadHistory.value = !reloadHistory.value;
    Navigator.pop(context);
    Navigator.pop(context);
    removedGrpItemsList.clear();
    lengthOfTransactions.value = false;
    setGroupTransactions.value = false;
    getGroupTransactions();
  } else {}
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
  if (getFlagOfResponse(response)) {
    trasactionsHideData.clear();
    var his = jsonDecode(response.body);
    trasactionsHideData
        .addAll(his['allTransactions']['categorized_transactions']);
  }
}

void addTransaction(String amount, String subCategory, String categories,
    BuildContext context, String dropdownValue,
    [bool isSplit = false,bool snackBar=true]) async {

  var body = {
    'amount': amount.toString(),
    'category': categories.toString(),
    'label': subCategory.toString(),
    'account': dropdownValue.toString(),
    'room': {},
    'isSplit': isSplit,
    'isDebit': isDebit
  };

  final response = await postDataApiCall("${url}/transaction/add", body);
   printData(response);
  if (getFlagOfResponse(response)) {
    final body = json.decode(response.body);
    if (!isSplit && snackBar) {
      snackBarCalled(context,  SnackbarData().transactionSuccess,AppColors.primaryColor);
    }
    transactionsHistory.insert(0, body['data'][0]);
    reloadHistory.value = !reloadHistory.value;
    getCategoryData();
    setDonectChat.value = !setDonectChat.value;
    processChartData();
    getAutoMationsTransactionsCustom(getFormattedDate(), context);
    Navigator.pop(context);
  } else {
    snackBarCalledfail(context, SnackbarData().transactionAddFail, Colors.red);
  }

   cashInAndOut.value =false;
}

void processChartData() {
  List<ChartData> newData = [];
  double newTotalValue = 0.0;

  Map<String, Color> categoryColors = {
    "Food": Color(0xFFE74C3C), // Red
    "Shopping": Color(0xFF8E44AD), // Purple
    "Travel": Color(0xFF3498DB), // Blue
    "Health": Color(0xFF2ECC71), // Green
    "Subscriptions": Color(0xFFF1C40F), // Yellow
    "Entertainment": Color(0xFFE67E22), // Orange
    "Insurance": Color(0xFF1ABC9C), // Teal
    "Emi": Color(0xFFD35400), // Dark Orange
    "Investments": Color(0xFF9B59B6), // Dark Purple
    "Untagged": Color(0xFF34495E), // Dark Gray-Blue
    "Bills": Color(0xFF16A085), // Dark Teal
    "Events": Color(0xFF27AE60), // Green
    "Personal Care": Color(0xFF2980B9), // Dark Blue
    "Services": Color(0xFFC0392B), // Dark Red
    "Current": Color(0xFF7D3C98), // Violet
    "Children": Color(0xFFF39C12), // Bright Yellow
    "Pet Care": Color(0xFF52BE80), // Soft Green
    "Sports": Color(0xFF5DADE2), // Sky Blue
    "Alcohol": Color(0xFFCD6155), // Soft Red
    "Hobbies": Color(0xFFAF7AC5), // Light Purple
    "Education": Color(0xFF45B39D), // Turquoise
    "Commerce": Color(0xFFDC7633), // Copper Orange
    "snacks": Color(0xFF5D6D7E), // Muted Blue-Gray
    "UPI": Color(0xFF5D6D7E), // Muted Blue-Gray
  };

  for (var item in categoriesList) {
    String category = item["category"];
    String percentage = item["total_debit_percentage"] ?? "";
    double value = item["total_debit"].toDouble();
    Color color = categoryColors[category] ?? Colors.grey; // Default color

    newData.add(ChartData(category, value, color, percentage));
    newTotalValue += value;
  }

  chartData.value = newData;
  totalValue.value = newTotalValue;
}

void getTransaction(context) async {
  var response = await getDataApiCall("${url}/transaction/history");

  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    trasactionsHistory.clear();
    trasactionsHistory.addAll(obj);
  } else {}
}

void pickCustomDateRange(BuildContext context) async {
  List<DateTime?> picked = await showCalendarDatePicker2Dialog(
        context: context,
        config: CalendarDatePicker2WithActionButtonsConfig(
          calendarType: CalendarDatePicker2Type.range,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          selectableDayPredicate: (day) => true,
          selectedDayHighlightColor:
              AppColors.primaryColor, // Selected range color
          controlsTextStyle:
              TextStyle(color: Colors.black), // Header text color
          dayTextStyle:
              TextStyle(color: Colors.black), // Default day text color
          selectedDayTextStyle:
              TextStyle(color: Colors.black), // Selected day text color
          weekdayLabelTextStyle: TextStyle(color: Colors.black),
        ),
        dialogSize: const Size(400, 300),
        value: [
          startDateCustom,
          endDateCustom,
          // DateTime.now().subtract(const Duration(days: 7)),
          // DateTime.now(),
        ],
        borderRadius: BorderRadius.circular(24),
      ) ??
      [];

  if (picked.length == 2 && picked[0] != null && picked[1] != null) {
    DateTime start = picked[0]!;
    DateTime end = picked[1]!;
    startDateCustom = start;
    endDateCustom = end;
    selectedButton.value = 'Custom';
    getGraphData.value = false;

    List<String> customDays = [];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      String day = (start.day + i).toString().padLeft(2, '0');
      customDays.add(day);
    }

    labels.assignAll(customDays);

    String startDate = start.toIso8601String().split('T')[0];
    String endDate = end.toIso8601String().split('T')[0];
    getAutoMationsTransactionsCustom(startDate, context, 'Custom', endDate);
  }
}

//double totalSpent = calculateTotal(chartData);
//  totalSpent =chartData["credited"]!.isNotEmpty && chartData["debited"]!.isNotEmpty? calculateTotal(chartData): 0.0;

double calculateTotal(Map<String, List<double>> data) {
  return data["credited"]!.reduce((a, b) => a + b) -
      data["debited"]!.reduce((a, b) => a + b);
}

void getAutoMationsTransactionsCustomoverall(date, context,
    [weekORmonths = 'month', String? endDate]) async {
  String urlPath = endDate != null && weekORmonths == 'custom'
      ? "$url/transactionauto/getWholeTransactionsGraph/${weekORmonths.toLowerCase()}/$date,${getNextDay(endDate)}"
      : "$url/transactionauto/getWholeTransactionsGraph/${weekORmonths.toLowerCase()}/$date";

  var response = await getDataApiCall(urlPath);

  trasactionsDataDebitWeeklyoverall.clear();

  List<String> labelsLocal = [];
  List<double> debitList = [];

  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    transactionChatGraphoverall.clear();

    // Declare dataoverall outside the try block
    Map dataoverall = his['data']['result'];

    try {
      List<double> debitValues =
          dataoverall.values.map((value) => getDouble(value['debit'])).toList();
      totalDebitValue.value =
          debitValues.reduce((a, b) => a + b); // Calculate total debit
      if (debitValues.isNotEmpty) {
        maxYValueoverall.value = debitValues.reduce((a, b) => a > b ? a : b);
      } else {
        maxYValueoverall.value = 500.0;
      }

      if (weekORmonths == 'custom' && endDate != null) {
        DateTime startDate = DateTime.parse(date);
        DateTime end = DateTime.parse(endDate);

        labelsLocal = [];
        int daysDiff = end.difference(startDate).inDays;
        debitList = List.filled(daysDiff + 1, 0.0);

        for (int i = 0; i <= daysDiff; i++) {
          DateTime currentDate = startDate.add(Duration(days: i));
          String formattedDate = DateFormat('MMM d').format(currentDate);
          labelsLocal.add(formattedDate);
        }

        dataoverall.forEach((key, value) {
          DateTime txDate = DateTime.parse(key);
          if (txDate.isAfter(startDate.subtract(Duration(days: 1))) &&
              txDate.isBefore(end.add(Duration(days: 1)))) {
            int index = txDate.difference(startDate).inDays;
            if (index >= 0 && index < debitList.length) {
              debitList[index] = getDouble(value['debit']);
            }
          }
        });
      } else if (weekORmonths == 'week') {
        labelsLocal =
            getWeekDays(); // ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
        debitList = List.filled(7, 0.0);

        // Parse the week string (e.g., "2025-W10")
        final weekParts = date.split('-W');
        final year = int.parse(weekParts[0]);
        final weekNumber = int.parse(weekParts[1]);
        DateTime weekStart = _getWeekStartDate(year, weekNumber);

        dataoverall.forEach((key, value) {
          DateTime txDate = DateTime.parse(key);
          int index = txDate.difference(weekStart).inDays;
          if (index >= 0 && index < 7) {
            debitList[index] = getDouble(value['debit']);
          }
        });
      } else {
        DateTime startDate =
            DateTime.parse("$date-01"); // Ensure full date for month
        int daysInMonth = DateTime(startDate.year, startDate.month + 1, 0).day;
        labelsLocal = List.generate(
            daysInMonth, (i) => (i + 1).toString().padLeft(2, '0'));
        debitList = List.filled(daysInMonth, 0.0);

        dataoverall.forEach((key, value) {
          DateTime txDate = DateTime.parse(key);
          if (txDate.month == startDate.month &&
              txDate.year == startDate.year) {
            int index = txDate.day - 1;
            if (index >= 0 && index < debitList.length) {
              debitList[index] = getDouble(value['debit']);
            }
          }
        });
      }
    } catch (e) {
      maxYValueoverall.value = 500.0;
      if (labelsLocal.isEmpty) {
        if (weekORmonths == 'custom' && endDate != null) {
          DateTime startDate = DateTime.parse(date);
          DateTime end = DateTime.parse(endDate);
          int daysDiff = end.difference(startDate).inDays;
          debitList = List.filled(daysDiff + 1, 0.0);
          for (int i = 0; i <= daysDiff; i++) {
            DateTime currentDate = startDate.add(Duration(days: i));
            String formattedDate = DateFormat('MMM d').format(currentDate);
            labelsLocal.add(formattedDate);
          }
          dataoverall.forEach((key, value) {
            DateTime txDate = DateTime.parse(key);
            if (txDate.isAfter(startDate.subtract(Duration(days: 1))) &&
                txDate.isBefore(end.add(Duration(days: 1)))) {
              int index = txDate.difference(startDate).inDays;
              if (index >= 0 && index < debitList.length) {
                debitList[index] = getDouble(value['debit']);
              }
            }
          });
        } else if (weekORmonths == 'week') {
          labelsLocal = getWeekDays();
          debitList = List.filled(7, 0.0);
          // Process week data using dataoverall
          final weekParts = date.split('-W');
          final year = int.parse(weekParts[0]);
          final weekNumber = int.parse(weekParts[1]);
          DateTime weekStart = _getWeekStartDate(year, weekNumber);
          dataoverall.forEach((key, value) {
            DateTime txDate = DateTime.parse(key);
            int index = txDate.difference(weekStart).inDays;
            if (index >= 0 && index < 7) {
              debitList[index] = getDouble(value['debit']);
            }
          });
        } else {
          DateTime startDate = DateTime.parse("$date-01");
          int daysInMonth =
              DateTime(startDate.year, startDate.month + 1, 0).day;
          labelsLocal = List.generate(
              daysInMonth, (i) => (i + 1).toString().padLeft(2, '0'));
          debitList = List.filled(daysInMonth, 0.0);
          dataoverall.forEach((key, value) {
            DateTime txDate = DateTime.parse(key);
            if (txDate.month == startDate.month &&
                txDate.year == startDate.year) {
              int index = txDate.day - 1;
              if (index >= 0 && index < debitList.length) {
                debitList[index] = getDouble(value['debit']);
              }
            }
          });
        }
      }
    }

    transactionChatGraphoverall['debited'] = debitList;

    getGraphDataoverall.value = false;
    labels2.assignAll(labelsLocal);
    getGraphDataoverall.value = true;
  } else {
    if (weekORmonths == 'custom' && endDate != null) {
      DateTime startDate = DateTime.parse(date);
      DateTime end = DateTime.parse(endDate);
      int daysDiff = end.difference(startDate).inDays;
      debitList = List.filled(daysDiff + 1, 0.0);
      for (int i = 0; i <= daysDiff; i++) {
        DateTime currentDate = startDate.add(Duration(days: i));
        String formattedDate = DateFormat('MMM d').format(currentDate);
        labelsLocal.add(formattedDate);
      }
    } else if (weekORmonths == 'week') {
      labelsLocal = getWeekDays();
      debitList = List.filled(7, 0.0);
    } else {
      DateTime startDate = DateTime.parse("$date-01");
      int daysInMonth = DateTime(startDate.year, startDate.month + 1, 0).day;
      labelsLocal =
          List.generate(daysInMonth, (i) => (i + 1).toString().padLeft(2, '0'));
      debitList = List.filled(daysInMonth, 0.0);
    }
    transactionChatGraphoverall['debited'] = debitList;
    getGraphDataoverall.value = true;
  }
}

// Helper function to calculate the start date of a week (Sunday)
DateTime _getWeekStartDate(int year, int weekNumber) {
  DateTime jan1 = DateTime(year, 1, 1);
  int daysOffset = jan1.weekday; // 1 = Monday, 7 = Sunday
  DateTime firstSunday = jan1.subtract(Duration(days: daysOffset % 7));
  DateTime weekStart = firstSunday.add(Duration(days: (weekNumber - 1) * 7));
  return weekStart;
}
// Helper functions

String getFormattedDateoverall() {
  final now = DateTime.now();
  return "${now.year}-${now.month.toString().padLeft(2, '0')}";
}

void pickCustomDateRangeoverall(BuildContext context) async {
  List<DateTime?> picked = await showCalendarDatePicker2Dialog(
        context: context,
        config: CalendarDatePicker2WithActionButtonsConfig(
          calendarType: CalendarDatePicker2Type.range,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          selectableDayPredicate: (day) => true,
          selectedDayHighlightColor: Colors.blueAccent,
          controlsTextStyle: TextStyle(color: Colors.black),
          dayTextStyle: TextStyle(color: Colors.black),
          selectedDayTextStyle: TextStyle(color: Colors.black),
          weekdayLabelTextStyle: TextStyle(color: Colors.black),
        ),
        dialogSize: const Size(300, 300),
        value: [
          DateTime.now().subtract(const Duration(days: 7)),
          DateTime.now(),
        ],
        borderRadius: BorderRadius.circular(24),
      ) ??
      [];

  if (picked.length == 2 && picked[0] != null && picked[1] != null) {
    DateTime start = picked[0]!;
    DateTime end = picked[1]!;

    selectedButton2.value = 'custom';
    getGraphDataoverall.value = false;

    List<String> customDays2 = [];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      String day = (start.day + i).toString().padLeft(2, '0');
      customDays2.add(day);
    }

    labels2.assignAll(customDays2);

    String startDate = start.toIso8601String().split('T')[0];
    String endDate = end.toIso8601String().split('T')[0];
    getAutoMationsTransactionsCustomoverall(
        startDate, context, 'custom', endDate);
  }
}

void overallTransactions(BuildContext context) {
  getAutoMationsTransactionsCustomoverall(getFormattedDateoverall(), context);
}
