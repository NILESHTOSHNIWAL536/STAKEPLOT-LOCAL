import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/ManuallyTransactions/manually.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finora_last2months_dashboard.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/headsUpAndMoneyMap.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finance_chart.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/categoriseSpending.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/nextFetch.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/finora.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/banksCardsSlider.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

class IndexScreen extends StatelessWidget {
  const IndexScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    final double debit = totalDebitThisMonth.value;
    final bool isZeroOrNegative = debit <= 0;
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
            // SizedBox(
            //   height: height * 0.21,
            //   child: SwipeableCardsScreen(),
            // ),
         

SizedBox(
  height: height * (isZeroOrNegative ? 0.54 : 0.21),
  child: isZeroOrNegative 
      ? FinoraLastTwoMonthsDashboard() 
      : SwipeableCardsScreen(),
),

            SizedBox(
                height: height * 0.5,
                child: InsightsScreen()
            ),
            DoughnutChartExample(),
            const SizedBox(
              height: 14,
            ),

            SizedBox(
                height: 30,
                child:  Text(HomepageStringsDart().madeWithLove,
                          style: FontManager().getTextStyle(context,
                              lWeight: FontWeight.w500,
                              fontSize: 16,
                              color: AppColors.primaryColor)),
            )
          ],
        ),
      ),
    );
  }
}
