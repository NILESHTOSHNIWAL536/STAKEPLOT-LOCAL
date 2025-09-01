import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/credit_card.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/veg_nonveg.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Add this for SVG support

class AllCalculatorScreen extends StatefulWidget {
  @override
  State<AllCalculatorScreen> createState() => _AllCalculatorScreenState();
}

class _AllCalculatorScreenState extends State<AllCalculatorScreen> {
  // Sample data for the grid items (replace with your actual data)
  final List<Map<String, dynamic>> calculators = [
    {
      'name': 'Credit Card Payoff',
      'svgPath': 'assets/icons/financeScreen/f6.svg'
    },
    {'name': 'EMIr', 'svgPath': 'assets/icons/financeScreen/f5.svg'},
    {'name': 'Rent vs Buy', 'svgPath': 'assets/icons/financeScreen/f4.svg'},
    {'name': 'Savings Goal', 'svgPath': 'assets/icons/financeScreen/f3.svg'},
    {'name': 'Auto Loan', 'svgPath': 'assets/icons/financeScreen/f2.svg'},
    {'name': 'Cost', 'svgPath': 'assets/icons/financeScreen/f1.svg'},
  ];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Transform.translate(
                offset: const Offset(0, 30),
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width / 1.6,
                        child: Row(
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
                            Text(
                              "Emi Calculators",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w600,
                                fontSize: 18,
                                color: AppColors.backgroundColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Transform.translate(
                offset: const Offset(0, 80),
                child: CustomPaint(
                  painter: CustomShapePainter(),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, 85),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                child: Container(
                  height: height / 1.32,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 columns
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1, // Square items
                    ),
                    itemCount: calculators.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // Add navigation or action for each calculator
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CreditCard()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.23),
                            border: Border.all(
                              color: Colors.white, // border: 1px solid #FFF
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                calculators[index]['svgPath'],
                                width: 50,
                                height: 50,
                                // Optional: tint the SVG
                              ),
                              SizedBox(height: 8),
                              Text(
                                calculators[index]['name'],
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: AppColors.backgroundColor,
                                ),
                                textAlign: TextAlign.center,
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
