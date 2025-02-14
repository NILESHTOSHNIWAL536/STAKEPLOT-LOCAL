// import 'package:flutter/material.dart';
// import 'dart:math';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter_application_code_stakeplot/Constants/customButton.dart';
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

// class FinancePage extends StatefulWidget {
//   const FinancePage({super.key});

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
//       getAutoMationsTransactionsCustom(getFormattedDate(), context);
//     } else if (selectedButton.value == "Week") {
//       getAutoMationsTransactionsCustom(getCurrentWeek(), context, 'Week');
//     } else {
//       getAutoMationsTransactionsCustom(getFormattedDate(), context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Get screen width to make the UI responsive
//     double screenWidth = MediaQuery.of(context).size.width;
//     double fontSizeFactor = screenWidth * 0.01;

//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       body:Obx(()=> !getGraphData.value? Center(child: Spinner()):Padding(
//          padding: EdgeInsets.all(0), // Responsive padding
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//                       'Weekly spending and cash flow',
//                       style: FontManager().getTextStyle(context,
//                           lWeight: FontWeight.w500,
//                           fontSize: fontSizeFactor * 4.5,
//                           color: AppColors.accentColor),
//                     ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       '₹${totalSpent.toStringAsFixed(2)}',
//                       style: FontManager().getTextStyle(context,
//                           lWeight: FontWeight.bold,
//                           fontSize: fontSizeFactor * 4,
//                           color: AppColors.accentColor),
//                     ),
//                     SizedBox(width: screenWidth * 0.02),
//                     Text(
//                       'This week',
//                       style: FontManager().getTextStyle(context,
//                           lWeight: FontWeight.normal,
//                           fontSize: fontSizeFactor * 2.5,
//                           color: AppColors.accentColor),
//                     ),
//                   ],
//                 ),
//                 CustomButton(
//               onTap: () {},
//               text: 'History',
//               fontSize: fontSizeFactor * 2.8,
//               height: 1.7,
//               width: 5.0,
//               icon: AvatarProfileImage(
//                   url: HomePageIcons.history,
//                   width: 36,
//                   height:
//                       36), // Optional; remove this line if you don't want an icon
//             ),
//               ],
//             ),

//             getMonthWeekCustom(fontSizeFactor, screenWidth),
//             LineChartWidget(chartData: transactionChatGraph, days: labels, selectedButton: selectedButton)
//           ],
//         ),
//       )
//       )
//       );
//   }

//   Widget getMonthWeekCustom(fontSizeFactor, screenWidth) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           'My Spendings',
//           style: FontManager().getTextStyle(context,
//               lWeight: FontWeight.normal,
//               fontSize: fontSizeFactor * 3.4,
//               color: AppColors.bg1),
//         ),
//         Row(
//           children: [
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

//                  selectedButton.value='Week';
//                  getGraphData.value = false;
//                 getAutoMationsTransactionsCustom(
//                     getCurrentWeek(), context, 'Week');

//                 // selectedButton.value = 'Week';
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
//   LineChartWidget({
//     super.key,
//     required this.chartData,
//     required this.days,
//     required this.selectedButton,
//   });

//   final Map<String, List<double>> chartData;
//   final List days;
//   final RxString selectedButton;
//   @override
//   State<LineChartWidget> createState() => _LineChartWidgetState();
// }

// class _LineChartWidgetState extends State<LineChartWidget> {
//   List<double> yAxisLabels = [];

//   @override
//   void initState() {
//     super.initState();
//   }

//   // Change to List
//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     double fontSizeFactor = screenWidth * 0.01;
//     double chartHeight = screenHeight * 0.1;

//     return graphTransaction.value
//         ? getGraphLineScroll(fontSizeFactor, chartHeight, screenWidth)
//         : getGraphLineScroll(fontSizeFactor, chartHeight, screenWidth);
//   }

//   Widget getGraphLineScroll(fontSizeFactor, chartHeight, screenWidth) {
//     return Container(
//       child: selectedButton.value != 'Week'
//           ? SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: getContainerOfGraph(
//                 screenWidth,
//                 fontSizeFactor,
//               ))
//           : Container(
//               child: getContainerOfGraph(
//                 screenWidth,
//                 fontSizeFactor,
//               ),
//             ),
//     );
//   }

//   Widget getContainerOfGraph(
//     screenWidth,
//     fontSizeFactor,
//   ) {
//     return SizedBox(
//       width: screenWidth * 2,
//       height: MediaQuery.of(context).size.height / 2.6,
//       child: GestureDetector(
//         onPanUpdate: (details) {
//           // Detect hover over points if required for further enhancements.
//         },
//         child: LineChart(
//           LineChartData(
//             gridData: FlGridData(
//               show: false,
//             ),
//             titlesData: FlTitlesData(
//               bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   interval: 1,
//                   // reservedSize: /,

//                   getTitlesWidget: (value, meta) {
//                     if (value.toInt() < labels.length) {
//                       return Text(
//                         labels[value.toInt()],
//                         style: FontManager().getTextStyle(context,
//                             lWeight: FontWeight.bold,
//                             fontSize: fontSizeFactor * 3.5,
//                             color: AppColors.accentColor),
//                       );
//                     }
//                     return SizedBox.shrink();
//                   },
//                 ),
//               ),
//               rightTitles:
//                   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//               topTitles:
//                   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//               leftTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,

//                   reservedSize: screenWidth * 0.22,
//                   // interval: maxYValue.value, // For 5 labels (4 intervals + 0 at the bottom)
//                   getTitlesWidget: (value, meta) {
//                     return Text(
//                       '₹${formatNumberString(value.toString())}',
//                       style: FontManager().getTextStyle(context,
//                           lWeight: FontWeight.normal,
//                           fontSize: fontSizeFactor * 3.3,
//                           color: AppColors.accentColor),
//                     );
//                   },
//                 ),
//               ),
//             ),
//             borderData: FlBorderData(
//               show: false,
//             ),
//             minY: 0,
//             maxY: maxYValue.value*1.2,
//             lineBarsData: [
//               linechart(transactionChatGraph["credited"]!),
//               linechart(transactionChatGraph["debited"]!),
//             ],
//             lineTouchData: LineTouchData(
//               touchTooltipData: LineTouchTooltipData(
//                 tooltipRoundedRadius: 1,
//                 tooltipPadding: const EdgeInsets.all(8),
//                 getTooltipItems: (touchedSpots) {
//                   return touchedSpots.map((touchedSpot) {
//                     String label =
//                         touchedSpot.bar.color == AppColors.primaryColor
//                             ? 'Credited'
//                             : 'Debited';
//                     return LineTooltipItem(
//                       '$label: ₹${touchedSpot.y.toStringAsFixed(2)}',
//                       FontManager().getTextStyle(context,
//                           lWeight: FontWeight.normal,
//                           fontSize: fontSizeFactor * 2.5,
//                           color: AppColors.accentColor),
//                     );
//                   }).toList();
//                 },
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   String formatNumberString(String value) {
//     // Convert string to double
//     double numValue = double.tryParse(value) ?? 0;

//     if (numValue >= 10000000) {
//       return '${(numValue / 10000000).toStringAsFixed(2)} Cr'; // Crores
//     } else if (numValue >= 100000) {
//       return '${(numValue / 100000).toStringAsFixed(2)} L'; // Lakhs
//     } else if (numValue >= 1000) {
//       return '${(numValue / 1000).toStringAsFixed(2)} K'; // Thousands
//     } else {
//       return value; // Return original string if less than 1000
//     }
//   }

//   LineChartBarData linechart(List<double> list) {
//     return LineChartBarData(
//       isCurved: true,
//       color: AppColors.accentColor,
//       barWidth: 1,
//       dotData: FlDotData(show: false),
//       belowBarData:
//           BarAreaData(show: false, color: Colors.red.withOpacity(0.2)),
//       spots: List.generate(
//         list.length,
//         (index) => FlSpot(index.toDouble(), list[index]),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_code_stakeplot/Constants/customButton.dart';
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

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  @override
  void initState() {
    super.initState();
    getGraphData.value = false;
    calledFunctionToFetchData();
  }

  void calledFunctionToFetchData() {
    if (selectedButton.value == "Month") {
      getAutoMationsTransactionsCustom(getFormattedDate(), context);
    } else if (selectedButton.value == "Week") {
      getAutoMationsTransactionsCustom(getCurrentWeek(), context, 'Week');
    } else {
      getAutoMationsTransactionsCustom(getFormattedDate(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width to make the UI responsive
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSizeFactor = screenWidth * 0.01;

    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Obx(() => !getGraphData.value
            ? Center(child: Spinner())
            : Padding(
                padding: EdgeInsets.all(0), // Responsive padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly spending and cash flow',
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w500,
                          fontSize: fontSizeFactor * 4.5,
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
                          onTap: () {},
                          text: 'History',
                          fontSize: fontSizeFactor * 2.8,
                          height: 1.7,
                          width: 5.0,
                          icon: AvatarProfileImage(
                              url: HomePageIcons.history,
                              width: 36,
                              height:
                                  36), // Optional; remove this line if you don't want an icon
                        ),
                      ],
                    ),
                    getMonthWeekCustom(fontSizeFactor, screenWidth),
                    //SizedBox(height: screenWidth * 0.04),
                    Expanded(
                      child: LineChartWidget(
                          chartData: transactionChatGraph,
                          days: labels,
                          selectedButton: selectedButton),
                    )
                  ],
                ),
              )));
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

                // selectedButton.value = 'Week';
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
  const LineChartWidget({
    super.key,
    required this.chartData,
    required this.days,
    required this.selectedButton,
  });

  final Map<String, List<double>> chartData;
  final List days;
  final RxString selectedButton;
  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
 // List<double> yAxisLabels = [];
   double maxYValue = 0.0;
  List<double> yAxisLabels = [];

  @override
  void initState() {
    super.initState();
    _calculateMaxYValueAndLabels();
  }
   void didUpdateWidget(LineChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chartData != widget.chartData) {
      _calculateMaxYValueAndLabels();
    }
  }

  void _calculateMaxYValueAndLabels() {
    setState(() {
      if (widget.chartData["credited"]!.isNotEmpty || widget.chartData["debited"]!.isNotEmpty) {
        maxYValue = [
          widget.chartData["credited"]!,
          widget.chartData["debited"]!
        ]
            .expand((x) => x)
            .reduce((value, element) => value > element ? value : element);
      }
      if (!maxYValue.isFinite) {
        maxYValue = 1000.0; // or any other reasonable default
      }
      yAxisLabels = List.generate(5, (index) => index * (maxYValue / 4));
    });
  }

  // Change to List
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSizeFactor = screenWidth * 0.01;
    double chartHeight = screenHeight * 0.5;

    return graphTransaction.value
        ? getGraphLineScroll(fontSizeFactor, chartHeight, screenWidth)
        : getGraphLineScroll(fontSizeFactor, chartHeight, screenWidth);
  }

  Widget getGraphLineScroll(fontSizeFactor, chartHeight, screenWidth) {
    return Container(
      child: selectedButton.value != 'Week'
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: getContainerOfGraph(
                screenWidth,
                fontSizeFactor,
              ))
          : Container(
              child: getContainerOfGraph(
                screenWidth,
                fontSizeFactor,
              ),
            ),
    );
  }

  Widget getContainerOfGraph(
    screenWidth,
    fontSizeFactor,
  ) {
    return Row(
      //mainAxisAlignment: Main,
      children: [
        // Padding(
        //   padding: const EdgeInsets.only(bottom: 12),
        //   child: Container(
        //     width: screenWidth * 0.12, // Adjusted width to ensure visibility
        //     height: MediaQuery.of(context).size.height * 0.5,
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: yAxisLabels.reversed.map((label) {
        //         return Text(
        //           '₹${formatNumberString(label.toStringAsFixed(1))}',
        //           style: FontManager().getTextStyle(context,
        //               lWeight: FontWeight.normal,
        //               fontSize: fontSizeFactor * 3,
        //               color: AppColors.accentColor),
        //           textAlign: TextAlign.left,
        //         );
        //       }).toList(),
        //     ),
        //   ),
        // ),
        SizedBox(
          width: selectedButton.value == 'Week'?screenWidth * 0.88:screenWidth * 2,
          height: MediaQuery.of(context).size.height / 2.06,
          child: GestureDetector(
            onPanUpdate: (details) {
              // Detect hover over points if required for further enhancements.
            },
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: false,
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < widget.days.length) {
                            return Text(
                              widget.days[value.toInt()],
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.normal,
                                  fontSize: fontSizeFactor * 3,
                                  color: AppColors.accentColor),
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ),
                  rightTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
        
                      reservedSize: screenWidth * 0.14,
                      interval: maxYValue /
                          4, // For 5 labels (4 intervals + 0 at the bottom)
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₹${formatNumberString(value.toString())}',
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.normal,
                              fontSize: fontSizeFactor * 3.0,
                              color: AppColors.accentColor),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minY: 0,
                 maxY: maxYValue * 1.2,
                lineBarsData: [
                  linechart(transactionChatGraph["credited"]!, AppColors.primaryColor),
              linechart(transactionChatGraph["debited"]!, AppColors.accentColor),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 1,
                    tooltipPadding: const EdgeInsets.all(8),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        String label =
                            touchedSpot.bar.color == AppColors.primaryColor
                                ? 'Credited'
                                : 'Debited';
                        return LineTooltipItem(
                          '$label: ₹${touchedSpot.y.toStringAsFixed(2)}',
                          FontManager().getTextStyle(context,
                              lWeight: FontWeight.normal,
                              fontSize: fontSizeFactor * 2.5,
                              color: AppColors.accentColor),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String formatNumberString(String value) {
    // Convert string to double
    double numValue = double.tryParse(value) ?? 0;

    if (numValue >= 10000000) {
      return '${(numValue / 10000000).toStringAsFixed(2)} Cr'; // Crores
    } else if (numValue >= 100000) {
      return '${(numValue / 100000).toStringAsFixed(2)} L'; // Lakhs
    } else if (numValue >= 1000) {
      return '${(numValue / 1000).toStringAsFixed(2)} K'; // Thousands
    } else {
      return value; // Return original string if less than 1000
    }
  }

  LineChartBarData linechart(List<double> list, Color color) {
    return LineChartBarData(
      isCurved: true,
      color: color,
      barWidth: 1,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false, color: Colors.red.withOpacity(0.2)),
      // Ensure the first and last points are within the chart area
      spots: List.generate(
        list.length,
        (index) => FlSpot(index.toDouble(), list[index].clamp(0, maxYValue * 1.2)),
      ),
    );
  }
}
