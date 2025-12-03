import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/finora_last_two_months_apis.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/init_hive.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
import 'package:flutter_application_code_stakeplot/repository/finora_repository.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../routes/route_transactions.dart';

Map<String, dynamic> finoraTransactionData = {};
RxBool FinoraLoading = false.obs;

class FinoraLastTwoMonthsDashboard extends StatefulWidget {
  @override
  _FinoraLastTwoMonthsDashboardState createState() =>
      _FinoraLastTwoMonthsDashboardState();
}

class _FinoraLastTwoMonthsDashboardState
    extends State<FinoraLastTwoMonthsDashboard> {
  RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    getFinoraPreviousMonthData();
    // initFinoraLastTwoMonthsData();
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
          child: Obx(
        () => isLoading.value
            ? Center(child: Spinner())
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards Row
                    textStyleImage(
                      context: context,
                      text: HomepageStringsDart().finora,
                      fontsize: 16,
                      c: AppColors.accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 14),

                    Obx(() =>
                        FinoraLoading.value ? getFindata() : getFindata()),
                    const SizedBox(height: 10),
                    // Chart Container
                    Container(
                      height: MediaQuery.sizeOf(context).height / 3,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: _calculateChartWidth(),
                          height: double.infinity, // Use full available height
                          child: _buildSpendingChart(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      )),
    );
  }

  Widget getFindata() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            finoraTransactionData['month2Name']?.toString() ?? 'June 2025',
            '₹ ${_formatAmount(finoraTransactionData['month2Avg'])}',
            AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            context,
            finoraTransactionData['month1Name']?.toString() ?? 'May 2025',
            '₹ ${_formatAmount(finoraTransactionData['month1Avg'])}',
            AppColors.finoraMonth,
          ),
        ),
      ],
    );
  }

  double _calculateChartWidth() {
    final month1Data = _getMonth1Data();
    final month2Data = _getMonth2Data();
    final maxDataPoints = month1Data.length > month2Data.length
        ? month1Data.length
        : month2Data.length;
    return maxDataPoints * 26.0;
  }

  Widget _buildSummaryCard(
      BuildContext context, String month, String amount, Color indicatorColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(89, 89, 89, 0.25),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                month,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w500,
                  fontSize: 12,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Avg/Day Spending',
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w500,
              fontSize: 10,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.bg1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingChart() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      // Increased margins to prevent clipping

      primaryXAxis: CategoryAxis(
        isVisible: false,
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        majorGridLines: const MajorGridLines(width: 0),
        labelRotation: 0,
      ),
      primaryYAxis: NumericAxis(
        isVisible: false,
        //  minimum: 0,
        maximum: _getMaxY(),
        // Add extra range for spline curves
        rangePadding: ChartRangePadding.additional,
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        builder: (dynamic data, dynamic point, dynamic series, int pointIndex,
            int seriesIndex) {
          final String month = seriesIndex == 0
              ? (finoraTransactionData['month1Name']?.toString() ?? 'Month 1')
              : (finoraTransactionData['month2Name']?.toString() ?? 'Month 2');
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$month\nDay: ${data.x}\n₹ ${_formatAmount(data.y)}',
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w600,
                fontSize: 10,
                color: AppColors.backgroundColor,
              ),
            ),
          );
        },
      ),
      series: <ChartSeries>[
        // Month1 line
        SplineSeries<ChartData, String>(
          dataSource: _getMonth1Data(),
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          color: AppColors.primaryColor,
          width: 4,
          // Use natural spline for smoother curves
          splineType: SplineType.natural,
          markerSettings: const MarkerSettings(
            isVisible: false,
            color: AppColors.primaryColor,
            borderColor: AppColors.backgroundColor,
            borderWidth: 1,
            height: 6,
            width: 6,
          ),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w600,
              fontSize: 10,
              color: AppColors.bg1,
            ),
            builder: (dynamic data, dynamic point, dynamic series,
                int pointIndex, int seriesIndex) {
              if (pointIndex == _getPeakIndex(_getMonth1Data())) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    '₹ ${_formatAmount(data.y)}',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w600,
                      fontSize: 10,
                      color: AppColors.bg1,
                    ),
                  ),
                );
              }
              return Container();
            },
          ),
        ),
        // Month2 line
        SplineSeries<ChartData, String>(
          dataSource: _getMonth2Data(),
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          color: AppColors.finoraMonth,
          width: 4,
          // Use natural spline for smoother curves
          splineType: SplineType.natural,
          markerSettings: const MarkerSettings(
            isVisible: false,
            color: AppColors.finoraMonth,
            borderColor: AppColors.backgroundColor,
            borderWidth: 1,
            height: 6,
            width: 6,
          ),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
            textStyle: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.w600,
              fontSize: 10,
              color: AppColors.bg1,
            ),
            builder: (dynamic data, dynamic point, dynamic series,
                int pointIndex, int seriesIndex) {
              if (pointIndex == _getMonth2Data().length - 1) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    '₹ ${_formatAmount(data.y)}',
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w600,
                      fontSize: 10,
                      color: AppColors.bg1,
                    ),
                  ),
                );
              }
              return Container();
            },
          ),
        ),
      ],
    );
  }

  List<ChartData> _getMonth1Data() {
    List<ChartData> data = [];
    if (finoraTransactionData.containsKey('month1DailySums')) {
      List<dynamic> dailySums = finoraTransactionData['month1DailySums'] ?? [];
      for (int i = 0; i < dailySums.length; i++) {
        final day = dailySums[i]['day']?.toString() ?? (i + 1).toString();
        final amount = _parseAmount(dailySums[i]['amount']);
        data.add(ChartData(day, amount));
      }
    }
    return data.isEmpty ? [ChartData('1', 0.0)] : data;
  }

  List<ChartData> _getMonth2Data() {
    List<ChartData> data = [];
    if (finoraTransactionData.containsKey('month2DailySums')) {
      List<dynamic> dailySums = finoraTransactionData['month2DailySums'] ?? [];
      for (int i = 0; i < dailySums.length; i++) {
        final day = dailySums[i]['day']?.toString() ?? (i + 1).toString();
        final amount = _parseAmount(dailySums[i]['amount']);
        data.add(ChartData(day, amount));
      }
    }
    return data.isEmpty ? [ChartData('1', 0.0)] : data;
  }

  double _getMinY() {
    final month1Data = _getMonth1Data();
    final month2Data = _getMonth2Data();

    List<double> allValues = [];
    allValues.addAll(month1Data.map((e) => e.y));
    allValues.addAll(month2Data.map((e) => e.y));

    if (allValues.isEmpty) return 0.0;

    double min = allValues.reduce((a, b) => a < b ? a : b);
    // Increase padding to 30% below minimum to accommodate spline curves
    return min;
  }

  double _getMaxY() {
    final month1Data = _getMonth1Data();
    final month2Data = _getMonth2Data();

    List<double> allValues = [];
    allValues.addAll(month1Data.map((e) => e.y));
    allValues.addAll(month2Data.map((e) => e.y));

    if (allValues.isEmpty) return 1000.0;

    double max = allValues.reduce((a, b) => a > b ? a : b);
    // Increase padding to 30% above maximum to accommodate spline curves
    return max * 1.3;
  }

  int _getPeakIndex(List<ChartData> data) {
    if (data.isEmpty) return 0;
    double maxY = data.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    return data.indexWhere((element) => element.y == maxY);
  }

  double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
    }
    return 0.0;
  }

  String _formatAmount(dynamic value) {
    double amount = _parseAmount(value);
    return amount.toStringAsFixed(2);
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}
