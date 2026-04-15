
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
import 'package:flutter_application_code_stakeplot/Constants/calculator_utils.dart';

import '../../Constants/core/app_padding_sizes.dart';
import '../../components/shared_utils.dart';

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
      backgroundColor: AppColors.newbg,
      body:Padding(
    
  padding: EdgeInsets.only(
    top: MediaQuery.of(context).size.height * 0.02,
  


  ),child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
               
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom:AppSizes.p10,right:AppSizes.p2,left:AppSizes.p4),
                      child: Container(
                               width: MediaQuery.sizeOf(context).width/10,
                           
                         
                          height: MediaQuery.sizeOf(context).height/22,
                        
                         decoration: BoxDecoration(
                            color: Colors.white,           // ✅ white background
                          shape: BoxShape.circle,        // ✅ rounded
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFF061D3D), // arrow color
                            size: 22,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                   SizedBox(  width: MediaQuery.of(context).size.width * 0.15)
,
                    Padding(
                      padding: const EdgeInsets.only(left:AppSizes.p14),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isInfoVisible = true;
                            _opacity = 1.0; // Fade in
                           
                          });
                          _timer?.cancel(); // Cancel any existing timer
                          // Start a new timer to fade out after 5 seconds
                          _timer = Timer(Duration(seconds: 2), () {
                            if (mounted) {
                              setState(() {
                                _opacity = 0.0; // Fade out
                               
                              });
                            }
                          });
                        },
                       
                        child: Padding(
                          padding: const EdgeInsets.only(bottom:AppSizes.p10,right:AppSizes.p4,),
                          child: Text(
                            "Credit Card Payoff",
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppColors.newtitlecolor,
                            ),
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
                      
                      });
                    }
                  },
                  child: _isInfoVisible
                      ? Container(
                          margin: EdgeInsets.symmetric(vertical: AppSizes.p4),
                          padding: EdgeInsets.all(AppSizes.p12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.backgroundColor, width: 1),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              "The Credit Card Payoff Calculator helps you estimate how long it will take to pay off your credit card balance. Adjust the sliders to input your current balance, interest rate, and monthly payment to see the payoff time and total interest paid.",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w400,
                                fontSize: 11,
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
                      SizedBox(height:10),
                       Padding(
                        
            padding: EdgeInsets.all(Colorcodes.paddingSize/2),
           
            
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                 Text(
                            "Breakdown",
                            style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w800,
                              fontSize: 20,
                              color: AppColors.primaryColor,
                            ),
                          ),
               
              ],
            ),
          ),
                Container(
                    decoration: BoxDecoration(
                        color: AppColors.newbg,
                        borderRadius: BorderRadius.circular(12)),
                     child: graph()),
                SizedBox(
                  height: AppSizes.h10,
                ),
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
      ),),
    );
  }

  Widget graph() {
    return PieChartGraph(
       title: "Breakdown",
    
      graphData: [
        {
          'title':'Principal: ₹${formatMoneyIndian(cardBalance.toStringAsFixed(0))}',
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
    title: Text(title,
        
        style: FontManager().getTextStyle(
                              context,
                              lWeight: FontWeight.w500,
                              fontSize: 16,
                              
                            ),)
        
  );
}

