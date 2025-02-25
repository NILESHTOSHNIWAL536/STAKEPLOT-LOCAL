// import 'package:flutter/material.dart';
// import 'dart:math';
// import 'package:flutter_application_code_stakeplot/Constants/customButton.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/expanded_finance.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';
// import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
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
//     calledFunctionToFetchData();
//   }

//   void calledFunctionToFetchData() {
//     if (selectedButton.value == "Month") {
     
//       //print(totalCredited);
//       getAutoMationsTransactionsCustom(getFormattedDate(), context);
//       _calculateTotalSpent();
//       //print("ssuming transactionChatGraph is your data map");
//       //print(totalCredited);
//     } else if (selectedButton.value == "Week") {
//       getAutoMationsTransactionsCustom(getCurrentWeek(), context, 'Week');
//       _calculateTotalSpent();
//     } else {
//       getAutoMationsTransactionsCustom(getFormattedDate(), context);
//       _calculateTotalSpent();
//     }
//   }

//   void _scrollToTransactionHistory() {
//   final RenderObject? renderObject =
//       widget.transactionHistoryKey.currentContext?.findRenderObject();
//   if (renderObject != null && renderObject is RenderBox) {
//     final position = renderObject.localToGlobal(Offset.zero);
//     final scrollOffset = widget.scrollController.offset;
//     final targetOffset = position.dy - scrollOffset;
//     print("Target offset: $targetOffset");
//     widget.scrollController.animateTo(
//       targetOffset > 0 ? targetOffset : 0,
//       duration: Duration(milliseconds: 500),
//       curve: Curves.easeInOut,
//     );
//   } else {
//     print("RenderObject not found for TransactionHistory");
//   }
// }

//   int _getDaysInCurrentMonth() {
//     final now = DateTime.now();
//     return DateTime(now.year, now.month + 1, 0).day;
//   }

//   void _calculateTotalSpent() {
//     // Assuming transactionChatGraph is your data map
//     if (transactionChatGraph.containsKey('credited') &&
//         transactionChatGraph.containsKey('debited')) {
//       List<double> credited = transactionChatGraph['credited'] ?? [];
//       List<double> debited = transactionChatGraph['debited'] ?? [];

//       // Calculate the sum of credited and debited amounts
//       double totalCredited = credited.fold(0.0, (sum, item) => sum + item);
//       double totalDebited = debited.fold(0.0, (sum, item) => sum + item);
    

//       // Total spent is the difference between credited and debited
//       setState(() {
//         totalSpent = totalCredited - totalDebited;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double fontSizeFactor = screenWidth * 0.01;

//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       body: Obx(() => !getGraphData.value
//           ? Center(child: Spinner())
//           : Padding(
//               padding: EdgeInsets.all(0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//                   Text(
//                     'Weekly spending and cash flow',
//                 style: FontManager().getTextStyle(context,
//                         lWeight: FontWeight.w300,
//                         fontSize: fontSizeFactor * 4.0,
//                         color: AppColors.accentColor),
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//             Row(
//               children: [
//                 Text(
//                   '₹${totalSpent.toStringAsFixed(2)}',
//                   style: FontManager().getTextStyle(context,
//                       lWeight: FontWeight.bold,
//                                 fontSize: fontSizeFactor * 4,
//                       color: AppColors.accentColor),
//                 ),
//                 SizedBox(width: screenWidth * 0.02),
//                 Text(
//                   'This week',
//                   style: FontManager().getTextStyle(context,
//                       lWeight: FontWeight.normal,
//                                 fontSize: fontSizeFactor * 2.5,
//                       color: AppColors.accentColor),
//                 ),
//                         ],
//                       ),
//                       CustomButton(
//                         onTap: () {
//                           print("History button tapped");
//                           _scrollToTransactionHistory();
//                         },
//                         text: 'History',
//                         fontSize: fontSizeFactor * 2.8,
//                         height: 1.7,
//                         width: 5.0,
//                         icon: AvatarProfileImage(
//                           url: HomePageIcons.history,
//                           width: 36,
//                           height: 36,
//                         ),
//                       ),
//                     ],
//                   ),
//                   getMonthWeekCustom(fontSizeFactor, screenWidth),
//                   LineChartWidget(
//                     chartData: transactionChatGraph,
//                     days: labels,
//                     selectedButton: selectedButton,
//                     daysInMonth: selectedButton == "Week"
//                         ? 7
//                         : selectedButton == "Month"
//                             ? _getDaysInCurrentMonth()
//                             : labels.length,
//                 ),
//               ],
//             ),
//             )),
//     );
//   }

//   Widget getMonthWeekCustom(fontSizeFactor, screenWidth) {
//     return Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'My Spendings',
//                   style: FontManager().getTextStyle(context,
//                       lWeight: FontWeight.normal,
//               fontSize: fontSizeFactor * 3.4,
//               color: AppColors.bg1),
//                 ),
//                 Row(
//                   children: [
//             GestureDetector(
//               onTap: () {
//                 getGraphData.value = false;
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
//                       child: Text(
//                         'Month',
//                         style: FontManager().getTextStyle(context,
//                             lWeight: FontWeight.normal,
//                         fontSize: fontSizeFactor * 3.4,
//                             color: AppColors.accentColor),
//                   ),
//                 ),
//                       ),
//                     ),
//                     SizedBox(width: screenWidth * 0.02),
//             GestureDetector(
//               onTap: () {
//                 selectedButton.value = 'Week';
//                 getGraphData.value = false;
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
//                       child: Text(
//                         'Week',
//                         style: FontManager().getTextStyle(context,
//                             lWeight: FontWeight.normal,
//                         fontSize: fontSizeFactor * 3.4,
//                             color: AppColors.accentColor),
//                   ),
//                 ),
//                       ),
//                     ),
//                     SizedBox(width: screenWidth * 0.02),
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
//                       child: Text(
//                         'Custom',
//                         style: FontManager().getTextStyle(context,
//                             lWeight: FontWeight.normal,
//                         fontSize: fontSizeFactor * 3.4,
//                             color: AppColors.accentColor),
//                       ),
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

//   const LineChartWidget({
//     super.key,
//     required this.chartData,
//     required this.days,
//     required this.selectedButton,
//     required this.daysInMonth,
//     this.isExpandedView = false,
//   });

//   @override
//   State<LineChartWidget> createState() => _LineChartWidgetState();
// }

// class _LineChartWidgetState extends State<LineChartWidget> {
//   late double maxYValue;

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

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double fontSizeFactor = screenWidth * 0.01;

//     return getGraphLineScroll(fontSizeFactor, screenWidth);
//   }

//   Widget getGraphLineScroll(double fontSizeFactor, double screenWidth) {
//     return Container(
//       height: MediaQuery.of(context).size.height / 2.6,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           // Fixed Y-axis labels
//           if (!widget.isExpandedView)
//             Container(
//               width: screenWidth * 0.15,
//               child: _buildYAxisLabels(fontSizeFactor),
//             ),
//           // Scrollable chart area
//           Expanded(
//             child: widget.selectedButton.value != 'Week'
//                 ? SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: getContainerOfGraph(screenWidth, fontSizeFactor),
//                   )
//                 : getContainerOfGraph(screenWidth, fontSizeFactor),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget getContainerOfGraph(double screenWidth, double fontSizeFactor) {
//     // List<ChartData> creditedData = widget.chartData["credited"]!
//     //     .asMap()
//     //     .entries
//     //     .map((entry) => ChartData(widget.days[entry.key], entry.value))
//     //     .toList();
//     //     print("..........................................");
//     // print(creditedData.toList());
//     // List<ChartData> debitedData = widget.chartData["debited"]!
//     //     .asMap()
//     //     .entries
//     //     .map((entry) => ChartData(widget.days[entry.key], entry.value))
//     //     .toList();
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

//     print("..........................................");
//     print("Labels: $labels");
//     print(creditedData);
//     print(debitedData);
//  double labelWidth = widget.selectedButton.value == 'Week' ? 50.0 : 40.0;
//     double chartWidth = dataLength * labelWidth;
//     return GestureDetector(
//       // Handle taps outside the chart lines

//       behavior: HitTestBehavior.opaque,
//       onTap: () {
//         if (widget.selectedButton.value == 'Month') {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ExpandedChartView(
//                 chartData: widget.chartData,
//                 days: widget.days,
//                 selectedButton: widget.selectedButton.value,
//                 selectedYear: DateTime.now().year,
//                 selectedMonth: DateTime.now().month,
//               ),
//             ),
//           );
//         }
//       },
//       child: SizedBox(
//          // width: screenWidth * (widget.selectedButton.value == 'Week' ? 1 : 2),
//           width: widget.selectedButton.value == 'Week'
//             ? screenWidth * 0.85 // Fixed width for Week
//             : max(chartWidth, screenWidth * 0.85), 
//           height: MediaQuery.of(context).size.height / 2.6,
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
//               interval: 1,
//                  labelRotation: widget.selectedButton.value == 'Week' ? 0 : -45,
//             edgeLabelPlacement: EdgeLabelPlacement.shift,
//             maximumLabels: dataLength, // Ensure all labels are considered
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
//               labelFormat: '₹{value}',
//               minimum: 0,
//               maximum: maxYValue * 1.2,
//             ),
//             tooltipBehavior: TooltipBehavior(
//               enable: true,
//               builder: (dynamic data, dynamic point, dynamic series,
//                   int pointIndex, int seriesIndex) {
//                 final ChartData chartData = data as ChartData;
//                 String label = seriesIndex == 0 ? 'Debited' : 'Credited';
//                 return GestureDetector(
//                   behavior: HitTestBehavior.opaque,
//                   onTap: () {
//                     // Use a slight delay to ensure point taps are processed first
//                     if (widget.selectedButton.value == 'Month') {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ExpandedChartView(
//                             chartData: widget.chartData,
//                             days: widget.days,
//                             selectedButton: widget.selectedButton.value,
//                             selectedYear: DateTime.now().year,
//                             selectedMonth: DateTime.now().month,
//                           ),
//                         ),
//                       );
//                     }
//       },
//       child: Container(
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
//                     );
//                   },
//                 ),
//             series: <ChartSeries>[
//               SplineSeries<ChartData, String>(
//                 dataSource: creditedData,
//                 xValueMapper: (ChartData data, _) => data.x,
//                 yValueMapper: (ChartData data, _) => data.y,
//                 color: AppColors.accentColor,
//                 width: 2, // Increased line width for better visibility
//                 enableTooltip: true,
//                 name: 'Debited',
//                 splineType: SplineType.cardinal, // Makes the curve smoother
//                 cardinalSplineTension: 0.5, // Adjust curve tension (0-1)
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
//                 color: AppColors.primaryColor,
//                 width: 2,
//                 enableTooltip: true,
//                 name: 'Credited',
//                 splineType: SplineType.cardinal,
//                 cardinalSplineTension: 0.5,
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
//             ],
//             legend: Legend(
//               isVisible: false,
//               position: LegendPosition.top,
//               textStyle: FontManager().getTextStyle(context,
//                             lWeight: FontWeight.normal,
//                   fontSize: fontSizeFactor * 3,
//                             color: AppColors.accentColor),
//             ),
//           )),
//     );
//   }

//   bool isTapOnLine(Offset tapPosition) {
//     // Implement your logic here
//     return false; // Placeholder return value
//   }

//   Widget _buildYAxisLabels(double fontSizeFactor) {
//     // Calculate intervals for Y-axis labels

//     final double interval = maxYValue * 1.2 / 4; // For 5 labels
//     List<Widget> labels = [];

//     for (int i = 0; i <= 4; i++) {
//       double value = interval * i;
//       labels.add(
//         Expanded(
//           child: Align(
//             alignment: Alignment.centerRight,
//             child: Text(
//               '₹${formatNumberString(value.toString())}',
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
//       children:
//           labels.reversed.toList(), // Reverse to have highest value at top
//     );
//   }

//   String formatNumberString(String value) {
//     double numValue = double.tryParse(value) ?? 0;
//     if (numValue >= 10000000) {
//       return '${(numValue / 10000000).toStringAsFixed(2)} Cr';
//     } else if (numValue >= 100000) {
//       return '${(numValue / 100000).toStringAsFixed(2)} L';
//     } else if (numValue >= 1000) {
//       return '${(numValue / 1000).toStringAsFixed(2)} K';
//     } else {
//       return value;
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
   RxBool isLoading = true.obs;
  @override
  void initState() {
    super.initState();

    getGraphData.value = false;
    calledFunctionToFetchData();
  }

  Future<void> calledFunctionToFetchData() async {
    isLoading.value = true;
    if (selectedButton.value == "Month") {
      labels = List.generate(_getDaysInCurrentMonth(), (i) => (i + 1).toString().padLeft(2, '0'));
      await getAutoMationsTransactionsCustom(getFormattedDate(), context);
    } else if (selectedButton.value == "Week") {
      labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      await getAutoMationsTransactionsCustom(getCurrentWeek(), context, 'Week');
    } else {
      labels = List.generate(_getDaysInCurrentMonth(), (i) => (i + 1).toString().padLeft(2, '0'));
      await getAutoMationsTransactionsCustom(getFormattedDate(), context);
    }
    _calculateTotalSpent();
    isLoading.value = false;
  }

  void _scrollToTransactionHistory() {
  final RenderObject? renderObject =
      widget.transactionHistoryKey.currentContext?.findRenderObject();
  if (renderObject != null && renderObject is RenderBox) {
    final position = renderObject.localToGlobal(Offset.zero);
    final scrollOffset = widget.scrollController.offset;
    final targetOffset = position.dy - scrollOffset;
    print("Target offset: $targetOffset");
    widget.scrollController.animateTo(
      targetOffset > 0 ? targetOffset : 0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  } else {
    print("RenderObject not found for TransactionHistory");
  }
}

  int _getDaysInCurrentMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0).day;
  }

  void _calculateTotalSpent() {
    List<double> credited = transactionChatGraph['credited'] ?? [];
    List<double> debited = transactionChatGraph['debited'] ?? [];
    double totalCredited = credited.fold(0.0, (sum, item) => sum + item);
    double totalDebited = debited.fold(0.0, (sum, item) => sum + item);
    setState(() {
      totalSpent = totalCredited - totalDebited;
    });
  }
Future<void> pickCustomDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      isLoading.value = true;
      selectedButton.value = 'Custom';
      List<String> customDays = [];
      for (int i = 0; i <= picked.end.difference(picked.start).inDays; i++) {
        DateTime date = picked.start.add(Duration(days: i));
        customDays.add(date.day.toString().padLeft(2, '0'));
      }
      labels = customDays; // Set labels before API call
      print("Custom days set: $customDays");
      
      await getAutoMationsTransactionsCustom(picked.start.toString(), context, 'Custom');
      _calculateTotalSpent();
      isLoading.value = false;
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSizeFactor = screenWidth * 0.01;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Obx(() => !getGraphData.value
          ? Center(child: Spinner())
          : Padding(
              padding: EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  Text(
                    'Weekly spending and cash flow',
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
                Text(
                  '₹${totalSpent.toStringAsFixed(2)}',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.bold,
                                fontSize: fontSizeFactor * 4,
                      color: AppColors.accentColor),
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  'This week',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.normal,
                                fontSize: fontSizeFactor * 2.5,
                      color: AppColors.accentColor),
                ),
                        ],
                      ),
                      CustomButton(
                        onTap: () {
                          print("History button tapped");
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
                  getMonthWeekCustom(fontSizeFactor, screenWidth),
                  LineChartWidget(
                    chartData: transactionChatGraph,
                    days: labels,
                    selectedButton: selectedButton,
                    daysInMonth: labels.length,
                ),
              ],
            ),
            )),
    );
  }

  Widget getMonthWeekCustom(fontSizeFactor, screenWidth) {
    return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Spendings',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.normal,
              fontSize: fontSizeFactor * 3.4,
              color: AppColors.bg1),
                ),
                Row(
                  children: [
            GestureDetector(
              onTap: () {
                getGraphData.value = false;
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
                getGraphData.value = false;
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
  double maxYValue = 1000.0; 
  final Map<String, List<double>> chartData;
  final List days;
  final RxString selectedButton;
  final int daysInMonth;
  final bool isExpandedView;

   LineChartWidget({
    super.key,
    required this.chartData,
    required this.days,
    required this.selectedButton,
    required this.daysInMonth,
    this.isExpandedView = false,
  });

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  

  @override
  void initState() {
    super.initState();
    _calculateMaxYValue();
  }

  @override
  void didUpdateWidget(LineChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chartData != widget.chartData) {
      _calculateMaxYValue();
    }
  }

 void _calculateMaxYValue() {
    if (widget.chartData["credited"]?.isNotEmpty == true || widget.chartData["debited"]?.isNotEmpty == true) {
      maxYValue = [
        widget.chartData["credited"] ?? [],
        widget.chartData["debited"] ?? []
      ].expand((x) => x).reduce(max).obs;
    } else {
      maxYValue = 1000.0.obs;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSizeFactor = screenWidth * 0.01;

    return getGraphLineScroll(fontSizeFactor, screenWidth);
  }

  Widget getGraphLineScroll(double fontSizeFactor, double screenWidth) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSizeFactor = screenWidth * 0.01;
     if (widget.days.isEmpty || widget.chartData.isEmpty) {
      return Center(child: Text("No data available"));
    }
    return Container(
      height: MediaQuery.of(context).size.height / 2.6,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fixed Y-axis labels
          if (!widget.isExpandedView)
            Container(
              width: screenWidth * 0.15,
              child: _buildYAxisLabels(fontSizeFactor),
            ),
          // Scrollable chart area
          Expanded(
            child: widget.selectedButton.value != 'Week'
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
    // List<ChartData> creditedData = widget.chartData["credited"]!
    //     .asMap()
    //     .entries
    //     .map((entry) => ChartData(widget.days[entry.key], entry.value))
    //     .toList();
    //     print("..........................................");
    // print(creditedData.toList());
    // List<ChartData> debitedData = widget.chartData["debited"]!
    //     .asMap()
    //     .entries
    //     .map((entry) => ChartData(widget.days[entry.key], entry.value))
    //     .toList();
   int dataLength = widget.daysInMonth;
   List<String> labels = List.from(widget.days);

    if (labels.length < dataLength) {
      labels.addAll(List.generate(dataLength - labels.length, (i) => (labels.length + i + 1).toString().padLeft(2, '0')));
    } else if (labels.length > dataLength) {
      labels = labels.sublist(0, dataLength);
    }

    if (widget.selectedButton.value == 'Week') {
      dataLength = 7; 
      labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    } 
   List<ChartData> creditedData = List.generate(dataLength, (index) {
      double value = widget.chartData["credited"]?.length != null && index < widget.chartData["credited"]!.length
          ? widget.chartData["credited"]![index]
          : 0.0;
      return ChartData(labels[index], value);
    });

    List<ChartData> debitedData = List.generate(dataLength, (index) {
      double value = widget.chartData["debited"]?.length != null && index < widget.chartData["debited"]!.length
          ? widget.chartData["debited"]![index]
          : 0.0;
      return ChartData(labels[index], value);
    });

    print("Labels: $labels");
    print("Credited Data: $creditedData");
    print("Debited Data: $debitedData");

    
 double labelWidth = widget.selectedButton.value == 'Week' ? 50.0 : 40.0;
    double chartWidth = dataLength * labelWidth;
    return GestureDetector(
      // Handle taps outside the chart lines

      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (widget.selectedButton.value == 'Month') {
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
      },
      child: SizedBox(
         // width: screenWidth * (widget.selectedButton.value == 'Week' ? 1 : 2),
          width: widget.selectedButton.value == 'Week'
            ? screenWidth * 0.85 // Fixed width for Week
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
              minorGridLines:
                  MinorGridLines(width: 0), // Ensure no minor grid lines
              axisLine: AxisLine(width: 0),
              interval: 1,
                 labelRotation: widget.selectedButton.value == 'Week' ? 0 : -45,
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            maximumLabels: dataLength, // Ensure all labels are considered
            ),
            primaryYAxis: NumericAxis(
              isVisible: false,
              labelStyle: FontManager().getTextStyle(context,
                  lWeight: FontWeight.normal,
                  fontSize: fontSizeFactor * 3.3,
                  color: AppColors.accentColor),
              majorGridLines: MajorGridLines(width: 0),
              minorGridLines:
                  MinorGridLines(width: 0), // Ensure no minor grid lines
              axisLine: AxisLine(width: 0),
              labelFormat: '₹{value}',
              minimum: 0,
              maximum: maxYValue * 1.2,
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              builder: (dynamic data, dynamic point, dynamic series,
                  int pointIndex, int seriesIndex) {
                final ChartData chartData = data as ChartData;
                String label = seriesIndex == 0 ? 'Debited' : 'Credited';
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    // Use a slight delay to ensure point taps are processed first
                    if (widget.selectedButton.value == 'Month') {
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
      },
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
              SplineSeries<ChartData, String>(
                dataSource: creditedData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                color: AppColors.accentColor,
                width: 2, // Increased line width for better visibility
                enableTooltip: true,
                name: 'Debited',
                splineType: SplineType.cardinal, // Makes the curve smoother
                cardinalSplineTension: 0.5, // Adjust curve tension (0-1)
                markerSettings: MarkerSettings(
                  isVisible: false,
                  height: 4,
                  width: 4,
                  shape: DataMarkerType.pentagon,
                ),
                onPointTap: (ChartPointDetails details) {
                  // Handle point tap here
                },
              ),
              SplineSeries<ChartData, String>(
                dataSource: debitedData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                color: AppColors.primaryColor,
                width: 2,
                enableTooltip: true,
                name: 'Credited',
                splineType: SplineType.cardinal,
                cardinalSplineTension: 0.5,
                markerSettings: MarkerSettings(
                  isVisible: false,
                  height: 4,
                  width: 4,
                  shape: DataMarkerType.circle,
                ),
                onPointTap: (ChartPointDetails details) {
                  // Handle point tap here
                },
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
          )),
    );
  }

  bool isTapOnLine(Offset tapPosition) {
    // Implement your logic here
    return false; // Placeholder return value
  }

  Widget _buildYAxisLabels(double fontSizeFactor) {
    // Calculate intervals for Y-axis labels

    final double interval = maxYValue * 1.2 / 4; // For 5 labels
    List<Widget> labels = [];

    for (int i = 0; i <= 4; i++) {
      double value = interval * i;
      labels.add(
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
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
      children:
          labels.reversed.toList(), // Reverse to have highest value at top
    );
  }

  String formatNumberString(String value) {
    double numValue = double.tryParse(value) ?? 0;
    if (numValue >= 10000000) {
      return '${(numValue / 10000000).toStringAsFixed(2)} Cr';
    } else if (numValue >= 100000) {
      return '${(numValue / 100000).toStringAsFixed(2)} L';
    } else if (numValue >= 1000) {
      return '${(numValue / 1000).toStringAsFixed(2)} K';
    } else {
      return value;
    }
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}
