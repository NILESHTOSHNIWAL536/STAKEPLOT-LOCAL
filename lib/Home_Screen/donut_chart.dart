import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
    ChartData('Transport', 15, Color(0xFF455A64)), // Dark Blue Grey
    ChartData('Entertainment', 10, Color(0xFF607D8B)), // Light Blue Grey
    ChartData('Others', 10, Color(0xFF263238)), // Dark Charcoal
    ChartData('Rent', 18, Color(0xFF81C784)), // Light Green
    ChartData('Utilities', 8, Color(0xFFB0BEC5)), // Light Grey
    ChartData('Healthcare', 6, Color(0xFFD32F2F)), // Dark Red
    ChartData('Education', 7, Color(0xFF7B1FA2)), // Dark Purple
    ChartData('Savings', 5, Color(0xFF004D40)), // Dark Teal
    ChartData('Shopping', 4, Color(0xFFFFC107)), // Amber
    ChartData('Travel', 6, Color(0xFF0288D1)), // Dark Blue
    ChartData('Insurance', 4, Color(0xFFFF5722)), // Deep Orange
    ChartData('Subscriptions', 3, Color(0xFF8E24AA)), // Purple
    ChartData('Charity', 2, Color(0xFFFF80AB)), // Light Pink
    ChartData('Debt Repayment', 3, Color(0xFF1976D2)),
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
                const Text(
                  'Monthly Expenses',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${totalValue.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: selectedIndex != null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Expenses: ${data[selectedIndex!].category}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${_getMonthlyRange()}',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Amount: \₹${data[selectedIndex!].value.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Total Spending',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${_getMonthlyRange()}',
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Amount: \₹${totalValue.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 18),
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
                                        : data.color.withOpacity(0.3),
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
