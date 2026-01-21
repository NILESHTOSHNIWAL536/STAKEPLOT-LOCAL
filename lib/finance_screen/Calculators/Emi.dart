import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
import 'package:flutter_application_code_stakeplot/Constants/calculator_utils.dart';

import '../../Constants/core/app_padding_sizes.dart';
import '../../components/shared_utils.dart';

class Emi extends StatefulWidget {
  const Emi({Key? key}) : super(key: key);

  @override
  _EmiState createState() => _EmiState();
}

class _EmiState extends State<Emi> {
  late List slidersList;
  double totalInterestPaid = 0;
  double loanAmount = 40000.0; // Adjusted initial value
  double annualInterestRate = 4.0; // Renamed and fixed
  double loanTenure = 4.0; // Adjusted initial value
  double emi = 0.0;
  bool _isInfoVisible = false; // Controls visibility of the container
  double _opacity = 0.0; // Controls the fade effect
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    getslidersList();
    calculateEMI();
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
      getJsonBodyObj("Loan amount", 40000.0, 10000.0, 10000000.0, (value) {
        updateSliderValue(0, value);
      }, TextEditingController(text: '40000')),
      getJsonBodyObj("Annual interest rate(%)", 4.0, 1.0, 30.0, (value) {
        updateSliderValue(1, value);
      }, TextEditingController(text: '4.0'), true, ""),
      getJsonBodyObj("Loan tenure(months)", 4.0, 1.0, 360.0, (value) {
        updateSliderValue(2, value);
      }, TextEditingController(text: '4'), false, "Mts"),
    ];
  }

  void calculateEMI() {
    double monthlyInterestRate = annualInterestRate / 12 / 100;

    if (monthlyInterestRate > 0 && loanTenure > 0) {
      emi = loanAmount *
          monthlyInterestRate *
          (pow(1 + monthlyInterestRate, loanTenure) /
              (pow(1 + monthlyInterestRate, loanTenure) - 1));
      double totalAmountPaid = emi * loanTenure;
      totalInterestPaid = totalAmountPaid - loanAmount;
    } else {
      emi = 0;
      totalInterestPaid = 0;
    }
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

      loanAmount = slidersList[0]['value'];
      annualInterestRate = slidersList[1]['value'];
      loanTenure = slidersList[2]['value'];
      calculateEMI();
    });
  }

  final List<ListItemModel> howToUseContent = [
    ListItemModel(
        title: "Loan Amount:",
        description:
            "Input: Adjust the slider to set your loan amount (e.g., ₹40,000)."),
    ListItemModel(
        title: "Annual Interest Rate:",
        description:
            "Input: Adjust the slider to set your annual interest rate (e.g., 4.5%)."),
    ListItemModel(
        title: "Loan Tenure:",
        description:
            "Input: Adjust the slider to set your loan tenure in months (e.g., 4 months)."),
  ];

  final List<ListItemModel> howItWorksContent = [
    ListItemModel(
        title: "Calculations:",
        description:
            "Monthly payment calculated using the formula EMI = P × r × (1 + r)ⁿ / ((1 + r)ⁿ - 1), where P is loan amount, r is monthly interest rate, and n is tenure in months. Total interest is total paid minus principal."),
  ];
  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to prevent memory leaks
    for (var slider in slidersList) {
      slider['controller'].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      // appBar: appbarHeader("EMI Calculator", context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
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
                        child: Text(
                          "EMI Calculator",
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
                              "The EMI Calculator helps you estimate your monthly loan repayment amount. Adjust the sliders to input your loan amount, annual interest rate, and loan tenure in months to see the monthly EMI and total interest paid.",
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
                SliderPage(
                  slidersList: slidersList,
                  onSliderValueChanged: updateSliderValue,
                ),
                Container(
                    margin:
                        EdgeInsets.only(left:AppSizes.p4, right:AppSizes.p4, top: 0,),
                    decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(12)),
                    child: graph()),
                SizedBox(
                  height: 10,
                ),
                CustomExpansionTile(
                  howToUseContent: howToUseContent,
                  howItWorksContent: howItWorksContent,
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
      title: "EMI Details",
      graphData: [
        {
          'title':
              "Principal: ₹${formatMoneyIndian(loanAmount.toStringAsFixed(0))}",
          'value': loanAmount
        },
        {
          'title': "Interest: ₹${totalInterestPaid.toStringAsFixed(0)}",
          'value': totalInterestPaid
        },
      ],
      graphDisc: [
        {
          'title': 'EMI:',
          'amount': "₹${formatMoneyIndian(emi.toStringAsFixed(2))}"
        },
        {
          'title': 'Total Interest Paid:',
          'amount':
              "₹${formatMoneyIndian(totalInterestPaid.toStringAsFixed(0))}"
        },
      ],
    );
  }
}

PreferredSizeWidget appbarHeader(String title, BuildContext context) {
  return AppBar(
    centerTitle: true,
    title: Text(title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
  );
}
