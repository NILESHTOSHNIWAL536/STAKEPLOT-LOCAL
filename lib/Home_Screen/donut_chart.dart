
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
  // final List<ChartData> data = [
  //   ChartData('Food', 20, Color(0xFFB39DDB)), // Light Purple
  //   ChartData('Shopping', 15, Color(0xFF455A64)), // Dark Blue Grey
  //   ChartData('Travel', 10, Color(0xFF607D8B)), // Light Blue Grey
  //   ChartData('Health', 10, Color(0xFF263238)), // Dark Charcoal
  //   ChartData('Bills', 18, Color(0xFF81C784)), // Light Green
  //   ChartData('Subscriptions', 8, Color(0xFFB0BEC5)), // Light Grey
  //   ChartData('Events', 6, Color(0xFFD32F2F)), // Dark Red
  //   ChartData('Personal Care', 7, Color(0xFF7B1FA2)), // Dark Purple
  //   ChartData('Services', 5, Color(0xFF004D40)), // Dark Teal
  //   ChartData('Emi', 4, Color(0xFFFFC107)), // Amber
  //   ChartData('Insurance', 6, Color(0xFF0288D1)), // Dark Blue
  //   ChartData('Support', 4, Color(0xFFFF5722)), // Deep Orange
  //   ChartData('Children', 3, Color(0xFF8E24AA)), // Purple
  //   ChartData('Pet Care', 2, Color(0xFFFF80AB)), // Light Pink
  //   ChartData('Sports', 3, Color(0xFF1976D2)), // Dark Blue
  //   ChartData('Alcohol', 2, Color(0xFF5C6BC0)), // Indigo
  //   ChartData('Hobbies', 2, Color(0xFF795548)), // Brown
  //   ChartData('Education', 3, Color(0xFF78909C)), // Blue Grey
  //   ChartData('snacks', 4, Color(0xFFF06292)), // Pink
  //   ChartData('Entertainment', 5, Color(0xFF4CAF50)), // Green
  // ];

  int? selectedIndex;
  List<ChartData> data = [];
  double totalValue = 0.0;

  @override
  void initState() {
    super.initState();
    getCategoryData();
  }
void getCategoryData() async {
  var res = await getDataApiCall("${url}/transactionauto/categorize");

  if (getFlagOfResponse(res)) {
    var data = jsonDecode(res.body);
    print("data getCategoryData()");
    print(data["data"]);
    categoriesList.clear();
    categoriesList.addAll(data["data"]);
    setDonectChat.value = !setDonectChat.value;
    categoriesList.refresh();
    processChartData();
  }
}
  void processChartData() {
    List<ChartData> newData = [];
    double newTotalValue = 0.0;

    Map<String, Color> categoryColors = {
      "Food": Color(0xFFB39DDB),
      "Shopping": Color(0xFF455A64),
      "Travel": Color(0xFF607D8B),
      "Health": Color(0xFF263238),
      "Subscriptions": Color(0xFFB0BEC5),
      "Entertainment": Color(0xFF4CAF50),
      "Insurance": Color(0xFF0288D1),
      "Emi": Color(0xFFFFC107),
      "Investments": Color(0xFFD32F2F),
      "Untagged": Color(0xFF78909C),


    };
   for (var item in categoriesList) {
      String category = item["category"];
      double value = item["total_debit"].toDouble();
      Color color = categoryColors[category] ?? Colors.grey; // Default color

      newData.add(ChartData(category, value, color));
      newTotalValue += value;
    }

    setState(() {
      data = newData;
      totalValue = newTotalValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
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
                const SizedBox(height: 10),
                Expanded(
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 8,
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
                                        : data.color,
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
                      Expanded(
                        flex: isLargeScreen ? 2 : 3,
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          child: selectedIndex != null
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Expenses: ${data[selectedIndex!].category}',
                                        style: FontManager().getTextStyle(
                                            context,
                                            lWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.accentColor),
                                      ),
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
                                        'Amount: \₹${data[selectedIndex!].value.toStringAsFixed(2)}',
                                        style: FontManager().getTextStyle(
                                            context,
                                            lWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: AppColors.accentColor),
                                      ),
                                    ],
                                  ),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Total Spending',
                                          style: FontManager().getTextStyle(
                                              context,
                                              lWeight: FontWeight.bold,
                                              fontSize: 16,
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
