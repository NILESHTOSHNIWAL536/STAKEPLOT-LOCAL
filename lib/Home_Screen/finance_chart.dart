// import 'package:flutter/material.dart';
// import 'dart:math';
// import 'package:flutter_application_code_stakeplot/Constants/customButton.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/expanded_finance.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';
// import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/loader.dart';
// import 'package:get/get.dart';
// import './colors.dart';
// import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

// class FinancePage extends StatefulWidget {
//   final ScrollController scrollController;
//   final GlobalKey transactionHistoryKey;
//   const FinancePage({
//     super.key,
//     required this.scrollController,
//     required this.transactionHistoryKey,
//   });

//   @override
//   State<FinancePage> createState() => _FinancePageState();
// }

// class _FinancePageState extends State<FinancePage> {
//   @override
//   void initState() {
//     super.initState();
//     getGraphData.value = false;
//     calledFunctionToFetchData(context);
//   }

//   void _scrollToTransactionHistory() {
//     final RenderObject? renderObject =
//         widget.transactionHistoryKey.currentContext?.findRenderObject();
//     if (renderObject != null && renderObject is RenderBox) {
//       final position = renderObject.localToGlobal(Offset.zero);
//       final scrollOffset = widget.scrollController.offset;
//       final targetOffset =
//           position.dy - scrollOffset - MediaQuery.of(context).size.height / 8;
//       // print("targetOffset $targetOffset");
//       widget.scrollController.animateTo(
//         targetOffset > 0 ? targetOffset : 0,
//         duration: Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     } else {}
//   }

//   int _getDaysInCurrentMonth() {
//     final now = DateTime.now();
//     return DateTime(now.year, now.month + 1, 0).day;
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
//             Text(
//               'Spending and cash flow',
//               style: FontManager().getTextStyle(context,
//                   lWeight: FontWeight.w300,
//                   fontSize: fontSizeFactor * 4.0,
//                   color: AppColors.accentColor),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Obx(() => Text(
//                           getGraphData.value
//                               ? '₹${doubleToFixed(totalDebitValue.toString())}'
//                               : '₹${doubleToFixed(totalDebitValue.toString())}',
//                           style: FontManager().getTextStyle(context,
//                               lWeight: FontWeight.bold,
//                               fontSize: fontSizeFactor * 4,
//                               color: AppColors.accentColor),
//                         )),
//                     SizedBox(width: screenWidth * 0.02),
//                     Obx(() {
//                       String displayText = '';
//                       if (selectedButton.value == 'Week') {
//                         displayText = 'This week';
//                       } else if (selectedButton.value == 'Month') {
//                         displayText = 'This month';
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
//                 CustomButton(
//                   onTap: () {
//                     _scrollToTransactionHistory();
//                   },
//                   text: 'History',
//                   fontSize: fontSizeFactor * 2.8,
//                   height: 1.7,
//                   width: 5.0,
//                   icon: AvatarProfileImage(
//                     url: HomePageIcons.history,
//                     width: 36,
//                     height: 36,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: screenHeight * 0.01),
//             Obx(() => getGraphData.value
//                 ? getMonthWeekCustom(fontSizeFactor, screenWidth)
//                 : getMonthWeekCustom(fontSizeFactor, screenWidth)),
//             Obx(() => !getGraphData.value
//                 ? Container(
//                     width: MediaQuery.of(context).size.width / 1.3,
//                     height: MediaQuery.of(context).size.height / 2.6,
//                     child: Center(child: Spinner()),
//                   )
//                 : LineChartWidget(
//                     chartData: transactionChatGraph,
//                     days: labels,
//                     selectedButton: selectedButton,
//                     shouldBeNavigate: true,
//                     daysInMonth: selectedButton == "Week"
//                         ? 7
//                         : selectedButton == "Month"
//                             ? _getDaysInCurrentMonth()
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
//           'Bank Spendings',
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
//                     'Month',
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
//                 selectedButton.value = 'Week';
//                 // getGraphData.value = false;
//                 getAutoMationsTransactionsCustom(
//                     getCurrentWeek(), context, 'Week');
//               },
//               child: Container(
//                 height: 35,
//                 width: screenWidth * 0.15,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(16),
//                   color: selectedButton.value == 'Week'
//                       ? AppColors.button
//                       : AppColors.backgroundColor,
//                 ),
//                 child: Center(
//                   child: Text(
//                     'Week',
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
//                     'Custom',
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
//   int getCurrentDateIndex(List<String> labels) {
//     final now = DateTime.now();
//     if (widget.selectedButton.value == 'Week') {
//       return now.weekday % 7; // 0 for Sunday, 1 for Monday, etc.
//     } else {
//       return now.day - 1; // 0-based index for day of month
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _calculateMaxYValue();
//   }

//   @override
//   void didUpdateWidget(LineChartWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.chartData != widget.chartData) {
//       _calculateMaxYValue();
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

//   ValueNotifier<bool> isTooltipVisible = ValueNotifier<bool>(false);

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double fontSizeFactor = screenWidth * 0.01;
//     return getGraphLineScroll(fontSizeFactor, screenWidth);
//   }

//   Widget getGraphLineScroll(double fontSizeFactor, double screenWidth) {
//     final creditedList = widget.chartData["credited"];
//   final debitedList = widget.chartData["debited"];

//   // Check if both lists are either null, empty, or contain only zeros
//   final bool hasNoData = (creditedList == null || creditedList.isEmpty || creditedList.every((e) => e == 0)) &&
//       (debitedList == null || debitedList.isEmpty || debitedList.every((e) => e == 0));
//     if (hasNoData) {
//       return Container(
//         color: AppColors.backgroundColor, // Use a neutral background color
//         height: MediaQuery.of(context).size.height / 2.6,
//         child: Center(
//           child: Text(
//                         'No spendings available',
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
//     return Container(
      
//       height: MediaQuery.of(context).size.height / 2.6,
//       child: Stack(
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Fixed Y-axis labels
//               if (!widget.isExpandedView)
//                 Container(
//                   // width: screenWidth * 0.06, // Reduced width (adjust as needed)
//                   padding: EdgeInsets.zero,
//                   child: _buildYAxisLabels(fontSizeFactor),
//                 ),
//               // Scrollable chart area
//               Expanded(
//                   child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: getContainerOfGraph(screenWidth, fontSizeFactor),
//               )),
//             ],
//           ),
//           // Icon button for navigation to ExpandedChartView (only in non-expanded view)
//           if (!widget.isExpandedView && widget.selectedButton.value == 'Month')
//             Positioned(
//               top: 8, // Adjust as needed
//               right: 2, // Adjust as needed
//               child: GestureDetector(
//                 behavior: HitTestBehavior.opaque,
//                 onTap: () {
//                   navToExpanded(); // Navigate to ExpandedChartView
//                 },
//                 child: Container(
//                   padding: EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     color: AppColors.button, // Background for visibility
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
//       // Custom and Month
//       dataLength = widget.daysInMonth;
//       labels = List.from(widget.days);

//       while (labels.length < dataLength) {
//         labels.add((labels.length + 1).toString().padLeft(2, '0'));
//       }
//       labels = labels.sublist(0, dataLength);

//       // For custom, adjust labels to be more compact
//     }
//     List<ChartData> creditedData = List.generate(dataLength, (index) {
//       double value = 0.0;
//       if (index < widget.chartData["credited"]!.length) {
//         value = widget.chartData["credited"]![index];
//       }
//       return ChartData(labels[index], value);
//     });

//     List<ChartData> debitedData = List.generate(dataLength, (index) {
//       double value = 0.0;
//       if (index < widget.chartData["debited"]!.length) {
//         value = widget.chartData["debited"]![index];
//       }
//       return ChartData(labels[index], value);
//     });

//     double labelWidth = widget.selectedButton.value == 'Week' ? 50.0 : 60.0;
//     double chartWidth = dataLength * labelWidth;

//     return Container(
//         //color: Colors.amber,
//         width: widget.selectedButton.value == 'Week'
//             ? screenWidth * 0.85 // Fixed width for Week
//             : max(chartWidth, screenWidth * 0.85),
//         height: MediaQuery.of(context).size.height / 2.6,
//         child: Transform.translate(
//           offset: widget.selectedButton.value == 'Week'
//               ? Offset(-20, 0)
//               : widget.selectedButton.value == 'Month'
//                   ? Offset(-30, 0)
//                   : Offset(-20, 0),
//           child: SfCartesianChart(
//             borderWidth: 0,
//             plotAreaBorderWidth: 0,
//             primaryXAxis: CategoryAxis(
//               labelStyle: FontManager().getTextStyle(context,
//                   lWeight: FontWeight.bold,
//                   fontSize: fontSizeFactor * 3,
//                   color: AppColors.accentColor),
//               majorGridLines: MajorGridLines(width: 0),
//               minorGridLines:
//                   MinorGridLines(width: 0), // Ensure no minor grid lines
//               axisLine: AxisLine(width: 0),
//               majorTickLines: const MajorTickLines(
//                   size: 0), // Hide major tick marks if desired
//               minorTickLines: const MinorTickLines(size: 0),
//               interval: 1,

//               // labelRotation: widget.selectedButton.value == 'Week' ? 0 : -45,
//               // edgeLabelPlacement: EdgeLabelPlacement.shift,
//               maximumLabels: dataLength, // Ensure all labels are considered
//             ),
//             primaryYAxis: NumericAxis(
//               isVisible: false,
//               labelStyle: FontManager().getTextStyle(context,
//                   lWeight: FontWeight.normal,
//                   fontSize: fontSizeFactor * 3.3,
//                   color: AppColors.accentColor),
//               majorGridLines: MajorGridLines(width: 0),
//               minorGridLines:
//                   MinorGridLines(width: 0), // Ensure no minor grid lines
//               axisLine: AxisLine(width: 0),
//               majorTickLines: const MajorTickLines(
//                   size: 0), // Hide major tick marks if desired
//               minorTickLines: const MinorTickLines(size: 0),
//               labelFormat: '₹{value}',
//               minimum: 0,
//               maximum: maxYValue * 1.2,
//             ),
//             //enableAxisAnimation: true,

//             tooltipBehavior: TooltipBehavior(
//               enable: true,
//               builder: (dynamic data, dynamic point, dynamic series,
//                   int pointIndex, int seriesIndex) {
//                 final ChartData chartData = data as ChartData;
//                 String label = seriesIndex == 1 ? 'Credited' : 'Debited';
//                 isTooltipVisible.value = false;
//                 return Padding(
//                   padding:
//                       EdgeInsets.only(left: 15, top: 0, right: 0, bottom: 0),
//                   child: Container(
//                     padding: EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.black54,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Text(
//                       '$label: ₹${chartData.y.toStringAsFixed(2)}',
//                       style: FontManager().getTextStyle(context,
//                           lWeight: FontWeight.normal,
//                           fontSize: fontSizeFactor * 2.5,
//                           color: Colors.white),
//                     ),
//                   ),
//                 );
//               },
//             ),

//             series: <ChartSeries>[
//               SplineAreaSeries<ChartData, String>(
//                 dataSource: creditedData,
//                 xValueMapper: (ChartData data, _) => data.x,
//                 yValueMapper: (ChartData data, _) => data.y,
//                 color:
//                     AppColors.primaryColor.withOpacity(0.2), // Faded area color
//                 borderWidth: 0, // No border, just the area
//                 enableTooltip: false, // Disable tooltip for the area layer
//                 splineType: SplineType.cardinal,
//                 cardinalSplineTension: 0.9,
//               ),
//               SplineSeries<ChartData, String>(
//                 dataSource: creditedData,
//                 xValueMapper: (ChartData data, _) => data.x,
//                 yValueMapper: (ChartData data, _) => data.y,
//                 color: AppColors.primaryColor,
//                 width: 1, // Increased line width for better visibility
//                 enableTooltip: true,
//                 name: 'Credited',
//                 splineType: SplineType.cardinal, // Makes the curve smoother
//                 cardinalSplineTension: 0.9, // Adjust curve tension (0-1)
//                 markerSettings: MarkerSettings(
//                   isVisible: false,
//                   height: 4,
//                   width: 4,
//                   shape: DataMarkerType.pentagon,
//                 ),
//                 onPointTap: (ChartPointDetails details) {
//                   // Handle point tap here
//                 },
//               ),
//               SplineSeries<ChartData, String>(
//                 dataSource: debitedData,
//                 xValueMapper: (ChartData data, _) => data.x,
//                 yValueMapper: (ChartData data, _) => data.y,
//                 color: AppColors.accentColor,
//                 width: 1,
//                 enableTooltip: true,
//                 name: 'Debited',
//                 splineType: SplineType.cardinal,
//                 cardinalSplineTension: 0.9,
//                 markerSettings: MarkerSettings(
//                   isVisible: false,
//                   height: 4,
//                   width: 4,
//                   shape: DataMarkerType.circle,
//                 ),
//                 onPointTap: (ChartPointDetails details) {
//                   // Handle point tap here
//                 },
//               ),
//               SplineAreaSeries<ChartData, String>(
//                 dataSource: debitedData,
//                 xValueMapper: (ChartData data, _) => data.x,
//                 yValueMapper: (ChartData data, _) => data.y,
//                 color:
//                     AppColors.accentColor.withOpacity(0.2), // Faded area color
//                 borderWidth: 0, // No border, just the area
//                 enableTooltip: false, // Disable tooltip for the area layer
//                 splineType: SplineType.cardinal,
//                 cardinalSplineTension: 0.9,
//               ),
//             ],
//             legend: Legend(
//               isVisible: false,
//               position: LegendPosition.top,
//               textStyle: FontManager().getTextStyle(context,
//                   lWeight: FontWeight.normal,
//                   fontSize: fontSizeFactor * 3,
//                   color: AppColors.accentColor),
//             ),
//           ),
//         ));
//   }

//   void navToExpanded() {
//      selectedYear.value=DateTime.now().year;
//       selectedMonth.value= DateTime.now().month;
//       currentPage=1;
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
//     // Implement your logic here
//     return false; // Placeholder return value
//   }

//   Widget _buildYAxisLabels(double fontSizeFactor) {
//     // Calculate the maximum value including padding
//     final double maxValue = maxYValue * 1.2;

//     // Determine the number of labels (e.g., 5) and calculate interval
//     const int numLabels = 5; // You can adjust this based on your needs
//     final double interval =
//         maxValue / (numLabels - 1); // Avoid division by zero

//     List<Widget> labels = [];

//     for (int i = 0; i < numLabels; i++) {
//       double value = i * interval;
//       labels.add(
//         Expanded(
//           child: Align(
//             alignment: Alignment.center,
//             child: Text(
//               '₹${formatNumberString(value.toStringAsFixed(0))}', // Use toStringAsFixed for precision
//               style: FontManager().getTextStyle(
//                 context,
//                 lWeight: FontWeight.normal,
//                 fontSize: fontSizeFactor * 3.3,
//                 color: AppColors.accentColor,
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: labels.reversed.toList(), // Highest value at top
//     );
//   }

//   String formatNumberString(String value) {
//     double numValue = double.tryParse(value) ?? 0;
//     if (numValue >= 10000000) {
//       return '${(numValue / 10000000).toStringAsFixed(1)} Cr'; // Increased precision
//     } else if (numValue >= 100000) {
//       return '${(numValue / 100000).toStringAsFixed(1)} L'; // Increased precision
//     } else if (numValue >= 1000) {
//       return '${(numValue / 1000).toStringAsFixed(1)} K'; // Increased precision
//     } else {
//       return numValue.toStringAsFixed(0); // No decimals for small values
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
import 'package:flutter_application_code_stakeplot/Constants/customButton.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/expanded_finance.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:get/get.dart';
import './colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class FinancePage extends StatefulWidget {
  final ScrollController scrollController;
  final GlobalKey transactionHistoryKey;
  const FinancePage({
    super.key,
    required this.scrollController,
    required this.transactionHistoryKey,
  });

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  @override
  void initState() {
    super.initState();
    getGraphData.value = false;
    calledFunctionToFetchData(context);
  }

  void _scrollToTransactionHistory() {
    final RenderObject? renderObject =
        widget.transactionHistoryKey.currentContext?.findRenderObject();
    if (renderObject != null && renderObject is RenderBox) {
      final position = renderObject.localToGlobal(Offset.zero);
      final scrollOffset = widget.scrollController.offset;
      final targetOffset =
          position.dy - scrollOffset - MediaQuery.of(context).size.height / 8;
     
      widget.scrollController.animateTo(
        targetOffset > 0 ? targetOffset : 0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {}
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
            Text(
              'Spending and cash flow',
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.w300,
                  fontSize: fontSizeFactor * 4.0,
                  color: AppColors.accentColor),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Obx(() => Text(
                          getGraphData.value
                              ? '₹${formatMoneyIndian(doubleToFixed(totalDebitValue.toString()))}'
                              : '₹${formatMoneyIndian(doubleToFixed(totalDebitValue.toString()))}',
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.bold,
                              fontSize: fontSizeFactor * 4,
                              color: AppColors.accentColor),
                        )),
                    SizedBox(width: screenWidth * 0.02),
                    Obx(() {
                      String displayText = '';
                      if (selectedButton.value == 'Week') {
                        displayText = 'This week';
                      } else if (selectedButton.value == 'Month') {
                        displayText = 'This month';
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
                        return SizedBox
                            .shrink(); // Do not show anything for Custom
                      }
                      // Determine the arrow icon and color based on the value
                      final isPositive = totalDebitValuePercent >= 0;
                      final arrowIcon = isPositive
                          ? Icons.arrow_upward
                          : Icons.arrow_downward;
                      final arrowColor = isPositive ? Colors.red : Colors.green;
                      final formattedValue = totalDebitValuePercent
                          .toStringAsFixed(1); // Round to one decimal place
                      final textColor = isPositive
                          ? Colors.red
                          : Colors.green; // Change text color based on value

                      return Row(
                        children: [
                          Text(
                            '$formattedValue%',
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.normal,
                                fontSize: fontSizeFactor * 2.5,
                                color:
                                    textColor), // Set text color based on value
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Icon(
                            arrowIcon,
                            color: arrowColor,
                            size: fontSizeFactor * 2.5, // Adjust size as needed
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                CustomButton(
                  onTap: () {
                    _scrollToTransactionHistory();
                  },
                  text: 'History',
                  fontSize: fontSizeFactor * 2.8,
                  height: 1.7,
                  width: 5.0,
                  icon: AvatarProfileImage(
                    url: HomePageIcons.history,
                    width: 36,
                    height: 36,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            Obx(() => getGraphData.value
                ? getMonthWeekCustom(fontSizeFactor, screenWidth)
                : getMonthWeekCustom(fontSizeFactor, screenWidth)),
            Obx(() => !getGraphData.value
                ? Container(
                    width: MediaQuery.of(context).size.width / 1.3,
                    height: MediaQuery.of(context).size.height / 2.6,
                    child: Center(child: Spinner()),
                  )
                : LineChartWidget(
                    chartData: transactionChatGraph,
                    days: labels,
                    selectedButton: selectedButton,
                    shouldBeNavigate: true,
                    daysInMonth: selectedButton == "Week"
                        ? 7
                        : selectedButton == "Month"
                            ? _getDaysInCurrentMonth()
                            : labels.length,
                  )),
          ],
        ),
      ),
    );
  }

  Widget getMonthWeekCustom(fontSizeFactor, screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Bank Spendings',
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.normal,
              fontSize: fontSizeFactor * 3.4,
              color: AppColors.bg1),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                // getGraphData.value = false;
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
                selectedButton.value = 'Week';
                // getGraphData.value = false;
                getAutoMationsTransactionsCustom(
                    getCurrentWeek(), context, 'Week');
              },
              child: Container(
                height: 35,
                width: screenWidth * 0.15,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: selectedButton.value == 'Week'
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
  ScrollController? _scrollController; // Make nullable to avoid late initialization issues

  int getCurrentDateIndex(List<String> labels) {
    final now = DateTime.now();
    if (widget.selectedButton.value == 'Week') {
      return now.weekday % 7; // 0 for Sunday, 1 for Monday, etc.
    } else {
      return now.day - 1; // 0-based index for day of month
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
      ].expand((x) => x).reduce((value, element) => value > element ? value : element);
    }
    if (!maxYValue.isFinite || maxYValue == 0) {
      maxYValue = 1000.0;
    }
  }

  void _scrollToCurrentDate() {
    if (_scrollController?.hasClients == true) {
      int currentIndex = getCurrentDateIndex(widget.days.cast<String>());
      double labelWidth = widget.selectedButton.value == 'Week' ? 50.0 : 60.0;
      double scrollOffset = (currentIndex-4) * labelWidth;

      double maxScrollExtent = _scrollController!.position.maxScrollExtent;
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
    super.dispose();
  }

  ValueNotifier<bool> isTooltipVisible = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSizeFactor = screenWidth * 0.01;
    return getGraphLineScroll(fontSizeFactor, screenWidth);
  }

  Widget getGraphLineScroll(double fontSizeFactor, double screenWidth) {
    final creditedList = widget.chartData["credited"];
    final debitedList = widget.chartData["debited"];

    final bool hasNoData = (creditedList == null || creditedList.isEmpty || creditedList.every((e) => e == 0)) &&
        (debitedList == null || debitedList.isEmpty || debitedList.every((e) => e == 0));
    if (hasNoData) {
      return Container(
        color: AppColors.backgroundColor,
        height: MediaQuery.of(context).size.height / 2.6,
        child: Center(
          child: Text(
            'No spendings available',
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
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!widget.isExpandedView)
                Container(
                  
                  width: screenWidth * 0.09, // Fixed width to prevent overflow
                  height: MediaQuery.of(context).size.height / 2.6, // Match chart height
                  child: _buildYAxisLabels(fontSizeFactor),
                ),
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
                    url: Sign.maximise, // Verify this URI
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

    double labelWidth = widget.selectedButton.value == 'Week' ? 50.0 : 60.0;
    double chartWidth = dataLength * labelWidth;

    return Container(
     
      width: widget.selectedButton.value == 'Week'
          ? screenWidth * 0.85
          : max(chartWidth, screenWidth * 0.85),
      height: MediaQuery.of(context).size.height / 2.6,
      child: Transform.translate(
        offset: widget.selectedButton.value == 'Week'
            ? Offset(-20, 0)
            : widget.selectedButton.value == 'Month'
                ? Offset(-35, 0)
                : Offset(-25, 0),
        child: SfCartesianChart(
          borderWidth: 0,
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(
            labelStyle: FontManager().getTextStyle(context,
                lWeight: FontWeight.w500,
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
            maximum: maxYValue * 1.2,
          ),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
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
          series: <ChartSeries>[
            SplineAreaSeries<ChartData, String>(
              dataSource: creditedData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              color: AppColors.primaryColor.withOpacity(0.2),
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
              onPointTap: (ChartPointDetails details) {},
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
              onPointTap: (ChartPointDetails details) {},
            ),
            SplineAreaSeries<ChartData, String>(
              dataSource: debitedData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              color: AppColors.accentColor.withOpacity(0.2),
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
    isLoadingMore.value=false;
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
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '₹${formatNumberString(value.toStringAsFixed(0))}',
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.normal,
                fontSize: fontSizeFactor * 3.0,
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
      return numValue.toStringAsFixed(0);
    }
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}