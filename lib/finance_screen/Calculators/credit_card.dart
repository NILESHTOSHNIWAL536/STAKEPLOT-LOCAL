import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';

import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';

class CreditCard extends StatefulWidget {
  const CreditCard({Key? key}) : super(key: key);

  @override
  _CreditCardState createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> {
  late List slidersList;
  double cardBalance = 0;
  double totalInterestPaid = 0;
  double monthlyPayment = 0;

  @override
  void initState() {
    super.initState();
    getslidersList();
  }

  void getslidersList() {
    slidersList = [
      getJsonBodyObj("Card balance", 2000, 1000, 10000, (value) {},
          TextEditingController(text: '2000')),
      getJsonBodyObj("Interest rate(%)", 4, 1, 30, (value) {},
          TextEditingController(text: '7')),
      getJsonBodyObj("Monthly payment", 600, 500, 5000, (value) {},
          TextEditingController(text: '600')),
    ];
  }

  Map<String, dynamic> getJsonBodyObj(
      String name,
      double value,
      double min,
      double max,
      Function(double) onChanged,
      TextEditingController controller) {
    return {
      'name': name,
      'value': value,
      'min': min,
      'max': max,
      'onChanged': onChanged,
      'controller': controller,
    };
  }

  final List<ListItemModel> howToUseContent = [
    ListItemModel(
        title: "1. Credit Card Balance:",
        description:
            "Input: Use the slider to set your current balance (e.g., ₹5,000)"),
    ListItemModel(
        title: "2. Credit Card Interest Rate:",
        description:
            "Input: Use the slider to set your annual interest rate (e.g., 18%)."),
    ListItemModel(
        title: "3. Monthly Payment:",
        description:
            "Input: Use the slider to set your planned monthly payment (e.g., ₹200)."),
  ];

  // Example data for "How it works?"

  final List<ListItemModel> howItWorksContent = [
    ListItemModel(
        title: "Monthly Interest Rate:",
        description: "Converts the annual interest rate to a monthly rate."),
    ListItemModel(
        title: "Months to Pay Off Debt:",
        description:
            "Calculates the number of months to pay off the debt using your balance, monthly payment, and interest rate."),
    ListItemModel(
        title: "Total Interest Paid:",
        description:
            "Computes the total interest paid over the repayment period. "),
    ListItemModel(
        title: "Payoff Details:",
        description:
            "Computes the total interest paid over the repayment period. "),
    ListItemModel(
        title: "Months to Pay Off:",
        description:
            "Displays the number of months required to pay off your debt."),
    ListItemModel(
        title: "Total Interest Paid:",
        description:
            "Shows the total interest you will pay over the repayment period."),
  ];

  // Callback function to update the slider values
  void updateSliderValue(int index, double newValue) {
    setState(() {
      slidersList[index]['value'] = newValue;
      slidersList[index]['controller'].text = newValue.toStringAsFixed(0);
    });

    cardBalance = slidersList[0]['value'];
    double interestRate = slidersList[1]['value'];
    monthlyPayment = slidersList[2]['value'];

    // Calculate number of months
    int months =
        calculateMonthsToPayOff(cardBalance, interestRate, monthlyPayment);

    // Calculate total interest paid
    totalInterestPaid =
        calculateTotalInterest(cardBalance, interestRate, months);
    setState(() {});
  }

  double calculateInterest(double interestRate) {
    // Use a simple calculation to demonstrate
    // In a real app, this would be a more complex formula
    return cardBalance * (interestRate / 100);
  }

  int calculateMonthsToPayOff(
      double balance, double annualRate, double monthlyPayment) {
    double monthlyRate = annualRate / 12 / 100;
    int months = 0;

    while (balance > 0) {
      balance = balance + balance * monthlyRate - monthlyPayment;
      if (balance < 0) break;
      months++;
    }

    return months;
  }

  double calculateTotalInterest(double balance, double annualRate, int months) {
    double totalInterest = 0;
    double monthlyRate = annualRate / 12 / 100;

    for (int i = 0; i < months; i++) {
      double interest = balance * monthlyRate;
      totalInterest += interest;
      balance -= (monthlyPayment - interest);
    }

    return totalInterest;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text("Credit Card Payoff Calculator"),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SliderPage(
                  slidersList: slidersList,
                  onSliderValueChanged: updateSliderValue),
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
      title: "Fetch",
      graphData: [
        {'title': 'Principal\n₹${(cardBalance).toString()}', 'value': cardBalance},
        {'title': 'Interest\n₹${(totalInterestPaid).toString()}', 'value': totalInterestPaid},
      ],
      graphDisc: [
        {
          'title': 'Monthly pay off:',
          'amount': "₹ ${(monthlyPayment).toString()}",
        },
        {'title': 'Total interest paid:', 'amount': "₹ ${(totalInterestPaid).toString()}"}
      ],
    );
  }
}
