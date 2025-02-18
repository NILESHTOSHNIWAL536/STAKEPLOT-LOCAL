import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import './BudgetDisplay.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class MyBudgetScreen extends StatefulWidget {
  final data;

  // Constructor updated to remove the 'insights' parameter
  MyBudgetScreen({
    required this.data,
  });

  @override
  State<MyBudgetScreen> createState() => _MyBudgetScreenState();
}

class _MyBudgetScreenState extends State<MyBudgetScreen> {
  List<FlSpot> monthlyBudgetData = [];
  Map<String, double> categories = {};
  List graphObj = [];

  @override
  void initState() {
    super.initState();
    getmonthlyBudgetData();
    print('Monthly Budget Data Length: ${monthlyBudgetData.length}');
    
    print('Monthly Budget Data: $monthlyBudgetData');
  }

  void getmonthlyBudgetData() {
    List list = widget.data['categoryBudgets'];

    
    for (int i = 0; i < list.length; i++) {
      double amount = double.parse(list[i]['amount'].toString());
      monthlyBudgetData.add(FlSpot(i.toDouble(), amount));
    }
    double totalAmount = list.fold(
        0, (sum, item) => sum + double.parse(item['amount'].toString()));
    for (int i = 0; i < list.length; i++) {
      double amount = double.parse(list[i]['amount'].toString());
      double percentage = (amount / totalAmount) * 100;
      // categories[list[i]['category']] = amount;
      // graphObj.add({
      //   'title': list[i]['category'] + "\n" + amount.toString(),
      //   'value': amount,
      // });
      categories[list[i]['category']] = percentage;
      graphObj.add({
        'title':
            list[i]['category'] + "\n" + percentage.toStringAsFixed(1) + "%",
        'value': percentage,
      });
    }
    setState(() {});
  }

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
        Text('Days remaining: 12 days', style: TextStyle(color: Colors.grey)),
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
          _buildText('₹ ${widget.data['amount'].toString()}', Colors.black,
              fontSize: 32, fontWeight: FontWeight.bold),
          SizedBox(height: 16),
          _buildRow('Amount spent', '₹ ${8000.toString()}', Colors.black),
          SizedBox(height: 8),
          _buildRow('Over spent', '₹ ${2000.toString()}', Colors.red),
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

  Widget graph() {
    return PieChartGraph(
        title: "Categories", graphData: graphObj, graphDisc: []);
  }

  Widget _buildCategoriesChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildText('Categories', Colors.black,
            fontSize: 18, fontWeight: FontWeight.bold),
        SizedBox(height: 8),
        // PieChartSample(categories: categories),
        graph(),
      ],
    );
  }
}

class LineChartSample extends StatelessWidget {
  final List<FlSpot> monthlyBudgetData;
  final int currentMonthIndex = DateTime.now().month - 1;

  LineChartSample({required this.monthlyBudgetData});
  @override
  List<_ChartData> _getChartData() {
    return monthlyBudgetData.map((spot) {
      return _ChartData(
        x: spot.x.toInt() + 1,
        y: spot.y,
        xString: DateFormat('MMM')
            .format(DateTime(2025, spot.x.toInt() + 1, 1)), // Example year
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double labelWidth = 80.0;
    return Container(
      height: 300, // Adjust the height as needed
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          
          // Width is set to allow all months to be fully visible when scrolled
          width: monthlyBudgetData.length * labelWidth > screenWidth
              ? monthlyBudgetData.length * labelWidth
              : screenWidth, // Assuming each label takes around 80 pixels
          child: SfCartesianChart(
            plotAreaBorderWidth: 0,
            primaryXAxis: CategoryAxis(
              labelStyle: TextStyle(color: AppColors.accentColor),
              majorGridLines: MajorGridLines(width: 0),
              minorGridLines: MinorGridLines(width: 0),
              edgeLabelPlacement: EdgeLabelPlacement
                  .shift, // Ensures labels are visible at edges
            ),
            primaryYAxis: NumericAxis(
              isVisible: false,
              labelStyle: TextStyle(color: AppColors.accentColor),
              majorGridLines: MajorGridLines(width: 0),
              minorGridLines: MinorGridLines(width: 0),
              minimum: 0,
              maximum: monthlyBudgetData.isNotEmpty
                  ? monthlyBudgetData.map((e) => e.y).reduce(math.max) * 1.2
                  : 100.0,
            ),
            series: <ChartSeries>[
              // Main budget line
              SplineSeries<_ChartData, String>(
                dataSource: _getChartData(),
                xValueMapper: (_ChartData data, _) => data.xString,
                yValueMapper: (_ChartData data, _) => data.y,
                color: AppColors.primaryColor,
                width: 2,
                splineType: SplineType.cardinal,
                cardinalSplineTension: 0.5,
              ),
              // Current Month Indicator - Adjusted to match the actual spending of that month
              SplineSeries<_ChartData, String>(
                dataSource: [
                  _ChartData(
                    x: currentMonthIndex + 1,
                    y: 0,
                    xString: DateFormat('MMM')
                        .format(DateTime(2023, currentMonthIndex + 1, 1)),
                  ),
                  _ChartData(
                    x: currentMonthIndex + 1,
                    y: monthlyBudgetData.isNotEmpty &&
                            currentMonthIndex < monthlyBudgetData.length
                        ? monthlyBudgetData[currentMonthIndex].y
                        : 0, // Use actual spending for current month
                    xString: DateFormat('MMM')
                        .format(DateTime(2023, currentMonthIndex + 1, 1)),
                  ),
                ],
                xValueMapper: (_ChartData data, _) => data.xString,
                yValueMapper: (_ChartData data, _) => data.y,
                color: AppColors.pollSelected,
                width: 15,
                splineType: SplineType.cardinal,
                cardinalSplineTension: 0.5,
              ),
            ],
            tooltipBehavior: TooltipBehavior(enable: true),
          ),
        ),
      ),
    );
  }
}

class _ChartData {
  _ChartData({required this.x, required this.y, required this.xString});
  final int x;
  final double y;
  final String xString;
}

class PieChartSample extends StatelessWidget {
  final Map<String, double> categories;

  const PieChartSample({required this.categories});

  @override
  Widget build(BuildContext context) {
    double totalAmount =
        categories.values.fold(0.0, (sum, amount) => sum + amount);
    return AspectRatio(
      aspectRatio: 1.4,
      child: PieChart(
        PieChartData(
          sections: categories.entries.map((entry) {
            double percentage = (entry.value / totalAmount) * 100;
            return PieChartSectionData(
              color: _getColor(entry.key),
              value: entry.value,
              //title: '${entry.key}\n${entry.value}%',
              title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
              radius: 50,
              badgePositionPercentageOffset: 1.7,
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
      case 'Food':
        return Colors.red;
      case 'Shopping':
        return Colors.teal;
      case 'Travel':
        return Colors.blue;
      case 'Health':
        return Colors.green;
      case 'Bills':
        return Colors.black;
      case 'Subscriptions':
        return Colors.purple;
      case 'Events':
        return Colors.orange;
      case 'PersonalCare':
        return Colors.pink;
      case 'Services':
        return Colors.brown;
      case 'Emi':
        return Colors.deepPurple;
      case 'Insurance':
        return Colors.indigo;
      case 'Support':
        return Colors.cyan;
      case 'Children':
        return Colors.grey;
      case 'PetCare':
        return Colors.lightGreen;
      case 'Sports':
        return Colors.lime;
      case 'Alcohol':
        return Colors.blueGrey;
      case 'Hobbies':
        return Colors.amber;
      case 'Snacks':
        return Colors.deepOrange;
      case 'Entertainment':
        return Colors.yellow;
      default:
        return Colors.blue;
    }
  }
}
