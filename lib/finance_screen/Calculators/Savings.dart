import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/creditCard.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/plot_finance.dart';

class Savings extends StatefulWidget {
  const Savings({Key? key}) : super(key: key);

  @override
  _SavingsState createState() => _SavingsState();
}

class _SavingsState extends State<Savings> {
  late List slidersList;

  @override
  void initState() {
    getslidersList();
  }

  void getslidersList() {
    slidersList = [
      getJsonBodyObj("Target amount", 4, 3, 12, (value) {},
          TextEditingController(text: '2')),
      getJsonBodyObj("Current savings", 4, 1, 12, (value) {},
          TextEditingController(text: '332')),
      getJsonBodyObj("Monthly contribution", 4, 1, 12, (value) {},
          TextEditingController(text: '2332')),
      getJsonBodyObj("Timeframe(months)", 4, 1, 12, (value) {},
          TextEditingController(text: '2332')),
      getJsonBodyObj("Interest rate (%)", 4, 1, 12, (value) {},
          TextEditingController(text: '2332')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appbarHeader("Savings goal calculator ", context),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SliderPage(slidersList: slidersList),
                  PieChartGraph(),
                  CustomExpansionTile(
                    howToUseContent: Expansioncalculator.creditcardTitle1,
                    howItWorksContent: Expansioncalculator.creditcardTitle2,
                  ),
                ],
              ),
            )));
  }
}
