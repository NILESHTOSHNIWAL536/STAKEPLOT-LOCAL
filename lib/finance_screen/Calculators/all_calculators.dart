

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Emi.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Rent_Buy.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/credit_card.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/inflation_calculator.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/sip_calculator.dart';

import 'package:flutter_svg/flutter_svg.dart';

class AllCalculatorScreen extends StatefulWidget {
  @override
  State<AllCalculatorScreen> createState() => _AllCalculatorScreenState();
}

class _AllCalculatorScreenState extends State<AllCalculatorScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> calculators = [
    {
      'name': 'Credit Card',
      'svgPath': 'assets/icons/financeScreen/credit.svg',
      'screen': CreditCard(),
      // 'icon': Icons.credit_card,
    },
    {
      'name': 'EMI',
      'svgPath': 'assets/icons/financeScreen/emi.svg',
      'screen': Emi(),
      // 'icon': Icons.account_balance,
    },
    {
      'name': 'Rent vs Buy',
      'svgPath': 'assets/icons/financeScreen/rent.svg',
      'screen': RentBuy(),
      // 'icon': Icons.home,
    },
    {
      'name': 'Inflation',
      'svgPath': 'assets/icons/financeScreen/inflation.svg',
      'screen': InflationCalculator(),
      // 'icon': Icons.trending_up,
    },
    {
      'name': 'SIP',
      'svgPath': 'assets/icons/financeScreen/sip.svg',
      'screen': SIPCalculator(),
      // 'icon': Icons.savings,
    },
  ];
// final List<Map<String, dynamic>> calculators = [
//   {
//     'name': 'EMI Calculator',
//     'svgPath': 'assets/icons/financeScreen/emi.svg',
//     'screen': Emi(),
//   },
//   {
//     'name': 'Credit Card Calculator',
//     'svgPath': 'assets/icons/financeScreen/credit_card.svg',
//     'screen': CreditCard(),
//   },
//   {
//     'name': 'Rent vs Buy Calculator',
//     'svgPath': 'assets/icons/financeScreen/rent_buy.svg',
//     'screen': RentBuy(),
//   },
//   {
//     'name': 'SIP Calculator',
//     'svgPath': 'assets/icons/financeScreen/sip.svg',
//     'screen': SIPCalculator(),
//   },
//   {
//     'name': 'Inflation Calculator',
//     'svgPath': 'assets/icons/financeScreen/inflation.svg',
//     'screen': InflationCalculator(),
//   },
// ];


  // Responsive breakpoints
  bool get isSmallScreen => MediaQuery.of(context).size.width < 600;
  bool get isMediumScreen =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 900;
  bool get isLargeScreen => MediaQuery.of(context).size.width >= 900;

  // Responsive sizing methods
  double get responsivePadding => isSmallScreen ? 16.0 : 24.0;
  double get iconSize => 20.0;
  double get fontSize => isSmallScreen ? 14.0 : 16.0;
  double get titleFontSize => isSmallScreen ? 24.0 : 28.0;
  double get subtitleFontSize => isSmallScreen ? 16.0 : 18.0;
  double get cardElevation => 8.0;

  // Animation state
  int? _tappedIndex;
  bool _isGridVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: Interval(0.2, 1.0, curve: Curves.easeIn)),
    );
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() => _isGridVisible = true);
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
   Widget build(BuildContext context) {
   

    return Scaffold(
      backgroundColor: AppColors.newbg, // Clean, bright background
      body: Stack(
        children: [
          // Animated Gradient Background with Finance Shapes

          // Main Content
          SafeArea(
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom AppBar with Tagline
                Container(
                  padding: EdgeInsets.fromLTRB(
                      responsivePadding, 20.0, responsivePadding, 16.0),
                  decoration: BoxDecoration(
                    color: AppColors.newbg,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          
                         Padding(
                           padding: const EdgeInsets.only(left:6),
                           child: Container(
                             
                             width:MediaQuery.sizeOf(context).width*0.12,
                             height:MediaQuery.sizeOf(context).height*0.05,
                            
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
                           
                           
                           child:  IconButton(
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: AppColors.primaryColor,// arrow color
                               
                            
                                size: isSmallScreen ? 28.0 : 32.0,
                           
                                
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                           ),
                         ),
                          
                           SizedBox(width: MediaQuery.of(context).size.width * 0.18, ),
                         
                        ],
                      ),
                      // SizedBox(height: 8.0),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: responsivePadding / 2),
                        child: Text(
                          " Calculators",
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w800,
                            fontSize:24,
                            color: AppColors.newtitlecolor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Grid Content
//                 Container(
//                  height: MediaQuery.sizeOf(context).height / 1.6,
//                   child: FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: Padding(
//                       padding: EdgeInsets.all(responsivePadding),
//                       child: GridView.builder(
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           // crossAxisCount: 2,
//                           // crossAxisSpacing: 10.0,
//                           // mainAxisSpacing: 10.0,
//                           // childAspectRatio: 0.95,
//  crossAxisCount: 2,
//     crossAxisSpacing: 14.0,
//     mainAxisSpacing: 18.0,
//     childAspectRatio: 1.02,

//                         ),
//                         itemCount: calculators.length,
//                         itemBuilder: (context, index) {
//                           final calculator = calculators[index];
//                           Widget? screen = calculator['screen'];

//                           return GestureDetector(
//                             onTapDown: (_) =>
//                                 setState(() => _tappedIndex = index),
//                             onTapUp: (_) => setState(() => _tappedIndex = null),
//                             onTapCancel: () =>
//                                 setState(() => _tappedIndex = null),
//                             onTap: () {
//                               if (screen != null) {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => screen),
//                                 );
//                               } else {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => Scaffold(
//                                       appBar: AppBar(title: Text('Error')),
//                                       body: Center(
//                                         child: Text(
//                                           'Screen not implemented for ${calculator['name']}',
//                                           style: TextStyle(
//                                               color: AppColors.primaryColor),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }
//                             },
// child: AnimatedScale(
//                               scale: _tappedIndex == index ? 0.92 : 1.0,
//                               duration: Duration(milliseconds: 200),
//                               curve: Curves.easeInOut,
//                               child: Card(
//                                 elevation: _tappedIndex == index
//                                     ? 12.0
//                                     : cardElevation,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color:
//                                         AppColors.newbg,
//                                     borderRadius: BorderRadius.circular(12),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.grey.withOpacity(0.2),
//                                         blurRadius: 10.0,
//                                         offset: Offset(4, 4),
//                                       ),
//                                       BoxShadow(
//                                         color: AppColors.backgroundColor.withOpacity(0.7),
//                                         blurRadius: 10.0,
//                                         offset: Offset(-4, -4),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Stack(
//                                     alignment: Alignment.bottomLeft,
//                                     children: [
//                                       // BACKGROUND ICON (watermark)
//                                       Opacity(
//                                         opacity: 0.15, // faded background
                                        
//                                       ),
//                                       // FOREGROUND CONTENT
//                                       Center(
//                                         child: Text(
//                                           calculator['name'],
//                                           style: FontManager().getTextStyle(
//                                             context,
//                                             lWeight: FontWeight.w800,
//                                             fontSize: 18,
//                                             color: AppColors.fontcolor,
//                                           ),
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// Grid Content (FULL SCREEN USE)
Expanded(
  child: FadeTransition(
    opacity: _fadeAnimation,
    child: Padding(
      // padding: EdgeInsets.all(responsivePadding),
      padding: EdgeInsets.all(20),
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(),   // No scroll, full screen layout
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,            // 2 per row like screenshot
          crossAxisSpacing: 6.0,
          mainAxisSpacing: 6.0,
          childAspectRatio: 1.15,       // height > width → matches given design
        ),
        itemCount: calculators.length,
        itemBuilder: (context, index) {
          final calculator = calculators[index];
          Widget? screen = calculator['screen'];

          return GestureDetector(
            onTapDown: (_) => setState(() => _tappedIndex = index),
            onTapUp: (_) => setState(() => _tappedIndex = null),
            onTapCancel: () => setState(() => _tappedIndex = null),
            onTap: () {
              if (screen != null) {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => screen),
                );
              }
            },

            /// YOUR CARD DESIGN (icon + text) goes here
            child: AnimatedScale(
              scale: _tappedIndex == index ? 0.92 : 1.0,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                // elevation: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.newbg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF979496)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // ICON
                      Container(
                         width: MediaQuery.of(context).size.width * 0.15,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                          color: AppColors.fontcolor.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(18),
                          // boxShadow: [ BoxShadow(
                          //   color: Colors.black12,
                          //   blurRadius: 4,
                          //   offset: Offset(2,2),
                          // )],
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            calculator['svgPath'],
                            width: 40, height: 40,
                          ),
                        ),
                      ),

                      SizedBox(height: 12),

                      // Label
                      Text(
                        calculator['name'],
                        textAlign: TextAlign.center,
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: AppColors.fontcolor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  ),
),],),)]),);}





}
