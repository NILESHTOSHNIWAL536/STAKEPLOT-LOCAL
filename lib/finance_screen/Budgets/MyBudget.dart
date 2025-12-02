
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/repository/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/repository/budget_apis.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/routes/route_finances.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:math' as math;

// New import for the global budget state

class MyBudgetScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  MyBudgetScreen({required this.data});

  @override
  State<MyBudgetScreen> createState() => _MyBudgetScreenState();
}

class _MyBudgetScreenState extends State<MyBudgetScreen> {
  @override
  void initState() {
    super.initState();
    _loadBudgetData();

    // getInsights(context);
  }

  Future<void> _loadBudgetData() async {
    final String budgetId = widget.data['_id']?.toString() ?? '679b6ea12af555d641c5da61';
    await Future.wait([
      BudgetService.fetchBudgetData(widget.data),
      BudgetService.fetchBudgetInsights(budgetId),
    ]);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> deleteBudget() async {
    final String budgetId = widget.data['_id']?.toString() ?? '679b6ea12af555d641c5da61';
    await BudgetService.deleteBudget(
      budgetId,
      context,
      onDeleteSuccess: () {
        if (mounted) {
          Navigator.of(context).pop();
        }
        getBudget();
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.accentColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        title: _buildText(widget.data['name'] ?? PlotFinanceStaticData().budgetTitle, AppColors.accentColor,
            fontSize: 18, fontWeight: FontWeight.bold),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              // Show confirmation dialog before deletion
              bool? confirm = await showDialog(
                context: context,
                useRootNavigator: false,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: _buildText(PlotFinanceStaticData().deleteBudgetTitle, AppColors.bg1,
                      fontSize: 18, fontWeight: FontWeight.bold),
                  content: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildText(
                     PlotFinanceStaticData().deleteBudgetTitle,
                      AppColors.bg1,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: _buildText(PlotFinanceStaticData().cancelButton, AppColors.bg1, // Updated
                          fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: _buildText(PlotFinanceStaticData().deleteButton, AppColors.bg1, // Updated
                          fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await deleteBudget();
              }
            },
          ),
        ],
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
              _buildContentSection()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    // Check if budgetChartData is empty or all values are zero
    bool hasNoData = budgetChartData.isEmpty ||
        budgetChartData.every((item) => item.y == 0.0);

    // Add a loading indicator if data is still being fetched
    if (budgetTransactions.isEmpty && budgetInsights == null) {
      return Center(
        child:Spinner(), // Loader when data is loading
      );
    }

    if (hasNoData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: _buildText(
            PlotFinanceStaticData().noSpendingData,
            AppColors.accentColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMonthlyBudgetChart(),
        SizedBox(height: 16),
        _buildInsights(),
        SizedBox(height: 16),
        _buildCategoriesChart(),
      ],
    );
  }

  Widget _buildDaysRemaining() {
    final endDateStr = widget.data['endDate'] ?? '2025-03-04T12:07:11.028Z';
    final endDate = DateTime.parse(endDateStr);
    final daysRemaining = endDate.difference(DateTime.now()).inDays;
     final daysRemainingTotal =daysRemaining>0? daysRemaining:0;
    return Row(
      children: [
        Icon(Icons.access_time, color: AppColors.primaryColor),
        SizedBox(width: 8),
        // Text('Days remaining: $daysRemaining days',
        //     style: TextStyle(color: Colors.grey)),
         _buildText(
            PlotFinanceStaticData().daysRemaining.replaceFirst('{days}', daysRemainingTotal.toString()), // Updated
            AppColors.accentColor,
            fontSize: 13,
            fontWeight: FontWeight.w400),
      ],
    );
  }

  Widget _buildBudgetSummary() {
    double totalSpent = budgetChartData.isNotEmpty
        ? budgetChartData.map((e) => e.y).reduce((a, b) => a + b)
        : 0.0;
    return Container(
      padding: EdgeInsets.all(16),
       decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Color(0xFFF3F4F6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
          ],
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildText(PlotFinanceStaticData().budgetAmountLabel, AppColors.greyColor), // Updated
          SizedBox(height: 8),
          _buildText('₹ ${formatMoneyIndian(widget.data['amount'].toString())}',
              AppColors.primaryColor,
              fontSize: 20, fontWeight: FontWeight.w500),
          SizedBox(height: 16),
          _buildRow(
            PlotFinanceStaticData().amountSpentLabel, // Updated
            '₹ ${formatMoneyIndian(totalSpent.toString())}',
            AppColors.accentColor,
          ),
          SizedBox(height: 8),
          _buildRow2(
            PlotFinanceStaticData().overSpentLabel, // Updated
            '₹ ${((totalSpent - (widget.data['amount'] as num)).clamp(0, double.infinity)).toStringAsFixed(2)}',
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
        _buildText(title, AppColors.accentColor,
            fontSize: 14, fontWeight: FontWeight.w500),
        _buildText(value, AppColors.accentColor,
            fontSize: 16, fontWeight: FontWeight.w500),
      ],
    );
  }

  Widget _buildRow2(String title, String value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildText(title, Colors.red,
            fontSize: 14, fontWeight: FontWeight.w500),
        _buildText(value, Colors.red,
            fontSize: 16, fontWeight: FontWeight.w500),
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
         _buildText(PlotFinanceStaticData().budgetSpendingTitle, AppColors.accentColor, // Updated
            fontSize: 18, fontWeight: FontWeight.bold),
        SizedBox(height: 8),
        SizedBox(
          height: MediaQuery.sizeOf(context).height / 3,
          child: LineChartSample(
              budgetData: budgetChartData, budgetType: selectedBudgetPeriod),
        ),
      ],
    );
  }

  Widget _buildInsights() {
    if (budgetInsights == null) {
    
      return Center(child: CircularProgressIndicator());
    }
    List<dynamic>? insightsList = budgetInsights; // Extract list
   
    return Container(
      padding: EdgeInsets.all(16),
      // decoration: _buildBackgroundDecoration(),
      decoration: BoxDecoration(
        color: AppColors.mt,
        borderRadius: BorderRadius.circular(12),
         border: Border.all(
            color: Color(0xFFF3F4F6),
            width: 1,
          ),
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
          _buildText(PlotFinanceStaticData().budgetSpendingTitle, AppColors.accentColor, // Updated
            fontSize: 18, fontWeight: FontWeight.bold),
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
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Color(0xFFF3F4F6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
          ],
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
              :  _buildText(PlotFinanceStaticData().insightsTitle, AppColors.accentColor, // Updated
              fontSize: 16, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }

  Widget graph() {
    return PieChartGraph(
      title: "Categories",
      graphData: pieGraphData,
      graphDisc: [],
    );
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
  final List<BudgetChartDataPoint> budgetData;
  final String budgetType;

  LineChartSample({required this.budgetData, required this.budgetType});
  bool _isAllZero(List<BudgetChartDataPoint> data) {
    return data.every((item) => item.y == 0.0);
  }

  @override
  Widget build(BuildContext context) {
    if (budgetData.isEmpty || _isAllZero(budgetData)) {
      return Center(
        child: Text(
          PlotFinanceStaticData().noSpendingData,
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.bold, fontSize: 12, color: AppColors.accentColor),
        ),
      );
    }
    double labelWidth;
    double labelRotation;

    switch (budgetType) {
      case 'weekly':
        labelWidth = 50.0;
        labelRotation = 0;
        break;
      case 'monthly':
        labelWidth = 60.0;
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
    return budgetData.isNotEmpty
        ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: math.max(chartWidth, MediaQuery.of(context).size.width),
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                borderWidth: 0,
                primaryXAxis: CategoryAxis(
                  labelStyle: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w400,
                      fontSize: 10,
                      color: AppColors.accentColor),
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
                  labelStyle: FontManager().getTextStyle(context,
                      lWeight: FontWeight.w400,
                      fontSize: 10,
                      color: AppColors.accentColor),
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
                  SplineAreaSeries<BudgetChartDataPoint, String>(
                    dataSource: budgetData,
                    xValueMapper: (BudgetChartDataPoint data, _) => data.xString,
                    yValueMapper: (BudgetChartDataPoint data, _) => data.y,
                    color: AppColors.primaryColor
                        .withOpacity(0.2), // Faded area color
                    borderWidth: 0, // No border, just the area
                    enableTooltip: false, // Disable tooltip for the area layer
                    splineType: SplineType.cardinal,
                    cardinalSplineTension: 0.9,
                  ),
                  SplineSeries<BudgetChartDataPoint, String>(
                    dataSource: budgetData,
                    xValueMapper: (BudgetChartDataPoint data, _) => data.xString,
                    yValueMapper: (BudgetChartDataPoint data, _) => data.y,
                    color: AppColors.primaryColor,
                    width: 1,
                    splineType: SplineType.cardinal,
                    cardinalSplineTension: 0.9,
                    name: '', // Hide series name
                  ),
                ],
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  builder: (dynamic data, dynamic point, dynamic series,
                      int pointIndex, int seriesIndex) {
                    final BudgetChartDataPoint chartData = data as BudgetChartDataPoint;
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.accentColor,
                      ),
                      padding: EdgeInsets.all(8),
                      child: Text('₹${chartData.y.toStringAsFixed(2)}',
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w400,
                              fontSize: 10,
                              color: AppColors.backgroundColor)),
                    );
                  },
                ),
              ),
            ),
          )
        : Center(
            child: Text(
               PlotFinanceStaticData().noSpendingData,
              style: FontManager().getTextStyle(context,
                  lWeight: FontWeight.bold, fontSize: 12, color: AppColors.accentColor),
            ),
          );
  }
}