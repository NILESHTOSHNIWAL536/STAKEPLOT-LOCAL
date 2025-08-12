import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/finance_data/finance_model.dart';
import 'dart:math';
import 'package:flutter_application_code_stakeplot/Home_Screen/expanded_finance.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history_button.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
// Other imports (e.g., AppColors, FontManager, HomepageStringsDart, LineChartWidget, etc.)
// class FinancePage extends StatefulWidget {
//   const FinancePage({
//     super.key,
//   });

//   @override
//   State<FinancePage> createState() => _FinancePageState();
// }

// class _FinancePageState extends State<FinancePage> {
//   @override
//   void initState() {
//     super.initState();
//     selectedButton.value = 'Month';
//     calledFunctionToFetchData(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     double fontSizeFactor = screenWidth * 0.01;

//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       body: Padding(
//         padding: EdgeInsets.all(0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   HomepageStringsDart().spendingAndCashFlow,
//                   style: FontManager().getTextStyle(context,
//                       lWeight: FontWeight.w300,
//                       fontSize: fontSizeFactor * 4.0,
//                       color: AppColors.accentColor),
//                 ),
//                 historyButton(fontSizeFactor, context),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Obx(() => Text(
//                           getGraphData.value
//                               ? '₹${formatMoneyIndian(doubleToFixed(totalDebitValue.toString()))}'
//                               : '₹${formatMoneyIndian(doubleToFixed(totalDebitValue.toString()))}',
//                           style: FontManager().getTextStyle(context,
//                               lWeight: FontWeight.bold,
//                               fontSize: fontSizeFactor * 4,
//                               color: AppColors.accentColor),
//                         )),
//                     SizedBox(width: screenWidth * 0.02),
//                     Obx(() {
//                       String displayText = '';
//                       if (selectedButton.value == 'Week') {
//                         displayText =
//                             HomepageStringsDart().lastWeek; //'This week';
//                       } else if (selectedButton.value == 'Month') {
//                         displayText = HomepageStringsDart().thisMonth;
//                       }
//                       return Text(
//                         displayText,
//                         style: FontManager().getTextStyle(context,
//                             lWeight: FontWeight.normal,
//                             fontSize: fontSizeFactor * 2.5,
//                             color: AppColors.accentColor),
//                       );
//                     }),
//                     SizedBox(width: screenWidth * 0.02),
//                     Obx(() {
//                       if (selectedButton.value == 'Custom') {
//                         return SizedBox
//                             .shrink(); // Do not show anything for Custom
//                       }
//                       // Determine the arrow icon and color based on the value
//                       final isPositive = totalDebitValuePercent >= 0;
//                       final arrowIcon = isPositive
//                           ? Icons.arrow_upward
//                           : Icons.arrow_downward;
//                       final arrowColor = isPositive ? Colors.red : Colors.green;
//                       final formattedValue = totalDebitValuePercent
//                           .toStringAsFixed(1); // Round to one decimal place
//                       final textColor = isPositive
//                           ? Colors.red
//                           : Colors.green; // Change text color based on value

//                       return Row(
//                         children: [
//                           Text(
//                             '$formattedValue%',
//                             style: FontManager().getTextStyle(context,
//                                 lWeight: FontWeight.normal,
//                                 fontSize: fontSizeFactor * 2.5,
//                                 color:
//                                     textColor), // Set text color based on value
//                           ),
//                           SizedBox(width: screenWidth * 0.01),
//                           Icon(
//                             arrowIcon,
//                             color: arrowColor,
//                             size: fontSizeFactor * 2.5, // Adjust size as needed
//                           ),
//                         ],
//                       );
//                     }),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: screenHeight * 0.01),
//             Obx(() => getGraphData.value
//                 ? getMonthWeekCustom(fontSizeFactor, screenWidth)
//                 : getMonthWeekCustom(fontSizeFactor, screenWidth)),
//             Obx(() => !getGraphData.value
//                 ? Container(
//                     width: MediaQuery.of(context).size.width,
//                     height: MediaQuery.of(context).size.height / 2.6,
//                     child: consentAndHandleDetails.isEmpty
//                         ? Center(
//                             child: textStyleImage(
//                                 context: context,
//                                 text:
//                                     HomepageStringsDart().noSpendingsAvailable,
//                                 fontsize: fontSizeFactor * 4.0,
//                                 c: AppColors.accentColor))
//                         : Center(
//                             child: Spinner(
//                               size: 60,
//                             ),
//                           ),
//                   )
//                 : LineChartWidget(
//                     chartData: transactionChatGraph,
//                     days: labels,
//                     selectedButton: selectedButton,
//                     shouldBeNavigate: true,
//                     daysInMonth: selectedButton == "Week"
//                         ? 7
//                         : selectedButton == "Month"
//                             ? getDaysInCurrentMonth()
//                             : labels.length,
//                   )),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget getMonthWeekCustom(fontSizeFactor, screenWidth) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           HomepageStringsDart().bankSpendings,
//           style: FontManager().getTextStyle(context,
//               lWeight: FontWeight.normal,
//               fontSize: fontSizeFactor * 3.4,
//               color: AppColors.bg1),
//         ),
//         Row(
//           children: [
//             GestureDetector(
//               onTap: () {
//                 // getGraphData.value = false;
//                 selectedButton.value = 'Month';
//                 getAutoMationsTransactionsCustom(getFormattedDate(), context);
//               },
//               child: Container(
//                 height: 35,
//                 width: screenWidth * 0.15,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(16),
//                   color: selectedButton.value == 'Month'
//                       ? AppColors.button
//                       : AppColors.backgroundColor,
//                 ),
//                 child: Center(
//                   child: Text(
//                     HomepageStringsDart().month,
//                     style: FontManager().getTextStyle(context,
//                         lWeight: FontWeight.normal,
//                         fontSize: fontSizeFactor * 3.4,
//                         color: AppColors.accentColor),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(width: screenWidth * 0.02),
//             GestureDetector(
//               onTap: () {
//                 pickCustomDateRange(context);
//               },
//               child: Container(
//                 height: 35,
//                 width: screenWidth * 0.15,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(16),
//                   color: selectedButton.value == 'Custom'
//                       ? AppColors.button
//                       : AppColors.backgroundColor,
//                 ),
//                 child: Center(
//                   child: Text(
//                     HomepageStringsDart().custom,
//                     style: FontManager().getTextStyle(context,
//                         lWeight: FontWeight.normal,
//                         fontSize: fontSizeFactor * 3.4,
//                         color: AppColors.accentColor),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  @override
  void initState() {
    super.initState();
    selectedButton.value = 'Month';
    _fetchData();
  }

    Future<void> _fetchData() async {
    try {
      // Ensure financeBox is open
      if (accountId.value.isEmpty) {
        accountId.value = userController.selectedBank.value;
        if (accountId.value.isEmpty) {
          print('No account ID available, setting empty state');
          // _setEmptyState('Month', getFormattedDate(), null);
          return;
        }
      }
       getAutoMationsTransactionsCustom( getFormattedDate(), context,'Month');
    } catch (e) {
      print('Error fetching data: $e');
      // _setEmptyState('Month', getFormattedDate(), null);
    }
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  HomepageStringsDart().spendingAndCashFlow,
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w300,
                      fontSize: fontSizeFactor * 4.0,
                      color: AppColors.accentColor),
                ),
                historyButton(fontSizeFactor, context),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Obx(() => Text(
                          '₹${formatMoneyIndian(doubleToFixed(totalDebitValue.toString()))}',
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.bold,
                              fontSize: fontSizeFactor * 4,
                              color: AppColors.accentColor),
                        )),
                    SizedBox(width: screenWidth * 0.02),
                    Obx(() {
                      String displayText = '';
                      if (selectedButton.value == 'Week') {
                        displayText = HomepageStringsDart().lastWeek;
                      } else if (selectedButton.value == 'Month') {
                        displayText = HomepageStringsDart().thisMonth;
                      }
                      return Text(
                        displayText,
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.normal,
                            fontSize: fontSizeFactor * 2.5,
                            color: AppColors.accentColor),
                      );
                    }),
                    SizedBox(width: screenWidth * 0.02),
                    Obx(() {
                      if (selectedButton.value == 'Custom') {
                        return SizedBox.shrink();
                      }
                      final isPositive = totalDebitValuePercent >= 0;
                      final arrowIcon = isPositive
                          ? Icons.arrow_upward
                          : Icons.arrow_downward;
                      final arrowColor = isPositive ? Colors.red : Colors.green;
                      final formattedValue =
                          totalDebitValuePercent.toStringAsFixed(1);
                      final textColor = isPositive ? Colors.red : Colors.green;

                      return Row(
                        children: [
                          Text(
                            '$formattedValue%',
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.normal,
                                fontSize: fontSizeFactor * 2.5,
                                color: textColor),
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Icon(
                            arrowIcon,
                            color: arrowColor,
                            size: fontSizeFactor * 2.5,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            Obx(() => getMonthWeekCustom(fontSizeFactor, screenWidth)),
            Obx(() => !getGraphData.value
                ? Container(
                    width: screenWidth,
                    height: screenHeight / 2.6,
                    child: Center(
                      child: Spinner(size: 60),
                    ),
                  )
                : transactionChatGraph['debited']?.isEmpty == true &&
                        transactionChatGraph['credited']?.isEmpty == true
                    ? Container(
                        width: screenWidth,
                        height: screenHeight / 2.6,
                        child: Center(
                          child: textStyleImage(
                            context: context,
                            text: HomepageStringsDart().noSpendingsAvailable,
                            fontsize: fontSizeFactor * 4.0,
                            c: AppColors.accentColor,
                          ),
                        ),
                      )
                    : LineChartWidget(
                        chartData: transactionChatGraph,
                        days: labels,
                        selectedButton: selectedButton,
                        shouldBeNavigate: true,
                        daysInMonth: selectedButton == "Week"
                            ? 7
                            : selectedButton == "Month"
                                ? getDaysInCurrentMonth()
                                : labels.length,
                      )),
          ],
        ),
      ),
    );
  }

  Widget getMonthWeekCustom(double fontSizeFactor, double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          HomepageStringsDart().bankSpendings,
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.normal,
              fontSize: fontSizeFactor * 3.4,
              color: AppColors.bg1),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                selectedButton.value = 'Month';
                getAutoMationsTransactionsCustom(getFormattedDate(), context);
              },
              child: Container(
                height: 35,
                width: screenWidth * 0.15,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: selectedButton.value == 'Month'
                      ? AppColors.button
                      : AppColors.backgroundColor,
                ),
                child: Center(
                  child: Text(
                    HomepageStringsDart().month,
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
                pickCustomDateRange(context);
              },
              child: Container(
                height: 35,
                width: screenWidth * 0.15,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: selectedButton.value == 'Custom'
                      ? AppColors.button
                      : AppColors.backgroundColor,
                ),
                child: Center(
                  child: Text(
                    HomepageStringsDart().custom,
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

class LineChartWidget extends StatefulWidget {
  final Map<String, List<double>> chartData;
  final List days;
  final RxString selectedButton;
  final int daysInMonth;
  final bool isExpandedView;
  final bool shouldBeNavigate;

  const LineChartWidget({
    super.key,
    required this.chartData,
    required this.days,
    required this.selectedButton,
    required this.daysInMonth,
    this.isExpandedView = false,
    this.shouldBeNavigate = false,
  });

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  double maxYValue = 10000;
  ScrollController? _scrollController;
  ValueNotifier<bool> isTooltipVisible = ValueNotifier<bool>(false);
  ValueNotifier<Map<String, dynamic>> tooltipData =
      ValueNotifier<Map<String, dynamic>>({});

  int getCurrentDateIndex(List<String> labels) {
    final now = DateTime.now();
    if (widget.selectedButton.value == 'Week') {
      return now.weekday % 7;
    } else {
      return now.day - 1;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _calculateMaxYValue();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController != null) {
        _scrollToCurrentDate();
      }
    });
  }

  @override
  void didUpdateWidget(LineChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chartData != widget.chartData) {
      _calculateMaxYValue();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController != null) {
          _scrollToCurrentDate();
        }
      });
    }
  }

  void _calculateMaxYValue() {
    if (widget.chartData["credited"]?.isNotEmpty == true ||
        widget.chartData["debited"]?.isNotEmpty == true) {
      maxYValue = [
        widget.chartData["credited"] ?? [],
        widget.chartData["debited"] ?? []
      ]
          .expand((x) => x)
          .reduce((value, element) => value > element ? value : element);
    }
    if (!maxYValue.isFinite || maxYValue == 0) {
      maxYValue = 1000.0;
    }
  }

  // void _scrollToCurrentDate() {
  //   if (_scrollController?.hasClients == true) {
  //     int currentIndex = getCurrentDateIndex(widget.days.cast<String>());
  //     double labelWidth = widget.selectedButton.value == 'Week' ? 50.0 : 60.0;
  //     double scrollOffset = (currentIndex - 4) * labelWidth;

  //     double maxScrollExtent = 0;
  //     if (_scrollController != null && _scrollController!.hasClients) {
  //       maxScrollExtent = _scrollController!.position.maxScrollExtent;
  //     }

  //     if (scrollOffset > maxScrollExtent) {
  //       scrollOffset = maxScrollExtent;
  //     } else if (scrollOffset < 0) {
  //       scrollOffset = 0;
  //     }

  //     _scrollController!.jumpTo(scrollOffset);
  //   }
  // }
  void _scrollToCurrentDate() {
    if (_scrollController?.hasClients == true) {
      // Find the last index with data
      int lastIndex = widget.chartData["credited"]!.length - 1;
      while (lastIndex >= 0 &&
          (widget.chartData["credited"]![lastIndex] == 0 &&
              widget.chartData["debited"]![lastIndex] == 0)) {
        lastIndex--;
      }

      // If there's no data, do not scroll
      if (lastIndex < 0) return;

      double labelWidth = widget.selectedButton.value == 'Week' ? 40.0 : 50.0;
      double scrollOffset = (lastIndex - 4) * labelWidth;

      double maxScrollExtent = 0;
      if (_scrollController != null && _scrollController!.hasClients) {
        maxScrollExtent = _scrollController!.position.maxScrollExtent;
      }

      if (scrollOffset > maxScrollExtent) {
        scrollOffset = maxScrollExtent;
      } else if (scrollOffset < 0) {
        scrollOffset = 0;
      }

      _scrollController!.jumpTo(scrollOffset);
    }
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    isTooltipVisible.dispose();
    tooltipData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSizeFactor = screenWidth * 0.01;
    return getGraphLineScroll(fontSizeFactor, screenWidth);
  }

  Widget getGraphLineScroll(double fontSizeFactor, double screenWidth) {
    final creditedList = widget.chartData["credited"];
    final debitedList = widget.chartData["debited"];

    final bool hasNoData = (creditedList == null ||
            creditedList.isEmpty ||
            creditedList.every((e) => e == 0)) &&
        (debitedList == null ||
            debitedList.isEmpty ||
            debitedList.every((e) => e == 0));
    if (hasNoData) {
      return Container(
        color: AppColors.backgroundColor,
        height: MediaQuery.of(context).size.height / 2.6,
        child: Center(
          child: Text(
            HomepageStringsDart().noSpendingsAvailable,
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.normal,
              fontSize: fontSizeFactor * 4.0,
              color: AppColors.accentColor,
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: MediaQuery.of(context).size.height / 2.6,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!widget.isExpandedView)
                Container(
                  alignment: Alignment.center,
                  width: screenWidth * 0.09,
                  // color: Colorcodes.moneyOrange,
                  height: MediaQuery.of(context).size.height / 2.6,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: _buildYAxisLabels(fontSizeFactor),
                ),
              // change in future
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: getContainerOfGraph(screenWidth, fontSizeFactor),
                ),
              ),
            ],
          ),
          if (!widget.isExpandedView && widget.selectedButton.value == 'Month')
            Positioned(
              top: 8,
              right: 2,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  navToExpanded();
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.button,
                    shape: BoxShape.circle,
                  ),
                  child: AvatarProfileImage(
                    url: Sign.maximise,
                    width: 36,
                    height: 36,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget getContainerOfGraph(double screenWidth, double fontSizeFactor) {
    int dataLength;
    List<String> labels;

    if (widget.selectedButton.value == 'Week') {
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

    List<ChartData> creditedData = List.generate(dataLength, (index) {
      double value = 0.0;
      if (index < (widget.chartData["credited"]?.length ?? 0)) {
        value = widget.chartData["credited"]![index];
      }
      return ChartData(labels[index], value);
    });

    List<ChartData> debitedData = List.generate(dataLength, (index) {
      double value = 0.0;
      if (index < (widget.chartData["debited"]?.length ?? 0)) {
        value = widget.chartData["debited"]![index];
      }
      return ChartData(labels[index], value);
    });

    double labelWidth = widget.selectedButton.value == 'Month' ? 40.0 : 43.0;
    double chartWidth = dataLength * labelWidth;

    return Container(
      // color: Colorcodes.barGraphOrange,
      padding: EdgeInsets.all(0),
      width: widget.selectedButton.value == 'Week'
          ? screenWidth * 0.85
          : max(chartWidth, screenWidth * 0.85),
      height: MediaQuery.of(context).size.height / 2.6,
      child: Container(
        // offset: widget.selectedButton.value == 'Week'
        //     ? Offset(-5, 0)
        //     : widget.selectedButton.value == 'Month'
        //         ? Offset(-28, 0)
        //         : Offset(-18, 0),
        child: SfCartesianChart(
          borderWidth: 0,
          plotAreaBorderWidth: 0,
          plotAreaBackgroundColor: Colors.transparent,
          enableSideBySideSeriesPlacement: false,

          margin: EdgeInsets.symmetric(horizontal: 0),

          // backgroundColor: Colors.red,
          primaryXAxis: CategoryAxis(
            //  edgeLabelPlacement: EdgeLabelPlacement.shift,

            labelStyle: FontManager().getTextStyle(context,
                lWeight: FontWeight.w500,
                fontSize: fontSizeFactor * 3,
                color: AppColors.accentColor),
            majorGridLines: const MajorGridLines(width: 0),
            minorGridLines: const MinorGridLines(width: 0),
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            minorTickLines: const MinorTickLines(size: 0),
            interval: 1,
            maximumLabels: dataLength,
          ),
          primaryYAxis: NumericAxis(
            isVisible: false,
            placeLabelsNearAxisLine: true,
            labelAlignment: LabelAlignment.start,
            // axisLabelIntersectAction: AxisLabelIntersectAction.hide,
            labelStyle: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.normal,
              fontSize: fontSizeFactor * 2.8,
              color: AppColors.accentColor,
            ),
            majorGridLines: MajorGridLines(width: 0),
            minorGridLines: MinorGridLines(width: 0),
            axisLine: AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            minorTickLines: const MinorTickLines(size: 0),
            labelFormat: '₹{value}',
            minimum: 0,
            maximum: maxYValue * 1.2,
          ),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            format: 'point.x: ₹point.y',
            duration: 0.2,
            builder: (dynamic data, dynamic point, dynamic series,
                int pointIndex, int seriesIndex) {
              final ChartData chartData = data as ChartData;
              String label = seriesIndex == 1 ? 'Credited' : 'Debited';
              isTooltipVisible.value = false;
              return Padding(
                padding: EdgeInsets.only(left: 15, top: 0, right: 0, bottom: 0),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$label: ₹${chartData.y.toStringAsFixed(2)}',
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.normal,
                        fontSize: fontSizeFactor * 2.5,
                        color: Colors.white),
                  ),
                ),
              );
            },
          ),
          trackballBehavior: TrackballBehavior(
            enable: true,
            tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
            lineType: TrackballLineType.vertical, // Vertical line for trackball
            lineColor:
                AppColors.accentColor.withOpacity(0.7), // Customize line color
            lineWidth: 1.0, // Thickness of the trackball line
            lineDashArray: [5, 5], // Dashed line pattern (optional)
//  activationMode: ActivationMode.singleTap,
            tooltipAlignment: ChartAlignment.near, // Trigger on single tap
            markerSettings: TrackballMarkerSettings(
              markerVisibility: TrackballVisibilityMode.visible, // Show marker
              height: 1, // Marker size
              width: 1,
              shape: DataMarkerType.circle, // Marker shape
              color: AppColors.primaryColor, // Marker color
              borderWidth: 1,
              borderColor: AppColors.accentColor, // Border color for marker
            ),
            builder: (BuildContext context, TrackballDetails trackballDetails) {
              // Get the data for the current point
              final int index = trackballDetails
                      .groupingModeInfo?.currentPointIndices.first ??
                  0;
              final String date = labels[index];
              final double creditedValue = creditedData[index].y;
              final double debitedValue = debitedData[index].y;

              return Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.mt.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${HomepageStringsDart().datePrefix} $date',
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.bold,
                        fontSize: fontSizeFactor * 2.4,
                        color: AppColors.bg3,
                      ),
                    ),
                    Text(
                      '${HomepageStringsDart().creditedPrefix} ₹${creditedValue.toStringAsFixed(2)}',
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.bold,
                        fontSize: fontSizeFactor * 2.7,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Text(
                      '${HomepageStringsDart().debitedPrefix} ₹${debitedValue.toStringAsFixed(2)}',
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.bold,
                        fontSize: fontSizeFactor * 2.7,
                        color: AppColors.accentColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          series: <ChartSeries>[
            SplineAreaSeries<ChartData, String>(
              dataSource: creditedData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              //color: const Color.fromARGB(255, 167, 187, 191),
              //use pollselected
              color: AppColors.primaryColor.withOpacity(0.1),
              borderWidth: 0,
              enableTooltip: false,
              splineType: SplineType.cardinal,
              cardinalSplineTension: 0.9,
            ),
            SplineSeries<ChartData, String>(
              dataSource: creditedData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              color: AppColors.primaryColor,
              width: 1,
              enableTooltip: true,
              name: 'Credited',
              splineType: SplineType.cardinal,
              cardinalSplineTension: 0.9,
              markerSettings: MarkerSettings(
                isVisible: false,
                height: 4,
                width: 4,
                shape: DataMarkerType.pentagon,
              ),
            ),
            SplineSeries<ChartData, String>(
              dataSource: debitedData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              color: AppColors.accentColor,
              width: 1,
              enableTooltip: true,
              name: 'Debited',
              splineType: SplineType.cardinal,
              cardinalSplineTension: 0.9,
              markerSettings: MarkerSettings(
                isVisible: false,
                height: 4,
                width: 4,
                shape: DataMarkerType.circle,
              ),
            ),
            SplineAreaSeries<ChartData, String>(
              dataSource: debitedData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              color: AppColors.accentColor.withOpacity(0.1),
              borderWidth: 0,
              enableTooltip: false,
              splineType: SplineType.cardinal,
              cardinalSplineTension: 0.9,
            ),
          ],
          legend: Legend(
            isVisible: false,
            position: LegendPosition.top,
            textStyle: FontManager().getTextStyle(context,
                lWeight: FontWeight.normal,
                fontSize: fontSizeFactor * 3,
                color: AppColors.accentColor),
          ),
        ),
      ),
    );
  }

  void navToExpanded() {
    selectedYear.value = DateTime.now().year;
    selectedMonth.value = DateTime.now().month;
    currentPage = 1;
    selectedButton.value = widget.selectedButton.value;
    currentChartData.value = widget.chartData;
    isLoadingMore.value = false;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpandedChartView(
          chartData: widget.chartData,
          days: widget.days,
          selectedButton: widget.selectedButton.value,
          selectedYear: DateTime.now().year,
          selectedMonth: DateTime.now().month,
        ),
      ),
    );
  }

  bool isTapOnLine(Offset tapPosition) {
    return false;
  }

  Widget _buildYAxisLabels(double fontSizeFactor) {
    final double maxValue = maxYValue * 1.2;
    const int numLabels = 5;
    final double interval = maxValue / (numLabels - 1);

    List<Widget> labels = [];
    for (int i = 0; i < numLabels; i++) {
      double value = i * interval;
      labels.add(
        Text(
          '₹${formatNumberString(value.toStringAsFixed(1))}',
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.normal,
            fontSize: fontSizeFactor * 2.7,
            color: AppColors.accentColor,
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
      return '${(numValue / 10000000).toStringAsFixed(1)}Cr';
    } else if (numValue >= 100000) {
      return '${(numValue / 100000).toStringAsFixed(1)}L';
    } else if (numValue >= 1000) {
      return '${(numValue / 1000).toStringAsFixed(1)}K';
    } else {
      return numValue.toStringAsFixed(0);
    }
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}
