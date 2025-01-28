// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/creditCard.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/plot_finance.dart';

// class CreditCard extends StatefulWidget {
//   const CreditCard({ Key? key }) : super(key: key);

//   @override
//   _CreditCardState createState() => _CreditCardState();
// }

// class _CreditCardState extends State<CreditCard> {

//    late List slidersList;

//   @override
//   void initState()
//   {
//       getslidersList();
//   }

//    void getslidersList(){
//       slidersList=[
//          getJsonBodyObj("Car Price",4,3,12,(value){},TextEditingController(text: '2')),
//          getJsonBodyObj("Down Payment",4,1,12,(value){},TextEditingController(text: '332')),
//          getJsonBodyObj("Loan Interest Rate",4,1,12,(value){},TextEditingController(text: '2332')),
//          getJsonBodyObj("Loan Tenure",4,1,12,(value){},TextEditingController(text: '2332')),
//          getJsonBodyObj("Annual maintenance cost",4,1,12,(value){},TextEditingController(text: '2332')),
//      ];
//   }
  
  
//   @override
//   Widget build(BuildContext context) {
//       return  Scaffold(
//           backgroundColor: AppColors.backgroundColor,
//           appBar: appbarHeader("Credit card pay off calculator ", context),
//           body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//                SliderPage(slidersList: slidersList),
//               PieChartGraph(),
//               CustomExpansionTile(
//                  howToUseContent: Expansioncalculator.creditcardTitle1,
//                 howItWorksContent: Expansioncalculator.creditcardTitle2,
//               ),
//   ])
//   )
//   ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Slider.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/expansionTile.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/graphCard.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/plot_finance.dart';

class CreditCard extends StatefulWidget {
  const CreditCard({Key? key}) : super(key: key);

  @override
  _CreditCardState createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> {
  late List slidersList;

  @override
  void initState() {
    super.initState();
    getSlidersList();
  }

  void getSlidersList() {
    slidersList = [
      getJsonBodyObj("Car Price", 5000, 0, 10000, TextEditingController(text: '5000')),
      getJsonBodyObj("Down Payment", 2000, 0, 5000, TextEditingController(text: '2000')),
      getJsonBodyObj("Loan Interest Rate", 5, 0, 10, TextEditingController(text: '5')),
      getJsonBodyObj("Loan Tenure", 5, 0, 20, TextEditingController(text: '5')),
      getJsonBodyObj("Annual Maintenance Cost", 300, 0, 1000, TextEditingController(text: '300')),
    ];
  }

  Map<String, dynamic> getJsonBodyObj(
      String name, double value, double min, double max, TextEditingController controller) {
    return {
      'name': name,
      'value': value,
      'min': min,
      'max': max,
      'controller': controller,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text("Credit Card Payoff Calculator"),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SliderPage(slidersList: slidersList),
              const PieChartGraph(),
             CustomExpansionTile(
                howToUseContent: Expansioncalculator.creditcardTitle1,
                howItWorksContent: Expansioncalculator.creditcardTitle2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}