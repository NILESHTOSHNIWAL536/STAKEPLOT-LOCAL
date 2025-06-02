import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/manually.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/headsUpAndMoneyMap.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finance_chart.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/categoriseSpending.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/nextFetch.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finora.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/banksCardsSlider.dart';

class IndexScreen extends StatelessWidget {
  const IndexScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
          child: SingleChildScrollView(
        child: Column(
          children: [
            Nextfetch(),
            SizedBox(
              height: height * 0.23,
              child: NumberPickerScreen(),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: height * 0.51,
              child: FinancePage(),
            ),
            SizedBox(
              height: height * 0.16,
              child: Manualtransaction(),
            ),
            const SizedBox(
              height: 14,
            ),
            SizedBox(
              height: height * 0.21,
              child: SwipeableCardsScreen(),
            ),
            SizedBox(
                height: height * 0.5,
                child: InsightsScreen()
            ),
            DoughnutChartExample()
          ],
        ),
      ),
    );
  }
}
