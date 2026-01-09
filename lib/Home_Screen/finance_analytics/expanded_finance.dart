// import 'dart:core';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/finance_analytics/finance_chart.dart';
// import 'package:flutter_application_code_stakeplot/components/helper.dart';
// import 'package:flutter_application_code_stakeplot/repository/expanded_finance_repository.dart';
// import 'package:flutter_application_code_stakeplot/repository/finance_repository.dart';
// import 'package:flutter_application_code_stakeplot/repository/home_page_apiCalls.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';
// import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
// import 'package:flutter_application_code_stakeplot/repository/transactions_repository.dart';
// import 'package:intl/intl.dart';
// import 'package:get/get.dart';

// import '../../components/shared_utils.dart';
// import 'fin_chart.dart';

// class ExpandedChartView extends StatefulWidget {
//   final Map<String, List<double>> chartData;
//   final List days;
//   final String selectedButton;
//   final int selectedYear;
//   final int selectedMonth;

//   const ExpandedChartView({
//     Key? key,
//     required this.chartData,
//     required this.days,
//     required this.selectedButton,
//     required this.selectedYear,
//     required this.selectedMonth,
//   }) : super(key: key);

//   @override
//   State<ExpandedChartView> createState() => _ExpandedChartViewState();
// }

// class _ExpandedChartViewState extends State<ExpandedChartView> {
//   final ScrollController scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     currentPage = 1;
//     hasMoreData = true;
//     currentDays.value = List.from(widget.days);
//     getAllTransactionHistory(context, true, isYearView.value,
//         isRefreshing: true);
//     updateMonthLabels();
//     filterDataForSelectedMonth();
//     scrollController.addListener(_onScroll);
//   }

//   void callBackApi() {
//     currentPage = 1;
//     isLoadingMore.value = false;
//     String currentMonth = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     getWeeklyGraphAndCustomDateGraph(currentMonth, context, weekORmonth: 'month',isSplashScreen: true);
//     getAllTransactionHistory(context, false, false, isRefreshing: true);
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     double fontSizeFactor = screenWidth * 0.01;

//     return WillPopScope(
//       onWillPop: () async {
//         callBackApi();
//         return true;
//       },
//       child: Scaffold(
//           backgroundColor: AppColors.backgroundColor,
//           appBar: appbarWidget(),
//           body: SingleChildScrollView(
//             controller: scrollController,
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: _buildMonthYearSelector(fontSizeFactor, screenWidth),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Obx(() => isLoading.value
//                       ? Center(
//                           child: Spinner(
//                           size: 30,
//                         ))
//                       : getLineGraph(screenHeight, screenWidth)),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 transactionsHistoryList(),
//               ],
//             ),
//           )),
//     );
//   }

//   Widget getLineGraph(screenHeight, screenWidth) {
//     return Container(
//       height: screenHeight / 2.6,
//       width: screenWidth / 1.1,
//       child: LineChartWidget(
//         chartData: currentChartData.value,
//         days: isYearView.value ? monthLabels : currentDays,
//         selectedButton: selectedButton,
//         daysInMonth: isYearView.value
//             ? 12
//             : getDaysInMonthExpanded(selectedYear.value, selectedMonth.value),
//         isExpandedView: true,
//       ),
//     );
//   }

//   Widget _buildMonthYearSelector(double fontSizeFactor, double screenWidth) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           HomepageStringsDart().spendingAndCashFlow,
//           style: FontManager().getTextStyle(context,
//               lWeight: FontWeight.w500,
//               fontSize: fontSizeFactor * 4.5,
//               color: AppColors.accentColor),
//         ),
//         SizedBox(height: 10),
//         Row(
//           children: [
//             Obx(() => Text(
//                   '₹${formatMoneyIndian(doubleToFixed(totalExpandedValue.toString()))}',
//                   style: FontManager().getTextStyle(context,
//                       lWeight: FontWeight.bold,
//                       fontSize: fontSizeFactor * 4,
//                       color: AppColors.accentColor),
//                 )),
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               HomepageStringsDart().bankSpendings,
//               style: FontManager().getTextStyle(context,
//                   lWeight: FontWeight.normal,
//                   fontSize: fontSizeFactor * 3.4,
//                   color: AppColors.bg1),
//             ),
//             Row(
//               children: [
//                 GestureDetector(
//                   onTap: () =>
//                       showMonthPicker(context, fontSizeFactor, screenWidth),
//                   child: Container(
//                     height: 35,
//                     width: screenWidth * 0.2,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                       color: AppColors.button,
//                     ),
//                     child: Center(
//                       child: Obx(() => Text(
//                             DateFormat('MMMM').format(DateTime(
//                                 selectedYear.value, selectedMonth.value, 1)),
//                             style: FontManager().getTextStyle(context,
//                                 lWeight: FontWeight.normal,
//                                 fontSize: fontSizeFactor * 3.4,
//                                 color: !isYearView.value
//                                     ? AppColors
//                                         .primaryColor // Contrast text color for highlight
//                                     : AppColors.accentColor),
//                           )),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: screenWidth * 0.02),
//                 GestureDetector(
//                   onTap: () =>
//                       showYearPicker(context, fontSizeFactor, screenWidth),
//                   child: Container(
//                     height: 35,
//                     width: screenWidth * 0.2,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                       color: AppColors.button,
//                     ),
//                     child: Center(
//                       child: Obx(() => Text(
//                             selectedYear.value.toString(),
//                             style: FontManager().getTextStyle(context,
//                                 lWeight: FontWeight.normal,
//                                 fontSize: fontSizeFactor * 3.4,
//                                 color: isYearView.value
//                                     ? AppColors
//                                         .primaryColor // Contrast text color for highlight
//                                     : AppColors.accentColor),
//                           )),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   AppBar appbarWidget() {
//     return AppBar(
//       leading: InkWell(
//         onTap: () {
//           Navigator.pop(context);

//           callBackApi();
//         },
//         child: Icon(
//           Icons.arrow_back,
//           color: AppColors.accentColor,
//         ),
//       ),
//       title: Text(HomepageStringsDart().detailedChartView),
//       backgroundColor: AppColors.backgroundColor,
//     );
//   }

//   void _onScroll() {
//     scrollController.addListener(() async {
//       if (scrollController.position.pixels >=
//           scrollController.position.maxScrollExtent - 50) {
//         getAllTransactionHistory(context, true, isYearView.value);
//       }
//     });
//   }

//   Widget transactionsHistoryList() {
//     return Obx(() => loadChatdataOnChnage.value
//         ? TransactionHistory(
//             isYearView: isYearView.value,
//             isflag: true,
//             showIcon: true,
//             expandedPage: true,
//           )
//         : TransactionHistory(
//             isYearView: isYearView.value,
//             isflag: true,
//             showIcon: true,
//             expandedPage: true,
//           ));
//   }
// }
// ExpandedChartView (final ready-to-paste)
// - toggle dummy vs real API with `useDummyData`
// - dynamic month/year selector
// - rounded stacked bars + straight connecting line (slightly below tips)
// - selection stable and deterministic
// - preserves transaction history and globals

// ExpandedChartView — chart-only month/year selector + no Y labels
// Paste this whole file over your current ExpandedChartView implementation.
// ExpandedChartView — final (Option A)
// Paste/replace your current ExpandedChartView implementation with this file.


// ExpandedChartView — final (all-selected initial state)
// Option A: month pills change both chart AND transactions
// Toggle dummy vs real API with `useDummyData` (constructor)


import 'dart:core';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:get/get.dart';

import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
import '../../backed_connections/apis_connect.dart';
import '../../components/helper.dart';
import '../../components/shared_utils.dart';
import '../../repository/expanded_finance_repository.dart';
import '../../repository/finance_repository.dart';
import '../../repository/transactions_repository.dart';

class ExpandedChartView extends StatefulWidget {
  final Map<String, List<double>> chartData;
  final List days;
  final String selectedButton;
  final int selectedYear;
  final int selectedMonth;

  /// Set this to true to use deterministic dummy data for the chart.
  /// Set to false to call fetchMonthlyData(...) (real API).
  final bool useDummyData;

  const ExpandedChartView({
    Key? key,
    required this.chartData,
    required this.days,
    required this.selectedButton,
    required this.selectedYear,
    required this.selectedMonth,
    this.useDummyData = true,
  }) : super(key: key);

  @override
  State<ExpandedChartView> createState() => _ExpandedChartViewState();
}

class _ExpandedChartViewState extends State<ExpandedChartView> {
  final ScrollController outerScrollController = ScrollController();

  // Local chart arrays (labels & values)
  late List<String> _days; // e.g. '01','02', 'May 12', etc.
  late List<double> _credited;
  late List<double> _debited;

  bool _loadingChart = true;

  // Selection state:
  // -1 => ALL selected (initial state, header empty)
  // >=0 => single selected day index (show header amounts; others greyed)
  int _selectedDayIndex = -1;

  // UI tuning
  final double pillHeight = 36.0;
  final double labelWidth = 44.0; // width reserved per day in chart
  final double chartAreaHeightFactor = 2.6;

  @override
  void initState() {
    super.initState();

    // Ensure globals have sane defaults
    try {
      if (selectedMonth.value == 0) selectedMonth.value = widget.selectedMonth;
      if (selectedYear.value == 0) selectedYear.value = widget.selectedYear;
    } catch (_) {}

    // Load initial month (use API when useDummyData==false)
    _applyMonth(selectedYear.value, selectedMonth.value, useApi: !widget.useDummyData, initial: true);

    // Transaction history lifecycle (preserve original behavior)
    currentPage = 1;
    hasMoreData = true;
    getAllTransactionHistory(context, true, isYearView.value, isRefreshing: true);
    updateMonthLabels();
    filterDataForSelectedMonth();

    outerScrollController.addListener(_onOuterScroll);
  }

  @override
  void dispose() {
    outerScrollController.removeListener(_onOuterScroll);
    outerScrollController.dispose();
    super.dispose();
  }

  /// Loads chart data for the given year/month.
  /// If useApi==true, it will call fetchMonthlyData(year, month) (your API).
  /// Otherwise it will generate deterministic dummy data.
  Future<void> _applyMonth(int year, int month, {bool useApi = false, bool initial = false}) async {
    setState(() {
      _loadingChart = true;
    });

    if (useApi) {
      try {
        await fetchMonthlyData(year, month); // populates currentChartData & currentDays (your existing flow)

        final List? gCred = currentChartData.value['credited'] as List?;
        final List? gDeb = currentChartData.value['debited'] as List?;
        final List<String> gLabels = currentDays.map((e) => e.toString()).toList();

        final bool hasApiData = (gCred != null && gCred.isNotEmpty) || (gDeb != null && gDeb.isNotEmpty);
        if (hasApiData && gLabels.isNotEmpty) {
          final int daysInMonth = DateTime(year, month + 1, 0).day;
          _days = List.generate(daysInMonth, (i) => (i + 1).toString().padLeft(2, '0'));
          _credited = List.generate(daysInMonth, (i) => (gCred != null && i < gCred.length) ? (gCred[i] ?? 0.0).toDouble() : 0.0);
          _debited = List.generate(daysInMonth, (i) => (gDeb != null && i < gDeb.length) ? (gDeb[i] ?? 0.0).toDouble() : 0.0);

          // if API provided custom labels for every day, use them
          if (gLabels.length == daysInMonth) _days = gLabels;

          // Reset selection to "all selected" on month load
          _selectedDayIndex = -1;

          setState(() {
            _loadingChart = false;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
          return;
        }
      } catch (e) {
        // fallback to dummy if API fails
      }
    }

    // Dummy fallback (deterministic per month-year)
    _generateDummyMonthData(year, month);

    // Reset selection to "all selected" on month load
    _selectedDayIndex = -1;

    setState(() {
      _loadingChart = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
  }

  void _generateDummyMonthData(int year, int month) {
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    _days = List.generate(daysInMonth, (i) => (i + 1).toString().padLeft(2, '0'));

    final rnd = Random(year * 100 + month);
    _credited = List.generate(daysInMonth, (i) {
      final base = 1800 + (i % 5) * 300;
      final noise = rnd.nextInt(1500);
      return (base + noise).toDouble();
    });
    _debited = List.generate(daysInMonth, (i) {
      final base = 650 + (i % 4) * 140;
      final noise = rnd.nextInt(900);
      return (base + noise).toDouble();
    });
  }

  void _scrollToEnd() {
    // Chart horizontal scroll is automatic because we set chart width to content width.
    // Keep this hook in case you add controllers later.
  }

  void _onOuterScroll() {
    if (outerScrollController.hasClients &&
        outerScrollController.position.pixels >= outerScrollController.position.maxScrollExtent - 50) {
      getAllTransactionHistory(context, true, isYearView.value);
    }
  }

  /// Month-pill tap: update global selectedMonth/year AND update chart & transactions (Option A)
  Future<void> _onMonthPillTap(int month) async {
    // Update global selection (this will be used by transaction history)
    selectedMonth.value = month;
    isYearView.value = false;

    // Reset pagination for transactions
    transactionsHistory.clear();
    currentPage = 1;
    isLoadingMore.value = false;

    // Fetch transactions for selected month
    getAllTransactionHistory(context, true, false);

    // Fetch chart data (API or dummy depending on constructor flag)
    await _applyMonth(selectedYear.value, selectedMonth.value, useApi: !widget.useDummyData);

    setState(() {});
  }

  /// Year picker: update global selectedYear AND fetch both transactions + chart (Option A)
  void _showYearPickerAndApply(BuildContext context, double fontSizeFactor, double screenWidth) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        final currentYear = DateTime.now().year;
        final yearsCount = currentYear - 2020 + 1;
        return Container(
          height: 300.0,
          padding: EdgeInsets.all(8.0),
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            childAspectRatio: 2.5,
            children: List.generate(yearsCount, (index) {
              final year = currentYear - index;
              return GestureDetector(
                onTap: () async {
                  selectedYear.value = year;
                  isYearView.value = false;
                  Navigator.pop(ctx);

                  // Reset transactions & fetch for new year/month
                  transactionsHistory.clear();
                  currentPage = 1;
                  isLoadingMore.value = false;
                  getAllTransactionHistory(context, true, false);

                  // Fetch chart for new year/month
                  await _applyMonth(selectedYear.value, selectedMonth.value, useApi: !widget.useDummyData);
                  setState(() {});
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.button,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      year.toString(),
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.normal, fontSize: 14, color: AppColors.accentColor),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  String _monthYearTitle() {
    try {
      return DateFormat('MMMM yyyy').format(DateTime(selectedYear.value, selectedMonth.value, 1));
    } catch (_) {
      return DateFormat('MMMM yyyy').format(DateTime(widget.selectedYear, widget.selectedMonth, 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double fontSizeFactor = screenWidth * 0.01;

    return WillPopScope(
      onWillPop: () async {
        callBackApi();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: appbarWidget(),
        body: SingleChildScrollView(
          controller: outerScrollController,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal:4.0, vertical: 8.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Row: months (chart+transaction selector) + year pill
              
              // Title and selected day amounts
              Center(
                child: Column(children: [
                  const SizedBox(height: 10),
                  Text(
                    _monthYearTitle(),
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w700, fontSize:24, color: AppColors.accentColor),
                  ),
                  const SizedBox(height: 6),
                  // Show header amounts only when a single day is selected (>=0)
                // Put this where you want the UI to show
if (_selectedDayIndex >= 0 &&
    _days != null &&
    _days.isNotEmpty &&
    _selectedDayIndex < _days.length &&
    _credited != null &&
    _debited != null &&
    _selectedDayIndex < _credited.length &&
    _selectedDayIndex < _debited.length)
  Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Credited container
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor, // light bg
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryColor
          ),
        ),
        child: Text(
          'Credit  :  ₹${formatNumber(_credited[_selectedDayIndex])}',
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.primaryColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      const SizedBox(width: 8),

      // Debited container
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor, // light bg
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primaryColor
          ),
        ),
        child: Text(
          'Debit  :  ₹${formatNumber(_debited[_selectedDayIndex])}',
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.primaryColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  )
else
  // empty placeholder (keeps spacing consistent)
  SizedBox(height: fontSizeFactor * 3),

                ]),
              ),

              const SizedBox(height: 16),

              // Chart card (no Y labels)
              Container(
                height: MediaQuery.sizeOf(context).height/3.8,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: AppColors.backgroundColor, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.financeChartBorder, width: 1)),
                padding: const EdgeInsets.all(14),
                child: _loadingChart
                    ? SizedBox(height: screenHeight / chartAreaHeightFactor, child: Center(child: Spinner(size: 30)))
                    : _buildExpandedChartNoYLabels(screenWidth, screenHeight),
              ),

              const SizedBox(height: 12),

              // Transaction history (unchanged; will reflect new selectedMonth/selectedYear)
              transactionsHistoryList(),
            ]),
          ),
        ),
      ),
    );
  }

  // Chart build WITHOUT Y axis labels
  Widget _buildExpandedChartNoYLabels(double screenWidth, double screenHeight) {
    final int dataLength = _days.length;
    final double chartHeight = screenHeight / chartAreaHeightFactor;
    final double chartWidth = max(screenWidth * 0.95, dataLength * labelWidth);

    final List<_ExpChartData> data = List.generate(dataLength, (i) {
      final credit = (i < _credited.length) ? _credited[i] : 0.0;
      final debit = (i < _debited.length) ? _debited[i] : 0.0;
      final String label = _days[i];
      return _ExpChartData(label, credit, debit);
    });

    final totals = data.map((e) => e.credit + e.debit).toList();
    final double maxTotal = totals.isEmpty ? 1.0 : totals.reduce(max);
    final double yMax = (maxTotal * 1.05).ceilToDouble();

    final double lineOffsetFactor = 0.92; // line slightly below bar tops

    // Colors
    final Color creditColor = AppColors.primaryColor;
    final Color debitColor = AppColors.debitedAmount;
    final Color greyColor = const Color(0xFFB7B8C7);

    return SizedBox(
      height: chartHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: chartWidth,
          height: chartHeight,
          child:
           SfCartesianChart(
            plotAreaBorderWidth: 0,
            
            margin: EdgeInsets.zero,
            primaryXAxis: CategoryAxis(
              labelStyle: FontManager().getTextStyle(context, lWeight: FontWeight.w400, fontSize: 12, color: AppColors.debitedAmount),
              majorGridLines: const MajorGridLines(width: 0),
              minorGridLines: const MinorGridLines(width: 0),
              axisLine: const AxisLine(width: 0),
              majorTickLines: const MajorTickLines(size: 0),
              minorTickLines: const MinorTickLines(size: 0),
              interval: 1,
              maximumLabels: dataLength,
            ),
            primaryYAxis: NumericAxis(minimum: 0, maximum: yMax, isVisible: false),

            selectionGesture: ActivationMode.singleTap,
            selectionType: SelectionType.point,
            onSelectionChanged: (SelectionArgs args) {
              final int idx = (args.pointIndex ?? -1);
              if (idx >= 0 && idx < data.length) {
                setState(() {
                  _selectedDayIndex = idx;
                });
              }
            },

            tooltipBehavior: TooltipBehavior(enable: false),

           series: <ChartSeries>[
  // Debited (bottom) - color via selected state:
  StackedColumnSeries<_ExpChartData, String>(
    dataSource: data,
    xValueMapper: (d, _) => d.label,
    yValueMapper: (d, _) => d.debit,
    spacing: 0.12,
    width: 0.85,
    pointColorMapper: (d, index) {
      // initial "all selected" state (-1) -> both highlighted
      if (_selectedDayIndex == -1) return debitColor;
      // when a single index is selected -> highlight that index, grey others
      return (index == _selectedDayIndex) ? debitColor : greyColor;
    },
    selectionBehavior: SelectionBehavior(enable: true, toggleSelection: false),
    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(6), bottomRight: Radius.circular(6)),
  ),

  // Credited (top)
  StackedColumnSeries<_ExpChartData, String>(
    dataSource: data,
    xValueMapper: (d, _) => d.label,
    yValueMapper: (d, _) => d.credit,
    spacing: 0.12,
    width: 0.85,
    pointColorMapper: (d, index) {
      if (_selectedDayIndex == -1) return creditColor;
      return (index == _selectedDayIndex) ? creditColor : greyColor;
    },
    selectionBehavior: SelectionBehavior(enable: true, toggleSelection: false),
    borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
  ),

  // Line series unchanged...
  LineSeries<_ExpChartData, String>(
    dataSource: data,
    xValueMapper: (d, _) => d.label,
    yValueMapper: (d, _) => (d.credit + d.debit) * lineOffsetFactor,
    width: 2.0,
    color: AppColors.strokeColor.withOpacity(0.9),
    markerSettings: MarkerSettings(
      isVisible: true,
      color: Colors.white,
      borderColor: AppColors.strokeColor,
      borderWidth: 2,
      height: 8,
      width: 8,
      shape: DataMarkerType.circle,
    ),
    enableTooltip: false,
  ),
],

          ),
       
        ),
      ),
    );
  }
AppBar appbarWidget() {
  return AppBar(
    backgroundColor: AppColors.newbg,
    centerTitle: true,

    leading: InkWell(
      onTap: () {
        Navigator.pop(context);
        callBackApi();
      },
      child: Icon(Icons.arrow_back, color: AppColors.accentColor),
    ),

    title: Text(
      HomepageStringsDart().detailedChartView,
      style: FontManager().getTextStyle(
        context,
        color: AppColors.accentColor,
        fontSize: 20,
        lWeight: FontWeight.w500,
      ),
    ),

    // 🔽 Add your custom row inside bottom of AppBar
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(60), // Increase height
      child: Column(
        children: [
        
          Row(
            children: [
              
              Container(
                width: MediaQuery.sizeOf(context).width * 0.72,
                child: SizedBox(
                  height: pillHeight,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 12,
                    itemBuilder: (ctx, idx) {
                      final int month = idx + 1;
                      final bool isSelected = month == selectedMonth.value;

                      return Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: GestureDetector(
                          onTap: () => _onMonthPillTap(month),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            height: pillHeight,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Color.fromRGBO(75, 77, 115, 0.08),
                              borderRadius: BorderRadius.circular(8),
                             
                            ),
                            child: Center(
                              child: Row(
                                children: [
                                  Text(
                                    DateFormat('MMMM')
                                        .format(DateTime(selectedYear.value, month, 1)),
                                    style: FontManager().getTextStyle(
                                      context,
                                      lWeight: FontWeight.w500,
                                      fontSize: 13,
                                      color: isSelected
                                          ? AppColors.backgroundColor
                                          : AppColors.primaryColor,
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 6),
                                    Icon(Icons.check_circle,
                                        size: 16, color: AppColors.backgroundColor),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // ---------------- YEAR PICKER BUTTON ----------------
              GestureDetector(
                onTap: () =>
                    _showYearPickerAndApply(context, 14, 400),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  height: pillHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.button,
                  ),
                  child: Row(
                    children: [
                      Obx(
                        () => Text(
                          selectedYear.value.toString(),
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.normal,
                            fontSize: 14,
                            color: AppColors.accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.keyboard_arrow_down,
                          size: 18, color: AppColors.accentColor),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}


  // Keep transaction history unchanged
  Widget transactionsHistoryList() {
    return Obx(() => loadChatdataOnChnage.value
        ? TransactionHistory(isYearView: isYearView.value, isflag: true, showIcon: true, expandedPage: true)
        : TransactionHistory(isYearView: isYearView.value, isflag: true, showIcon: true, expandedPage: true));
  }



  // Preserve original callback behavior
  void callBackApi() {
    currentPage = 1;
    isLoadingMore.value = false;
    String currentMonth = DateFormat('yyyy-MM-dd').format(DateTime.now());
    getWeeklyGraphAndCustomDateGraph(currentMonth, context, weekORmonth: 'month', isSplashScreen: true);
    getAllTransactionHistory(context, false, false, isRefreshing: true);
  }
}

class _ExpChartData {
  _ExpChartData(this.label, this.credit, this.debit);
  final String label;
  final double credit;
  final double debit;
}
