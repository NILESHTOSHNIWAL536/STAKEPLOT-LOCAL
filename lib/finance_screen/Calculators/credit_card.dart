// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/creditCard.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/plot_finance.dart';

// class CreditCard extends StatefulWidget {
//   const CreditCard({ Key? key }) : super(key: key);

//   @override
//   _CreditCardState createState() => _CreditCardState();
// }

// class _CreditCardState extends State<CreditCard> {

//    late List slidersList;

//   @override
//   void initState()
//   {
//       getslidersList();
//   }

//    void getslidersList(){
//       slidersList=[
//          getJsonBodyObj("Car Price",4,3,12,(value){},TextEditingController(text: '2')),
//          getJsonBodyObj("Down Payment",4,1,12,(value){},TextEditingController(text: '332')),
//          getJsonBodyObj("Loan Interest Rate",4,1,12,(value){},TextEditingController(text: '2332')),
//          getJsonBodyObj("Loan Tenure",4,1,12,(value){},TextEditingController(text: '2332')),
//          getJsonBodyObj("Annual maintenance cost",4,1,12,(value){},TextEditingController(text: '2332')),
//      ];
//   }

//   @override
//   Widget build(BuildContext context) {
//       return  Scaffold(
//           backgroundColor: AppColors.backgroundColor,
//           appBar: appbarHeader("Credit card pay off calculator ", context),
//           body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//                SliderPage(slidersList: slidersList),
//               PieChartGraph(),
//               CustomExpansionTile(
//                  howToUseContent: Expansioncalculator.creditcardTitle1,
//                 howItWorksContent: Expansioncalculator.creditcardTitle2,
//               ),
//   ])
//   )
//   ),
//     );
//   }
// }

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

  @override
  void initState() {
    super.initState();
    getslidersList();
  }

  void getslidersList() {
    slidersList = [
      getJsonBodyObj("Card balance", 4, 3, 12, (value) {},
          TextEditingController(text: '2')),
      getJsonBodyObj("Interest rate(%)", 4, 1, 12, (value) {},
          TextEditingController(text: '332')),
      getJsonBodyObj("Monthly payment", 4, 1, 12, (value) {},
          TextEditingController(text: '2332')),
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
              SliderPage(slidersList: slidersList),
              const PieChartGraph(),
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
}
