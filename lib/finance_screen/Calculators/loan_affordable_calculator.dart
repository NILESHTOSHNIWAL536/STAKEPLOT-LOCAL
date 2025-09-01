import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Calculators/loan_eligible.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoanAffordableCalculator extends StatefulWidget {
  const LoanAffordableCalculator({super.key});

  @override
  State<LoanAffordableCalculator> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<LoanAffordableCalculator> {
  
  @override
  void initState() {
    super.initState();
    
  }

 

 

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: SingleChildScrollView(
                child: Padding(
                  
                  padding: const EdgeInsets.symmetric(vertical: 22,horizontal: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                      const SizedBox(height: 24),
                      // Container(
                      //   child: Row(
                      //     children: [
                      //       GestureDetector(
                      //         onTap: () {
                      //           Navigator.pop(context);
                      //         },
                      //         child: Icon(
                      //           Icons.arrow_back,
                      //           color: AppColors.backgroundColor,
                      //         ),
                      //       ),
                      //       Padding(
                      //         padding: const EdgeInsets.only(left: 40),
                      //         child: Text(
                      //           "Currency Converter",
                      //           style: FontManager().getTextStyle(
                      //             context,
                      //             lWeight: FontWeight.w600,
                      //             fontSize: 20,
                      //             color: Colors.white,
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(height: 24),
                      Stack(
                        children: [
                         Positioned(
          top: 0, // Start from the top of the Stack
          left: 0,
          right: 0,
          child: Container(
            // color: Colors.amber,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xE6061F35), // #061F35 with 0.9 opacity (E6 hex = 90%)
        const Color(0x00061F35), // fully transparent
      ],
    ),),
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    color: AppColors.backgroundColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Text(
                    "Currency Converter",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
                        Container(
                           margin: const EdgeInsets.only(top: 60),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              
                              AvatarProfileImageZero(
                                  url: 'assets/icons/financeScreen/currency.svg',
                                  width: 1,
                                  height: 1.5
                              ),
                                          
                              LoanEligibilityScreen(),
                              const SizedBox(height: 24),
                              // Recent Conversions
                            ],
                          ),
                        ),
                       ] ),
                      
                    ]),
                )));
  }

  // @override
  // void dispose() {
  //   // Avoid calling setState in dispose
  //   clearPreferences();
  //   amountController.dispose();
  //   searchController.dispose();
  //   super.dispose();
  // }
}
