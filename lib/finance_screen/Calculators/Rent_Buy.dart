import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';

import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';

import 'package:flutter_application_code_stakeplot/Constants/calculator_utils.dart';

import '../../Constants/core/app_padding_sizes.dart';
import '../../components/shared_utils.dart';

class RentBuy extends StatefulWidget {
  const RentBuy({Key? key}) : super(key: key);

  @override
  _RentBuyState createState() => _RentBuyState();
}

class _RentBuyState extends State<RentBuy> {
  late List slidersList;

  double homePrice = 2000000.0;
  double downPayment = 20.0; // Percentage
  double loanInterestRate = 4.0; // Percentage
  double loanTenure = 240.0; // Months
  double propertyTaxRate = 1.0; // Percentage
  double maintenanceCost = 2.0; // Percentage per year
  double homeAppreciationRate = 3.0; // Percentage per year
  double monthlyRent = 10000.0;
  double rentIncreaseRate = 2.0; // Percentage per year

  double totalRentingCost = 0.0;
  double totalBuyingCost = 0.0;
  bool _isInfoVisible = false; // Controls visibility of the container
  double _opacity = 0.0; // Controls the fade effect
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    getslidersList();
    calculateRentVsBuy(); // Initial calculation
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
      getJsonBodyObj("Home price", 2000000.0, 2000000.0, 100000000.0, (value) {
        updateSliderValue(0, value);
      }, TextEditingController(text: '2000000')),
      getJsonBodyObj("Down payment(%)", 20.0, 0.0, 100.0, (value) {
        updateSliderValue(1, value);
      }, TextEditingController(text: '20'), false, "%"),
      getJsonBodyObj("Loan interest rate(%)", 4.0, 1.0, 20.0, (value) {
        updateSliderValue(2, value);
      }, TextEditingController(text: '4.0'), false, "%"),
      getJsonBodyObj("Loan tenure(months)", 240.0, 12.0, 360.0, (value) {
        updateSliderValue(3, value);
      }, TextEditingController(text: '240'), false, "Mts"),
      getJsonBodyObj("Property tax rate(%)", 1.0, 0.0, 5.0, (value) {
        updateSliderValue(4, value);
      }, TextEditingController(text: '1.0'), false, "%"),
      getJsonBodyObj("Maintenance Cost (% per year)", 2.0, 0.0, 10.0, (value) {
        updateSliderValue(5, value);
      }, TextEditingController(text: '2.0'), false, "%"),
      getJsonBodyObj("Home Appreciation Rate (% per year)", 3.0, 0.0, 20.0,
          (value) {
        updateSliderValue(6, value);
      }, TextEditingController(text: '3.0'), false, "%"),
      getJsonBodyObj("Monthly Rent", 10000.0, 5000.0, 100000.0, (value) {
        updateSliderValue(7, value);
      }, TextEditingController(text: '10000')),
      getJsonBodyObj("Rent Increase Rate (% per year)", 2.0, 0.0, 10.0,
          (value) {
        updateSliderValue(8, value);
      }, TextEditingController(text: '2.0'), false, "%"),
    ];
  }

  void calculateRentVsBuy() {
    double monthlyInterestRate = loanInterestRate / 12 / 100;
    double downPaymentAmount = (downPayment / 100) * homePrice;
    double loanAmount = homePrice - downPaymentAmount;

    double emi = 0;
    if (monthlyInterestRate > 0 && loanTenure > 0) {
      emi = loanAmount *
          monthlyInterestRate *
          (pow(1 + monthlyInterestRate, loanTenure) /
              (pow(1 + monthlyInterestRate, loanTenure) - 1));
    }
    double totalLoanCost = emi * loanTenure;

    double totalPropertyTax =
        (propertyTaxRate / 100) * homePrice * (loanTenure / 12);
    double totalMaintenanceCost =
        (maintenanceCost / 100) * homePrice * (loanTenure / 12);
    double appreciatedValue =
        homePrice * pow(1 + (homeAppreciationRate / 100), loanTenure / 12);
    totalBuyingCost = downPaymentAmount +
        totalLoanCost +
        totalPropertyTax +
        totalMaintenanceCost -
        appreciatedValue;

    totalRentingCost = 0;
    double currentRent = monthlyRent;
    for (int i = 0; i < loanTenure / 12; i++) {
      totalRentingCost += currentRent * 12;
      currentRent *= 1 + (rentIncreaseRate / 100);
    }
  }

  void updateSliderValue(int index, double newValue) {
    double min = slidersList[index]['min'];
    double max = slidersList[index]['max'];
    newValue = newValue.clamp(min, max);

    setState(() {
      // Float fields: 2, 4, 5, 6, 8 (interest rates and percentages)
      if (index != 2 && index != 4 && index != 5 && index != 6 && index != 8) {
        newValue = newValue.roundToDouble(); // Integer for non-float fields
      }
      slidersList[index]['value'] = newValue;
      slidersList[index]['controller'].text =
          (index == 2 || index == 4 || index == 5 || index == 6 || index == 8)
              ? newValue.toStringAsFixed(1)
              : newValue.toStringAsFixed(0);

      homePrice = slidersList[0]['value'];
      downPayment = slidersList[1]['value'];
      loanInterestRate = slidersList[2]['value'];
      loanTenure = slidersList[3]['value'];
      propertyTaxRate = slidersList[4]['value'];
      maintenanceCost = slidersList[5]['value'];
      homeAppreciationRate = slidersList[6]['value'];
      monthlyRent = slidersList[7]['value'];
      rentIncreaseRate = slidersList[8]['value'];

      calculateRentVsBuy();
    });
  }

  final List<ListItemModel> howToUseContent = [
    ListItemModel(
        title: "Home Price:",
        description:
            "Adjust the slider to set the price of the home (e.g., ₹2,000,000)."),
    ListItemModel(
        title: "Down Payment (%):",
        description:
            "Set the percentage of the home price for the down payment (e.g., 20%)."),
    ListItemModel(
        title: "Loan Interest Rate (%):",
        description: "Set the annual loan interest rate (e.g., 4.5%)."),
    ListItemModel(
        title: "Loan Tenure (Months):",
        description: "Set the loan tenure in months (e.g., 240 months)."),
    ListItemModel(
        title: "Property Tax Rate (%):",
        description: "Set the annual property tax rate (e.g., 1.0%)."),
    ListItemModel(
        title: "Maintenance Cost (% per year):",
        description:
            "Set the annual maintenance cost percentage (e.g., 2.0%)."),
    ListItemModel(
        title: "Home Appreciation Rate (% per year):",
        description: "Set the annual home appreciation rate (e.g., 3.0%)."),
    ListItemModel(
        title: "Monthly Rent:",
        description: "Set the current monthly rent (e.g., ₹10,000)."),
    ListItemModel(
        title: "Rent Increase Rate (% per year):",
        description: "Set the annual rent increase rate (e.g., 2.0%)."),
  ];

  final List<ListItemModel> howItWorksContent = [
    ListItemModel(
        title: "EMI Calculation:",
        description:
            "Calculates monthly loan payment using the formula EMI = P × r × (1 + r)ⁿ / ((1 + r)ⁿ - 1)."),
    ListItemModel(
        title: "Total Buy Cost:",
        description:
            "Includes down payment, loan cost, property tax, maintenance, minus home appreciation."),
    ListItemModel(
        title: "Total Rent Cost:",
        description:
            "Sums annual rent costs with yearly increases over the loan tenure."),
    ListItemModel(
        title: "Comparison:",
        description: "Compares total buying vs. renting costs in a pie chart."),
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
      // appBar: appbarHeader("Rent vs Buy Calculator", context),
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
                          "Rent vs Buy Calculator",
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
                              "The Rent vs. Buy Calculator helps you compare the costs of renting versus buying a home. Adjust the sliders to input the home price, down payment, loan interest rate, loan tenure, property tax rate, maintenance cost, home appreciation rate, monthly rent, and rent increase rate to see the total costs of renting and buying.",
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
                      left:AppSizes.p4,
                      right:AppSizes.p4,
                      top: 0,
                    ),
                    decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(12)),
                    child: graph()),
                SizedBox(
                  height: AppSizes.h10,
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
      title: "Rent vs Buy Details:",
      graphData: [
        {
          'title':
              'Total Buy Cost: ₹${formatMoneyIndian(totalBuyingCost.toStringAsFixed(0))}',
          'value': totalBuyingCost
        },
        {
          'title':
              'Total Renting Cost: ₹${formatMoneyIndian(totalRentingCost.toStringAsFixed(0))}',
          'value': totalRentingCost
        },
      ],
      graphDisc: [
        {
          'title': 'Total Cost of Renting:',
          'amount': "₹${formatMoneyIndian(totalRentingCost.toStringAsFixed(0))}"
        },
        {
          'title': 'Total Cost of Buying:',
          'amount': "₹${formatMoneyIndian(totalBuyingCost.toStringAsFixed(0))}"
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
