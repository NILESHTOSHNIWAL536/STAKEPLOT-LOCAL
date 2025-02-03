import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import './BudgetDisplay.dart';

class MyBudgetScreen extends StatelessWidget {
  final int daysRemaining;
  final double budgetAmount;
  final double amountSpent;
  final double overSpent;
  final Map<String, double> categories;
  final List<FlSpot> monthlyBudgetData;

  // Constructor updated to remove the 'insights' parameter
  MyBudgetScreen({
    required this.daysRemaining,
    required this.budgetAmount,
    required this.amountSpent,
    required this.overSpent,
    required this.categories,
    required this.monthlyBudgetData,
  });

  // Named constructor for example usage
  MyBudgetScreen.example()
      : this(
          daysRemaining: 12,
          budgetAmount: 1500,
          amountSpent: 2000,
          overSpent: 500,
          categories: {
            'Shopping': 40,
            'Children': 35,
            'Bills': 10,
            'Alcohol & Smoking': 15,
          },
          monthlyBudgetData: const [
            FlSpot(0, 400),
            FlSpot(1, 400),
            FlSpot(2, 500),
            FlSpot(3, 900),
            FlSpot(4, 650),
            FlSpot(5, 500),
            FlSpot(6, 400),
            FlSpot(7, 400),
            FlSpot(8, 500),
            FlSpot(9, 900),
            FlSpot(10, 650),
            FlSpot(11, 500),
          ],
        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        title: Text('My Budget',
            style: TextStyle(color: Colors.black, fontSize: 20)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDaysRemaining(),
              SizedBox(height: 16),
              _buildBudgetSummary(),
              SizedBox(height: 16),
              _buildMonthlyBudgetChart(),
              SizedBox(height: 16),
              _buildInsights(),
              SizedBox(height: 16),
              _buildCategoriesChart(),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaysRemaining() {
    return Row(
      children: [
        Icon(Icons.access_time, color: Colors.grey),
        SizedBox(width: 8),
        Text('Days remaining: $daysRemaining days',
            style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildBudgetSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildText('Budget amount', Colors.grey),
          SizedBox(height: 8),
          _buildText('₹ $budgetAmount', Colors.black,
              fontSize: 32, fontWeight: FontWeight.bold),
          SizedBox(height: 16),
          _buildRow('Amount spent', '₹ $amountSpent', Colors.black),
          SizedBox(height: 8),
          _buildRow('Over spent', '₹ $overSpent', Colors.red),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: textColor)),
        Text(value, style: TextStyle(color: textColor)),
      ],
    );
  }

  Widget _buildText(String text, Color color,
      {double fontSize = 16, FontWeight fontWeight = FontWeight.normal}) {
    return Text(text,
        style: TextStyle(
            color: color, fontSize: fontSize, fontWeight: fontWeight));
  }

  Widget _buildMonthlyBudgetChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildText('Monthly budget', Colors.black,
            fontSize: 18, fontWeight: FontWeight.bold),
        SizedBox(height: 8),
        LineChartSample(monthlyBudgetData: monthlyBudgetData),
      ],
    );
  }

  Widget _buildInsights() {
    // Static insights content moved here instead of being passed as a parameter
    final insights = [
      {
        'title': 'Unwanted purchases',
        'description': 'Reduce shopping to maintain proper budget'
      },
      {
        'title': 'Your essentials',
        'description': 'Cut down on non-essentials to stay within budget'
      },
      {
        'title': 'Upgrade budget',
        'description': 'Review your expenses and set higher limits'
      },
      {
        'title': 'Strict cutoffs',
        'description': 'Limit unnecessary expenses to save more'
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mt,
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.2),
        //     spreadRadius: 2,
        //     blurRadius: 5,
        //     offset: Offset(0, 3),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildText('Insights', Colors.black,
                  fontSize: 18, fontWeight: FontWeight.bold),
              Chip(
                label: Text('Budget hero'),
                backgroundColor: Colors.grey[200],
              ),
            ],
          ),
          SizedBox(height: 16),
          ...insights
              .map((insight) => _buildInsightCard(
                  title: insight['title']!,
                  description: insight['description']!))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
      {required String title, required String description}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.button,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildText(title, Colors.black, fontWeight: FontWeight.bold),
          SizedBox(height: 4),
          _buildText(description, Colors.grey),
        ],
      ),
    );
  }

  Widget _buildCategoriesChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildText('Categories', Colors.black,
            fontSize: 18, fontWeight: FontWeight.bold),
        SizedBox(height: 8),
        PieChartSample(categories: categories),
      ],
    );
  }
}

class LineChartSample extends StatelessWidget {
  final List<FlSpot> monthlyBudgetData;
  final int currentMonthIndex = DateTime.now().month - 1;
  final double currentMonthSpending = 400.0;

  LineChartSample({required this.monthlyBudgetData});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, titleMeta) {
                  // Display months 1 to 12 as titles, but only once for each month
                  if (value >= 0 && value <= 11) {
                    // Get the month names (e.g., Jan, Feb, Mar)
                    const monthNames = [
                      '1',
                      '2',
                      '3',
                      '4',
                      '5',
                      '6',
                      '7',
                      '8',
                      '9',
                      '10',
                      '11',
                      '12'
                    ];

                    // Display month names only once
                    if (value == value.toInt()) {
                      return Text(monthNames[value.toInt()]);
                    }
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: monthlyBudgetData,
              isCurved: true,
              color: AppColors.primaryColor,
              barWidth: 2,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              spots: [
                FlSpot(currentMonthIndex.toDouble(), 0),
                FlSpot(currentMonthIndex.toDouble(), currentMonthSpending),
              ],
              isCurved: true,
              color: AppColors.pollSelected,
              barWidth: 10,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

class PieChartSample extends StatelessWidget {
  final Map<String, double> categories;

  const PieChartSample({required this.categories});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.4,
      child: PieChart(
        PieChartData(
          sections: categories.entries.map((entry) {
            return PieChartSectionData(
              color: _getColor(entry.key),
              value: entry.value,
              title: '${entry.key}\n${entry.value}%',
              radius: 50,
              titleStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor),
            );
          }).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 0,
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Color _getColor(String category) {
    switch (category) {
      case 'Shopping':
        return Colors.teal;
      case 'Children':
        return Colors.grey;
      case 'Bills':
        return Colors.black;
      case 'Alcohol & Smoking':
        return Colors.blueGrey;
      default:
        return Colors.blue;
    }
  }
}
