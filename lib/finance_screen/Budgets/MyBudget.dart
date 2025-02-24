import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class MyBudgetScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  MyBudgetScreen({required this.data});

  @override
  State<MyBudgetScreen> createState() => _MyBudgetScreenState();
}

class _MyBudgetScreenState extends State<MyBudgetScreen> {
  List<FlSpot> monthlyBudgetData = [];
  Map<String, double> categories = {};
  List graphObj = [];
  List<_ChartData> budgetSpentData = [];
  String budgetType = 'monthly';

  @override
  void initState() {
    super.initState();
    getmonthlyBudgetData();
    fetchBudgetData();
  }

  Future<void> fetchBudgetData() async {
    final String budgetId = widget.data['_id']?.toString() ?? '67b84fdcfab72f34be29c893';
    final String apiUrl = '$url/budget/get-budget-spents/$budgetId';
    print('Fetching budget data from: $apiUrl');

    try {
      var response = await getDataApiCall(apiUrl);
      print('API Response: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          budgetType = widget.data['budgetPeriod']?.toLowerCase() ?? 'monthly';
          processBudgetData(data);
        });
      } else {
        print('Failed to load budget data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching budget data: $e');
    }
  }

  void processBudgetData(dynamic data) {
    // Access the 'transactions' list within 'data'
    List<dynamic> spentData = data['data'] != null && data['data']['transactions'] != null
        ? data['data']['transactions']
        : [];
    budgetSpentData.clear();

    if (spentData.isEmpty) {
      print('No spending data available');
      return;
    }

    print('Processing with budgetType: $budgetType');
    if (budgetType == 'weekly') {
      double totalAmount = spentData[0]['debitTotalAmount']?.toDouble() ?? 0.0;
      double dailyAmount = totalAmount / 7;
      List<String> weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      for (int i = 0; i < 7; i++) {
        budgetSpentData.add(_ChartData(
          x: i,
          y: dailyAmount,
          xString: weekdays[i],
        ));
      }
    } else if (budgetType == 'monthly') {
      double totalAmount = spentData[0]['debitTotalAmount']?.toDouble() ?? 0.0;
      // Assuming February (28 days) based on API response date "19-02-2025"
      int daysInMonth = 28;
      double dailyAmount = totalAmount / daysInMonth;
      for (int i = 0; i < daysInMonth; i++) {
        budgetSpentData.add(_ChartData(
          x: i,
          y: dailyAmount,
          xString: (i + 1).toString(), // 1 to 28
        ));
      }
    } else if (budgetType == 'yearly') {
      for (int i = 0; i < spentData.length && i < 12; i++) {
        double amount = spentData[i]['debitTotalAmount']?.toDouble() ?? 0.0;
        budgetSpentData.add(_ChartData(
          x: i,
          y: amount,
          xString: spentData[i]['_id'], // e.g., "19-02-2025"
        ));
      }
      // Fill remaining months with 0
      for (int i = spentData.length; i < 12; i++) {
        budgetSpentData.add(_ChartData(
          x: i,
          y: 0.0,
          xString: DateFormat('MMM').format(DateTime(2025, i + 1, 1)),
        ));
      }
    }

    print('Processed budgetSpentData: $budgetSpentData');
  }

  void getmonthlyBudgetData() {
    List list = widget.data['categoryBudgets'] ?? [];
    monthlyBudgetData.clear();
    categories.clear();
    graphObj.clear();

    for (int i = 0; i < list.length; i++) {
      double amount = double.parse(list[i]['amount'].toString());
      monthlyBudgetData.add(FlSpot(i.toDouble(), amount));
    }
    double totalAmount = list.fold(0, (sum, item) => sum + double.parse(item['amount'].toString()));
    for (int i = 0; i < list.length; i++) {
      double amount = double.parse(list[i]['amount'].toString());
      double percentage = totalAmount > 0 ? (amount / totalAmount) * 100 : 0;
      categories[list[i]['category']] = percentage;
      graphObj.add({
        'title': list[i]['category'] + "\n" + percentage.toStringAsFixed(1) + "%",
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
        title: Text('My Budget', style: TextStyle(color: Colors.black, fontSize: 20)),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaysRemaining() {
    final endDateStr = widget.data['endDate'] ?? '2025-03-04T12:07:11.028Z';
    final endDate = DateTime.parse(endDateStr);
    final daysRemaining = endDate.difference(DateTime.now()).inDays;
    return Row(
      children: [
        Icon(Icons.access_time, color: Colors.grey),
        SizedBox(width: 8),
        Text('Days remaining: $daysRemaining days', style: TextStyle(color: Colors.grey)),
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
          _buildRow('Amount spent', '₹ 2580', Colors.black), // Updated from API
          SizedBox(height: 8),
          _buildRow('Over spent', '₹ ${2580 - widget.data['amount']}', Colors.red),
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
    return Text(
      text,
      style: TextStyle(color: color, fontSize: fontSize, fontWeight: fontWeight),
    );
  }

  Widget _buildMonthlyBudgetChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildText('Budget Spending', Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        SizedBox(height: 8),
        budgetSpentData.isEmpty
            ? Center(child: Text('No spending data available', style: TextStyle(color: Colors.red)))
            : SizedBox(
                height: 300,
                child: LineChartSample(budgetData: budgetSpentData, budgetType: budgetType),
              ),
      ],
    );
  }

  Widget _buildInsights() {
    final insights = [
      {'title': 'Unwanted purchases', 'description': 'Reduce shopping to maintain proper budget'},
      {'title': 'Your essentials', 'description': 'Cut down on non-essentials to stay within budget'},
      {'title': 'Upgrade budget', 'description': 'Review your expenses and set higher limits'},
      {'title': 'Strict cutoffs', 'description': 'Limit unnecessary expenses to save more'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildText('Insights', Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
              Chip(label: Text('Budget hero'), backgroundColor: Colors.grey[200]),
            ],
          ),
          SizedBox(height: 16),
          ...insights.map((insight) => _buildInsightCard(
              title: insight['title']!, description: insight['description']!)).toList(),
        ],
      ),
    );
  }

  Widget _buildInsightCard({required String title, required String description}) {
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
    return PieChartGraph(title: "Categories", graphData: graphObj, graphDisc: []);
  }

  Widget _buildCategoriesChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildText('Categories', Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        SizedBox(height: 8),
        graph(),
      ],
    );
  }
}

class LineChartSample extends StatelessWidget {
  final List<_ChartData> budgetData;
  final String budgetType;

  LineChartSample({required this.budgetData, required this.budgetType});

  @override
  Widget build(BuildContext context) {
    double labelWidth;
    double labelRotation;

    switch (budgetType) {
      case 'weekly':
        labelWidth = 50.0;
        labelRotation = 0;
        break;
      case 'monthly':
        labelWidth = 30.0;
        labelRotation = 45;
        break;
      case 'yearly':
        labelWidth = 40.0;
        labelRotation = 0;
        break;
      default:
        labelWidth = 80.0;
        labelRotation = 0;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: math.max(budgetData.length * labelWidth, MediaQuery.of(context).size.width),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(
            labelStyle: TextStyle(color: AppColors.accentColor, fontSize: 12),
            majorGridLines: MajorGridLines(width: 0),
            minorGridLines: MinorGridLines(width: 0),
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            labelRotation: labelRotation.toInt(),
            maximumLabels: budgetData.length,
          ),
          primaryYAxis: NumericAxis(
            isVisible: true,
            labelStyle: TextStyle(color: AppColors.accentColor),
            majorGridLines: MajorGridLines(width: 0),
            minorGridLines: MinorGridLines(width: 0),
            minimum: 0,
            maximum: budgetData.isNotEmpty ? budgetData.map((e) => e.y).reduce(math.max) * 1.2 : 1000.0,
          ),
          series: <ChartSeries>[
            SplineSeries<_ChartData, String>(
              dataSource: budgetData,
              xValueMapper: (_ChartData data, _) => data.xString,
              yValueMapper: (_ChartData data, _) => data.y,
              color: AppColors.primaryColor,
              width: 2,
              splineType: SplineType.cardinal,
              cardinalSplineTension: 0.5,
              name: '', // Hide series name
            ),
          ],
          tooltipBehavior: TooltipBehavior(
            enable: true,
            builder: (dynamic data, dynamic point, dynamic series, int pointIndex, int seriesIndex) {
              final _ChartData chartData = data as _ChartData;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.8),
                ),
                padding: EdgeInsets.all(8),
                child: Text(
                  '${chartData.xString}: ₹${chartData.y.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
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

  @override
  String toString() => '($x, $y, $xString)';
}

// PieChartSample remains unchanged
class PieChartSample extends StatelessWidget {
  final Map<String, double> categories;

  const PieChartSample({required this.categories});

  @override
  Widget build(BuildContext context) {
    double totalAmount = categories.values.fold(0.0, (sum, amount) => sum + amount);
    return AspectRatio(
      aspectRatio: 1.4,
      child: PieChart(
        PieChartData(
          sections: categories.entries.map((entry) {
            double percentage = totalAmount > 0 ? (entry.value / totalAmount) * 100 : 0;
            return PieChartSectionData(
              color: _getColor(entry.key),
              value: entry.value,
              title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
              radius: 50,
              badgePositionPercentageOffset: 1.7,
              titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
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