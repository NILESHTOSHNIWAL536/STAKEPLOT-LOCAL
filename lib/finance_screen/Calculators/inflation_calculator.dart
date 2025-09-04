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

class InflationCalculator extends StatefulWidget {
  const InflationCalculator({Key? key}) : super(key: key);

  @override
  _InflationCalculatorState createState() => _InflationCalculatorState();
}

class _InflationCalculatorState extends State<InflationCalculator> {
  late List slidersList;
  double presentValue = 10000.0; // Current amount
  double inflationRate = 5.0; // Annual inflation rate (%)
  double timePeriod = 5.0; // Time period in years
  double futureValue = 0.0; // Future value adjusted for inflation
  double purchasingPowerLoss = 0.0; // Difference between future and present value
  bool _isInfoVisible = false;
  double _opacity = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    getSlidersList();
    calculateInflationDetails();
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

  void getSlidersList() {
    slidersList = [
      getJsonBodyObj("Current Amount", 10000.0, 1000.0, 100000.0, (value) {
        updateSliderValue(0, value);
      }, TextEditingController(text: '10000')),
      getJsonBodyObj("Inflation Rate (%)", 5.0, 1.0, 15.0, (value) {
        updateSliderValue(1, value);
      }, TextEditingController(text: '5.0'), true, ""),
      getJsonBodyObj("Time Period (Years)", 5.0, 1.0, 30.0, (value) {
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

      presentValue = slidersList[0]['value'];
      inflationRate = slidersList[1]['value'];
      timePeriod = slidersList[2]['value'];

      calculateInflationDetails();
    });
  }

  void calculateInflationDetails() {
    double annualRate = inflationRate / 100;
    futureValue = presentValue * pow(1 + annualRate, timePeriod);
    purchasingPowerLoss = futureValue - presentValue;
    purchasingPowerLoss = purchasingPowerLoss < 0 ? 0 : purchasingPowerLoss;
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
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.primaryColorHeader,
            ),
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
                      Container(
                        width: MediaQuery.sizeOf(context).width / 1.5,
                        child: Center(
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
                              "Inflation Calculator",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w600,
                                fontSize: 18,
                                color: AppColors.backgroundColor,
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
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                "The Inflation Calculator helps you estimate the future value of your money adjusted for inflation. Adjust the sliders to input the current amount, expected annual inflation rate, and time period to see the future value and loss in purchasing power.",
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
                    onSliderValueChanged: updateSliderValue,
                  ),
                  Container(
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
                        title: "Current Amount:",
                        description:
                            "Adjust the slider to set the current amount of money (e.g., ₹10000).",
                      ),
                      ListItemModel(
                        title: "Inflation Rate:",
                        description:
                            "Adjust the slider to set the expected annual inflation rate (e.g., 5%).",
                      ),
                      ListItemModel(
                        title: "Time Period:",
                        description:
                            "Adjust the slider to set the time period in years (e.g., 5 years).",
                      ),
                    ],
                    howItWorksContent: [
                      ListItemModel(
                        title: "Future Value:",
                        description:
                            "Calculated using the compound interest formula adjusted for inflation.",
                      ),
                      ListItemModel(
                        title: "Purchasing Power Loss:",
                        description:
                            "The difference between the future value and the current amount, representing the loss in purchasing power.",
                      ),
                    ],
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
      title: "Value Breakdown",
      graphData: [
        {
          'title':
              'Current Value: ₹${formatMoneyIndian(presentValue.toStringAsFixed(0))}',
          'value': presentValue,
        },
        {
          'title':
              'Purchasing Power Loss: ₹${formatMoneyIndian(purchasingPowerLoss.toStringAsFixed(0))}',
          'value': purchasingPowerLoss,
        },
      ],
      graphDisc: [
        {
          'title': 'Future Value:',
          'amount': "₹${formatMoneyIndian(futureValue.toStringAsFixed(2))}",
        },
        {
          'title': 'Current Value:',
          'amount': "₹${formatMoneyIndian(presentValue.toStringAsFixed(2))}",
        },
        {
          'title': 'Purchasing Power Loss:',
          'amount': "₹${formatMoneyIndian(purchasingPowerLoss.toStringAsFixed(2))}",
        },
      ],
    );
  }
}