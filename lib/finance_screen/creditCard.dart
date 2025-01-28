// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

// import 'package:flutter_application_code_stakeplot/avatarProfile.dart';

// import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';

// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';

// //import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/learnMore.dart';

//   getJsonBodyObj(String name,double value,double min,double max,Function(double) onChanged ,TextEditingController controller){
//        return {
//           'controller':controller,
//           'name':name,
//           'value':value,
//           'min':min,
//           'max':max,
//           'onChanged':onChanged,
//        };
//    }


// class CreditCard extends StatefulWidget {
//   @override
//   _CreditCardState createState() => _CreditCardState();
// }

// class _CreditCardState extends State<CreditCard> {
//   double cardBalance = 21500;
//   double interestRate = 19;
//   double monthlyPayment = 1210;
//   int monthsToPayOff = 0;
//   double totalInterestPaid = 0;
//    TextEditingController cardBalanceController = TextEditingController();
//    TextEditingController interestRateController = TextEditingController();
//    TextEditingController monthlyPaymentController = TextEditingController();


//   late List slidersList;

 



//   void calculatePayoff() {
//     double balance = cardBalance;
//     double monthlyRate = (interestRate / 100) / 12;
//     int months = 0;
//     double totalInterest = 0;

//     while (balance > 0) {
//       double interest = balance * monthlyRate;
//       totalInterest += interest;
//       balance = balance + interest - monthlyPayment;
//       if (balance < 0) balance = 0;
//       months++;
//     }

//     setState(() {
//       monthsToPayOff = months;
//       totalInterestPaid = totalInterest;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     cardBalanceController.text = cardBalance.toStringAsFixed(0);
//     interestRateController.text = interestRate.toStringAsFixed(0);
//     monthlyPaymentController.text = monthlyPayment.toStringAsFixed(0);
//     calculatePayoff();
//     getslidersList();
//   }

//   void getslidersList(){
//       slidersList=[
//          getJsonBodyObj("Card Balance",4,3,12,(value){},TextEditingController(text: '2')),
//          getJsonBodyObj("Interest Rate (%)",4,1,12,(value){},TextEditingController(text: '332')),
//          getJsonBodyObj("Monthly Payment",4,1,12,(value){},TextEditingController(text: '2332')),
//      ];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar:appbarHeader("Credit Card Pay Off Calculator", context),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                     color: AppColors.mt,
//                     borderRadius: BorderRadius.circular(16)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                         SliderPage(slidersList: slidersList),
                        
             
//             ],
//           ),
//       ))
//   ])
//   )
//   )
//   );
//   }


//   Widget  graph(){
//       return Column(
//           children: [
//                 const Text(
//                 'Fetch',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               Text('Monthly Payoff: $monthsToPayOff months'),
//               Text(
//                   'Total Interest Paid: ₹${totalInterestPaid.toStringAsFixed(2)}'),
//               const SizedBox(height: 20),
//               SizedBox(height: 150, child: buildPieChart()),
//               const SizedBox(height: 20),
//           ],
//       );
//   }


//   Widget buildTextField(String label, TextEditingController controller,
//       Function(String) onChanged) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextField(
//         controller: controller,
//         keyboardType: TextInputType.number,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(),
//         ),
//         onChanged: onChanged,
//       ),
//     );
//   }



  

//    Widget expansion(){
//       return Column(
//          children: [
//              ExpansionTile(
//                 title: const Text('How to use the calculator?'),
//                 children: [
//                   Padding(
//                       padding: EdgeInsets.all(16.0),
//                       child: Container(
//                         child: const Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("1.Credit Card Balance"),
//                             Text(
//                                 "Input:Use the slider to set your current balance (eg..5000)"),
//                             Text("2.Credit Card Interest Rate"),
//                             Text(
//                                 "Input:Use the slider to set your annual interest rate (eg..18%)"),
//                             Text("3.Monthly Payment"),
//                             Text(
//                                 "Input:Use the slider to set your planned monthly payment (eg..200)"),
//                           ],
//                         ),
//                       ))
//                 ],
//               ),
//               ExpansionTile(
//                 title: const Text('How it works?'),
//                 children: [
//                   Padding(
//                       padding: EdgeInsets.all(16.0),
//                       child: Container(
//                         child: const Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Monthly Interest Rate:"),
//                             Text(
//                                 "Converts the annual interest rate to a monthly rate"),
//                             Text("Months to pay off Debt:"),
//                             Text(
//                                 "Calculates the number of months to pay off the debt using your balance, monthly payment and interest rate"),
//                             Text("Total Interest Paid:"),
//                             Text(
//                                 "Computes the total interest paid over the repayment method"),
//                           ],
//                         ),
//                       ))
//                 ],
//               ),
//          ],
//       );
//    }

//   Widget getList(){
//      return Column(
//       children: [
//              const Text(
//                         'Start Calculation',
//                         style: TextStyle(
//                             fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 16),
//                       buildTextField('Card Balance', cardBalanceController,
//                           (value) {
//                         setState(() {
//                           cardBalance = double.tryParse(value) ?? cardBalance;
//                         });
//                         calculatePayoff();
//                       }),
//                       buildSlider('Card Balance', cardBalance, 1000, 50000,
//                           (value) {
//                         setState(() {
//                           cardBalance = value;
//                           cardBalanceController.text = value.toStringAsFixed(0);
//                           calculatePayoff();
//                         });
//                       }),
//                       buildTextField(
//                           'Interest Rate (%)', interestRateController, (value) {
//                         setState(() {
//                           interestRate = double.tryParse(value) ?? interestRate;
//                         });
//                         calculatePayoff();
//                       }),
//                       buildSlider('Interest Rate (%)', interestRate, 1, 30,
//                           (value) {
//                         setState(() {
//                           interestRate = value;
//                           interestRateController.text =
//                               value.toStringAsFixed(0);
//                           calculatePayoff();
//                         });
//                       }),
//                       buildTextField(
//                           'Monthly Payment', monthlyPaymentController, (value) {
//                         setState(() {
//                           monthlyPayment =
//                               double.tryParse(value) ?? monthlyPayment;
//                         });
//                         calculatePayoff();
//                       }),
//                       buildSlider('Monthly Payment', monthlyPayment, 500, 5000,
//                           (value) {
//                         setState(() {
//                           monthlyPayment = value;
//                           monthlyPaymentController.text =
//                               value.toStringAsFixed(0);
//                           calculatePayoff();
//                         });
//                       }),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),
//               const Text(
//                 'Fetch',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               Text('Monthly Payoff: $monthsToPayOff months'),
//               Text(
//                   'Total Interest Paid: ₹${totalInterestPaid.toStringAsFixed(2)}'),
//               const SizedBox(height: 20),
//               SizedBox(height: 150, child: buildPieChart()),
//               const SizedBox(height: 20),
//               const CustomExpansionTile(
//           howToUseContent: [
//             "1. Credit Card Balance: Use the slider to set your current balance (e.g., 5000).",
//             "2. Credit Card Interest Rate: Use the slider to set your annual interest rate (e.g., 18%).",
//             "3. Monthly Payment: Use the slider to set your planned monthly payment (e.g., 200).",
//           ],
//           howItWorksContent: [
//             "Monthly Interest Rate: Converts the annual interest rate to a monthly rate.",
//             "Months to Pay off Debt: Calculates the number of months to pay off the debt using your balance, monthly payment, and interest rate.",
//             "Total Interest Paid: Computes the total interest paid over the repayment method.",
//           ],
//         ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

  


//   Widget buildPieChart() {
//     return PieChart(
//       PieChartData(
//         sections: [
//           PieChartSectionData(
//             value: cardBalance,
//             title: 'Principal\n₹${cardBalance.toStringAsFixed(0)}',
//             color: AppColors.primaryColor,
//             radius: 50,
//           ),
//           PieChartSectionData(
//             value: totalInterestPaid,
//             title: 'Interest\n₹${totalInterestPaid.toStringAsFixed(0)}',
//             color: AppColors.uncoloredPie,
//             radius: 50,
//           ),
//         ],
//       ),
//     );
            
     
//   }
// }