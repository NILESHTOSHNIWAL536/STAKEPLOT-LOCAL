
// import 'dart:math'; // Import math library for log function
// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/plot_finance.dart';

// class CreditCard extends StatefulWidget {
//   const CreditCard({Key? key}) : super(key: key);

//   @override
//   _CreditCardState createState() => _CreditCardState();
// }

// class _CreditCardState extends State<CreditCard> {
//   late List slidersList;
//   double cardBalance = 2000;
//   double totalInterestPaid = 0;
//   double monthlyPayment = 600;
//   double interestRate = 7;
//   int monthsToPayOff = 0;

//   @override
//   void initState() {
//     super.initState();
//     getslidersList();
//   }

//   void getslidersList() {
//   // Create controllers first
//   var balanceController = TextEditingController(text: '2000');
//   var interestController = TextEditingController(text: '7');
//   var paymentController = TextEditingController(text: '600');

//   // Add listeners to update slider values when text changes
//   balanceController.addListener(() {
//     double? newValue = double.tryParse(balanceController.text);
//     if (newValue != null) {
//       updateSliderValue(0, newValue);
//     }
//   });

//   interestController.addListener(() {
//     double? newValue = double.tryParse(interestController.text);
//     if (newValue != null) {
//       updateSliderValue(1, newValue);
//     }
//   });

//   paymentController.addListener(() {
//     double? newValue = double.tryParse(paymentController.text);
//     if (newValue != null) {
//       updateSliderValue(2, newValue);
//     }
//   });

//   slidersList = [
//     getJsonBodyObj("Card balance", 2000, 1000, 100000, (value) {
//       updateSliderValue(0, value);
//     }, balanceController),
//     getJsonBodyObj("Interest rate(%)", 7, 1, 10, (value) {
//       updateSliderValue(1, value);
//     }, interestController),
//     getJsonBodyObj("Monthly payment", 600, 10, 5000, (value) {
//       updateSliderValue(2, value);
//     }, paymentController),
//   ];
// }

// void updateSliderValue(int index, double newValue) {
//   // Add bounds checking to ensure value is within min/max
//   double min = slidersList[index]['min'];
//   double max = slidersList[index]['max'];
//   newValue = newValue.clamp(min, max);

//   setState(() {
//     slidersList[index]['value'] = newValue;
//     // Only update text if it's different to avoid infinite loop with listener
//     if (slidersList[index]['controller'].text != newValue.toStringAsFixed(0)) {
//       slidersList[index]['controller'].text = newValue.toStringAsFixed(0);
//     }

//     cardBalance = slidersList[0]['value'];
//     interestRate = slidersList[1]['value'];
//     monthlyPayment = slidersList[2]['value'];

//     monthsToPayOff = calculateMonthsToPayOff(cardBalance, interestRate, monthlyPayment);
//     totalInterestPaid = calculateTotalInterest(cardBalance, interestRate, monthsToPayOff);
//   });
// }
// //Calculate the number of months to pay off the debt using logarithmic formula
//   int calculateMonthsToPayOff(double balance, double annualRate, double monthlyPayment) {
//     double monthlyRate = annualRate / 12 / 100;

//     if (monthlyPayment <= balance * monthlyRate) {
//       return double.infinity.toInt(); // Prevent infinite loop
//     }

//     int months = (log(monthlyPayment / (monthlyPayment - balance * monthlyRate)) / log(1 + monthlyRate)).ceil();
//     return months.isFinite ? months : 0;
//   }

//   // Calculate total interest paid
//   double calculateTotalInterest(double balance, double annualRate, int months) {
//     double totalInterest = 0;
//     double monthlyRate = annualRate / 12 / 100;
    
//     for (int i = 0; i < months; i++) {
//       double interest = balance * monthlyRate;
//       totalInterest += interest;
//       balance -= (monthlyPayment - interest);
//       if (balance <= 0) break;
//     }
//     return totalInterest;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: AppBar(
//         title: const Text("Credit Card Payoff Calculator"),
//         backgroundColor: AppColors.backgroundColor,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
              
//               SliderPage(slidersList: slidersList, onSliderValueChanged: updateSliderValue),
//               graph(),
//               CustomExpansionTile(
//                 howToUseContent: [
//                   ListItemModel(
//                     title: "Months to Pay Off:",
//                     description: "Number of months required to clear the balance: $monthsToPayOff"
//                   ),
//                   ListItemModel(
//                     title: "Total Interest Paid:",
//                     description: "Total interest over the repayment period: ₹${totalInterestPaid.toStringAsFixed(2)}"
//                   ),
//                 ],
//                 howItWorksContent: [
//                   ListItemModel(
//                     title: "Monthly Interest Rate:",
//                     description: "Annual rate is divided by 12 and converted to decimal."
//                   ),
//                   ListItemModel(
//                     title: "Logarithmic Formula:",
//                     description: "Mathematically estimates the time required to clear the debt."
//                   ),
//                   ListItemModel(
//                     title: "Total Interest Calculation:",
//                     description: "Iteratively calculates interest over each month until payoff."
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget graph() {
//     return PieChartGraph(
//       title: "Breakdown",
//       graphData: [
//         {'title': 'Principal : ₹${(cardBalance).toStringAsFixed(2)}', 'value': cardBalance},
//         {'title': 'Interest : ₹${(totalInterestPaid).toStringAsFixed(2)}', 'value': totalInterestPaid},
//       ],
//       graphDisc: [
       
//         {'title': 'Months to Pay Off:', 'amount': "$monthsToPayOff"},
//         {'title': 'Total Interest Paid:', 'amount': "₹${totalInterestPaid.toStringAsFixed(2)}"}
//       ],
//     );
//   }
// }
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/plot_finance.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/utils.dart';

class CreditCard extends StatefulWidget {
  const CreditCard({Key? key}) : super(key: key);

  @override
  _CreditCardState createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> {
  late List slidersList;
  double cardBalance = 2000.0;
  double totalInterestPaid = 0.0;
  double monthlyPayment = 600.0;
  double interestRate = 7.0;
  int monthsToPayOff = 0;

  @override
  void initState() {
    super.initState();
    getslidersList();
    calculatePayoffDetails(); // Initial calculation
  }

  void getslidersList() {
    slidersList = [
      getJsonBodyObj("Card balance", 2000.0, 1000.0, 100000.0, (value) {
        updateSliderValue(0, value);
      }, TextEditingController(text: '2000')),
      getJsonBodyObj("Interest rate(%)", 7.0, 1.0, 10.0, (value) {
        updateSliderValue(1, value);
      }, TextEditingController(text: '7.0'), true, ""),
      getJsonBodyObj("Monthly payment", 600.0, 10.0, 5000.0, (value) {
        updateSliderValue(2, value);
      }, TextEditingController(text: '600')),
    ];
  }

  void updateSliderValue(int index, double newValue) {
    double min = slidersList[index]['min'];
    double max = slidersList[index]['max'];
    newValue = newValue.clamp(min, max);

    setState(() {
      if (index != 1) {
        newValue = newValue.roundToDouble(); // Integer for non-interest fields
      }
      slidersList[index]['value'] = newValue;
      slidersList[index]['controller'].text =
          (index == 1) ? newValue.toStringAsFixed(1) : newValue.toStringAsFixed(0);

      cardBalance = slidersList[0]['value'];
      interestRate = slidersList[1]['value'];
      monthlyPayment = slidersList[2]['value'];

      calculatePayoffDetails();
    });
  }

  void calculatePayoffDetails() {
    double monthlyRate = interestRate / 12 / 100;
    if (monthlyPayment <= cardBalance * monthlyRate) {
      monthsToPayOff = double.infinity.toInt();
      totalInterestPaid = 0;
    } else {
      monthsToPayOff = (log(monthlyPayment / (monthlyPayment - cardBalance * monthlyRate)) / log(1 + monthlyRate)).ceil();
      monthsToPayOff = monthsToPayOff.isFinite ? monthsToPayOff : 0;

      double balance = cardBalance;
      totalInterestPaid = 0;
      for (int i = 0; i < monthsToPayOff && balance > 0; i++) {
        double interest = balance * monthlyRate;
        totalInterestPaid += interest;
        balance -= (monthlyPayment - interest);
      }
    }
  }

  @override
  void dispose() {
    for (var slider in slidersList) {
      slider['controller'].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text("Credit Card Payoff Calculator"),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: SafeArea(
        child: Padding(
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
                      title: "Card Balance:",
                      description: "Adjust the slider to set your current credit card balance (e.g., ₹2000).",
                    ),
                    ListItemModel(
                      title: "Interest Rate:",
                      description: "Adjust the slider to set your annual interest rate (e.g., 7.5%).",
                    ),
                    ListItemModel(
                      title: "Monthly Payment:",
                      description: "Adjust the slider to set your monthly payment amount (e.g., ₹600).",
                    ),
                  ],
                  howItWorksContent: [
                    ListItemModel(
                      title: "Monthly Interest Rate:",
                      description: "Annual rate divided by 12 and converted to decimal.",
                    ),
                    ListItemModel(
                      title: "Payoff Time:",
                      description: "Calculated using a logarithmic formula based on balance, rate, and payment.",
                    ),
                    ListItemModel(
                      title: "Total Interest:",
                      description: "Sum of monthly interest payments until balance is cleared.",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget graph() {
    return PieChartGraph(
      title: "Breakdown",
      graphData: [
        {'title': 'Principal: ₹${cardBalance.toStringAsFixed(0)}', 'value': cardBalance},
        {'title': 'Interest: ₹${totalInterestPaid.toStringAsFixed(0)}', 'value': totalInterestPaid},
      ],
      graphDisc: [
        {'title': 'Months to Pay Off:', 'amount': monthsToPayOff.isFinite ? "$monthsToPayOff" : "Infinite"},
        {'title': 'Total Interest Paid:', 'amount': "₹${totalInterestPaid.toStringAsFixed(2)}"},
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