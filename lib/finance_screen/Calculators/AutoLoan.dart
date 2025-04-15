// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
// // import 'package:flutter_application_code_stakeplot/finance_screen/creditCard.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/plot_finance.dart';
// String selectedBrand = 'Toyota'; // Selected car brand

// class AutoLoan extends StatefulWidget {
//   const AutoLoan({ Key? key }) : super(key: key);

//   @override
//   _AutoLoanState createState() => _AutoLoanState();
// }

// class _AutoLoanState extends State<AutoLoan> {

//   late List slidersList;

  
//  double carPrice = 3000000; // Car price
// double downPayment = 20; // Down payment as percentage
// double loanInterestRate = 7; // Annual loan interest rate
// int loanTenure = 60; // Loan tenure in months
// double maintenanceCost = 3; // Annual maintenance cost as percentage of car price
// // String selectedBrand = 'Toyota'; // Selected car brand

// double monthlyLoanPayment = 0; // Monthly loan payment
// double totalLoanCost = 0; // Total cost of the loan
// double annualMaintenanceCost = 0; // Annual maintenance cost
// double depreciationValue = 0; // Depreciation value after 4 years


//   @override
//   void initState()
//   {
//       getslidersList();
//   }

//    void getslidersList(){
//       slidersList=[
//          getJsonBodyObj("Car Price",510000,500000,10000000,(value){},TextEditingController(text: '2')),
//          getJsonBodyObj("Down Payment",4,0,100,(value){},TextEditingController(text: '332'),false,"%"),
//          getJsonBodyObj("Loan Interest Rate",4,1,20,(value){},TextEditingController(text: '2332'),false,"%"),
//          getJsonBodyObj("Loan Tenure(Months)",12,12,120,(value){},TextEditingController(text: '2332'),false,"Months"),
//          getJsonBodyObj("Annual maintenance cost",4,1,10,(value){},TextEditingController(text: '2332'),false,"%"),
//      ];
//   }
//   final List<ListItemModel> howToUseContent = [
//   ListItemModel(
//       title: "Car Price",
//       description: "Use the slider to set the price of the car you intend to purchase."),
//   ListItemModel(
//       title: "Down Payment (%)",
//       description: "Adjust the slider to set the percentage of the car price you plan to pay as a down payment."),
//   ListItemModel(
//       title: "Loan Interest Rate (%)",
//       description: "Set the annual interest rate for the loan using the slider."),
//   ListItemModel(
//       title: "Loan Tenure (Months)",
//       description: "Adjust the slider to set the loan tenure in months (1-120 months)."),
//   ListItemModel(
//       title: "Annual Maintenance Cost (% of car price)",
//       description: "Set the annual maintenance cost as a percentage of the car price using the slider."),
//   ListItemModel(
//       title: "Select Car Brand",
//       description: "Choose from various car brands to see estimates tailored to specific vehicles."),
// ];


//   // Example data for "How it works?"
//   final List<ListItemModel> howItWorksContent = [
//   ListItemModel(
//       title: "Monthly Loan Payment Calculation",
//       description: "The calculator determines the Equated Monthly Installment (EMI) based on the car price, down payment, loan interest rate, and loan tenure."),
//   ListItemModel(
//       title: "Total Loan Cost Calculation",
//       description: "This includes the total amount paid towards the loan over the specified tenure, considering the EMI payments."),
//   ListItemModel(
//       title: "Annual Maintenance Cost Calculation",
//       description: "The calculator estimates the annual maintenance expenses based on the selected car brand and the specified maintenance cost percentage."),
//   ListItemModel(
//       title: "Depreciation Value Calculation",
//       description: "The estimated depreciation value of the car after four years is calculated based on the selected car brand."),
// ];

//  void updateSliderValue(int index, double newValue) {
//     setState(() {
//       switch (index) {
//         case 0:
//           carPrice = newValue;
//           break;
//         case 1:
//           downPayment = newValue;
//           break;
//         case 2:
//           loanInterestRate = newValue;
//           break;
//         case 3:
//           loanTenure = newValue.toInt();
//           break;
//         case 4:
//           maintenanceCost = newValue;
//           break;
//       }
//       calculateLoanDetails();
//     });
//   }

//   void calculateLoanDetails() {
//     double monthlyInterestRate = loanInterestRate / 12 / 100;
//     double downPaymentAmount = (downPayment / 100) * carPrice;
//     double loanAmount = carPrice - downPaymentAmount;

//     double emi = (loanAmount * monthlyInterestRate *
//         pow(1 + monthlyInterestRate, loanTenure)) /
//         (pow(1 + monthlyInterestRate, loanTenure) - 1);
//     double totalCost = emi * loanTenure;

//     Map<String, double> maintenanceCostMap = {
//       'Toyota': 0.35,
//       'Honda': 0.65,
//       'Hyundai': 0.46,
//       'Mahindra': 0.30,
//       'Tata': 0.53,
//       'Jeep': 0.75,
//     };
//     double maintenancePercentage = maintenanceCostMap[selectedBrand] ?? 2.0;
//     double annualMaintenance = (maintenancePercentage / 100) * carPrice;

//     Map<String, double> depreciationMap = {
//       'Toyota': 0.60,
//       'Honda': 0.55,
//       'Hyundai': 0.50,
//       'Mahindra': 0.55,
//       'Tata': 0.50,
//       'Jeep': 0.50,
//     };
//     double depreciation = (depreciationMap[selectedBrand] ?? 0.50) * carPrice;

//     setState(() {
//       monthlyLoanPayment = emi;
//       totalLoanCost = totalCost;
//       annualMaintenanceCost = annualMaintenance;
//       depreciationValue = depreciation;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//           appBar: appbarHeader("Auto loan calculator ", context),
//           body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//              SliderPage(slidersList: slidersList,onSliderValueChanged: updateSliderValue,title: "Cars",),
//              graph(),
//               CustomExpansionTile(
//                  howToUseContent: howToUseContent,
//                 howItWorksContent: howItWorksContent,
//               ),
             
//             ],
//           ),
//   )
//   ),
//     );
//   }

//  Widget graph() {
//     return PieChartGraph(
//       title: "Auto Loan Details:",
//       graphData: [
//         {'title': 'Total Loan Cost : ₹${totalLoanCost.toStringAsFixed(2)}', 'value': totalLoanCost},
//         {'title': 'Annual Maintenance : ₹${annualMaintenanceCost.toStringAsFixed(2)}', 'value': annualMaintenanceCost},
//         {'title': 'Depreciation Value : ₹${depreciationValue.toStringAsFixed(2)}', 'value': depreciationValue},
//       ],
//       graphDisc: [
//         {'title': 'Monthly Loan Payment:', 'amount': "₹ ${monthlyLoanPayment.toStringAsFixed(2)}"},
//         {'title': 'Total Loan Cost:', 'amount': "₹ ${totalLoanCost.toStringAsFixed(2)}"},
//         {'title': 'Annual Maintenance:', 'amount': "₹ ${annualMaintenanceCost.toStringAsFixed(2)}"},
//         {'title': 'Depreciation Value:', 'amount': "₹ ${depreciationValue.toStringAsFixed(2)}"},
//       ]
//     );
//   }


// }


// PreferredSizeWidget appbarHeader(String title,BuildContext context,){
//     return AppBar(
//          centerTitle: true,
//           title: textStyle(context: context,text: title,fontsize: 16,fontWeight: FontWeight.w500),
//     );
// }
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/plot_finance.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/utils.dart';

class AutoLoan extends StatefulWidget {
  const AutoLoan({Key? key}) : super(key: key);

  @override
  _AutoLoanState createState() => _AutoLoanState();
}

class _AutoLoanState extends State<AutoLoan> {
  late List slidersList;
  double carPrice = 3000000;
  double downPayment = 20;
  double loanInterestRate = 7;
  int loanTenure = 60;
  double maintenanceCost = 3;
  double monthlyLoanPayment = 0;
  double totalLoanCost = 0;
  double annualMaintenanceCost = 0;
  double depreciationValue = 0;

  @override
  void initState() {
    super.initState();
    getslidersList();
    calculateLoanDetails();
  }

  void getslidersList() {
    slidersList = [
      getJsonBodyObj("Car Price", 3000000.0, 500000.0, 10000000.0, (value) {
        updateSliderValue(0, value);
      }, TextEditingController(text: '3000000')),
      getJsonBodyObj("Down Payment", 20.0, 0.0, 100.0, (value) {
        updateSliderValue(1, value);
      }, TextEditingController(text: '20'), false, "%"),
      getJsonBodyObj("Loan Interest Rate", 7.0, 1.0, 20.0, (value) {
        updateSliderValue(2, value);
      }, TextEditingController(text: '7.0'), false, "%"),
      getJsonBodyObj("Loan Tenure(Months)", 60.0, 12.0, 120.0, (value) {
        updateSliderValue(3, value);
      }, TextEditingController(text: '60'), false, "Mts"),
      getJsonBodyObj("Annual maintenance cost", 3.0, 1.0, 10.0, (value) {
        updateSliderValue(4, value);
      }, TextEditingController(text: '3.0'), false, "%"),
    ];
  }

  void updateSliderValue(int index, double newValue) {
    setState(() {
      switch (index) {
        case 0:
          carPrice = newValue.roundToDouble(); // Integer
          slidersList[index]['value'] = carPrice;
          slidersList[index]['controller'].text = carPrice.toStringAsFixed(0);
          break;
        case 1:
          downPayment = newValue.roundToDouble(); // Integer
          slidersList[index]['value'] = downPayment;
          slidersList[index]['controller'].text = downPayment.toStringAsFixed(0);
          break;
        case 2:
          loanInterestRate = newValue; // Float
          slidersList[index]['value'] = loanInterestRate;
          slidersList[index]['controller'].text = loanInterestRate.toStringAsFixed(1);
          break;
        case 3:
          loanTenure = newValue.round(); // Integer
          slidersList[index]['value'] = loanTenure.toDouble();
          slidersList[index]['controller'].text = loanTenure.toString();
          break;
        case 4:
          maintenanceCost = newValue; // Float
          slidersList[index]['value'] = maintenanceCost;
          slidersList[index]['controller'].text = maintenanceCost.toStringAsFixed(1);
          break;
      }
      calculateLoanDetails();
    });
  }

  void calculateLoanDetails() {
    double monthlyInterestRate = loanInterestRate / 12 / 100;
    double downPaymentAmount = (downPayment / 100) * carPrice;
    double loanAmount = carPrice - downPaymentAmount;

    if (monthlyInterestRate > 0 && loanTenure > 0) {
      monthlyLoanPayment = (loanAmount * monthlyInterestRate *
              pow(1 + monthlyInterestRate, loanTenure)) /
          (pow(1 + monthlyInterestRate, loanTenure) - 1);
      totalLoanCost = monthlyLoanPayment * loanTenure;
    } else {
      monthlyLoanPayment = 0;
      totalLoanCost = 0;
    }

    Map<String, double> maintenanceCostMap = {
      'Toyota': 0.35,
      'Honda': 0.65,
      'Hyundai': 0.46,
      'Mahindra': 0.30,
      'Tata': 0.53,
      'Jeep': 0.75,
    };
    double maintenancePercentage = maintenanceCostMap[selectedBrand] ?? 2.0;
    annualMaintenanceCost = (maintenanceCost / 100) * carPrice; // Use slider value

    Map<String, double> depreciationMap = {
      'Toyota': 0.60,
      'Honda': 0.55,
      'Hyundai': 0.50,
      'Mahindra': 0.55,
      'Tata': 0.50,
      'Jeep': 0.50,
    };
    depreciationValue = (depreciationMap[selectedBrand] ?? 0.50) * carPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbarHeader("Auto Loan Calculator", context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SliderPage(
                  slidersList: slidersList,
                  onSliderValueChanged: updateSliderValue,
                  title: "Cars",
                ),
                graph(),
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
      title: "Auto Loan Details:",
      graphData: [
        {'title': 'Total Loan Cost: ₹${totalLoanCost.toStringAsFixed(2)}', 'value': totalLoanCost},
        {'title': 'Annual Maintenance: ₹${annualMaintenanceCost.toStringAsFixed(2)}', 'value': annualMaintenanceCost},
        {'title': 'Depreciation Value: ₹${depreciationValue.toStringAsFixed(2)}', 'value': depreciationValue},
      ],
      graphDisc: [
        {'title': 'Monthly Loan Payment:', 'amount': "₹${monthlyLoanPayment.toStringAsFixed(2)}"},
        {'title': 'Total Loan Cost:', 'amount': "₹${totalLoanCost.toStringAsFixed(2)}"},
        {'title': 'Annual Maintenance:', 'amount': "₹${annualMaintenanceCost.toStringAsFixed(2)}"},
        {'title': 'Depreciation Value:', 'amount': "₹${depreciationValue.toStringAsFixed(2)}"},
      ],
    );
  }

  final List<ListItemModel> howToUseContent = [
    ListItemModel(title: "Car Price", description: "Use the slider to set the price of the car you intend to purchase."),
    ListItemModel(title: "Down Payment (%)", description: "Adjust the slider to set the percentage of the car price you plan to pay as a down payment."),
    ListItemModel(title: "Loan Interest Rate (%)", description: "Set the annual interest rate for the loan using the slider."),
    ListItemModel(title: "Loan Tenure (Months)", description: "Adjust the slider to set the loan tenure in months (12-120 months)."),
    ListItemModel(title: "Annual Maintenance Cost (% of car price)", description: "Set the annual maintenance cost as a percentage of the car price using the slider."),
    ListItemModel(title: "Select Car Brand", description: "Choose from various car brands to see estimates tailored to specific vehicles."),
  ];

  final List<ListItemModel> howItWorksContent = [
    ListItemModel(title: "Monthly Loan Payment Calculation", description: "The calculator determines the Equated Monthly Installment (EMI) based on the car price, down payment, loan interest rate, and loan tenure."),
    ListItemModel(title: "Total Loan Cost Calculation", description: "This includes the total amount paid towards the loan over the specified tenure, considering the EMI payments."),
    ListItemModel(title: "Annual Maintenance Cost Calculation", description: "The calculator estimates the annual maintenance expenses based on the specified maintenance cost percentage."),
    ListItemModel(title: "Depreciation Value Calculation", description: "The estimated depreciation value of the car after four years is calculated based on the selected car brand."),
  ];
}

PreferredSizeWidget appbarHeader(String title, BuildContext context) {
  return AppBar(
    centerTitle: true,
    title: textStyle(context: context, text: title, fontsize: 16, fontWeight: FontWeight.w500),
  );
}