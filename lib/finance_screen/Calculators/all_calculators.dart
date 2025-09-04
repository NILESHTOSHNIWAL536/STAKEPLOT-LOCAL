// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Emi.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Rent_Buy.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Savings.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/TripCost.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/credit_card.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/sip_calculator.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/veg_nonveg.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class AllCalculatorScreen extends StatefulWidget {
//   @override
//   State<AllCalculatorScreen> createState() => _AllCalculatorScreenState();
// }

// class _AllCalculatorScreenState extends State<AllCalculatorScreen> {
//   final List<Map<String, dynamic>> calculators = [
//     {
//       'name': 'Credit Card Payoff',
//       'svgPath': 'assets/icons/financeScreen/f6.svg',
//       'screen': CreditCard(),
//     },
//     {
//       'name': 'EMI',
//       'svgPath': 'assets/icons/financeScreen/f5.svg',
//       'screen': Emi(),
//     },
//     {
//       'name': 'Rent vs Buy',
//       'svgPath': 'assets/icons/financeScreen/f4.svg',
//       'screen': RentBuy(),
//     },
//     // {
//     //   'name': 'Savings Goal',
//     //   'svgPath': 'assets/icons/financeScreen/f3.svg',
//     //   'screen': Savings(),
//     // },
//     // {
//     //   'name': 'Auto Loan',
//     //   'svgPath': 'assets/icons/financeScreen/f2.svg',
//     //   'screen': AutoLoan(),
//     // },
//     // {
//     //   'name': 'Cost',
//     //   'svgPath': 'assets/icons/financeScreen/f1.svg',
//     //   'screen': TripCost(),
//     // },
//     {
//       'name': 'SIP',
//       'svgPath': 'assets/icons/financeScreen/f1.svg',
//       'screen': SIPCalculator(),
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     double height = MediaQuery.sizeOf(context).height;
//     // double width = MediaQuery.sizeOf(context).width;
//     return Scaffold(
//       backgroundColor: AppColors.primaryColor,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: Transform.translate(
//                 offset: const Offset(0, 30),
//                 child: Container(
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         width: MediaQuery.sizeOf(context).width / 1.6,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             IconButton(
//                               icon: Icon(
//                                 Icons.arrow_back,
//                                 color: AppColors.backgroundColor,
//                               ),
//                               onPressed: () {
//                                 Navigator.pop(context);
//                               },
//                             ),
//                             Text(
//                               "Emi Calculators",
//                               style: FontManager().getTextStyle(
//                                 context,
//                                 lWeight: FontWeight.w600,
//                                 fontSize: 18,
//                                 color: AppColors.backgroundColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   height: 150,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         const Color(0xE6061F35),
//                         const Color(0x00061F35),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: Transform.translate(
//                 offset: const Offset(0, 80),
//                 child: CustomPaint(
//                   painter: CustomShapePainter(),
//                 ),
//               ),
//             ),
//             Transform.translate(
//               offset: const Offset(0, 85),
//               child: Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
//                 child: Container(
//                   height: height / 1.32,
//                   child: GridView.builder(
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 16,
//                       mainAxisSpacing: 16,
//                       childAspectRatio: 1,
//                     ),
//                     itemCount: calculators.length,
//                     itemBuilder: (context, index) {
//                       Widget? screen;
//                       try {
//                         screen = calculators[index]['screen'];
//                       } catch (e) {

//                       }
//                       return GestureDetector(
//                         onTap: () {
//                           if (screen != null) {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(builder: (context) => screen!),
//                             );
//                           } else {

//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => Scaffold(
//                                   appBar: AppBar(title: Text('Error')),
//                                   body: Center(
//                                     child: Text(
//                                         'Screen not implemented for ${calculators[index]['name']}'),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Color.fromRGBO(255, 255, 255, 0.23),
//                             border: Border.all(
//                               color: Colors.white,
//                               width: 1.0,
//                             ),
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               SvgPicture.asset(
//                                 calculators[index]['svgPath'],
//                                 width: 50,
//                                 height: 50,
//                               ),
//                               SizedBox(height: 8),
//                               Text(
//                                 calculators[index]['name'],
//                                 style: FontManager().getTextStyle(
//                                   context,
//                                   lWeight: FontWeight.w500,
//                                   fontSize: 14,
//                                   color: AppColors.backgroundColor,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/AutoLoan.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Emi.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Rent_Buy.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Savings.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/TripCost.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/credit_card.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/sip_calculator.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/veg_nonveg.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AllCalculatorScreen extends StatefulWidget {
  @override
  State<AllCalculatorScreen> createState() => _AllCalculatorScreenState();
}

class _AllCalculatorScreenState extends State<AllCalculatorScreen> {
  final List<Map<String, dynamic>> calculators = [
    {
      'name': 'Credit Card Payoff',
      'svgPath': 'assets/icons/financeScreen/f6.svg',
      'screen': CreditCard(),
    },
    {
      'name': 'EMI',
      'svgPath': 'assets/icons/financeScreen/f5.svg',
      'screen': Emi(),
    },
    {
      'name': 'Rent vs Buy',
      'svgPath': 'assets/icons/financeScreen/f4.svg',
      'screen': RentBuy(),
    },
    // {
    //   'name': 'Savings Goal',
    //   'svgPath': 'assets/icons/financeScreen/f3.svg',
    //   'screen': Savings(),
    // },
    // {
    //   'name': 'Auto Loan',
    //   'svgPath': 'assets/icons/financeScreen/f2.svg',
    //   'screen': AutoLoan(),
    // },
    // {
    //   'name': 'Cost',
    //   'svgPath': 'assets/icons/financeScreen/f1.svg',
    //   'screen': TripCost(),
    // },
    {
      'name': 'SIP',
      'svgPath': 'assets/icons/financeScreen/f1.svg',
      'screen': SIPCalculator(),
    },
  ];

  // Responsive breakpoints
  bool get isSmallScreen => MediaQuery.of(context).size.width < 600;
  bool get isMediumScreen =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 900;
  bool get isLargeScreen => MediaQuery.of(context).size.width >= 900;
  bool get isTablet => MediaQuery.of(context).size.width >= 600;
  bool get isLandscape =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  // Responsive sizing methods
  double get responsivePadding => isSmallScreen
      ? 12.0
      : isMediumScreen
          ? 16.0
          : 20.0;
  double get headerHeight => isSmallScreen
      ? 120.0
      : isMediumScreen
          ? 140.0
          : 150.0;
  double get headerOffset => isSmallScreen
      ? 20.0
      : isMediumScreen
          ? 25.0
          : 30.0;
  double get shapeOffset => isSmallScreen
      ? 70.0
      : isMediumScreen
          ? 70.0
          : 80.0;
  double get gridOffset => isSmallScreen
      ? 80.0
      : isMediumScreen
          ? 75.0
          : 85.0;
  double get gridHorizontalPadding => isSmallScreen
      ? 40.0
      : isMediumScreen
          ? 25.0
          : 30.0;
  double get gridSpacing => isSmallScreen
      ? 20.0
      : isMediumScreen
          ? 24.0
          : 28.0;
  double get iconSize => isSmallScreen
      ? 50.0
      : isMediumScreen
          ? 55.0
          : 60.0;
  double get fontSize => isSmallScreen
      ? 14.0
      : isMediumScreen
          ? 13.0
          : 14.0;
  double get titleFontSize => isSmallScreen
      ? 18.0
      : isMediumScreen
          ? 17.0
          : 18.0;

  // Responsive grid configuration
  int get crossAxisCount {
    if (isLargeScreen) return 2;
    if (isMediumScreen) return 2;
    return 2;
  }

  double get childAspectRatio {
    if (isLargeScreen) return 0.9;
    if (isMediumScreen) return 0.85;
    return 0.75;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Header Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsivePadding),
              child: Transform.translate(
                offset: Offset(0, headerOffset),
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: width / (isSmallScreen ? 1.8 : 1.6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: AppColors.backgroundColor,
                                size: isSmallScreen ? 20 : 24,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Flexible(
                              child: Text(
                                "EMI Calculators",
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w600,
                                  fontSize: titleFontSize,
                                  color: AppColors.backgroundColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  height: headerHeight,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(isSmallScreen ? 16 : 20),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xE6061F35),
                        const Color(0x00061F35),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Custom Shape
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsivePadding),
              child: Transform.translate(
                offset: Offset(0, shapeOffset),
                child: CustomPaint(
                  painter: CustomShapePainter(),
                ),
              ),
            ),

            // Grid Section
            Transform.translate(
              offset: Offset(0, gridOffset),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: gridHorizontalPadding,
                    vertical: responsivePadding),
                child: Container(
                  height: height / (isLandscape ? 1.15 : 1.4),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: gridSpacing,
                      mainAxisSpacing: gridSpacing,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: calculators.length,
                    itemBuilder: (context, index) {
                      Widget? screen;
                      try {
                        screen = calculators[index]['screen'];
                      } catch (e) {
                        // Handle error silently
                      }

                      return GestureDetector(
                        onTap: () {
                          if (screen != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => screen!),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: AppBar(title: Text('Error')),
                                  body: Center(
                                    child: Text(
                                        'Screen not implemented for ${calculators[index]['name']}'),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.23),
                            border: Border.all(
                              color: Colors.white,
                              width: 1.0,
                            ),
                            borderRadius:
                                BorderRadius.circular(isSmallScreen ? 4 : 6),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                calculators[index]['svgPath'],
                                width: iconSize,
                                height: iconSize,
                              ),
                              SizedBox(height: isSmallScreen ? 10 : 12),
                              Flexible(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    calculators[index]['name'],
                                    style: FontManager().getTextStyle(
                                      context,
                                      lWeight: FontWeight.w500,
                                      fontSize: fontSize,
                                      color: AppColors.backgroundColor,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
