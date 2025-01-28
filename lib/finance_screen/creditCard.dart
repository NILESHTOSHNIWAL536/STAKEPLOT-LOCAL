import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

import 'package:flutter_application_code_stakeplot/avatarProfile.dart';

import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';

import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';

//import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';

  getJsonBodyObj(String name,double value,double min,double max,Function(double) onChanged ,TextEditingController controller){
       return {
          'controller':controller,
          'name':name,
          'value':value,
          'min':min,
          'max':max,
          'onChanged':onChanged,
       };
   }


class CreditCard extends StatefulWidget {
  @override
  _CreditCardState createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> {
  double cardBalance = 21500;
  double interestRate = 19;
  double monthlyPayment = 1210;
  int monthsToPayOff = 0;
  double totalInterestPaid = 0;
   TextEditingController cardBalanceController = TextEditingController();
   TextEditingController interestRateController = TextEditingController();
   TextEditingController monthlyPaymentController = TextEditingController();


  late List slidersList;

 



  void calculatePayoff() {
    double balance = cardBalance;
    double monthlyRate = (interestRate / 100) / 12;
    int months = 0;
    double totalInterest = 0;

    while (balance > 0) {
      double interest = balance * monthlyRate;
      totalInterest += interest;
      balance = balance + interest - monthlyPayment;
      if (balance < 0) balance = 0;
      months++;
    }

    setState(() {
      monthsToPayOff = months;
      totalInterestPaid = totalInterest;
    });
  }

  @override
  void initState() {
    super.initState();
    cardBalanceController.text = cardBalance.toStringAsFixed(0);
    interestRateController.text = interestRate.toStringAsFixed(0);
    monthlyPaymentController.text = monthlyPayment.toStringAsFixed(0);
    calculatePayoff();
    getslidersList();
  }

  void getslidersList(){
      slidersList=[
         getJsonBodyObj("Card Balance",4,3,12,(value){},TextEditingController(text: '2')),
         getJsonBodyObj("Interest Rate (%)",4,1,12,(value){},TextEditingController(text: '332')),
         getJsonBodyObj("Monthly Payment",4,1,12,(value){},TextEditingController(text: '2332')),
     ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar:appbarHeader("Credit Card Pay Off Calculator", context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: AppColors.mt,
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        SliderPage(slidersList: slidersList),
                        
             
            ],
          ),
      ))
  ])
  )
  )
  );
  }


  Widget  graph(){
      return Column(
          children: [
                const Text(
                'Fetch',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('Monthly Payoff: $monthsToPayOff months'),
              Text(
                  'Total Interest Paid: ₹${totalInterestPaid.toStringAsFixed(2)}'),
              const SizedBox(height: 20),
              SizedBox(height: 150, child: buildPieChart()),
              const SizedBox(height: 20),
          ],
      );
  }


  Widget buildTextField(String label, TextEditingController controller,
      Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }



  Widget buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: cardBalance,
            title: 'Principal\n₹${cardBalance.toStringAsFixed(0)}',
            color: AppColors.primaryColor,
            radius: 50,
          ),
          PieChartSectionData(
            value: totalInterestPaid,
            title: 'Interest\n₹${totalInterestPaid.toStringAsFixed(0)}',
            color: AppColors.uncoloredPie,
            radius: 50,
          ),
        ],
      ),
    );
  }

   Widget expansion(){
      return Column(
         children: [
             ExpansionTile(
                title: const Text('How to use the calculator?'),
                children: [
                  Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Container(
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("1.Credit Card Balance"),
                            Text(
                                "Input:Use the slider to set your current balance (eg..5000)"),
                            Text("2.Credit Card Interest Rate"),
                            Text(
                                "Input:Use the slider to set your annual interest rate (eg..18%)"),
                            Text("3.Monthly Payment"),
                            Text(
                                "Input:Use the slider to set your planned monthly payment (eg..200)"),
                          ],
                        ),
                      ))
                ],
              ),
              ExpansionTile(
                title: const Text('How it works?'),
                children: [
                  Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Container(
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Monthly Interest Rate:"),
                            Text(
                                "Converts the annual interest rate to a monthly rate"),
                            Text("Months to pay off Debt:"),
                            Text(
                                "Calculates the number of months to pay off the debt using your balance, monthly payment and interest rate"),
                            Text("Total Interest Paid:"),
                            Text(
                                "Computes the total interest paid over the repayment method"),
                          ],
                        ),
                      ))
                ],
              ),
         ],
      );
   }

  Widget getList(){
     return Column(
      children: [
             const Text(
                        'Start Calculation',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      buildTextField('Card Balance', cardBalanceController,
                          (value) {
                        setState(() {
                          cardBalance = double.tryParse(value) ?? cardBalance;
                        });
                        calculatePayoff();
                      }),
                      buildSlider('Card Balance', cardBalance, 1000, 50000,
                          (value) {
                        setState(() {
                          cardBalance = value;
                          cardBalanceController.text = value.toStringAsFixed(0);
                          calculatePayoff();
                        });
                      }),
                      buildTextField(
                          'Interest Rate (%)', interestRateController, (value) {
                        setState(() {
                          interestRate = double.tryParse(value) ?? interestRate;
                        });
                        calculatePayoff();
                      }),
                      buildSlider('Interest Rate (%)', interestRate, 1, 30,
                          (value) {
                        setState(() {
                          interestRate = value;
                          interestRateController.text =
                              value.toStringAsFixed(0);
                          calculatePayoff();
                        });
                      }),
                      buildTextField(
                          'Monthly Payment', monthlyPaymentController, (value) {
                        setState(() {
                          monthlyPayment =
                              double.tryParse(value) ?? monthlyPayment;
                        });
                        calculatePayoff();
                      }),
                      buildSlider('Monthly Payment', monthlyPayment, 500, 5000,
                          (value) {
                        setState(() {
                          monthlyPayment = value;
                          monthlyPaymentController.text =
                              value.toStringAsFixed(0);
                          calculatePayoff();
                        });
                      }),
                      const SizedBox(height: 20),
                    ],
            
     );
  }
}

// //   }
// import 'package:flutter/material.dart';
// import 'package:get/get.dart'; // Import GetX package
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:fl_chart/fl_chart.dart';

// class CreditCardController extends GetxController {
//   RxDouble cardBalance = 21500.0.obs;
//   RxDouble interestRate = 19.0.obs;
//   RxDouble monthlyPayment = 1210.0.obs;
//   RxInt monthsToPayOff = 0.obs;
//   RxDouble totalInterestPaid = 0.0.obs;
//   var maxCardBalance = 50000.0.obs;  // Dynamic max card balance
//   TextEditingController cardBalanceController = TextEditingController();
//   TextEditingController interestRateController = TextEditingController();
//   TextEditingController monthlyPaymentController = TextEditingController();

//   void calculatePayoff() {
//     double balance = cardBalance.value;
//     double monthlyRate = (interestRate.value / 100) / 12;
//     int months = 0;
//     double totalInterest = 0;

//     while (balance > 0) {
//       double interest = balance * monthlyRate;
//       totalInterest += interest;
//       balance = balance + interest - monthlyPayment.value;
//       if (balance < 0) balance = 0;
//       months++;
//     }

//     monthsToPayOff.value = months;
//     totalInterestPaid.value = totalInterest;
//   }

//   // Function to update card balance with validation
//   void updateCardBalance(String value) {
//     double newBalance = double.tryParse(value) ?? cardBalance.value;

//     // Ensure card balance stays within valid range
//     if (newBalance < 0) {
//       newBalance = 0;
//     } else if (newBalance > maxCardBalance.value) {
//       newBalance = maxCardBalance.value;
//     }

//     cardBalance.value = newBalance;
//     calculatePayoff();
//   }

//   void updateCardBalanceFromSlider(double value) {
//     // Ensure slider value is within range
//     cardBalance.value = value;
//     cardBalanceController.text = value.toStringAsFixed(0);
//     calculatePayoff();
//   }

//   void updateInterestRate(String value) {
//     interestRate.value = double.tryParse(value) ?? interestRate.value;
//     calculatePayoff();
//   }

//   void updateInterestRateFromSlider(double value) {
//     interestRate.value = value;
//     interestRateController.text = value.toStringAsFixed(0);
//     calculatePayoff();
//   }

//   void updateMonthlyPayment(String value) {
//     monthlyPayment.value = double.tryParse(value) ?? monthlyPayment.value;
//     calculatePayoff();
//   }

//   void updateMonthlyPaymentFromSlider(double value) {
//     monthlyPayment.value = value;
//     monthlyPaymentController.text = value.toStringAsFixed(0);
//     calculatePayoff();
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     cardBalanceController.text = cardBalance.value.toStringAsFixed(0);
//     interestRateController.text = interestRate.value.toStringAsFixed(0);
//     monthlyPaymentController.text = monthlyPayment.value.toStringAsFixed(0);
//     calculatePayoff();
//   }
// }

// class CreditCard extends StatelessWidget {
//   final CreditCardController controller = Get.put(CreditCardController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundColor,
//       appBar: AppBar(
//         backgroundColor: AppColors.backgroundColor,
//         title: const Text('Credit Card Pay Off Calculator'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {},
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   color: AppColors.mt,
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'Start Calculation',
//                         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 16),
//                       buildTextField('Card Balance', controller.cardBalanceController, (value) {
//                         controller.updateCardBalance(value);
//                       }),
//                       buildSlider('Card Balance', controller.cardBalance.value, 0, controller.maxCardBalance.value, (value) {
//                         controller.updateCardBalanceFromSlider(value);
//                       }),
//                       buildTextField('Interest Rate (%)', controller.interestRateController, (value) {
//                         controller.interestRate.value = double.tryParse(value) ?? controller.interestRate.value;
//                         controller.calculatePayoff();
//                       }),
//                       buildSlider('Interest Rate (%)', controller.interestRate.value, 1, 30, (value) {
//                         controller.interestRate.value = value;
//                         controller.interestRateController.text = value.toStringAsFixed(0);
//                         controller.calculatePayoff();
//                       }),
//                       buildTextField('Monthly Payment', controller.monthlyPaymentController, (value) {
//                         controller.monthlyPayment.value = double.tryParse(value) ?? controller.monthlyPayment.value;
//                         controller.calculatePayoff();
//                       }),
//                       buildSlider('Monthly Payment', controller.monthlyPayment.value, 500, 5000, (value) {
//                         controller.monthlyPayment.value = value;
//                         controller.monthlyPaymentController.text = value.toStringAsFixed(0);
//                         controller.calculatePayoff();
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
//               Obx(() => Text('Monthly Payoff: ${controller.monthsToPayOff.value} months')),
//               Obx(() => Text('Total Interest Paid: ₹${controller.totalInterestPaid.value.toStringAsFixed(2)}')),
//               const SizedBox(height: 20),
//               SizedBox(height: 150, child: buildPieChart(controller)),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildTextField(String label, TextEditingController controller, Function(String) onChanged) {
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

//   Widget buildSlider(String label, double value, double min, double max, Function(double) onChanged) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('$label: ₹${value.toStringAsFixed(0)}'),
//         Slider(
//           value: value,
//           min: min,
//           max: max,
//           divisions: 100,
//           label: value.toStringAsFixed(0),
//           onChanged: onChanged,
//           activeColor: AppColors.primaryColor,
//           inactiveColor: AppColors.uncoloredPie,
//         ),
//       ],
//     );
//   }

//   Widget buildPieChart(CreditCardController controller) {
//     return Obx(() => PieChart(
//       PieChartData(
//         sections: [
//           PieChartSectionData(
//             value: controller.cardBalance.value,
//             title: 'Principal\n₹${controller.cardBalance.value.toStringAsFixed(0)}',
//             color: AppColors.primaryColor,
//             radius: 50,
//           ),
//           PieChartSectionData(
//             value: controller.totalInterestPaid.value,
//             title: 'Interest\n₹${controller.totalInterestPaid.value.toStringAsFixed(0)}',
//             color: AppColors.uncoloredPie,
//             radius: 50,
//           ),
//         ],
//       ),
//     ));
//   }
// }
