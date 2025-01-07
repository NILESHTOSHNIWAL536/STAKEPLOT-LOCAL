import 'package:flutter/material.dart';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';
import './colors.dart';

class FinanceChartApp extends StatelessWidget {
  const FinanceChartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const FinancePage(),
    );
  }
}

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  String selectedButton = 'Month'; // Default view is "Month"
  DateTimeRange? selectedDateRange; // Default view is "Month"
  int selectedDay = 1;
  int year = DateTime.now().year; // Current year
  int month =
      DateTime.now().month; // Default selected day for "Month" button (Day 1)
  Map<int, List<double>> creditedData = {};
  Map<int, List<double>> debitedData = {};

  @override
  void initState() {
    super.initState();
    updateData();
  }

  int getDaysInMonth(int year, int month) {
    if (month == 12) {
      return DateTime(year + 1, 1, 0).day;
    }
    return DateTime(year, month + 1, 0).day;
  }

  void updateData() {
    int daysInMonth = getDaysInMonth(year, month);

    setState(() {
      creditedData = {
        for (int i = 1; i <= daysInMonth; i++)
          i: List.generate(5, (j) => Random().nextInt(500).toDouble()),
      };

      debitedData = {
        for (int i = 1; i <= daysInMonth; i++)
          i: List.generate(5, (j) => Random().nextInt(400).toDouble()),
      };
    });
  }

  final Map<int, Map<String, double>> weekData = {
    for (int i = 0; i < 5; i++)
      i: {
        'Mon': Random().nextInt(500).toDouble(),
        'Tue': Random().nextInt(500).toDouble(),
        'Wed': Random().nextInt(500).toDouble(),
        'Thu': Random().nextInt(500).toDouble(),
        'Fri': Random().nextInt(500).toDouble(),
        'Sat': Random().nextInt(500).toDouble(),
        'Sun': Random().nextInt(500).toDouble(),
      },
  };

  double calculateTotal(Map<String, List<double>> data) {
    return data["credited"]!.reduce((a, b) => a + b) -
        data["debited"]!.reduce((a, b) => a + b);
  }

  Future<void> _pickCustomDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width *
                0.8, // Adjust width (80% of screen width)
            height: MediaQuery.of(context).size.height *
                0.6, // Adjust height (60% of screen height)
            child: child!,
          ),
        );
      },
    );
    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
        selectedButton = 'Custom';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<double>> chartData;
    List<String> labels;

    if (selectedButton == 'Week') {
      final currentWeek = weekData[0]!;
      chartData = {
        "credited": currentWeek.values.toList(),
        "debited": currentWeek.values
            .map((e) => e * 0.8)
            .toList(), // Debited is 80% of credited
      };
      labels = currentWeek.keys.toList();
    } else if (selectedButton == 'Month') {
      chartData = {
        "credited": List.generate(
            30, (index) => creditedData[index + 1]!.reduce((a, b) => a + b)),
        "debited": List.generate(
            30, (index) => debitedData[index + 1]!.reduce((a, b) => a + b)),
      };
      labels = List.generate(30, (index) => (index + 1).toString());
    } else if (selectedButton == 'Custom' && selectedDateRange != null) {
      final startDate = selectedDateRange!.start;
      final endDate = selectedDateRange!.end;

      // Filter data for the selected range
      chartData = {
        "credited": List.generate(
          endDate.difference(startDate).inDays + 1,
          (index) => creditedData[startDate.add(Duration(days: index)).day]!
              .reduce((a, b) => a + b),
        ),
        "debited": List.generate(
          endDate.difference(startDate).inDays + 1,
          (index) => debitedData[startDate.add(Duration(days: index)).day]!
              .reduce((a, b) => a + b),
        ),
      };

      // Generate labels for the selected date range
      labels = List.generate(
        endDate.difference(startDate).inDays + 1,
        (index) => (startDate.add(Duration(days: index))).day.toString(),
      );
    } else {
      // Default case
      chartData = {
        "credited": [],
        "debited": [],
      };
      labels = [];
    }

    double totalSpent = calculateTotal(chartData);

    // Get screen width to make the UI responsive
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSizeFactor = screenWidth * 0.01;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Spending and Cash flow',
              style: TextStyle(fontSize: fontSizeFactor * 3),
            ),
            Row(
              children: [
                Text(
                  '₹${totalSpent.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: fontSizeFactor * 3),
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  'This week',
                  style: TextStyle(fontSize: fontSizeFactor * 2),
                ),
                Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.timer_rounded),
                  label: Text(
                    'History',
                    style: TextStyle(fontSize: fontSizeFactor * 2),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Spendings',
                  style: TextStyle(
                      fontSize: fontSizeFactor * 2,
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedButton = 'Month';
                          selectedDay = 1;
                        });
                      },
                      child: Text(
                        'Month',
                        style: TextStyle(
                            color: AppColors.accentColor,
                            fontSize: fontSizeFactor * 2),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedButton = 'Week';
                        });
                      },
                      child: Text(
                        'Week',
                        style: TextStyle(
                            color: AppColors.accentColor,
                            fontSize: fontSizeFactor * 2),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    ElevatedButton(
                      onPressed: () {
                        _pickCustomDateRange(context);
                      },
                      child: Text(
                        'Custom',
                        style: TextStyle(
                            color: AppColors.accentColor,
                            fontSize: fontSizeFactor * 2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.05),
            Expanded(
              child: LineChartWidget(
                chartData: chartData,
                days: labels,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  const LineChartWidget({
    super.key,
    required this.chartData,
    required this.days,
  });

  final Map<String, List<double>> chartData;
  final List<String> days;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSizeFactor = screenWidth * 0.01;

    return GestureDetector(
      onPanUpdate: (details) {
        // Detect hover over points if required for further enhancements.
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04), // Responsive padding
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: screenWidth * 0.1, // Dynamic reserved size
                  interval: 500,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '₹${value.toInt()}',
                      style: TextStyle(
                          fontSize: fontSizeFactor * 1.2), // Adjusted font size
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < days.length) {
                      return Text(
                        days[value.toInt()],
                        style: TextStyle(
                            fontSize:
                                fontSizeFactor * 1.2), // Adjusted font size
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
            ),
            borderData: FlBorderData(
              show: false,
              border: Border.all(color: Colors.black38, width: 1),
            ),
            minY: 0,
            maxY: 3000,
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                color: AppColors.primaryColor,
                barWidth: 1,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                    show: false, color: Colors.green.withOpacity(0.2)),
                spots: List.generate(
                    chartData["credited"]!.length,
                    (index) => FlSpot(
                        index.toDouble(), chartData["credited"]![index])),
              ),
              LineChartBarData(
                isCurved: true,
                color: AppColors.accentColor,
                barWidth: 1,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                    show: false, color: Colors.red.withOpacity(0.2)),
                spots: List.generate(
                    chartData["debited"]!.length,
                    (index) =>
                        FlSpot(index.toDouble(), chartData["debited"]![index])),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipRoundedRadius: 1,
                tooltipPadding: const EdgeInsets.all(8),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((touchedSpot) {
                    if (touchedSpot.bar.color == AppColors.primaryColor) {
                      return LineTooltipItem(
                        'Credited: ₹${touchedSpot.y.toStringAsFixed(2)}',
                        const TextStyle(color: Colors.green),
                      );
                    } else if (touchedSpot.bar.color == AppColors.accentColor) {
                      return LineTooltipItem(
                        'Debited: ₹${touchedSpot.y.toStringAsFixed(2)}',
                        const TextStyle(color: Colors.red),
                      );
                    }
                    return null;
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
