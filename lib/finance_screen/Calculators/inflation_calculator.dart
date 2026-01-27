import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/repository/debt_service.dart';
import 'package:get/get.dart';

import '../../Constants/core/app_padding_sizes.dart';

class InflationCalculator extends StatefulWidget {
  InflationCalculator({Key? key}) : super(key: key);

  @override
  State<InflationCalculator> createState() => _InflationCalculatorState();
}

class _InflationCalculatorState extends State<InflationCalculator> {
  final amountController = TextEditingController(text: '');

  final yearsController = TextEditingController(text: '');

  @override
  void initState() {
    amountController.text = "";
    yearsController.text = "";
    showResults = false.obs;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.newbg,
      body:  Padding(
    
  padding: EdgeInsets.only(
    top: MediaQuery.of(context).size.height * 0.02,
  ),
  


   child:SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom:AppSizes.p10,left:AppSizes.p10), 
                        child: Container(
                           width: MediaQuery.sizeOf(context).width/8,
                           
                         
                          height: MediaQuery.sizeOf(context).height/22,
                          //  width:40,
                          // height:40,
                          
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
                          child: IconButton(
                            icon: Icon(
                               Icons.arrow_back_rounded,
                              color: Color(0xFF061D3D), // arrow color
                              size: 22,
                            ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),),
                    ),
                    SizedBox(  width: MediaQuery.of(context).size.width * 0.15)
                          ,
                  Padding(
                      padding: const EdgeInsets.only(right: AppSizes.p10,top:AppSizes.p10),
                      child: Text(
                        "Inflation Calculator",
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w800,
                          fontSize: 20,
                          color: AppColors.newtitlecolor,
                        ),
                      ),
                    ),
                    // const SizedBox(width: 48),
                  ],
                ),
                SizedBox(height: AppSizes.h24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p14),
                  child: Text(
                    "Calculate the impact of inflation on your money",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w500,
                      fontSize: 16,
                      color: AppColors.accentColor.withOpacity(0.8),
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.h24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p14),
                  child: TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Current Amount (₹)',
                      labelStyle: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.accentColor.withOpacity(0.7),
                      ),
                      floatingLabelStyle: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.accentColor,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSizes.p16,
                        horizontal: AppSizes.p12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryColor.withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.primaryColor.withOpacity(0.1),
                    ),
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w400,
                      fontSize: 16,
                      color: AppColors.accentColor,
                    ),
                    onChanged: (value) {
                      originalAmount.value = double.tryParse(value) ?? 10000.0;
                    },
                  ),
                ),
                SizedBox(height: AppSizes.h16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p14),
                  child: TextField(
                    controller: yearsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Time Period (Years)',
                      labelStyle: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.accentColor.withOpacity(0.7),
                      ),
                      floatingLabelStyle: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.accentColor,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: AppSizes.p16,
                        horizontal: AppSizes.p12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryColor.withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryColor,
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.primaryColor.withOpacity(0.1),
                    ),
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w400,
                      fontSize: 16,
                      color: AppColors.accentColor,
                    ),
                    onChanged: (value) {
                      inflatedYears.value = double.tryParse(value) ?? 5.0;
                    },
                  ),
                ),
                SizedBox(height: AppSizes.h24),
                Center(
                  child: ElevatedButton(
                    onPressed: isLoadingInflation.value
                        ? () {
                            null;
                          }
                        : () {
                            calculateInflation();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSizes.p14,
                        horizontal: 32,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'Calculate',
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.backgroundColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.h24),
                Obx(() {
                  if (!showResults.value) {
                    return SizedBox.shrink(); // empty widget when not showing
                  }

                  return Container(
                    padding: const EdgeInsets.all(AppSizes.p20),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Calculation Results',
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w600,
                            fontSize: 18,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(height: AppSizes.h16),
                        Text(
                          'Future Value: ₹${inflatedFutureValue.value.toStringAsFixed(2)}',
                          style: FontManager().getTextStyle(
                            context,
                            lWeight: FontWeight.w400,
                            fontSize: 14,
                            color: AppColors.accentColor,
                          ),
                        ),
                        SizedBox(height: AppSizes.h16),
                        if (inflationPredictions.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Yearly Predictions',
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              SizedBox(height: AppSizes.h12),
                              ...inflationPredictions
                                  .map((prediction) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: AppSizes.p4),
                                        child: Text(
                                          'Year ${prediction['year']}: ₹${prediction['future_value'].toStringAsFixed(2)} (Inflation: ${prediction['predicted_inflation_percent']}%)',
                                          style: FontManager().getTextStyle(
                                            context,
                                            lWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: AppColors.accentColor,
                                          ),
                                        ),
                                      )),
                              SizedBox(height: AppSizes.h12),
                              Text(
                                'Disclaimer: These results are based on an assumed inflation rate and may not reflect actual future values.',
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color:
                                      AppColors.primaryColor.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    ),);
  }
}
