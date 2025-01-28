import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/';

class PieChartgraph extends StatefulWidget {
  const PieChart({super.key});

  @override
  State<PieChartgraph> createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  @override
  Widget build(BuildContext context) {
    return buildPieChart();
  }
}
Widget buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: cardBalance,
            title: 'Principal\n₹${cardBalance.toStringAsFixed(0)}',
            color: AppColors.primaryColor,
            radius: 50,
          ),
          PieChartSectionData(-
            value: totalInterestPaid,
            title: 'Interest\n₹${totalInterestPaid.toStringAsFixed(0)}',
            color: AppColors.uncoloredPie,
            radius: 50,
          ),
        ],
      ),
    );
  }