import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/plot_finance.dart';

class Savings extends StatefulWidget {
  const Savings({Key? key}) : super(key: key);

  @override
  _SavingsState createState() => _SavingsState();
}

class _SavingsState extends State<Savings> {
  late List slidersList;

  double targetAmount = 2300.0;
  double currentSavings = 400.0;
  double monthlyContribution = 400.0;
  int timeframe = 4;
  double interestRate = 4.0;

  double endBalance = 0.0;
  double interestEarned = 0.0;
  double goalProgress = 0.0;
  double remainingAmount = 0.0;
  List<double> savingsData = [];

  @override
  void initState() {
    super.initState();
    getslidersList();
    calculateSavings(); // Initial calculation
  }

  void getslidersList() {
    slidersList = [
      getJsonBodyObj("Target amount", 2300.0, 1000.0, 100000.0, (value) {
        updateSliderValue(0, value);
      }, TextEditingController(text: '2300')),
      getJsonBodyObj("Current savings", 400.0, 0.0, 100000.0, (value) {
        updateSliderValue(1, value);
      }, TextEditingController(text: '400')),
      getJsonBodyObj("Monthly contribution", 400.0, 100.0, 10000.0, (value) {
        updateSliderValue(2, value);
      }, TextEditingController(text: '400')),
      getJsonBodyObj("Timeframe(months)", 4.0, 1.0, 360.0, (value) {
        updateSliderValue(3, value);
      }, TextEditingController(text: '4'), false, "Months"),
      getJsonBodyObj("Interest rate(%)", 4.0, 0.0, 10.0, (value) {
        updateSliderValue(4, value);
      }, TextEditingController(text: '4.0'), false, "%"),
    ];
  }

  void updateSliderValue(int index, double newValue) {
    double min = slidersList[index]['min'];
    double max = slidersList[index]['max'];
    newValue = newValue.clamp(min, max);

    setState(() {
      if (index != 4) {
        newValue = newValue.roundToDouble(); // Integer for non-interest fields
      }
      slidersList[index]['value'] = newValue;
      slidersList[index]['controller'].text =
          (index == 4) ? newValue.toStringAsFixed(1) : newValue.toStringAsFixed(0);

      targetAmount = slidersList[0]['value'];
      currentSavings = slidersList[1]['value'];
      monthlyContribution = slidersList[2]['value'];
      timeframe = slidersList[3]['value'].toInt();
      interestRate = slidersList[4]['value'];

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

    endBalance = totalSavings;
    interestEarned = totalInterest;
    goalProgress = ((totalSavings / targetAmount) * 100).clamp(0, 100); // Updated to use totalSavings
  }

  final List<ListItemModel> howToUseContent = [
    ListItemModel(
        title: "Target Amount:",
        description: "Adjust the slider to set your savings goal (e.g., ₹2300)."),
    ListItemModel(
        title: "Current Savings:",
        description: "Set your current savings amount (e.g., ₹400)."),
    ListItemModel(
        title: "Monthly Contribution:",
        description: "Set your monthly savings contribution (e.g., ₹400)."),
    ListItemModel(
        title: "Timeframe (Months):",
        description: "Set the duration in months (e.g., 4 months)."),
    ListItemModel(
        title: "Interest Rate (%):",
        description: "Set the annual interest rate (e.g., 4.5%)."),
  ];

  final List<ListItemModel> howItWorksContent = [
    ListItemModel(
        title: "Monthly Savings Calculation:",
        description: "Adds monthly contributions and interest earned each month."),
    ListItemModel(
        title: "End Balance Calculation:",
        description: "Projects total savings after timeframe, including interest."),
    ListItemModel(
        title: "Interest Earned Calculation:",
        description: "Estimates total interest based on rate and contributions."),
    ListItemModel(
        title: "Goal Progress Tracking:",
        description: "Shows progress as a percentage of the target amount."),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarHeader("Savings Goal Calculator", context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SliderPage(slidersList: slidersList, onSliderValueChanged: updateSliderValue),
              graph(),
              CustomExpansionTile(
                howToUseContent: howToUseContent,
                howItWorksContent: howItWorksContent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget graph() {
    return PieChartGraph(
      title: "Savings Goal Progress:",
      graphData: [
        {'title': 'Remaining Amount: ₹${remainingAmount.toStringAsFixed(0)}', 'value': remainingAmount},
        {'title': 'Current Savings: ₹${endBalance.toStringAsFixed(0)}', 'value': endBalance}, // Updated to use endBalance
      ],
      graphDisc: [
        {'title': 'End Balance:', 'amount': "₹${endBalance.toStringAsFixed(2)}"},
        {'title': 'Interest Earned:', 'amount': "₹${interestEarned.toStringAsFixed(2)}"},
        {'title': 'Progress:', 'amount': "${goalProgress.toStringAsFixed(2)}%"},
      ],
    );
  }
}

PreferredSizeWidget appbarHeader(String title, BuildContext context) {
  return AppBar(
    centerTitle: true,
    title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
  );
}