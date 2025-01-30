import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart package for PieChart
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import './BudgetDisplay.dart';

class MyBudgetScreen extends StatelessWidget {
  final int daysRemaining;
  final double budgetAmount;
  final double amountSpent;
  final double overSpent;
  final Map<String, double> categories;
  final List<Map<String, String>> insights;
  final List<FlSpot> monthlyBudgetData; // Dynamic data for the LineChart
int currentMonthIndex = DateTime.now().month - 1; // Month is 1-based, so subtract 1 for 0-based index

  MyBudgetScreen({
    required this.daysRemaining,
    required this.budgetAmount,
    required this.amountSpent,
    required this.overSpent,
    required this.categories,
    required this.insights,
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
          insights: [
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
          ],
          monthlyBudgetData: [
            FlSpot(0, 300),
            FlSpot(1, 400),
            FlSpot(2, 500),
            FlSpot(3, 600),
            FlSpot(4, 650),
            FlSpot(5, 700),
          ],
        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
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
              // Days remaining
              _buildDaysRemaining(),
              SizedBox(height: 16),

              // Budget summary
              _buildBudgetSummary(),
              SizedBox(height: 16),

              // Monthly budget chart
              _buildMonthlyBudgetChart(),
              SizedBox(height: 16),

              // Insights
              _buildInsights(),
              SizedBox(height: 16),

              // Categories pie chart
              _buildCategoriesChart(),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build days remaining section
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

  // Function to build budget summary section
  Widget _buildBudgetSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
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

  // Function to build a row with two texts
  Widget _buildRow(String title, String value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: textColor)),
        Text(value, style: TextStyle(color: textColor)),
      ],
    );
  }

  // Function to build a text with optional style
  Widget _buildText(String text, Color color,
      {double fontSize = 16, FontWeight fontWeight = FontWeight.normal}) {
    return Text(text,
        style: TextStyle(
            color: color, fontSize: fontSize, fontWeight: fontWeight));
  }

  // Function to build monthly budget chart
  Widget _buildMonthlyBudgetChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Monthly budget',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: LineChartSample(
              monthlyBudgetData:
                  monthlyBudgetData),
        ), // Line chart for monthly budget
      ],
    );
  }

  // Function to build insights section
  Widget _buildInsights() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    description: insight['description']!,
                  ))
              .toList(),
        ],
      ),
    );
  }

  // Function to build each insight card
  Widget _buildInsightCard(
      {required String title, required String description}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(description, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // Function to build categories pie chart
  Widget _buildCategoriesChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        PieChartSample(categories: categories), // Pie chart for categories
      ],
    );
  }
}

// LineChartSample widget
class LineChartSample extends StatelessWidget {
  final List<FlSpot> monthlyBudgetData; // Dynamic data for the LineChart
int currentMonthIndex = DateTime.now().month - 1; // Month is 1-based, so subtract 1 for 0-based index
double currentMonthSpending = 300.0; // Replace with actual data

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
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false), // Hide left axis titles
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false), // Hide top axis titles
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false), // Hide right axis titles
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true, // Show bottom axis titles
            getTitlesWidget: (value, titleMeta) {
              // Return the title for each point on the bottom axis based on value
              if (value == 0) {
                return Text('Jan');
              } else if (value == 1) {
                return Text('Feb');
              } else if (value == 2) {
                return Text('Mar');
              } else if (value == 3) {
                return Text('Apr');
              } else if (value == 4) {
                return Text('May');
              } else if (value == 5) {
                return Text('Jun');
              }
              return const Text('');
            },
           // margin: 10, // Add some space at the bottom for the titles
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        // Regular line chart for all months
        LineChartBarData(
          spots: monthlyBudgetData, // Use dynamic data here
          isCurved: true,
          color: AppColors.primaryColor, // Line color
          barWidth: 2, // Line width
          belowBarData: BarAreaData(show: false),
          dotData: FlDotData(show: false), // Remove dots
        ),
        // Add a rectangle bar for current month
        LineChartBarData(
          spots: [
            FlSpot(currentMonthIndex.toDouble(), 0), // Start from bottom
            FlSpot(currentMonthIndex.toDouble(), currentMonthSpending), // End at current month's value
          ],
          isCurved: true,
          color: AppColors.pollSelected, // Rectangle color
          barWidth: 10, // Width of the rectangle
          belowBarData: BarAreaData(show: false),
          dotData: FlDotData(show: false), // Remove dots
        ),
      ],
    
    ),
  ),
);

  }
}



// PieChartSample widget
class PieChartSample extends StatelessWidget {
  final Map<String, double> categories;

  const PieChartSample({required this.categories});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sections: categories.entries.map((entry) {
            return PieChartSectionData(
              color: _getColor(entry.key),
              value: entry.value,
              title: '${entry.value}%',
              radius: 50,
              titleStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
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
