import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';

import 'package:flutter_application_code_stakeplot/finance_screen/utils.dart';

class Savings extends StatefulWidget {
  const Savings({Key? key}) : super(key: key);

  @override
  _SavingsState createState() => _SavingsState();
}

class _SavingsState extends State<Savings> {
  late List slidersList;

  double targetAmount = 2300.0;
  double currentSavings = 400.0;
  double monthlyContribution = 400.0;
  int timeframe = 4;
  double interestRate = 4.0;

  double endBalance = 0.0;
  double interestEarned = 0.0;
  double goalProgress = 0.0;
  double remainingAmount = 0.0;
  List<double> savingsData = [];
  bool _isInfoVisible = false; // Controls visibility of the container
  double _opacity = 0.0; // Controls the fade effect
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    getslidersList();
    calculateSavings(); // Initial calculation
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
      getJsonBodyObj("Target amount", 2300.0, 1000.0, 100000.0, (value) {
        updateSliderValue(0, value);
      }, TextEditingController(text: '2300')),
      getJsonBodyObj("Current savings", 400.0, 0.0, 100000.0, (value) {
        updateSliderValue(1, value);
      }, TextEditingController(text: '400')),
      getJsonBodyObj("Monthly contribution", 400.0, 100.0, 10000.0, (value) {
        updateSliderValue(2, value);
      }, TextEditingController(text: '400')),
      getJsonBodyObj("Timeframe(months)", 4.0, 1.0, 360.0, (value) {
        updateSliderValue(3, value);
      }, TextEditingController(text: '4'), false, "mts"),
      getJsonBodyObj("Interest rate(%)", 4.0, 0.0, 10.0, (value) {
        updateSliderValue(4, value);
      }, TextEditingController(text: '4.0'), false, "%"),
    ];
  }

  void updateSliderValue(int index, double newValue) {
    double min = slidersList[index]['min'];
    double max = slidersList[index]['max'];
    newValue = newValue.clamp(min, max);

    setState(() {
      if (index != 4) {
        newValue = newValue.roundToDouble(); // Integer for non-interest fields
      }
      slidersList[index]['value'] = newValue;
      slidersList[index]['controller'].text = (index == 4)
          ? newValue.toStringAsFixed(1)
          : newValue.toStringAsFixed(0);

      targetAmount = slidersList[0]['value'];
      currentSavings = slidersList[1]['value'];
      monthlyContribution = slidersList[2]['value'];
      timeframe = slidersList[3]['value'].toInt();
      interestRate = slidersList[4]['value'];

      calculateSavings();
    });
  }

  void calculateSavings() {
    // Exact same logic as React useEffect
    double totalSavings = currentSavings;
    final double monthlyRate = interestRate / 100 / 12;
    savingsData.clear();

    // Calculate savings progression
    for (int i = 0; i < timeframe; i++) {
      totalSavings += monthlyContribution;
      totalSavings += totalSavings * monthlyRate;
      savingsData.add(totalSavings);
    }

    // Calculate metrics matching React
    final double totalInterest =
        totalSavings - (currentSavings + monthlyContribution * timeframe);
    //remainingAmount = targetAmount - currentSavings; // Match React's doughnut data

    setState(() {
      endBalance = double.parse(totalSavings.toStringAsFixed(2));
      interestEarned = double.parse(totalInterest.toStringAsFixed(2));
      goalProgress = double.parse(
          ((currentSavings / targetAmount) * 100).toStringAsFixed(2));
      remainingAmount = targetAmount - currentSavings;
      remainingAmount = remainingAmount < 0 ? 0 : remainingAmount;
    });
  }

  final List<ListItemModel> howToUseContent = [
    ListItemModel(
        title: "Target Amount:",
        description:
            "Adjust the slider to set your savings goal (e.g., ₹2300)."),
    ListItemModel(
        title: "Current Savings:",
        description: "Set your current savings amount (e.g., ₹400)."),
    ListItemModel(
        title: "Monthly Contribution:",
        description: "Set your monthly savings contribution (e.g., ₹400)."),
    ListItemModel(
        title: "Timeframe (Months):",
        description: "Set the duration in months (e.g., 4 months)."),
    ListItemModel(
        title: "Interest Rate (%):",
        description: "Set the annual interest rate (e.g., 4.5%)."),
  ];

  final List<ListItemModel> howItWorksContent = [
    ListItemModel(
        title: "Monthly Savings Calculation:",
        description:
            "Adds monthly contributions and interest earned each month."),
    ListItemModel(
        title: "End Balance Calculation:",
        description:
            "Projects total savings after timeframe, including interest."),
    ListItemModel(
        title: "Interest Earned Calculation:",
        description:
            "Estimates total interest based on rate and contributions."),
    ListItemModel(
        title: "Goal Progress Tracking:",
        description: "Shows progress as a percentage of the target amount."),
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
      backgroundColor: AppColors.primaryColor,
      // appBar: appbarHeader("Savings Goal Calculator", context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.primaryColorHeader),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: AppColors.backgroundColor,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      GestureDetector(
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
                          "Savings Calculator",
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w600,
                            fontSize: 18,
                            color: AppColors.backgroundColor,
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
                            margin: EdgeInsets.symmetric(vertical: 4),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundColor.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.backgroundColor, width: 1),
                            ),
                            child: SingleChildScrollView(
                             child: Text(
  "The Savings Goal Calculator helps you estimate how much you can save towards your financial goal. Adjust the sliders to input your target amount, current savings, monthly contribution, timeframe in months, and annual interest rate to see the projected end balance, interest earned, and progress towards your goal.",
  style: FontManager().getTextStyle(
    context,
    lWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.primaryColor,
  ),
  textAlign: TextAlign.center,
),
                            ),
                          )
                        : SizedBox.shrink(),
                  ),
                  SliderPage(
                      slidersList: slidersList,
                      onSliderValueChanged: updateSliderValue),
                  Container(
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
      ),
    );
  }

  Widget graph() {
    return PieChartGraph(
      title: "Savings Goal Progress:",
      graphData: [
        {
          'title':
              'Remaining Amount: ₹${formatMoneyIndian(remainingAmount.toStringAsFixed(0))}',
          'value': remainingAmount
        },
        {
          'title':
              'Current Savings: ₹${formatMoneyIndian(currentSavings.toStringAsFixed(0))}',
          'value': currentSavings
        }, // Updated to use endBalance
      ],
      graphDisc: [
        {
          'title': 'End Balance:',
          'amount': "₹${formatMoneyIndian(endBalance.toStringAsFixed(2))}"
        },
        {
          'title': 'Interest Earned:',
          'amount': "₹${interestEarned.toStringAsFixed(2)}"
        },
        {'title': 'Progress:', 'amount': "${goalProgress.toStringAsFixed(2)}%"},
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
