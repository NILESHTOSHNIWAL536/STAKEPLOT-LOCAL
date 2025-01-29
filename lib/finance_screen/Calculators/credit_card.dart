
import 'dart:math'; // Import math library for log function
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/plot_finance.dart';

class CreditCard extends StatefulWidget {
  const CreditCard({Key? key}) : super(key: key);

  @override
  _CreditCardState createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> {
  late List slidersList;
  double cardBalance = 2000;
  double totalInterestPaid = 0;
  double monthlyPayment = 600;
  double interestRate = 7;
  int monthsToPayOff = 0;

  @override
  void initState() {
    super.initState();
    getslidersList();
  }

  void getslidersList() {
    slidersList = [
      getJsonBodyObj("Card balance", 2000, 1000, 100000, (value) {
        updateSliderValue(0, value);
      }, TextEditingController(text: '2000')),
      getJsonBodyObj("Interest rate(%)", 7, 1, 10, (value) {
        updateSliderValue(1, value);
      }, TextEditingController(text: '7')),
      getJsonBodyObj("Monthly payment", 600, 10, 5000, (value) {
        updateSliderValue(2, value);
      }, TextEditingController(text: '600')),
    ];
  }

  

  // Callback function to update slider values and recalculate payoff details
  void updateSliderValue(int index, double newValue) {
    setState(() {
      slidersList[index]['value'] = newValue;
      slidersList[index]['controller'].text = newValue.toStringAsFixed(0);

      cardBalance = slidersList[0]['value'];
      interestRate = slidersList[1]['value'];
      monthlyPayment = slidersList[2]['value'];

      monthsToPayOff = calculateMonthsToPayOff(cardBalance, interestRate, monthlyPayment);
      totalInterestPaid = calculateTotalInterest(cardBalance, interestRate, monthsToPayOff);
    });
  }

  // Calculate the number of months to pay off the debt using logarithmic formula
  int calculateMonthsToPayOff(double balance, double annualRate, double monthlyPayment) {
    double monthlyRate = annualRate / 12 / 100;

    if (monthlyPayment <= balance * monthlyRate) {
      return double.infinity.toInt(); // Prevent infinite loop
    }

    int months = (log(monthlyPayment / (monthlyPayment - balance * monthlyRate)) / log(1 + monthlyRate)).ceil();
    return months.isFinite ? months : 0;
  }

  // Calculate total interest paid
  double calculateTotalInterest(double balance, double annualRate, int months) {
    double totalInterest = 0;
    double monthlyRate = annualRate / 12 / 100;
    
    for (int i = 0; i < months; i++) {
      double interest = balance * monthlyRate;
      totalInterest += interest;
      balance -= (monthlyPayment - interest);
      if (balance <= 0) break;
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
              SliderPage(slidersList: slidersList, onSliderValueChanged: updateSliderValue),
              graph(),
              CustomExpansionTile(
                howToUseContent: [
                  ListItemModel(
                    title: "Months to Pay Off:",
                    description: "Number of months required to clear the balance: $monthsToPayOff"
                  ),
                  ListItemModel(
                    title: "Total Interest Paid:",
                    description: "Total interest over the repayment period: ₹${totalInterestPaid.toStringAsFixed(2)}"
                  ),
                ],
                howItWorksContent: [
                  ListItemModel(
                    title: "Monthly Interest Rate:",
                    description: "Annual rate is divided by 12 and converted to decimal."
                  ),
                  ListItemModel(
                    title: "Logarithmic Formula:",
                    description: "Mathematically estimates the time required to clear the debt."
                  ),
                  ListItemModel(
                    title: "Total Interest Calculation:",
                    description: "Iteratively calculates interest over each month until payoff."
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget graph() {
    return PieChartGraph(
      title: "Breakdown",
      graphData: [
        {'title': 'Principal\n₹${(cardBalance).toStringAsFixed(2)}', 'value': cardBalance},
        {'title': 'Interest\n₹${(totalInterestPaid).toStringAsFixed(2)}', 'value': totalInterestPaid},
      ],
      graphDisc: [
       
        {'title': 'Months to Pay Off:', 'amount': "$monthsToPayOff"},
        {'title': 'Total Interest Paid:', 'amount': "₹${totalInterestPaid.toStringAsFixed(2)}"}
      ],
    );
  }
}
