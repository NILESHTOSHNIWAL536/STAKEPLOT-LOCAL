import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finance_chart.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';
class ExpandedFinance extends StatelessWidget {
  const ExpandedFinance({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Expanded Finance View'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: FinancePage(
        isExpandedView: true,
        showMonthYearFilter: true,
      ),
    );
  }
}