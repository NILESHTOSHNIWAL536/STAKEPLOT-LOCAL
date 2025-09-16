// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/utils.dart';

// class CreditCard extends StatefulWidget {
//   const CreditCard({Key? key}) : super(key: key);

//   @override
//   _CreditCardState createState() => _CreditCardState();
// }

// class _CreditCardState extends State<CreditCard> {
//   late List slidersList;
//   double cardBalance = 2000.0;
//   double totalInterestPaid = 0.0;
//   double monthlyPayment = 600.0;
//   double interestRate = 7.0;
//   int monthsToPayOff = 0;
//   bool _isInfoVisible = true; // Controls visibility of the animated container
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     getslidersList();
//     calculatePayoffDetails();
//     _timer = Timer(Duration(seconds: 2), () {
//       if (mounted) {
//         setState(() {
//           _isInfoVisible = false;
//         });
//       }
//     }); // Initial calculation
//   }

//   void getslidersList() {
//     slidersList = [
//       getJsonBodyObj("Card balance", 2000.0, 1000.0, 100000.0, (value) {
//         updateSliderValue(0, value);
//       }, TextEditingController(text: '2000')),
//       getJsonBodyObj("Interest rate(%)", 7.0, 1.0, 10.0, (value) {
//         updateSliderValue(1, value);
//       }, TextEditingController(text: '7.0'), true, ""),
//       getJsonBodyObj("Monthly payment", 600.0, 10.0, 5000.0, (value) {
//         updateSliderValue(2, value);
//       }, TextEditingController(text: '600')),
//     ];
//   }

//   void updateSliderValue(int index, double newValue) {
//     double min = slidersList[index]['min'];
//     double max = slidersList[index]['max'];
//     newValue = newValue.clamp(min, max);

//     setState(() {
//       if (index != 1) {
//         newValue = newValue.roundToDouble(); // Integer for non-interest fields
//       }
//       slidersList[index]['value'] = newValue;
//       slidersList[index]['controller'].text = (index == 1)
//           ? newValue.toStringAsFixed(1)
//           : newValue.toStringAsFixed(0);

//       cardBalance = slidersList[0]['value'];
//       interestRate = slidersList[1]['value'];
//       monthlyPayment = slidersList[2]['value'];

//       calculatePayoffDetails();
//     });
//   }

//   void calculatePayoffDetails() {
//     double monthlyRate = interestRate / 12 / 100;
//     if (monthlyPayment <= cardBalance * monthlyRate) {
//       monthsToPayOff = double.infinity.toInt();
//       totalInterestPaid = 0;
//     } else {
//       monthsToPayOff =
//           (log(monthlyPayment / (monthlyPayment - cardBalance * monthlyRate)) /
//                   log(1 + monthlyRate))
//               .ceil();
//       monthsToPayOff = monthsToPayOff.isFinite ? monthsToPayOff : 0;

//       double balance = cardBalance;
//       totalInterestPaid = 0;
//       for (int i = 0; i < monthsToPayOff && balance > 0; i++) {
//         double interest = balance * monthlyRate;
//         totalInterestPaid += interest;
//         balance -= (monthlyPayment - interest);
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     for (var slider in slidersList) {
//       slider['controller'].dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primaryColor,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Container(
//             padding: const EdgeInsets.all(16.0),
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16),
//                 color: AppColors.primaryColorHeader),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       IconButton(
//                         icon: Icon(
//                           Icons.arrow_back,
//                           color: AppColors.backgroundColor,
//                         ),
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _isInfoVisible =
//                                 !_isInfoVisible; // Toggle visibility
//                             if (_isInfoVisible) {
//                               // Restart timer when container is shown via tap
//                               _timer?.cancel();
//                               _timer = Timer(Duration(seconds: 2), () {
//                                 if (mounted) {
//                                   setState(() {
//                                     _isInfoVisible = false;
//                                   });
//                                 }
//                               });
//                             }
//                           });
//                         },
//                         child: Text(
//                           "Credit Card Payoff Calculator",
//                           style: FontManager().getTextStyle(
//                             context,
//                             lWeight: FontWeight.w600,
//                             fontSize: 18,
//                             color: AppColors.backgroundColor,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   AnimatedContainer(
//                     duration: Duration(milliseconds: 500),
//                     curve: Curves.easeInOut,
//                     height: _isInfoVisible ? 100 : 0,
//                     margin:
//                         EdgeInsets.symmetric(vertical: _isInfoVisible ? 10 : 0),
//                     padding:
//                         _isInfoVisible ? EdgeInsets.all(12) : EdgeInsets.zero,
//                     decoration: BoxDecoration(
//                       color: AppColors.backgroundColor.withOpacity(0.9),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.white, width: 1),
//                     ),
//                     child: _isInfoVisible
//                         ? SingleChildScrollView(
//                             child: Text(
//                               "The Credit Card Payoff Calculator helps you estimate how long it will take to pay off your credit card balance. Adjust the sliders to input your current balance, interest rate, and monthly payment to see the payoff time and total interest paid.",
//                               style: FontManager().getTextStyle(
//                                 context,
//                                 lWeight: FontWeight.w400,
//                                 fontSize: 14,
//                                 color: AppColors.primaryColor,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           )
//                         : SizedBox.shrink(),
//                   ),
//                   SliderPage(
//                       slidersList: slidersList,
//                       onSliderValueChanged: updateSliderValue),
//                   Container(
//                       decoration: BoxDecoration(
//                           color: AppColors.backgroundColor,
//                           borderRadius: BorderRadius.circular(12)),
//                       child: graph()),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   CustomExpansionTile(
//                     howToUseContent: [
//                       ListItemModel(
//                         title: "Card Balance:",
//                         description:
//                             "Adjust the slider to set your current credit card balance (e.g., ₹2000).",
//                       ),
//                       ListItemModel(
//                         title: "Interest Rate:",
//                         description:
//                             "Adjust the slider to set your annual interest rate (e.g., 7.5%).",
//                       ),
//                       ListItemModel(
//                         title: "Monthly Payment:",
//                         description:
//                             "Adjust the slider to set your monthly payment amount (e.g., ₹600).",
//                       ),
//                     ],
//                     howItWorksContent: [
//                       ListItemModel(
//                         title: "Monthly Interest Rate:",
//                         description:
//                             "Annual rate divided by 12 and converted to decimal.",
//                       ),
//                       ListItemModel(
//                         title: "Payoff Time:",
//                         description:
//                             "Calculated using a logarithmic formula based on balance, rate, and payment.",
//                       ),
//                       ListItemModel(
//                         title: "Total Interest:",
//                         description:
//                             "Sum of monthly interest payments until balance is cleared.",
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget graph() {
//     return PieChartGraph(
//       title: "Breakdown",
//       graphData: [
//         {
//           'title':
//               'Principal: ₹${formatMoneyIndian(cardBalance.toStringAsFixed(0))}',
//           'value': cardBalance
//         },
//         {
//           'title': 'Interest: ₹${totalInterestPaid.toStringAsFixed(0)}',
//           'value': totalInterestPaid
//         },
//       ],
//       graphDisc: [
//         {
//           'title': 'Months to Pay Off:',
//           'amount': monthsToPayOff.isFinite ? "$monthsToPayOff" : "Infinite"
//         },
//         {
//           'title': 'Total Interest Paid:',
//           'amount': "₹${totalInterestPaid.toStringAsFixed(2)}"
//         },
//       ],
//     );
//   }
// }

// PreferredSizeWidget appbarHeader(String title, BuildContext context) {
//   return AppBar(
//     centerTitle: true,
//     title: Text(title,
//         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//   );
// }
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
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
  bool _isInfoVisible = false; // Controls visibility of the container
  double _opacity = 0.0; // Controls the fade effect
  Timer? _timer; // Timer to hide the container after 5 seconds

  @override
  void initState() {
    super.initState();
    getslidersList();
    calculatePayoffDetails(); // Initial calculation
    // Trigger fade-in animation on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isInfoVisible = true;
          _opacity = 1.0; // Fade in
        });
        // Start timer to fade out after 5 seconds
        _timer = Timer(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _opacity = 0.0; // Fade out
            });
          }
        });
      }
    });
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
      slidersList[index]['controller'].text = (index == 1)
          ? newValue.toStringAsFixed(1)
          : newValue.toStringAsFixed(0);

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
      monthsToPayOff =
          (log(monthlyPayment / (monthlyPayment - cardBalance * monthlyRate)) /
                  log(1 + monthlyRate))
              .ceil();
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
    _timer?.cancel();
    for (var slider in slidersList) {
      slider['controller'].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isInfoVisible = true;
                            _opacity = 1.0; // Fade in
                          });
                          _timer?.cancel();

                          _timer = Timer(Duration(seconds: 2), () {
                            if (mounted) {
                              setState(() {
                                _opacity = 0.0; // Fade out
                              });
                            }
                          });
                        },
                        child: Text(
                          "Credit Card Payoff Calculator",
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w800,
                            fontSize: 40,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  onEnd: () {
                    // Hide container after fade-out completes
                    if (_opacity == 0.0 && mounted) {
                      setState(() {
                        _isInfoVisible = false;
                        print(
                            'Container hidden: _isInfoVisible = $_isInfoVisible');
                      });
                    }
                  },
                  child: _isInfoVisible
                      ? Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              "The Credit Card Payoff Calculator helps you estimate how long it will take to pay off your credit card balance. Adjust the sliders to input your current balance, interest rate, and monthly payment to see the payoff time and total interest paid.",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w400,
                                fontSize: 14,
                                color: AppColors.backgroundColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : SizedBox.shrink(),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: Column(
                    children: [
                      SliderPage(
                        slidersList: slidersList,
                        onSliderValueChanged: updateSliderValue,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: 4,
                          right: 4,
                          top: 0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: graph(),
                      ),
                      SizedBox(height: 10),
                      CustomExpansionTile(
                        howToUseContent: [
                          ListItemModel(
                            title: "Card Balance:",
                            description:
                                "Adjust the slider to set your current credit card balance (e.g., ₹2000).",
                          ),
                          ListItemModel(
                            title: "Interest Rate:",
                            description:
                                "Adjust the slider to set your annual interest rate (e.g., 7.5%).",
                          ),
                          ListItemModel(
                            title: "Monthly Payment:",
                            description:
                                "Adjust the slider to set your monthly payment amount (e.g., ₹600).",
                          ),
                        ],
                        howItWorksContent: [
                          ListItemModel(
                            title: "Monthly Interest Rate:",
                            description:
                                "Annual rate divided by 12 and converted to decimal.",
                          ),
                          ListItemModel(
                            title: "Payoff Time:",
                            description:
                                "Calculated using a logarithmic formula based on balance, rate, and payment.",
                          ),
                          ListItemModel(
                            title: "Total Interest:",
                            description:
                                "Sum of monthly interest payments until balance is cleared.",
                          ),
                        ],
                      ),
                    ],
                  ),
                )
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
        {
          'title':
              'Principal: ₹${formatMoneyIndian(cardBalance.toStringAsFixed(0))}',
          'value': cardBalance,
        },
        {
          'title': 'Interest: ₹${totalInterestPaid.toStringAsFixed(0)}',
          'value': totalInterestPaid,
        },
      ],
      graphDisc: [
        {
          'title': 'Months to Pay Off:',
          'amount': monthsToPayOff.isFinite ? "$monthsToPayOff" : "Infinite",
        },
        {
          'title': 'Total Interest Paid:',
          'amount': "₹${totalInterestPaid.toStringAsFixed(2)}",
        },
      ],
    );
  }
}

PreferredSizeWidget appbarHeader(String title, BuildContext context) {
  return AppBar(
    centerTitle: true,
    title: Text(
      title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    ),
  );
}
