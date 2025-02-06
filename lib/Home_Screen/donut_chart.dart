import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'colors.dart';

class ChartData {
  final String category;
  final double value;
  final Color color;

  ChartData(this.category, this.value, this.color);
}

class DoughnutChartExample extends StatefulWidget {
  @override
  State<DoughnutChartExample> createState() => _DoughnutChartExampleState();
}

class _DoughnutChartExampleState extends State<DoughnutChartExample> {
  final List<ChartData> data = [
    ChartData('Food', 20, Color(0xFFB39DDB)), // Light Purple
    ChartData('Shopping', 15, Color(0xFF455A64)), // Dark Blue Grey
    ChartData('Travel', 10, Color(0xFF607D8B)), // Light Blue Grey
    ChartData('Health', 10, Color(0xFF263238)), // Dark Charcoal
    ChartData('Bills', 18, Color(0xFF81C784)), // Light Green
    ChartData('Subscriptions', 8, Color(0xFFB0BEC5)), // Light Grey
    ChartData('Events', 6, Color(0xFFD32F2F)), // Dark Red
    ChartData('Personal Care', 7, Color(0xFF7B1FA2)), // Dark Purple
    ChartData('Services', 5, Color(0xFF004D40)), // Dark Teal
    ChartData('Emi', 4, Color(0xFFFFC107)), // Amber
    ChartData('Insurance', 6, Color(0xFF0288D1)), // Dark Blue
    ChartData('Support', 4, Color(0xFFFF5722)), // Deep Orange
    ChartData('Children', 3, Color(0xFF8E24AA)), // Purple
    ChartData('Pet Care', 2, Color(0xFFFF80AB)), // Light Pink
    ChartData('Sports', 3, Color(0xFF1976D2)), // Dark Blue
    ChartData('Alcohol', 2, Color(0xFF5C6BC0)), // Indigo
    ChartData('Hobbies', 2, Color(0xFF795548)), // Brown
    ChartData('Education', 3, Color(0xFF78909C)), // Blue Grey
    ChartData('snacks', 4, Color(0xFFF06292)), // Pink
    ChartData('Entertainment', 5, Color(0xFF4CAF50)), // Green
  ];

  int? selectedIndex;
  late double totalValue;

  @override
  void initState() {
    super.initState();
    totalValue = data.fold(0, (sum, item) => sum + item.value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 600;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Expenses',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.normal,
                      fontSize: 14,
                      color: AppColors.bg3),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\₹${totalValue.toStringAsFixed(2)}',
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.accentColor),
                    ),
                    Text(
                      'This week',
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.bg3),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: isLargeScreen ? 2 : 3,
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            //color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.grey.withOpacity(0.2),
                            //     spreadRadius: 2,
                            //     blurRadius: 5,
                            //   ),
                            // ],
                          ),
                          child: selectedIndex != null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Expenses: ${data[selectedIndex!].category}',
                                      style: FontManager().getTextStyle(context,
                                          lWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: AppColors.accentColor),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${_getMonthlyRange()}',
                                      style: FontManager().getTextStyle(context,
                                          lWeight: FontWeight.normal,
                                          fontSize: 12,
                                          color: AppColors.bg3),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Amount: \₹${data[selectedIndex!].value.toStringAsFixed(2)}',
                                      style: FontManager().getTextStyle(context,
                                          lWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.accentColor),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Total Spending',
                                          style: FontManager().getTextStyle(
                                              context,
                                              lWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: AppColors.accentColor)),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${_getMonthlyRange()}',
                                        style: FontManager().getTextStyle(
                                            context,
                                            lWeight: FontWeight.normal,
                                            fontSize: 12,
                                            color: AppColors.bg3),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Amount: \₹${totalValue.toStringAsFixed(2)}',
                                        style: FontManager().getTextStyle(
                                            context,
                                            lWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: AppColors.accentColor),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: Container(
                          alignment: Alignment.center,
                          child: SfCircularChart(
                            series: <CircularSeries>[
                              DoughnutSeries<ChartData, String>(
                                dataSource: data,
                                xValueMapper: (ChartData data, _) =>
                                    data.category,
                                yValueMapper: (ChartData data, _) => data.value,
                                pointColorMapper: (ChartData data, int index) =>
                                    selectedIndex == null ||
                                            selectedIndex == index
                                        ? data.color
                                        : data.color.withOpacity(0.0),
                                explode: true,
                                explodeIndex: selectedIndex,
                                dataLabelSettings:
                                    const DataLabelSettings(isVisible: false),
                                enableTooltip: true,
                                onPointTap: (ChartPointDetails details) {
                                  setState(() {
                                    if (selectedIndex == details.pointIndex) {
                                      selectedIndex = null;
                                    } else {
                                      selectedIndex = details.pointIndex;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getMonthlyRange() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth =
        DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));

    return '${_formatDate(startOfMonth)} - ${_formatDate(endOfMonth)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
