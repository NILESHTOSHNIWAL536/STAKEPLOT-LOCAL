
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/repository/finance_repository.dart';
import 'package:flutter_application_code_stakeplot/repository/home_page_apiCalls.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/repository/finora_repository.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:week_of_year/week_of_year.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import '../../Home_Screen/insightsController.dart';
import '../../routes/route_transactions.dart';


void updateCatAndMoneyMap(BuildContext context)
{
  final controller = Get.find<InsightsController>();
  controller.getHomePageInsights(context);
  controller.getHomePageMoneyMapInsights(context);
  getCategoryData(context);
}

void pickCustomDateRange(BuildContext context) async {
  List<DateTime?> picked = await showCalendarDatePicker2Dialog(
        context: context,
        useRootNavigator: false,
        config: CalendarDatePicker2WithActionButtonsConfig(
          calendarType: CalendarDatePicker2Type.range,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          selectableDayPredicate: (day) => true,
          selectedDayHighlightColor:
              AppColors.primaryColor, // Selected range color
          controlsTextStyle:
              TextStyle(color: AppColors.accentColor), // Header text color
          dayTextStyle:
              TextStyle(color: AppColors.accentColor), // Default day text color
          selectedDayTextStyle:
              TextStyle(color: AppColors.accentColor), // Selected day text color
          weekdayLabelTextStyle: TextStyle(color: AppColors.accentColor),
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
    getWeeklyGraphAndCustomDateGraph(startDate, context,
        weekORmonth: 'Custom', endDate: endDate);
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
  // String urlPath = endDate != null && weekORmonths == 'custom'
  //     ? "$url/transactionaut2o/getWholeTransactionsGraph/${weekORmonths.toLowerCase()}/$date,${getNextDay(endDate)}"
  //     : "$url/transactionaut2o/getWholeTransactionsGraph/${weekORmonths.toLowerCase()}/$date";

  String urlPath = endDate != null && weekORmonths == 'custom'
    ? BankTransactionRoutes.getWholeTransactionsGraph(
        type: weekORmonths.toLowerCase(),
        value: "$date,${getNextDay(endDate)}",
      )
    : BankTransactionRoutes.getWholeTransactionsGraph(
        type: weekORmonths.toLowerCase(),
        value: date,
      );


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



void pickCustomDateRangeoverall(BuildContext context) async {
  List<DateTime?> picked = await showCalendarDatePicker2Dialog(
        context: context,
        config: CalendarDatePicker2WithActionButtonsConfig(
          calendarType: CalendarDatePicker2Type.range,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          selectableDayPredicate: (day) => true,
          selectedDayHighlightColor: Colors.blueAccent,
          controlsTextStyle: TextStyle(color: AppColors.accentColor),
          dayTextStyle: TextStyle(color: AppColors.accentColor),
          selectedDayTextStyle: TextStyle(color: AppColors.accentColor),
          weekdayLabelTextStyle: TextStyle(color: AppColors.accentColor),
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
