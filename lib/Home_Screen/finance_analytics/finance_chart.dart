// // import 'package:flutter/material.dart';
// // import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// // import 'dart:math';
// // import 'package:flutter_application_code_stakeplot/Home_Screen/finance_analytics/expanded_finance.dart';
// // import 'package:flutter_application_code_stakeplot/Home_Screen/history/history_button.dart';
// // import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
// // import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
// // import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
// // import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// // import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
// // import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
// // import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
// // import 'package:flutter_application_code_stakeplot/repository/finance_repository.dart';
// // import 'package:get/get.dart';
// // import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// // import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// // import 'package:syncfusion_flutter_charts/charts.dart';
// // import '../../components/shared_utils.dart';

// // class FinancePage extends StatefulWidget {
// //   const FinancePage({super.key});

// //   @override
// //   State<FinancePage> createState() => _FinancePageState();
// // }

// // class _FinancePageState extends State<FinancePage> {
// //   @override
// //   void initState() {
// //     super.initState();
// //     selectedButton.value = 'Month';

// //     _fetchData();
// //   }

// //   Future<void> _fetchData() async {
// //     try {
// //       // Ensure financeBox is open
// //       if (accountId.value.isEmpty) {
// //         accountId.value = userController.selectedBank.value;
// //       }
// //       getWeeklyGraphAndCustomDateGraph(getFormattedDate(), context,weekORmonth: 'Month');
// //     } catch (e) {
// //       // _setEmptyState('Month', getFormattedDate(), null);
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     double screenWidth = MediaQuery.of(context).size.width;
// //     double screenHeight = MediaQuery.of(context).size.height;
// //     double fontSizeFactor = screenWidth * 0.01;

// //     return Scaffold(
// //       backgroundColor: AppColors.backgroundColor,
// //       body: Padding(
// //         padding: EdgeInsets.all(0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   HomepageStringsDart().spendingAndCashFlow,
// //                   style: FontManager().getTextStyle(context,
// //                       lWeight: FontWeight.w300,
// //                       fontSize: fontSizeFactor * 4.0,
// //                       color: AppColors.accentColor),
// //                 ),
// //                 // historyButton(context),
// //               ],
// //             ),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Row(
// //                   children: [
// //                     Obx(() => Text(
// //                           '₹${formatMoneyIndian(doubleToFixed(totalDebitValue.toString()))}',
// //                           style: FontManager().getTextStyle(context,
// //                               lWeight: FontWeight.bold,
// //                               fontSize: fontSizeFactor * 4,
// //                               color: AppColors.accentColor),
// //                         )),
// //                     SizedBox(width: screenWidth * 0.02),
// //                     Obx(() {
// //                       String displayText = '';
// //                       if (selectedButton.value == 'Week') {
// //                         displayText = HomepageStringsDart().lastWeek;
// //                       } else if (selectedButton.value == 'Month') {
// //                         displayText = HomepageStringsDart().thisMonth;
// //                       }
// //                       return Text(
// //                         displayText,
// //                         style: FontManager().getTextStyle(context,
// //                             lWeight: FontWeight.normal,
// //                             fontSize: fontSizeFactor * 2.5,
// //                             color: AppColors.accentColor),
// //                       );
// //                     }),
// //                     SizedBox(width: screenWidth * 0.02),
// //                     Obx(() {
// //                       if (selectedButton.value == 'Custom') {
// //                         return SizedBox.shrink();
// //                       }
// //                       final isPositive = totalDebitValuePercent >= 0;
// //                       final arrowIcon = isPositive
// //                           ? Icons.arrow_upward
// //                           : Icons.arrow_downward;
// //                       final arrowColor = isPositive ? Colors.red : Colors.green;
// //                       final formattedValue =
// //                           totalDebitValuePercent.toStringAsFixed(1);
// //                       final textColor = isPositive ? Colors.red : Colors.green;

// //                       return Row(
// //                         children: [
// //                           Text(
// //                             '$formattedValue%',
// //                             style: FontManager().getTextStyle(context,
// //                                 lWeight: FontWeight.normal,
// //                                 fontSize: fontSizeFactor * 2.5,
// //                                 color: textColor),
// //                           ),
// //                           SizedBox(width: screenWidth * 0.01),
// //                           Icon(
// //                             arrowIcon,
// //                             color: arrowColor,
// //                             size: fontSizeFactor * 2.5,
// //                           ),
// //                         ],
// //                       );
// //                     }),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //             SizedBox(height: screenHeight * 0.01),
// //             Obx(() => getMonthWeekCustom(fontSizeFactor, screenWidth)),
// //             Obx(() => !getGraphData.value
// //                 ? Container(
// //                     width: screenWidth,
// //                     height: screenHeight / 2.6,
// //                     child: Center(
// //                       child: Spinner(size: 60),
// //                     ),
// //                   )
// //                 : transactionChatGraph['debited']?.isEmpty == true &&
// //                         transactionChatGraph['credited']?.isEmpty == true
// //                     ? Container(
// //                         width: screenWidth,
// //                         height: screenHeight / 2.6,
// //                         child: Center(
// //                           child: textStyleImage(
// //                             context: context,
// //                             text: HomepageStringsDart().noSpendingsAvailable,
// //                             fontsize: fontSizeFactor * 4.0,
// //                             c: AppColors.accentColor,
// //                           ),
// //                         ),
// //                       )
// //                     : LineChartWidget(
// //                         chartData: transactionChatGraph,
// //                         days: labels,
// //                         selectedButton: selectedButton,
// //                         shouldBeNavigate: true,
// //                         daysInMonth: selectedButton == "Week"
// //                             ? 7
// //                             : selectedButton == "Month"
// //                                 ? getDaysInCurrentMonth()
// //                                 : labels.length,
// //                       )),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget getMonthWeekCustom(double fontSizeFactor, double screenWidth) {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         Text(
// //           HomepageStringsDart().bankSpendings,
// //           style: FontManager().getTextStyle(context,
// //               lWeight: FontWeight.normal,
// //               fontSize: fontSizeFactor * 3.4,
// //               color: AppColors.bg1),
// //         ),
// //         Row(
// //           children: [
// //             GestureDetector(
// //               onTap: () {
// //                 selectedButton.value = 'Month';
// //                 getWeeklyGraphAndCustomDateGraph(getFormattedDate(), context);
// //               },
// //               child: Container(
// //                 height: 35,
// //                 width: screenWidth * 0.15,
// //                 decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.circular(16),
// //                   color: selectedButton.value == 'Month'
// //                       ? AppColors.button
// //                       : AppColors.backgroundColor,
// //                 ),
// //                 child: Center(
// //                   child: Text(
// //                     HomepageStringsDart().month,
// //                     style: FontManager().getTextStyle(context,
// //                         lWeight: FontWeight.normal,
// //                         fontSize: fontSizeFactor * 3.4,
// //                         color: AppColors.accentColor),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             SizedBox(width: screenWidth * 0.02),
// //             GestureDetector(
// //               onTap: () {
// //                 pickCustomDateRange(context);
// //               },
// //               child: Container(
// //                 height: 35,
// //                 width: screenWidth * 0.15,
// //                 decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.circular(16),
// //                   color: selectedButton.value == 'Custom'
// //                       ? AppColors.button
// //                       : AppColors.backgroundColor,
// //                 ),
// //                 child: Center(
// //                   child: Text(
// //                     HomepageStringsDart().custom,
// //                     style: FontManager().getTextStyle(context,
// //                         lWeight: FontWeight.normal,
// //                         fontSize: fontSizeFactor * 3.4,
// //                         color: AppColors.accentColor),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ],
// //     );
// //   }
// // }

// class LineChartWidget extends StatefulWidget {
//   final Map<String, List<double>> chartData;
//   final List days;
//   final RxString selectedButton;
//   final int daysInMonth;
//   final bool isExpandedView;
//   final bool shouldBeNavigate;

//   const LineChartWidget({
//     super.key,
//     required this.chartData,
//     required this.days,
//     required this.selectedButton,
//     required this.daysInMonth,
//     this.isExpandedView = false,
//     this.shouldBeNavigate = false,
//   });

//   @override
//   State<LineChartWidget> createState() => _LineChartWidgetState();
// }

// class _LineChartWidgetState extends State<LineChartWidget> {
//   double maxYValue = 10000;
//   ScrollController? _scrollController;
//   ValueNotifier<bool> isTooltipVisible = ValueNotifier<bool>(false);
//   ValueNotifier<Map<String, dynamic>> tooltipData =
//       ValueNotifier<Map<String, dynamic>>({});

//   int getCurrentDateIndex(List<String> labels) {
//     final now = DateTime.now();
//     if (widget.selectedButton.value == 'Week') {
//       return now.weekday % 7;
//     } else {
//       return now.day - 1;
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _calculateMaxYValue();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && _scrollController != null) {
//         _scrollToCurrentDate();
//       }
//     });
//   }

//   @override
//   void didUpdateWidget(LineChartWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.chartData != widget.chartData) {
//       _calculateMaxYValue();
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted && _scrollController != null) {
//           _scrollToCurrentDate();
//         }
//       });
//     }
//   }

//   void _calculateMaxYValue() {
//     if (widget.chartData["credited"]?.isNotEmpty == true ||
//         widget.chartData["debited"]?.isNotEmpty == true) {
//       maxYValue = [
//         widget.chartData["credited"] ?? [],
//         widget.chartData["debited"] ?? []
//       ]
//           .expand((x) => x)
//           .reduce((value, element) => value > element ? value : element);
//     }
//     if (!maxYValue.isFinite || maxYValue == 0) {
//       maxYValue = 1000.0;
//     }
//   }

//   // void _scrollToCurrentDate() {
//   //   if (_scrollController?.hasClients == true) {
//   //     int currentIndex = getCurrentDateIndex(widget.days.cast<String>());
//   //     double labelWidth = widget.selectedButton.value == 'Week' ? 50.0 : 60.0;
//   //     double scrollOffset = (currentIndex - 4) * labelWidth;

//   //     double maxScrollExtent = 0;
//   //     if (_scrollController != null && _scrollController!.hasClients) {
//   //       maxScrollExtent = _scrollController!.position.maxScrollExtent;
//   //     }

//   //     if (scrollOffset > maxScrollExtent) {
//   //       scrollOffset = maxScrollExtent;
//   //     } else if (scrollOffset < 0) {
//   //       scrollOffset = 0;
//   //     }

//   //     _scrollController!.jumpTo(scrollOffset);
//   //   }
//   // }
//   void _scrollToCurrentDate() {
//     if (_scrollController?.hasClients == true) {
//       // Find the last index with data
//       int lastIndex = widget.chartData["credited"]!.length - 1;
//       while (lastIndex >= 0 &&
//           (widget.chartData["credited"]![lastIndex] == 0 &&
//               widget.chartData["debited"]![lastIndex] == 0)) {
//         lastIndex--;
//       }

//       // If there's no data, do not scroll
//       if (lastIndex < 0) return;

//       double labelWidth = widget.selectedButton.value == 'Week' ? 40.0 : 50.0;
//       double scrollOffset = (lastIndex - 4) * labelWidth;

//       double maxScrollExtent = 0;
//       if (_scrollController != null && _scrollController!.hasClients) {
//         maxScrollExtent = _scrollController!.position.maxScrollExtent;
//       }

//       if (scrollOffset > maxScrollExtent) {
//         scrollOffset = maxScrollExtent;
//       } else if (scrollOffset < 0) {
//         scrollOffset = 0;
//       }

//       _scrollController!.jumpTo(scrollOffset);
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController?.dispose();
//     isTooltipVisible.dispose();
//     tooltipData.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double fontSizeFactor = screenWidth * 0.01;
//     return getGraphLineScroll(fontSizeFactor, screenWidth);
//   }

//   Widget getGraphLineScroll(double fontSizeFactor, double screenWidth) {
//     final creditedList = widget.chartData["credited"];
//     final debitedList = widget.chartData["debited"];

//     final bool hasNoData = (creditedList == null ||
//             creditedList.isEmpty ||
//             creditedList.every((e) => e == 0)) &&
//         (debitedList == null ||
//             debitedList.isEmpty ||
//             debitedList.every((e) => e == 0));
//     if (hasNoData) {
//       return Container(
//         color: AppColors.backgroundColor,
//         height: MediaQuery.of(context).size.height / 2.6,
//         child: Center(
//           child: Text(
//             HomepageStringsDart().noSpendingsAvailable,
//             style: FontManager().getTextStyle(
//               context,
//               lWeight: FontWeight.normal,
//               fontSize: fontSizeFactor * 4.0,
//               color: AppColors.accentColor,
//             ),
//           ),
//         ),
//       );
//     }
//     return SizedBox(
//       height: MediaQuery.of(context).size.height / 2.6,
//       width: MediaQuery.of(context).size.width,
//       child: Stack(
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               if (!widget.isExpandedView)
//                 Container(
//                   alignment: Alignment.center,
//                   width: screenWidth * 0.09,
//                   // color: Colorcodes.moneyOrange,
//                   height: MediaQuery.of(context).size.height / 2.6,
//                   padding: EdgeInsets.symmetric(vertical: 12),
//                   child: _buildYAxisLabels(fontSizeFactor),
//                 ),
//               // change in future
//               Expanded(
//                 child: SingleChildScrollView(
//                   controller: _scrollController,
//                   scrollDirection: Axis.horizontal,
//                   child: getContainerOfGraph(screenWidth, fontSizeFactor),
//                 ),
//               ),
//             ],
//           ),
//           if (!widget.isExpandedView && widget.selectedButton.value == 'Month')
//             Positioned(
//               top: 8,
//               right: 2,
//               child: GestureDetector(
//                 behavior: HitTestBehavior.opaque,
//                 onTap: () {
//                   navToExpanded();
//                 },
//                 child: Container(
//                   padding: EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     color: AppColors.button,
//                     shape: BoxShape.circle,
//                   ),
//                   child: AvatarProfileImage(
//                     url: Sign.maximise,
//                     width: 36,
//                     height: 36,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget getContainerOfGraph(double screenWidth, double fontSizeFactor) {
//     int dataLength;
//     List<String> labels;

//     if (widget.selectedButton.value == 'Week') {
//       dataLength = 7;
//       labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
//     } else {
//       dataLength = widget.daysInMonth;
//       labels = List.from(widget.days);
//       while (labels.length < dataLength) {
//         labels.add((labels.length + 1).toString().padLeft(2, '0'));
//       }
//       labels = labels.sublist(0, dataLength).map((label) {
//         if (widget.selectedButton.value == 'Custom') {
//           // For Custom, keep the full label (e.g., "Aug 12")
//           return label;
//         } else {
//           // For Month, show only the day number (e.g., "12")
//           if (label.contains(' ')) {
//             return label
//                 .split(' ')[1]
//                 .padLeft(2, '0'); // Extract day number and pad with zero
//           }
//           return label.padLeft(2, '0'); // Ensure two-digit format
//         }
//       }).toList();
//       // labels = labels.sublist(0, dataLength);
//     }

//     List<ChartData> creditedData = List.generate(dataLength, (index) {
//       double value = 0.0;
//       if (index < (widget.chartData["credited"]?.length ?? 0)) {
//         value = widget.chartData["credited"]![index];
//       }
//       return ChartData(labels[index], value);
//     });

//     List<ChartData> debitedData = List.generate(dataLength, (index) {
//       double value = 0.0;
//       if (index < (widget.chartData["debited"]?.length ?? 0)) {
//         value = widget.chartData["debited"]![index];
//       }
//       return ChartData(labels[index], value);
//     });

//     double labelWidth = widget.selectedButton.value == 'Month' ? 40.0 : 43.0;
//     double chartWidth = dataLength * labelWidth;

//     return Container(
//       // color: Colorcodes.barGraphOrange,
//       padding: EdgeInsets.all(0),
//       width: widget.selectedButton.value == 'Week'
//           ? screenWidth * 0.85
//           : max(chartWidth, screenWidth * 0.85),
//       height: MediaQuery.of(context).size.height / 2.6,
//       child: Container(
//         // offset: widget.selectedButton.value == 'Week'
//         //     ? Offset(-5, 0)
//         //     : widget.selectedButton.value == 'Month'
//         //         ? Offset(-28, 0)
//         //         : Offset(-18, 0),
//         child: SfCartesianChart(
//           borderWidth: 0,
//           plotAreaBorderWidth: 0,
//           plotAreaBackgroundColor: Colors.transparent,
//           enableSideBySideSeriesPlacement: false,

//           margin: EdgeInsets.symmetric(horizontal: 0),

//           // backgroundColor: Colors.red,
//           primaryXAxis: CategoryAxis(
//             //  edgeLabelPlacement: EdgeLabelPlacement.shift,

//             labelStyle: FontManager().getTextStyle(context,
//                 lWeight: FontWeight.w500,
//                 fontSize: fontSizeFactor * 3,
//                 color: AppColors.accentColor),
//             majorGridLines: const MajorGridLines(width: 0),
//             minorGridLines: const MinorGridLines(width: 0),
//             axisLine: const AxisLine(width: 0),
//             majorTickLines: const MajorTickLines(size: 0),
//             minorTickLines: const MinorTickLines(size: 0),
//             interval: 1,
//             maximumLabels: dataLength,
//           ),
//           primaryYAxis: NumericAxis(
//             isVisible: false,
//             placeLabelsNearAxisLine: true,
//             labelAlignment: LabelAlignment.start,
//             // axisLabelIntersectAction: AxisLabelIntersectAction.hide,
//             labelStyle: FontManager().getTextStyle(
//               context,
//               lWeight: FontWeight.normal,
//               fontSize: fontSizeFactor * 2.8,
//               color: AppColors.accentColor,
//             ),
//             majorGridLines: MajorGridLines(width: 0),
//             minorGridLines: MinorGridLines(width: 0),
//             axisLine: AxisLine(width: 0),
//             majorTickLines: const MajorTickLines(size: 0),
//             minorTickLines: const MinorTickLines(size: 0),
//             labelFormat: '₹{value}',
//             minimum: 0,
//             maximum: maxYValue * 1.2,
//           ),
//           tooltipBehavior: TooltipBehavior(
//             enable: true,
//             format: 'point.x: ₹point.y',
//             duration: 0.2,
//             builder: (dynamic data, dynamic point, dynamic series,
//                 int pointIndex, int seriesIndex) {
//               final ChartData chartData = data as ChartData;
//               String label = seriesIndex == 1 ? 'Credited' : 'Debited';
//               isTooltipVisible.value = false;
//               return Padding(
//                 padding: EdgeInsets.only(left: 15, top: 0, right: 0, bottom: 0),
//                 child: Container(
//                   padding: EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.black54,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     '$label: ₹${chartData.y.toStringAsFixed(2)}',
//                     style: FontManager().getTextStyle(context,
//                         lWeight: FontWeight.normal,
//                         fontSize: fontSizeFactor * 2.5,
//                         color: AppColors.backgroundColor),
//                   ),
//                 ),
//               );
//             },
//           ),
//           trackballBehavior: TrackballBehavior(
//             enable: true,
//             tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
//             lineType: TrackballLineType.vertical, // Vertical line for trackball
//             lineColor:
//                 AppColors.accentColor.withOpacity(0.7), // Customize line color
//             lineWidth: 1.0, // Thickness of the trackball line
//             lineDashArray: [5, 5], // Dashed line pattern (optional)
// //  activationMode: ActivationMode.singleTap,
//             tooltipAlignment: ChartAlignment.near, // Trigger on single tap
//             markerSettings: TrackballMarkerSettings(
//               markerVisibility: TrackballVisibilityMode.visible, // Show marker
//               height: 1, // Marker size
//               width: 1,
//               shape: DataMarkerType.circle, // Marker shape
//               color: AppColors.primaryColor, // Marker color
//               borderWidth: 1,
//               borderColor: AppColors.accentColor, // Border color for marker
//             ),
//             builder: (BuildContext context, TrackballDetails trackballDetails) {
//               // Get the data for the current point
//               final int index = trackballDetails
//                       .groupingModeInfo?.currentPointIndices.first ??
//                   0;
//               final String date = labels[index];
//               final double creditedValue = creditedData[index].y;
//               final double debitedValue = debitedData[index].y;

//               return Container(
//                 margin: EdgeInsets.only(top: 10),
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: AppColors.mt.withOpacity(0.4),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       '${HomepageStringsDart().datePrefix} $date',
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight: FontWeight.bold,
//                         fontSize: fontSizeFactor * 2.4,
//                         color: AppColors.bg3,
//                       ),
//                     ),
//                     Text(
//                       '${HomepageStringsDart().creditedPrefix} ₹${creditedValue.toStringAsFixed(2)}',
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight: FontWeight.bold,
//                         fontSize: fontSizeFactor * 2.7,
//                         color: AppColors.primaryColor,
//                       ),
//                     ),
//                     Text(
//                       '${HomepageStringsDart().debitedPrefix} ₹${debitedValue.toStringAsFixed(2)}',
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight: FontWeight.bold,
//                         fontSize: fontSizeFactor * 2.7,
//                         color: AppColors.accentColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//           series: <ChartSeries>[
//             SplineAreaSeries<ChartData, String>(
//               dataSource: creditedData,
//               xValueMapper: (ChartData data, _) => data.x,
//               yValueMapper: (ChartData data, _) => data.y,
//               //color: const Color.fromARGB(255, 167, 187, 191),
//               //use pollselected
//               color: AppColors.primaryColorOpacity,
//               borderWidth: 0,
//               enableTooltip: false,
//               splineType: SplineType.cardinal,
//               cardinalSplineTension: 0.9,
//             ),
//             SplineSeries<ChartData, String>(
//               dataSource: creditedData,
//               xValueMapper: (ChartData data, _) => data.x,
//               yValueMapper: (ChartData data, _) => data.y,
//               color: AppColors.primaryColor,
//               width: 1,
//               enableTooltip: true,
//               name: 'Credited',
//               splineType: SplineType.cardinal,
//               cardinalSplineTension: 0.9,
//               markerSettings: MarkerSettings(
//                 isVisible: false,
//                 height: 4,
//                 width: 4,
//                 shape: DataMarkerType.pentagon,
//               ),
//             ),
//             SplineSeries<ChartData, String>(
//               dataSource: debitedData,
//               xValueMapper: (ChartData data, _) => data.x,
//               yValueMapper: (ChartData data, _) => data.y,
//               color: AppColors.accentColor,
//               width: 1,
//               enableTooltip: true,
//               name: 'Debited',
//               splineType: SplineType.cardinal,
//               cardinalSplineTension: 0.9,
//               markerSettings: MarkerSettings(
//                 isVisible: false,
//                 height: 4,
//                 width: 4,
//                 shape: DataMarkerType.circle,
//               ),
//             ),
//             SplineAreaSeries<ChartData, String>(
//               dataSource: debitedData,
//               xValueMapper: (ChartData data, _) => data.x,
//               yValueMapper: (ChartData data, _) => data.y,
//               color: AppColors.accentColorOpacity,
//               borderWidth: 0,
//               enableTooltip: false,
//               splineType: SplineType.cardinal,
//               cardinalSplineTension: 0.9,
//             ),
//           ],
//           legend: Legend(
//             isVisible: false,
//             position: LegendPosition.top,
//             textStyle: FontManager().getTextStyle(context,
//                 lWeight: FontWeight.normal,
//                 fontSize: fontSizeFactor * 3,
//                 color: AppColors.accentColor),
//           ),
//         ),
//       ),
//     );
//   }

//   void navToExpanded() {
//     selectedYear.value = DateTime.now().year;
//     selectedMonth.value = DateTime.now().month;
//     currentPage = 1;
//     selectedButton.value = widget.selectedButton.value;
//     currentChartData.value = widget.chartData;
//     isLoadingMore.value = false;
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ExpandedChartView(
//           chartData: widget.chartData,
//           days: widget.days,
//           selectedButton: widget.selectedButton.value,
//           selectedYear: DateTime.now().year,
//           selectedMonth: DateTime.now().month,
//         ),
//       ),
//     );
//   }

//   bool isTapOnLine(Offset tapPosition) {
//     return false;
//   }

//   Widget _buildYAxisLabels(double fontSizeFactor) {
//     final double maxValue = maxYValue * 1.2;
//     const int numLabels = 5;
//     final double interval = maxValue / (numLabels - 1);

//     List<Widget> labels = [];
//     for (int i = 0; i < numLabels; i++) {
//       double value = i * interval;
//       labels.add(
//         Text(
//           '₹${formatNumberString(value.toStringAsFixed(1))}',
//           style: FontManager().getTextStyle(
//             context,
//             lWeight: FontWeight.normal,
//             fontSize: fontSizeFactor * 2.7,
//             color: AppColors.accentColor,
//           ),
//         ),
//       );
//     }

//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: labels.reversed.toList(),
//     );
//   }

//   String formatNumberString(String value) {
//     double numValue = double.tryParse(value) ?? 0;
//     if (numValue >= 10000000) {
//       return '${(numValue / 10000000).toStringAsFixed(1)}Cr';
//     } else if (numValue >= 100000) {
//       return '${(numValue / 100000).toStringAsFixed(1)}L';
//     } else if (numValue >= 1000) {
//       return '${(numValue / 1000).toStringAsFixed(1)}K';
//     } else {
//       return numValue.toStringAsFixed(0);
//     }
//   }
// }

// class ChartData {
//   ChartData(this.x, this.y);
//   final String x;
//   final double y;
// }


import 'package:flutter/material.dart';
import 'dart:math';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../Constants/colors.dart';
import '../../Constants/font_manager.dart';
import '../../components/shared_utils.dart';
import 'expanded_finance.dart';

class SpendingCardTwoPanels extends StatefulWidget {
  const SpendingCardTwoPanels({super.key});

  @override
  State<SpendingCardTwoPanels> createState() => _SpendingCardTwoPanelsState();
}

class ChartData {
  ChartData(this.label, this.credit, this.debit);
  final String label;
  final double credit;
  final double debit;
}

class _SpendingCardTwoPanelsState extends State<SpendingCardTwoPanels> {
  // Dummy data (replace with your real arrays)
  final List<int> labels = [12, 13, 14, 15, 16, 17, 18];
  final List<double> credited = [1200, 900, 1400, 2200, 1600, 2000, 1800];
  final List<double> debited = [800, 600, 400, 300, 700, 400, 600];

  int selectedIndex = 6;
  final double chartMaxHeight = 180.0;
  final double barWidth = 26.0;
  final double barSpacing = 18.0;

  @override
  void initState() {
    super.initState();
    selectedIndex = max(0, labels.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    // Build ChartData (use length from your lists)
    final int n = max(credited.length, debited.length);
    // Ensure we only use first 7 entries if you want exactly 7 bars:
    final int count = min(n, 7);
    final List<ChartData> data = List.generate(count, (i) {
      final c = i < credited.length ? credited[i] : 0.0;
      final d = i < debited.length ? debited[i] : 0.0;
      return ChartData((labels.length > i ? labels[i].toString() : (i + 1).toString()), c, d);
    });

    final List<double> totals = data.map((e) => e.credit + e.debit).toList();
    final double maxTotal = totals.isEmpty ? 1.0 : totals.reduce(max);
    final double yMax = (maxTotal * 1.2).ceilToDouble();

    // Layout calculations (no Expanded)
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final horizontalMargin = 2.0;

    final gapBetween = 12.0;

    double rightVisible = MediaQuery.sizeOf(context).width / 2;
    rightVisible = max(rightVisible, 120.0);
    rightVisible = min(rightVisible, sw * 0.64);
    // Selected values for left panel
    final double selCred = selectedIndex < data.length ? data[selectedIndex].credit : 0.0;
    final double selDeb = selectedIndex < data.length ? data[selectedIndex].debit : 0.0;

    // Outer white card (single container)
    return Container(
      width: MediaQuery.sizeOf(context).width,
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor, // #FFFFFF
        borderRadius: BorderRadius.circular(10), // 10px
        border: Border.all(
          color: AppColors.financeChartBorder, // #E6E9EB
          width: 1,
        ),
        boxShadow: [BoxShadow(color: AppColors.accentColorOpacity, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left data container (keeps your mediaquery width)
            Material(
              color: AppColors.transparentColor,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                 
                  final Map<String, List<double>> chartMap = {
                    'credited': List<double>.from(credited),
                    'debited': List<double>.from(debited),
                  };
                  final List<String> dayLabels = labels.map((e) => e.toString()).toList();

                  // selectedButton is an RxString in your app — fallback to 'Month' here
                  final String selBtn = 'Month';
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExpandedChartView(
                        chartData: chartMap,
                        days: dayLabels,
                        selectedButton: selBtn,
                        selectedYear: DateTime.now().year,
                        selectedMonth: DateTime.now().month,
                      ),
                    ),
                  );
                 
                },
                child: Container(
                  width: MediaQuery.sizeOf(context).width / 3.3,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Spending',
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w500, fontSize: 14, color: AppColors.primaryColor)),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹ ${formatNumber(selCred)}',
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.w500, fontSize: 14, color: AppColors.primaryColor)),
                          const SizedBox(width: 8),
                          Text('Credited',
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.w400, fontSize: 12, color: AppColors.primaryColor)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹ ${formatNumber(selDeb)}',
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.w500, fontSize: 14, color: AppColors.debitedAmount)),
                          const SizedBox(width: 8),
                          Text('Debited',
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.w400, fontSize: 12, color: AppColors.debitedAmount)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: gapBetween),

            Container(
              width: MediaQuery.sizeOf(context).width / 2,
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: chartMaxHeight - 40,
                    width: rightVisible,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(data.length, (i) {
                        final d = data[i];

                        // Heights for stacked bar
                        final double maxBarH = chartMaxHeight - 40;
                        final double debitH = (d.debit / yMax) * maxBarH;
                        final double creditH = (d.credit / yMax) * maxBarH;

                        final bool isSel = i == selectedIndex;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              debugPrint('Bar $i tapped');
                              setState(() => selectedIndex = i);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Stacked bar
                                Container(
                                  width: (rightVisible / 8), // ensures 7 bars fit comfortably
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFE8EAF0), width: 1),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Credit portion
                                      AnimatedContainer(
                                        duration: Duration(milliseconds: 220),
                                        height: creditH.clamp(0.0, maxBarH),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: isSel
                                              ? AppColors.primaryColor
                                              : AppColors.primaryColor.withOpacity(0.22),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(6),
                                            topRight: Radius.circular(6),
                                          ),
                                        ),
                                      ),

                                      // Debit portion
                                      AnimatedContainer(
                                        duration: Duration(milliseconds: 220),
                                        height: debitH.clamp(0.0, maxBarH),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: isSel
                                              ? AppColors.debitedAmount
                                              : AppColors.debitedAmount.withOpacity(0.22),
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(6),
                                            bottomRight: Radius.circular(6),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Label
                                SizedBox(
                                  width: (rightVisible / 8),
                                  child: Text(
                                    d.label,
                                    textAlign: TextAlign.center,
                                    style: FontManager().getTextStyle(
                                      context,
                                      lWeight: FontWeight.w400,
                                      fontSize: 11,
                                      color: AppColors.debitedAmount,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 
}





// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../Constants/colors.dart';
// import '../../Constants/font_manager.dart';
// import '../../backed_connections/apis_connect.dart';
// import '../../components/shared_utils.dart';
// import '../../repository/finance_repository.dart';
// import '../finance_analytics/expanded_finance.dart';
// import '../../backed_connections/apiAutomations/getTrasactions.dart';

// class SpendingCardTwoPanels extends StatefulWidget {
//   const SpendingCardTwoPanels({super.key});

//   @override
//   State<SpendingCardTwoPanels> createState() =>
//       _SpendingCardTwoPanelsState();
// }

// class ChartData {
//   ChartData(this.label, this.credit, this.debit);
//   final String label;
//   final double credit;
//   final double debit;
// }

// class _SpendingCardTwoPanelsState
//     extends State<SpendingCardTwoPanels> {
//   int selectedIndex = 0;
//   final double chartMaxHeight = 180;

//   @override
//   void initState() {
//     super.initState();

//     /// 🔥 Call REAL API (Month data)
//     getWeeklyGraphAndCustomDateGraph(
//       DateTime.now().toIso8601String(),
//       context,
//       weekORmonth: 'Month',
//     );
//   }

//   /// 🔹 Find index of TODAY in labels (dd format)
//   int findTodayIndex(List<String> labels) {
//     final String today =
//         DateTime.now().day.toString().padLeft(2, '0');

//     return labels.lastIndexWhere((l) => l == today);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (!getGraphData.value) {
//         return const SizedBox(
//           height: 220,
//           child: Center(child: CircularProgressIndicator()),
//         );
//       }

//       final List<double> credited =
//           List<double>.from(transactionChatGraph['credited'] ?? []);
//       final List<double> debited =
//           List<double>.from(transactionChatGraph['debited'] ?? []);
//       final List<String> dayLabels =
//           labels.map((e) => e.toString()).toList();

//       if (credited.isEmpty ||
//           debited.isEmpty ||
//           dayLabels.isEmpty) {
//         return const SizedBox(
//           height: 220,
//           child: Center(child: Text('No data available')),
//         );
//       }

//       /// 🔥 TODAY → LAST 7 DAYS LOGIC
//       final int todayIndex = findTodayIndex(dayLabels);

//       /// If today not found, fallback to last available day
//       final int endIndex =
//           todayIndex != -1 ? todayIndex : dayLabels.length - 1;

//       final int startIndex = max(0, endIndex - 6);

//       final List<double> visibleCredited =
//           credited.sublist(startIndex, endIndex + 1);
//       final List<double> visibleDebited =
//           debited.sublist(startIndex, endIndex + 1);
//       final List<String> visibleLabels =
//           dayLabels.sublist(startIndex, endIndex + 1);

//       /// Always select TODAY bar
//       selectedIndex = visibleLabels.length - 1;

//       return _buildCard(
//         context,
//         visibleCredited,
//         visibleDebited,
//         visibleLabels,
//       );
//     });
//   }

//   Widget _buildCard(
//     BuildContext context,
//     List<double> credited,
//     List<double> debited,
//     List<String> labels,
//   ) {
//     final List<ChartData> data = List.generate(labels.length, (i) {
//       return ChartData(labels[i], credited[i], debited[i]);
//     });

//     final double selCred = data[selectedIndex].credit;
//     final double selDeb = data[selectedIndex].debit;

//     final double maxTotal = data
//         .map((e) => e.credit + e.debit)
//         .fold(0, max);

//     final double yMax = maxTotal == 0 ? 1 : maxTotal * 1.2;

//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double rightVisible = min(screenWidth * 0.55, 260);

//     return Container(
//       margin: const EdgeInsets.all(6),
//       decoration: BoxDecoration(
//         color: AppColors.backgroundColor,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: AppColors.financeChartBorder),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.accentColorOpacity,
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           )
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Row(
//           children: [
//             /// LEFT PANEL
//             InkWell(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => ExpandedChartView(
//                       chartData: {
//                         'credited': credited,
//                         'debited': debited,
//                       },
//                       days: labels,
//                       selectedButton: 'Month',
//                       selectedYear: DateTime.now().year,
//                       selectedMonth: DateTime.now().month,
//                     ),
//                   ),
//                 );
//               },
//               child: SizedBox(
//                 width: screenWidth / 3.2,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'My Spending',
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight: FontWeight.w500,
//                         fontSize: 14,
//                         color: AppColors.primaryColor,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       '₹ ${formatNumber(selCred)}',
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight: FontWeight.w500,
//                         fontSize: 14,
//                         color: AppColors.primaryColor,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       'Credited',
//                       style: FontManager().getTextStyle(
//                         context,
//                         fontSize: 12,
//                         color: AppColors.primaryColor,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       '₹ ${formatNumber(selDeb)}',
//                       style: FontManager().getTextStyle(
//                         context,
//                         lWeight: FontWeight.w500,
//                         fontSize: 14,
//                         color: AppColors.debitedAmount,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       'Debited',
//                       style: FontManager().getTextStyle(
//                         context,
//                         fontSize: 12,
//                         color: AppColors.debitedAmount,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(width: 12),

//             /// RIGHT STACKED BAR CHART (TODAY → LAST 7 DAYS)
//             SizedBox(
//               width: rightVisible,
//               height: chartMaxHeight,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 mainAxisAlignment:
//                     MainAxisAlignment.spaceBetween,
//                 children: List.generate(data.length, (i) {
//                   final d = data[i];
//                   final bool isSel = i == selectedIndex;

//                   final double creditH =
//                       (d.credit / yMax) * chartMaxHeight;
//                   final double debitH =
//                       (d.debit / yMax) * chartMaxHeight;

//                   return InkWell(
//                     onTap: () {
//                       setState(() => selectedIndex = i);
//                     },
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         Container(
//                           width: rightVisible / 8,
//                           decoration: BoxDecoration(
//                             borderRadius:
//                                 BorderRadius.circular(6),
//                             border: Border.all(
//                               color: const Color(0xFFE8EAF0),
//                             ),
//                           ),
//                           child: Column(
//                             mainAxisAlignment:
//                                 MainAxisAlignment.end,
//                             children: [
//                               AnimatedContainer(
//                                 duration: const Duration(
//                                     milliseconds: 200),
//                                 height: creditH,
//                                 decoration: BoxDecoration(
//                                   color: isSel
//                                       ? AppColors.primaryColor
//                                       : AppColors.primaryColor
//                                           .withOpacity(0.3),
//                                   borderRadius:
//                                       const BorderRadius.vertical(
//                                     top: Radius.circular(6),
//                                   ),
//                                 ),
//                               ),
//                               AnimatedContainer(
//                                 duration: const Duration(
//                                     milliseconds: 200),
//                                 height: debitH,
//                                 decoration: BoxDecoration(
//                                   color: isSel
//                                       ? AppColors.debitedAmount
//                                       : AppColors.debitedAmount
//                                           .withOpacity(0.3),
//                                   borderRadius:
//                                       const BorderRadius.vertical(
//                                     bottom: Radius.circular(6),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         Text(
//                           d.label,
//                           style: FontManager().getTextStyle(
//                             context,
//                             fontSize: 11,
//                             color: AppColors.debitedAmount,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
