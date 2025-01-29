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


  double targetAmount = 2300;
  double currentSavings = 400;
  double monthlyContribution = 400;
  int timeframe = 4;
  double interestRate = 4;

  double endBalance = 0;
  double interestEarned = 0;
  double goalProgress = 0;
   double remainingAmount = 0;
  List<double> savingsData = [];

  @override
  void initState() {
    getslidersList();
  }

  void getslidersList() {
    slidersList = [
      getJsonBodyObj("Target amount", 2300, 1000, 100000, (value) {},
          TextEditingController(text: '2')),
      getJsonBodyObj("Current savings", 4, 0, 100000, (value) {},
          TextEditingController(text: '332')),
      getJsonBodyObj("Monthly contribution", 400, 100, 10000, (value) {},
          TextEditingController(text: '2332')),
      getJsonBodyObj("Timeframe(months)", 4, 1, 360, (value) {},
          TextEditingController(text: '2332'),false,"Months"),
      getJsonBodyObj("Interest rate (%)", 4, 0, 10, (value) {},
          TextEditingController(text: '2332'),false,"%"),
    ];
  }

  final List<ListItemModel> howToUseContent = [
    ListItemModel(
        title: "Target Amount",
        description:
            "Adjust the slider to set the desired savings goal amount."),
    ListItemModel(
        title: "Current Savings",
        description:
            "Use the slider to set the current amount of savings you have accumulated."),
    ListItemModel(
        title: "Monthly Contribution",
        description:
            "Set the monthly amount you plan to contribute towards your savings goal."),
    ListItemModel(
        title: "Timeframe (Months)",
        description:
            "Adjust the slider to set the duration in months over which you aim to achieve your savings goal."),
    ListItemModel(
        title: "Interest Rate (%)",
        description: "Set the expected annual interest rate for your savings."),
  ];

  // Example data for "How it works?"
  final List<ListItemModel> howItWorksContent = [
    ListItemModel(
        title: "Monthly Savings Calculation",
        description:
            "The calculator determines the total savings by adding your monthly contributions and the interest earned each month."),
    ListItemModel(
        title: "End Balance Calculation",
        description:
            "This represents the projected total savings at the end of the specified timeframe, considering both contributions and accrued interest."),
    ListItemModel(
        title: "Interest Earned Calculation",
        description:
            "The calculator estimates the total interest earned over the savings period based on the interest rate and contributions."),
    ListItemModel(
        title: "Goal Progress Tracking",
        description:
            "The progress towards your savings goal is displayed as a percentage, indicating how close you are to reaching your target amount."),
  ];

  

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
                  SliderPage(slidersList: slidersList,onSliderValueChanged: updateSliderValue),
                  graph(),
                  CustomExpansionTile(
                    howToUseContent: howToUseContent,
                    howItWorksContent: howItWorksContent,
                  ),
                ],
              ),
            )));
  }

 Widget graph() {
    return PieChartGraph(title: "Savings goal progress:", graphData: [
      {'title': 'Remaining amount\n₹${remainingAmount.toStringAsFixed(2)}', 'value': remainingAmount},
      {'title': 'Current savings\n₹${currentSavings.toStringAsFixed(2)}', 'value': currentSavings},
    ], graphDisc:  [
      {
        'title': 'End balance:', 
        'amount': "₹ ${endBalance.toStringAsFixed(2)}"
      },
      {'title': 'Interest earned:', 'amount': "₹ ${interestEarned.toStringAsFixed(2)}"},
      {'title': 'Progress:', 'amount': "${goalProgress.toStringAsFixed(2)}%"},
    ]);
  }





     // Callback function to update the slider values
  void updateSliderValue(int index, double newValue)
  {
    setState(() {
      slidersList[index]['value'] = newValue;
      slidersList[index]['controller'].text = newValue.toStringAsFixed(0);
      switch (index) {
        case 0:
          targetAmount = newValue;
          break;
        case 1:
          currentSavings = newValue;
          break;
        case 2:
          monthlyContribution = newValue;
          break;
        case 3:
          timeframe = newValue.toInt();
          break;
        case 4:
          interestRate = newValue;
          break;
      }
      calculateSavings();
    });
  }

   void calculateSavings() {
    double totalSavings = currentSavings;
    double monthlyRate = interestRate / 100 / 12;
    savingsData.clear();

    for (int i = 0; i < timeframe; i++) {
      totalSavings += monthlyContribution;
      totalSavings += totalSavings * monthlyRate;
      savingsData.add(totalSavings);
    }

    double totalInterest = totalSavings - (currentSavings + monthlyContribution * timeframe);
    remainingAmount = targetAmount - totalSavings;
    remainingAmount = remainingAmount < 0 ? 0 : remainingAmount;

    setState(() {
      endBalance = totalSavings;
      interestEarned = totalInterest;
      goalProgress = ((currentSavings / targetAmount) * 100).clamp(0, 100);
    });
  }

}
