import 'dart:convert';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_application_code_stakeplot/Constants/customButton.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/expanded_finance.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:week_of_year/week_of_year.dart';
import './colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Global Rx variables
final RxBool getGraphDataoverall = false.obs;
final RxString selectedButton2 = 'month'.obs;
final RxList<String> labels2 = <String>[].obs;
final RxMap<String, List<double>> transactionChatGraphoverall =
    <String, List<double>>{}.obs;
final RxDouble maxYValueoverall = 1000.0.obs;
final RxDouble totalDebitValue = 0.0.obs;

class TransactionGraph extends StatefulWidget {
  const TransactionGraph({super.key});

  @override
  State<TransactionGraph> createState() => _TransactionGraphState();
}

class _TransactionGraphState extends State<TransactionGraph> {
  @override
  void initState() {
    super.initState();
    getGraphDataoverall.value = false;
    overallTransactions(context);
  }

  int _getDaysInCurrentMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSizeFactor = screenWidth * 0.01;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Text(
                    //   'Transactions',
                    //   style: FontManager().getTextStyle(context,
                    //       lWeight: FontWeight.normal,
                    //       fontSize: fontSizeFactor * 2.5,
                    //       color: AppColors.accentColor),
                    // ),
                  ],
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            Obx(() => getMonthWeekCustom2(fontSizeFactor, screenWidth)),
            Obx(() => !getGraphDataoverall.value
                ? Container(
                    width: MediaQuery.of(context).size.width / 1.3,
                    height: MediaQuery.of(context).size.height / 2.6,
                    child: Center(child: Spinner()),
                  )
                : BarChartWidget(
                    chartData: transactionChatGraphoverall,
                    days: labels2,
                    selectedButton: selectedButton2,
                    shouldBeNavigate: true,
                    daysInMonth: selectedButton2.value == "week"
                        ? 7
                        : selectedButton2.value == "month"
                            ? _getDaysInCurrentMonth()
                            : labels2.length,
                  )),
          ],
        ),
      ),
    );
  }

  Widget getMonthWeekCustom2(double fontSizeFactor, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Overall Transactions',
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w600,
              fontSize: fontSizeFactor * 4.0,
              color: AppColors.bg1),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                selectedButton2.value = 'month';
                getAutoMationsTransactionsCustomoverall(
                    getFormattedDateoverall(), context);
              },
              child: Container(
                height: 35,
                width: screenWidth * 0.15,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: selectedButton2.value == 'month'
                      ? AppColors.button
                      : AppColors.backgroundColor,
                ),
                child: Center(
                  child: Text(
                    'Month',
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.normal,
                        fontSize: fontSizeFactor * 3.4,
                        color: AppColors.accentColor),
                  ),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
            GestureDetector(
              onTap: () {
                selectedButton2.value = 'week';
                getAutoMationsTransactionsCustomoverall(
                    getCurrentWeekoverall(), context, 'week');
              },
              child: Container(
                height: 35,
                width: screenWidth * 0.15,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: selectedButton2.value == 'week'
                      ? AppColors.button
                      : AppColors.backgroundColor,
                ),
                child: Center(
                  child: Text(
                    'Week',
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.normal,
                        fontSize: fontSizeFactor * 3.4,
                        color: AppColors.accentColor),
                  ),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
            GestureDetector(
              onTap: () {
                pickCustomDateRangeoverall(context);
              },
              child: Container(
                height: 35,
                width: screenWidth * 0.15,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: selectedButton2.value == 'custom'
                      ? AppColors.button
                      : AppColors.backgroundColor,
                ),
                child: Center(
                  child: Text(
                    'Custom',
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.normal,
                        fontSize: fontSizeFactor * 3.4,
                        color: AppColors.accentColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class BarChartWidget extends StatefulWidget {
  final RxMap<String, List<double>> chartData;
  final RxList<String> days;
  final RxString selectedButton;
  final int daysInMonth;
  final bool isExpandedView;
  final bool shouldBeNavigate;

  const BarChartWidget({
    super.key,
    required this.chartData,
    required this.days,
    required this.selectedButton,
    required this.daysInMonth,
    this.isExpandedView = false,
    this.shouldBeNavigate = false,
  });

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSizeFactor = screenWidth * 0.01;
    return Obx(() => getGraphBarScroll(fontSizeFactor,
        screenWidth)); // Wrap with Obx to react to maxYValueoverall changes
  }

  Widget getGraphBarScroll(double fontSizeFactor, double screenWidth) {
    return Container(
      height: MediaQuery.of(context).size.height / 2.6,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.isExpandedView)
            Container(
              child: _buildYAxisLabels(fontSizeFactor),
            ),
          Expanded(
            child: widget.selectedButton.value != 'week'
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: getContainerOfGraph(screenWidth, fontSizeFactor),
                  )
                : getContainerOfGraph(screenWidth, fontSizeFactor),
          ),
        ],
      ),
    );
  }

  Widget getContainerOfGraph(double screenWidth, double fontSizeFactor) {
    int dataLength;
    List<String> labels;

    if (widget.selectedButton.value == 'week') {
      dataLength = 7;
      labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    } else {
      dataLength = widget.daysInMonth;
      labels = List.from(widget.days);
      while (labels.length < dataLength) {
        labels.add((labels.length + 1).toString().padLeft(2, '0'));
      }
      labels = labels.sublist(0, dataLength);
    }

    List<ChartData> debitedData = List.generate(dataLength, (index) {
      double value = 0.0;
      if (index < widget.chartData["debited"]!.length) {
        value = widget.chartData["debited"]![index];
      }
      return ChartData(labels[index], value);
    });

    double barWidth = widget.selectedButton.value == 'week' ? 50.0 : 40.0;
    double chartWidth = dataLength * barWidth;

    return Container(
      width: widget.selectedButton.value == 'week'
          ? screenWidth * 0.85
          : max(chartWidth, screenWidth * 0.85),
      height: MediaQuery.of(context).size.height / 2.6,
      child: SfCartesianChart(
        borderWidth: 0,
        plotAreaBorderWidth: 0,
        primaryXAxis: CategoryAxis(
          labelStyle: FontManager().getTextStyle(context,
              lWeight: FontWeight.bold,
              fontSize: fontSizeFactor * 3,
              color: AppColors.accentColor),
          majorGridLines: MajorGridLines(width: 0),
          minorGridLines: MinorGridLines(width: 0),
          axisLine: AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          minorTickLines: const MinorTickLines(size: 0),
          interval: 1,
          maximumLabels: dataLength,
        ),
        primaryYAxis: NumericAxis(
          isVisible: false,
          labelStyle: FontManager().getTextStyle(context,
              lWeight: FontWeight.normal,
              fontSize: fontSizeFactor * 3.3,
              color: AppColors.accentColor),
          majorGridLines: MajorGridLines(width: 0),
          minorGridLines: MinorGridLines(width: 0),
          axisLine: AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0),
          minorTickLines: const MinorTickLines(size: 0),
          labelFormat: '₹{value}',
          minimum: 0,
          maximum: maxYValueoverall.value * 1.2, // Use Rx value
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
              int seriesIndex) {
            final ChartData chartData = data as ChartData;
            return Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Spent: ₹${chartData.y.toStringAsFixed(2)}',
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.normal,
                    fontSize: fontSizeFactor * 2.5,
                    color: Colors.white),
              ),
            );
          },
        ),
        series: <ChartSeries>[
          ColumnSeries<ChartData, String>(
            dataSource: debitedData,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y,
            color: AppColors.primaryColor,
            width: 0.6,
            spacing: 0.2,
            enableTooltip: true,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20), // Cylinder effect
            ),
            name: 'Debited',
            onPointTap: (ChartPointDetails details) {},
          ),
        ],
      ),
    );
  }

  Widget _buildYAxisLabels(double fontSizeFactor) {
    final double interval = maxYValueoverall.value * 1.2 / 4; // Use Rx value
    List<Widget> labels = [];

    for (int i = 0; i <= 4; i++) {
      double value = interval * i;
      labels.add(
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              '₹${formatNumberString(value.toString())}',
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.normal,
                fontSize: fontSizeFactor * 3.3,
                color: AppColors.accentColor,
              ),
            ),
          ),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels.reversed.toList(),
    );
  }

  String formatNumberString(String value) {
    double numValue = double.tryParse(value) ?? 0;
    if (numValue >= 10000000) {
      return '${(numValue / 10000000).toStringAsFixed(0)} Cr';
    } else if (numValue >= 100000) {
      return '${(numValue / 100000).toStringAsFixed(0)} L';
    } else if (numValue >= 1000) {
      return '${(numValue / 1000).toStringAsFixed(0)} K';
    } else {
      return numValue
          .toStringAsFixed(2); // Replace doubleToFixed with direct formatting
    }
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
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
double getDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is String) return double.tryParse(value) ?? 0.0;
  if (value is num) return value.toDouble();
  return 0.0;
}

String getFormattedDateoverall() {
  final now = DateTime.now();
  return "${now.year}-${now.month.toString().padLeft(2, '0')}";
}

String getCurrentWeekoverall() {
  final now = DateTime.now();
  final year = now.year;
  String s = '$year-W${now.weekOfYear.toString().padLeft(2, '0')}';
  return s;
}

void pickCustomDateRangeoverall(BuildContext context) async {
  List<DateTime?> picked = await showCalendarDatePicker2Dialog(
        context: context,
        config: CalendarDatePicker2WithActionButtonsConfig(
          calendarType: CalendarDatePicker2Type.range,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          selectableDayPredicate: (day) => true,
          selectedDayHighlightColor: AppColors.primaryColor,
          controlsTextStyle: TextStyle(color: Colors.black),
          dayTextStyle: TextStyle(color: Colors.black),
          selectedDayTextStyle: TextStyle(color: Colors.black),
          weekdayLabelTextStyle: TextStyle(color: Colors.black),
        ),
        dialogSize: const Size(400, 300),
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

List<String> getWeekDays() {
  return ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
}

String getNextDay(String date) {
  DateTime parsedDate = DateTime.parse(date);
  DateTime nextDay = parsedDate.add(Duration(days: 1));
  return "${nextDay.year}-${nextDay.month.toString().padLeft(2, '0')}-${nextDay.day.toString().padLeft(2, '0')}";
}
