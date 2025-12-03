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

import '../../components/shared_utils.dart';

class SIPCalculator extends StatefulWidget {
  const SIPCalculator({Key? key}) : super(key: key);

  @override
  _SIPCalculatorState createState() => _SIPCalculatorState();
}

class _SIPCalculatorState extends State<SIPCalculator> {
  late List slidersList;
  double monthlyInvestment = 5000.0;
  double expectedReturnRate = 12.0;
  double investmentPeriod = 5.0;
  double futureValue = 0.0;
  double totalInvested = 0.0;
  double totalReturns = 0.0;
  bool _isInfoVisible = false;
  double _opacity = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    getslidersList();
    calculateSIPDetails();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isInfoVisible = true;
          _opacity = 1.0;
        });
        _timer = Timer(Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _opacity = 0.0;
            });
          }
        });
      }
    });
  }

  void getslidersList() {
    slidersList = [
      getJsonBodyObj("Monthly Investment", 5000.0, 1000.0, 100000.0, (value) {
        updateSliderValue(0, value);
      }, TextEditingController(text: '5000')),
      getJsonBodyObj("Expected Return Rate(%)", 12.0, 1.0, 20.0, (value) {
        updateSliderValue(1, value);
      }, TextEditingController(text: '12.0'), true, ""),
      getJsonBodyObj("Investment Period (Years)", 5.0, 1.0, 30.0, (value) {
        updateSliderValue(2, value);
      }, TextEditingController(text: '5')),
    ];
  }

  void updateSliderValue(int index, double newValue) {
    double min = slidersList[index]['min'];
    double max = slidersList[index]['max'];
    newValue = newValue.clamp(min, max);

    setState(() {
      if (index != 1) {
        newValue = newValue.roundToDouble();
      }
      slidersList[index]['value'] = newValue;
      slidersList[index]['controller'].text = (index == 1)
          ? newValue.toStringAsFixed(1)
          : newValue.toStringAsFixed(0);

      monthlyInvestment = slidersList[0]['value'];
      expectedReturnRate = slidersList[1]['value'];
      investmentPeriod = slidersList[2]['value'];

      calculateSIPDetails();
    });
  }

  void calculateSIPDetails() {
    double annualRate = expectedReturnRate / 100;
    double monthlyRate = pow(1 + annualRate, 1 / 12) - 1;
    double months = investmentPeriod * 12;
    if (monthlyRate == 0) {
      futureValue = monthlyInvestment * months;
    } else {
      futureValue = monthlyInvestment *
          ((pow(1 + monthlyRate, months) - 1) / monthlyRate) *
          (1 + monthlyRate);
    }
    totalInvested = monthlyInvestment * months;
    totalReturns = futureValue - totalInvested;
    totalReturns = totalReturns < 0 ? 0 : totalReturns;
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
                      padding: const EdgeInsets.only(left: 14),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isInfoVisible = true;
                            _opacity = 1.0;
                         
                          });
                          _timer?.cancel();
                          _timer = Timer(Duration(seconds: 2), () {
                            if (mounted) {
                              setState(() {
                                _opacity = 0.0;
                               
                              });
                            }
                          });
                        },
                        child: Text(
                          "SIP Calculator",
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w800,
                            fontSize: 40,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  onEnd: () {
                    if (_opacity == 0.0 && mounted) {
                      setState(() {
                        _isInfoVisible = false;
                       
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
                            border: Border.all(color: AppColors.backgroundColor, width: 1),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              "The SIP Calculator helps you estimate the future value of your Systematic Investment Plan. Adjust the sliders to input your monthly investment, expected annual return rate (net of fees), and investment period to see the total invested amount and returns.",
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
                      title: "Monthly Investment:",
                      description:
                          "Adjust the slider to set your monthly investment amount (e.g., ₹5000).",
                    ),
                    ListItemModel(
                      title: "Expected Return Rate:",
                      description:
                          "Adjust the slider to set the expected annual return rate (e.g., 12%).",
                    ),
                    ListItemModel(
                      title: "Investment Period:",
                      description:
                          "Adjust the slider to set the investment duration in years (e.g., 5 years).",
                    ),
                  ],
                  howItWorksContent: [
                    ListItemModel(
                      title: "Monthly Rate:",
                      description:
                          "Annual return rate divided by 12 and converted to decimal.",
                    ),
                    ListItemModel(
                      title: "Future Value:",
                      description:
                          "Calculated using the compound interest formula for monthly investments.",
                    ),
                    ListItemModel(
                      title: "Total Returns:",
                      description:
                          "Future value minus the total amount invested.",
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
      title: "Investment Breakdown",
      graphData: [
        {
          'title':
              'Invested: ₹${formatMoneyIndian(totalInvested.toStringAsFixed(0))}',
          'value': totalInvested,
        },
        {
          'title':
              'Returns: ₹${formatMoneyIndian(totalReturns.toStringAsFixed(0))}',
          'value': totalReturns,
        },
      ],
      graphDisc: [
        {
          'title': 'Future Value:',
          'amount': "₹${formatMoneyIndian(futureValue.toStringAsFixed(2))}",
        },
        {
          'title': 'Total Invested:',
          'amount': "₹${formatMoneyIndian(totalInvested.toStringAsFixed(2))}",
        },
        {
          'title': 'Total Returns:',
          'amount': "₹${formatMoneyIndian(totalReturns.toStringAsFixed(2))}",
        },
      ],
    );
  }
}
