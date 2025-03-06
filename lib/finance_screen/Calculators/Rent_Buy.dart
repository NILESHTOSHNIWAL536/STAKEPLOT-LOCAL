
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/creditCard.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/plot_finance.dart';

class RentBuy extends StatefulWidget {
  const RentBuy({Key? key}) : super(key: key);

  @override
  _RentBuyState createState() => _RentBuyState();
}

class _RentBuyState extends State<RentBuy> {
  late List slidersList;

  double rentingCost = 46000.0;
  double buying = 9946.0;
  double interest = 0;
  double principal = 0;

  @override
  void initState() {
    getslidersList();
  }

  void getslidersList() {
    slidersList = [
      getJsonBodyObj("Home price", 2000000, 2000000, 100000000, (value) {
        updateSliderValue(0, value);
      }, TextEditingController(text: '2')),
      getJsonBodyObj("Down payment(%)", 4, 0, 100, (value) {
        updateSliderValue(1, value);
      }, TextEditingController(text: '332'), false, "%"),
      getJsonBodyObj("Loan interest rate(%)", 4, 1, 20, (value) {
        updateSliderValue(2, value);
      }, TextEditingController(text: '2332'), false, "%"),
      getJsonBodyObj("Loan tenure(months)", 14, 12, 360, (value) {
        updateSliderValue(3, value);
      }, TextEditingController(text: '2332'), false, "Months"),
      getJsonBodyObj("Property tax rate(%)", 4, 0, 5, (value) {
        updateSliderValue(4, value);
      }, TextEditingController(text: '2332'), false, "%"),
      getJsonBodyObj("Maintenance Cost (% per year)", 4, 0, 10, (value) {
        updateSliderValue(5, value);
      }, TextEditingController(text: '2332'), false, "%"),
      getJsonBodyObj("Home Appreciation Rate (% per year)", 4, 0, 20, (value) {
        updateSliderValue(6, value);
      }, TextEditingController(text: '2332'), false, "%"),
      getJsonBodyObj("Monthly Rent", 10000, 5000, 100000, (value) {
        updateSliderValue(7, value);
      }, TextEditingController(text: '2332')),
      getJsonBodyObj("Rent Increase Rate (% per year)", 4, 0, 10, (value) {
        updateSliderValue(8, value);
      }, TextEditingController(text: '2332'), false, "%"),
    ];
  }
void calculateRentVsBuy({
  required double homePrice,
  required double downPayment,
  required double loanInterestRate,
  required double loanTenure, // in months
  required double propertyTaxRate,
  required double maintenanceCost,
  required double homeAppreciationRate,
  required double rent,
  required double rentIncreaseRate,
}) {
  // Convert annual interest rate to monthly
  double monthlyInterestRate = loanInterestRate / 12 / 100;
  
  // Calculate down payment amount
  double downPaymentAmount = (downPayment / 100) * homePrice;

  // Loan amount
  double loanAmount = homePrice - downPaymentAmount;

  // Calculate EMI
  double emi = loanAmount *
      monthlyInterestRate *
      (pow(1 + monthlyInterestRate, loanTenure) /
          (pow(1 + monthlyInterestRate, loanTenure) - 1));

  double totalLoanCost = emi * loanTenure;

  // Calculate total property tax
  double totalPropertyTax =
      (propertyTaxRate / 100) * homePrice * (loanTenure / 12);

  // Calculate total maintenance cost
  double totalMaintenanceCost =
      (maintenanceCost / 100) * homePrice * (loanTenure / 12);

  // Calculate home appreciation
  double appreciatedValue =
      homePrice * pow(1 + (homeAppreciationRate / 100), loanTenure / 12);

  // Calculate total buying cost
  double totalBuyCost = downPaymentAmount +
      totalLoanCost +
      totalPropertyTax +
      totalMaintenanceCost -
      appreciatedValue;

  // Calculate total rent cost
  double totalRent = 0;
  double currentRent = rent;
  
  for (int i = 0; i < loanTenure / 12; i++) {
    totalRent += currentRent * 12;
    currentRent *= 1 + (rentIncreaseRate / 100);
  }

  // Update the UI using setState
  setState(() {
    buying = totalBuyCost.roundToDouble();
    rentingCost = totalRent.roundToDouble();
  });
}

  void updateSliderValue(int index, double newValue) {
  setState(() {
    slidersList[index]['value'] = newValue;
    slidersList[index]['controller'].text = newValue.toStringAsFixed(0);
  });

  // Trigger Calculation
  calculateRentVsBuy(
    homePrice: slidersList[0]['value'],
    downPayment: slidersList[1]['value'],
    loanInterestRate: slidersList[2]['value'],
    loanTenure: slidersList[3]['value'],
    propertyTaxRate: slidersList[4]['value'],
    maintenanceCost: slidersList[5]['value'],
    homeAppreciationRate: slidersList[6]['value'],
    rent: slidersList[7]['value'],
    rentIncreaseRate: slidersList[8]['value'],
  );
}


  final List<ListItemModel> howToUseContent = [
    ListItemModel(
        title: "Home Price",
        description:
            "Adjust the slider to set the price of the home you are considering to buy."),
    ListItemModel(
        title: "Down Payment (%)",
        description:
            "Use the slider to set the percentage of the home price you plan to pay upfront as a down payment."),
    ListItemModel(
        title: "Loan Interest Rate (%)",
        description:
            "Set the annual interest rate for the loan using the slider."),
    ListItemModel(
        title: "Loan Tenure (Months)",
        description:
            "Adjust the slider to set the loan tenure in months (1-360 months)."),
    ListItemModel(
        title: "Property Tax Rate (%)",
        description:
            "Use the slider to set the annual property tax rate as a percentage of the home price."),
    ListItemModel(
        title: "Maintenance Cost (% per year)",
        description:
            "Set the annual maintenance cost as a percentage of the home price using the slider."),
    ListItemModel(
        title: "Home Appreciation Rate (% per year)",
        description:
            "Adjust the slider to set the expected annual appreciation rate of the home’s value."),
    ListItemModel(
        title: "Monthly Rent",
        description: "Use the slider to set the current monthly rent."),
    ListItemModel(
        title: "Rent Increase Rate (% per year)",
        description: "Adjust the slider to set the annual rent increase rate."),
  ];

  // Example data for "How it works?"
  final List<ListItemModel> howItWorksContent = [
    ListItemModel(
        title: "EMI Calculation",
        description:
            "The calculator determines the Equated Monthly Installment (EMI) based on the home price, down payment, loan interest rate, and loan tenure."),
    ListItemModel(
        title: "Total Buy Cost Calculation",
        description:
            "This includes the down payment, total loan cost (EMI x loan tenure), property tax, and maintenance cost over the loan tenure. "
            "The appreciated value of the home over the loan tenure is subtracted from the total buy cost to account for the potential increase in home value."),
    ListItemModel(
        title: "Total Rent Cost Calculation",
        description:
            "The total rent paid over the loan tenure is calculated by accounting for the initial rent and the annual rent increase rate."),
    ListItemModel(
        title: "Comparison",
        description:
            "The calculator compares the total cost of buying and renting over the specified period. "
            "The results are displayed in a doughnut chart, visually representing the costs of both options."),
  ];

  // Callback function to update the slider values

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appbarHeader("Rent vs Buy Calculator", context),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SliderPage(
                      slidersList: slidersList,
                      onSliderValueChanged: updateSliderValue),
                  graph(),
                  CustomExpansionTile(
                    howToUseContent: howToUseContent,
                    howItWorksContent: howItWorksContent,
                  ),
                ],
              ),
            )));
  }

  Widget graph() {
    return PieChartGraph(title: "Rent vs Buy Details:", graphData: [
      {'title': 'total buy cost : ₹${(buying).toString()}', 'value': buying},
      {'title': 'total renting cost : ₹${(rentingCost).toString()}', 'value': rentingCost},
    ], graphDisc: [
      {
        'title': 'Total cost of renting:',
        'amount': "₹ ${(rentingCost).toString()}",
      },
      {'title': 'Total cost of buying:', 'amount': "₹ ${(buying).toString()}"}
    ]);
  }
}
