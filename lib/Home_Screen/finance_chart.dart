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
                    daysInMonth:30,
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
  final Map<String, List<double>> chartData;
  final List days;
  final RxString selectedButton;
  final int daysInMonth; 

  const LineChartWidget({
    super.key,
    required this.chartData,
    required this.days,
    required this.selectedButton,
    required this.daysInMonth,

    
  });

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  late double maxYValue;
   

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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSizeFactor = screenWidth * 0.01;

    return getGraphLineScroll(fontSizeFactor, screenWidth);
  }

  Widget getGraphLineScroll(double fontSizeFactor, double screenWidth) {
    return Container(
      height: MediaQuery.of(context).size.height / 2.6,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Fixed Y-axis labels
          Container(
            width: screenWidth * 0.15, // Fixed width for Y-axis labels
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

    // List<ChartData> debitedData = widget.chartData["debited"]!
    //     .asMap()
    //     .entries
    //     .map((entry) => ChartData(widget.days[entry.key], entry.value))
    //     .toList();
   int dataLength = widget.daysInMonth;
    
    // Ensure widget.days has enough elements, pad with empty strings if needed
    List<String> labels = List.from(widget.days);
    while (labels.length < dataLength) {
      labels.add((labels.length + 1).toString().padLeft(2, '0'));
    }
    // Trim excess labels if any
    labels = labels.sublist(0, dataLength);

    List<ChartData> creditedData = List.generate(dataLength, (index) {
      double value = 0.0;
      if (index < widget.chartData["credited"]!.length) {
        value = widget.chartData["credited"]![index];
      } else if (widget.chartData["credited"]!.length > 0) {
        // Handle case where data exists but is shorter than required
        value = 0.0;
      }
      return ChartData(labels[index], value);
    });

    List<ChartData> debitedData = List.generate(dataLength, (index) {
      double value = 0.0;
      if (index < widget.chartData["debited"]!.length) {
        value = widget.chartData["debited"]![index];
      } else if (widget.chartData["debited"]!.length > 0) {
        // Handle case where data exists but is shorter than required
        value = 0.0;
      }
      return ChartData(labels[index], value);
    });
    //bool isPointTapped = false;
    return GestureDetector(
      // Handle taps outside the chart lines

      behavior: HitTestBehavior.opaque,
                  onTap: () {
                    // Use a slight delay to ensure point taps are processed first
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
                  },
      child: SizedBox(
          width: screenWidth * (widget.selectedButton.value == 'Week' ? 1 : 2),
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
              //  labelRotation: -45,
              // edgeLabelPlacement: EdgeLabelPlacement.shift,
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

            // onChartTouchInteraction: (ChartTouchInteractionArgs args) {
            //   if (args.type == ChartInteractionType.tapUp) {
            //     // Check if the tap was on a data point
            //     bool isPointTapped = false;
            //     for (var series in args.series) {
            //       if (series != null && series.dataPoints != null) {
            //         for (var point in series.dataPoints) {
            //           if (point.isVisible &&
            //               point.region != null &&
            //               point.region!.contains(args.position)) {
            //             isPointTapped = true;
            //             break;
            //           }
            //         }
            //       }
            //       if (isPointTapped) break;
            //     }

            // //     // Navigate only if the tap was outside data points
            //     if (!isPointTapped) {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => ExpandedChartView(
            //             chartData: widget.chartData,
            //             days: widget.days,
            //             selectedButton: widget.selectedButton.value,
            //             selectedYear: DateTime.now().year,
            //             selectedMonth: DateTime.now().month,
            //           ),
            //         ),
            //       );
            //     }
            //   }
            //   return true;
            // },
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
