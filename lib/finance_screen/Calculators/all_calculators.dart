

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Emi.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/Rent_Buy.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/credit_card.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/inflation_calculator.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/sip_calculator.dart';

import 'package:flutter_svg/flutter_svg.dart';

import '../../Constants/core/app_padding_sizes.dart';

class AllCalculatorScreen extends StatefulWidget {
  @override
  State<AllCalculatorScreen> createState() => _AllCalculatorScreenState();
}

class _AllCalculatorScreenState extends State<AllCalculatorScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> calculators = [
    {
      'name': 'Credit Card',
      'svgPath': 'assets/icons/financeScreen/f6.svg',
      'screen': CreditCard(),
      'icon': Icons.credit_card,
    },
    {
      'name': 'EMI',
      'svgPath': 'assets/icons/financeScreen/f5.svg',
      'screen': Emi(),
      'icon': Icons.account_balance,
    },
    {
      'name': 'Rent vs Buy',
      'svgPath': 'assets/icons/financeScreen/f4.svg',
      'screen': RentBuy(),
      'icon': Icons.home,
    },
    {
      'name': 'Inflation',
      'svgPath': 'assets/icons/financeScreen/f3.svg',
      'screen': InflationCalculator(),
      'icon': Icons.trending_up,
    },
    {
      'name': 'SIP',
      'svgPath': 'assets/icons/financeScreen/f1.svg',
      'screen': SIPCalculator(),
      'icon': Icons.savings,
    },
  ];

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
      backgroundColor: AppColors.backgroundColor, // Clean, bright background
      body: Stack(
        children: [
          // Animated Gradient Background with Finance Shapes

          // Main Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom AppBar with Tagline
                Container(
                  padding: EdgeInsets.fromLTRB(
                      responsivePadding, 20.0, responsivePadding, 16.0),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: AppColors.primaryColor,
                              size: isSmallScreen ? 28.0 : 32.0,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          // Expanded(
                          //   child: Text(
                          //     "Smart Calculators",
                          //     style: FontManager().getTextStyle(
                          //       context,
                          //       lWeight: FontWeight.w900,
                          //       fontSize: titleFontSize,
                          //       color: AppColors.primaryColor,
                          //     ),
                          //     textAlign: TextAlign.center,
                          //   ),
                          // ),
                          SizedBox(width: AppSizes.w48),
                        ],
                      ),
                      SizedBox(height: AppSizes.h8),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: responsivePadding / 2),
                        child: Text(
                          "All Your Calculations, One Place",
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w800,
                            fontSize: 50,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Grid Content
                Container(
                  height: MediaQuery.sizeOf(context).height / 1.6,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: EdgeInsets.all(responsivePadding),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          childAspectRatio: 1.6,
                        ),
                        itemCount: calculators.length,
                        itemBuilder: (context, index) {
                          final calculator = calculators[index];
                          Widget? screen = calculator['screen'];

                          return GestureDetector(
                            onTapDown: (_) =>
                                setState(() => _tappedIndex = index),
                            onTapUp: (_) => setState(() => _tappedIndex = null),
                            onTapCancel: () =>
                                setState(() => _tappedIndex = null),
                            onTap: () {
                              if (screen != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => screen),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Scaffold(
                                      appBar: AppBar(title: Text('Error')),
                                      body: Center(
                                        child: Text(
                                          'Screen not implemented for ${calculator['name']}',
                                          style: TextStyle(
                                              color: AppColors.primaryColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: AnimatedScale(
                              scale: _tappedIndex == index ? 0.92 : 1.0,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: Card(
                                elevation: _tappedIndex == index
                                    ? 12.0
                                    : cardElevation,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primaryColor.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        blurRadius: 10.0,
                                        offset: Offset(4, 4),
                                      ),
                                      BoxShadow(
                                        color: AppColors.backgroundColor.withOpacity(0.7),
                                        blurRadius: 10.0,
                                        offset: Offset(-4, -4),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.bottomLeft,
                                    children: [
                                      // BACKGROUND ICON (watermark)
                                      Opacity(
                                        opacity: 0.15, // faded background
                                        child: SvgPicture.asset(
                                          calculator['svgPath'],
                                          width: 100,
                                          height: 100,
                                          color: AppColors.backgroundColor,
                                        ),
                                      ),

                                      // FOREGROUND CONTENT
                                      Center(
                                        child: Text(
                                          calculator['name'],
                                          style: FontManager().getTextStyle(
                                            context,
                                            lWeight: FontWeight.w800,
                                            fontSize: 18,
                                            color: AppColors.backgroundColor,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
