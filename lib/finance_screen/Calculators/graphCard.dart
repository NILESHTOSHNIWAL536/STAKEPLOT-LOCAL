import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';

  double cardBalance=300.0;
  double totalInterestPaid=130.0;

class PieChartGraph extends StatefulWidget {
  const PieChartGraph({super.key});

  @override
  State<PieChartGraph> createState() => _PieChartGraphState();
}

class _PieChartGraphState extends State<PieChartGraph> {


  @override
  Widget build(BuildContext context) {
    return buildPieChart();
  }

Widget buildPieChart() {
    return Container(
        width: MediaQuery.of(context).size.width/1.1,
                height:  MediaQuery.of(context).size.height/4,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: cardBalance,
              title: 'Principal\n₹${cardBalance.toStringAsFixed(0)}',
              color: AppColors.primaryColor,
              radius: 50,
            ),
            PieChartSectionData(
              value: totalInterestPaid,
              title: 'Interest\n₹${totalInterestPaid.toStringAsFixed(0)}',
              color: AppColors.uncoloredPie,
              radius: 50,
            ),
          ],
        ),
      ),
    );
  }

  
}