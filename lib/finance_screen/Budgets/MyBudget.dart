import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
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
  //List<Map<String, dynamic>> graphObj=[];
  List<_ChartData> budgetSpentData = [];
  String budgetType = 'monthly';
  List<dynamic> transactions = []; // Store raw transactions from API
  Map<String, dynamic>? budgetData;
  Map<String, dynamic>? insightsData;

  @override
  void initState() {
    super.initState();
    getmonthlyBudgetData();
    fetchBudgetData();
    fetchBudgetInsights();
    // getInsights(context);
  }

  Future<void> fetchBudgetInsights() async {
    final String budgetId =
        widget.data['_id']?.toString() ?? '679b6ea12af555d641c5da61';
    final String apiUrl = '$url/budget/get-insights/$budgetId';
    // print('Fetching insights with budgetId: $budgetId');
    // print('API URL: $apiUrl');
    try {
      var response = await getDataApiCall(apiUrl);
      //  print('Insights API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          insightsData = data; // Store insights data in state
        });
      } else {
        //  print('Failed to fetch insights: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error fetching insights: $e');
    }
  }

  Future<void> fetchBudgetData() async {
    final String budgetId =
        widget.data['_id']?.toString() ?? '67b84fdcfab72f34be29c893';
    final String apiUrl = '$url/budget/get-budget-spents/$budgetId';
    try {
      var response = await getDataApiCall(apiUrl);
      print('API Response: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          budgetType = widget.data['budgetPeriod']?.toLowerCase() ?? 'monthly';
          transactions = data['data']['transactions'] ?? [];

          // Clear previous data
          budgetSpentData.clear();

          if (budgetType == 'yearly') {
            Map<String, int> monthOrder = {
              'January': 0,
              'February': 1,
              'March': 2,
              'April': 3,
              'May': 4,
              'June': 5,
              'July': 6,
              'August': 7,
              'September': 8,
              'October': 9,
              'November': 10,
              'December': 11
            };
            budgetSpentData = transactions.map((transaction) {
              int index = monthOrder[transaction['_id']] ?? 0;
              String xString =
                  DateFormat('MMM').format(DateTime(2025, index + 1, 1));
              return _ChartData(
                x: index,
                y: (transaction['debitTotalAmount'] as num?)?.toDouble() ?? 0.0,
                xString: xString,
              );
            }).toList();

            // Fill missing months
            for (int i = 0; i < 12; i++) {
              if (!budgetSpentData.any((data) => data.x == i)) {
                String monthName =
                    DateFormat('MMM').format(DateTime(2025, i + 1, 1));
                budgetSpentData
                    .add(_ChartData(x: i, y: 0.0, xString: monthName));
              }
            }
            budgetSpentData.sort((a, b) => a.x.compareTo(b.x));
          } else if (budgetType == 'monthly') {
            // Determine the month and year from the first transaction or endDate
            String firstDateStr =
                transactions.isNotEmpty ? transactions[0]['_id'] : '01-03-2025';
            DateTime firstDate = DateFormat('dd-MM-yyyy').parse(firstDateStr);
            int daysInMonth =
                DateTime(firstDate.year, firstDate.month + 1, 0).day;

            // Map transactions to days
            Map<int, double> dailySpent = {};
            for (var transaction in transactions) {
              DateTime date =
                  DateFormat('dd-MM-yyyy').parse(transaction['_id']);
              int dayIndex = date.day - 1; // 0-based index
              dailySpent[dayIndex] =
                  (transaction['debitTotalAmount'] as num?)?.toDouble() ?? 0.0;
            }

            // Fill all days of the month
            for (int i = 0; i < daysInMonth; i++) {
              budgetSpentData.add(_ChartData(
                x: i,
                y: dailySpent[i] ?? 0.0,
                xString: (i + 1).toString(),
              ));
            }
          } else {
            // weekly
            List<String> weekdays = [
              'Sun',
              'Mon',
              'Tue',
              'Wed',
              'Thu',
              'Fri',
              'Sat'
            ];
            budgetSpentData = transactions.map((transaction) {
              int index = transactions.indexOf(transaction);
              return _ChartData(
                x: index,
                y: (transaction['debitTotalAmount'] as num?)?.toDouble() ?? 0.0,
                xString: weekdays[index % 7],
              );
            }).toList();

            // Fill remaining days if less than 7
            for (int i = budgetSpentData.length; i < 7; i++) {
              budgetSpentData
                  .add(_ChartData(x: i, y: 0.0, xString: weekdays[i]));
            }
            budgetSpentData.sort((a, b) => a.x.compareTo(b.x));
          }

          print('Processed budgetSpentData: $budgetSpentData');
        });
      } else {
        print('Failed to load budget data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching budget data: $e');
    }
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
    double totalAmount = list.fold(
        0, (sum, item) => sum + double.parse(item['amount'].toString()));
    for (int i = 0; i < list.length; i++) {
      double amount = double.parse(list[i]['amount'].toString());
      double percentage = totalAmount > 0 ? (amount / totalAmount) * 100 : 0;
      categories[list[i]['category']] = percentage;
      graphObj.add({
        'title': list[i]['category'] +" "+ percentage.toStringAsFixed(1) + "%",
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
        title: _buildText('My Budget', Colors.black,
            fontSize: 18, fontWeight: FontWeight.bold),
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
        // Text('Days remaining: $daysRemaining days',
        //     style: TextStyle(color: Colors.grey)),
        _buildText('Days remaining: $daysRemaining days', Colors.black,
            fontSize: 13, fontWeight: FontWeight.w400),
      ],
    );
  }

  Widget _buildBudgetSummary() {
    double totalSpent = budgetSpentData.isNotEmpty
        ? budgetSpentData.map((e) => e.y).reduce((a, b) => a + b)
        : 0.0;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildText('Budget amount', Colors.grey),
          SizedBox(height: 8),
          _buildText(
              '₹ ${widget.data['amount'].toString()}', AppColors.primaryColor,
              fontSize: 26, fontWeight: FontWeight.w500),
          SizedBox(height: 16),
          _buildRow(
            'Amount spent',
            '₹ $totalSpent',
            Colors.black,
          ),
          SizedBox(height: 8),
          _buildRow2(
            'Over spent',
            '₹ ${(totalSpent - (widget.data['amount'] as num)).clamp(0, double.infinity)}',
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildText(title, Colors.black,
            fontSize: 16, fontWeight: FontWeight.w500),
        _buildText(value, Colors.black,
            fontSize: 18, fontWeight: FontWeight.w500),
      ],
    );
  }

  Widget _buildRow2(String title, String value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildText(title, Colors.red,
            fontSize: 16, fontWeight: FontWeight.w500),
        _buildText(value, Colors.red,
            fontSize: 18, fontWeight: FontWeight.w500),
      ],
    );
  }

  Widget _buildText(String text, Color color,
      {double fontSize = 16, FontWeight fontWeight = FontWeight.normal}) {
    return Text(
      text,
      style: FontManager().getTextStyle(context,
          lWeight: fontWeight, fontSize: fontSize, color: color),
      // style:
      //     TextStyle(color: color, fontSize: fontSize, fontWeight: fontWeight),
    );
  }

  Widget _buildMonthlyBudgetChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildText('Budget Spending', Colors.black,
            fontSize: 18, fontWeight: FontWeight.bold),
        SizedBox(height: 8),
        budgetSpentData.isEmpty
            ? Center(
                // child: Text('No spending data available',
                //     style: TextStyle(color: Colors.red))
                child: _buildText('No spending data available', Colors.black,
                    fontSize: 18, fontWeight: FontWeight.bold),
              )
            : SizedBox(
                height: 300,
                child: LineChartSample(
                    budgetData: budgetSpentData, budgetType: budgetType),
              ),
      ],
    );
  }

  Widget _buildInsights() {
    if (insightsData == null) {
      return Center(child: CircularProgressIndicator());
    }

    List<dynamic>? insightsList = insightsData?['data']; // Extract list

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildText('Insights', AppColors.accentColor,
              fontSize: 16, fontWeight: FontWeight.bold),
          SizedBox(height: 8),
          insightsList != null && insightsList.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true, // Allows ListView inside a Column
                  physics:
                      NeverScrollableScrollPhysics(), // Disable scrolling (parent will scroll)
                  itemCount: insightsList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50, // Light blue background
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      // child: Text(
                      //   insightsList[index],
                      //   style: TextStyle(fontSize: 16, color: Colors.black87),
                      // ),
                      child: _buildText(insightsList[index], AppColors.bg3,
                          fontWeight: FontWeight.w500),
                    );
                  },
                )
              : _buildText("No insights available", Colors.black,
                  fontSize: 12, fontWeight: FontWeight.bold)
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
        labelRotation = 0;
        break;
      case 'yearly':
        labelWidth = 50.0;
        labelRotation = 0;
        break;
      default:
        labelWidth = 80.0;
        labelRotation = 0;
    }
    double chartWidth = budgetData.length * labelWidth;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: math.max(chartWidth, MediaQuery.of(context).size.width),
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(
            labelStyle: TextStyle(color: AppColors.accentColor, fontSize: 12),
            majorGridLines: MajorGridLines(width: 0),
            minorGridLines: MinorGridLines(width: 0),
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            interval: 1,
            labelRotation: labelRotation.toInt(),
            maximumLabels: budgetData.length,
            axisLine: AxisLine(width: 0),
            majorTickLines: const MajorTickLines(
                size: 0), // Hide major tick marks if desired
            minorTickLines: const MinorTickLines(size: 0),
          ),
          primaryYAxis: NumericAxis(
            isVisible: true,
            labelStyle: TextStyle(color: AppColors.accentColor),
            majorGridLines: MajorGridLines(width: 0),
            minorGridLines: MinorGridLines(width: 0),
            axisLine: AxisLine(width: 0),
            minimum: 0,
            maximum: budgetData.isNotEmpty
                ? budgetData.map((e) => e.y).reduce(math.max) * 1.2
                : 1000.0,
            majorTickLines: const MajorTickLines(
                size: 0), // Hide major tick marks if desired
            minorTickLines: const MinorTickLines(size: 0),
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
            builder: (dynamic data, dynamic point, dynamic series,
                int pointIndex, int seriesIndex) {
              final _ChartData chartData = data as _ChartData;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.black.withOpacity(0.8),
                ),
                padding: EdgeInsets.all(8),
                child: Text(
                  '₹${chartData.y.toStringAsFixed(2)}',
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
    double totalAmount =
        categories.values.fold(0.0, (sum, amount) => sum + amount);
    return AspectRatio(
      aspectRatio: 1.4,
      child: PieChart(
        PieChartData(
          sections: categories.entries.map((entry) {
            double percentage =
                totalAmount > 0 ? (entry.value / totalAmount) * 100 : 0;
            return PieChartSectionData(
              color: _getColor(entry.key),
              value: entry.value,
              title: '${entry.key} : ${percentage.toStringAsFixed(1)}%',
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
