import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/core/app_padding_sizes.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/dotted_Border.dart';
import 'package:flutter_application_code_stakeplot/Utils/rewardscreen.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';

import 'package:flutter_application_code_stakeplot/image_service/profile.dart';

import 'package:shared_preferences/shared_preferences.dart';


class RewardsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              left:AppSizes.p16,
              right:AppSizes.p16,
              top:AppSizes.p20,
              bottom:AppSizes.p16
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width/1.1,
                  padding:const  EdgeInsets.only(bottom: AppSizes.p10),
                  child: textStyleImage(
                    context: context,
                    text: "What's New ?",
                    fontWeight: FontWeight.bold,
                    fontsize: 16,  
                  ),
                ),
                Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 1.16,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: AppSizes.p20),
                        child: Column(
                          children: [
                           ...RewardScreenStrings().rewardIntroList
                            .asMap()
                            .entries
                            .map((entry) {
                              final index = entry.key;
                              final data = entry.value;
                              final curve = MediaQuery.of(context).size.height / 4.2 / 2;
                              
                              return Padding(
                                padding: const EdgeInsets.only(top: AppSizes.p55,bottom: AppSizes.p10),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    GestureDetector(
                                      onTap: (){
                                        if(RewardScreenStrings().rewardIntroList.length>2 && index<2){
                                           snackBarCalled(context,"Scroll To Bottom");

                                        }
                                         
                                      },
                                      child: getRewardCard(context, data, curve)),
                                    getBorderDotted(curve, context),
                                    getImage(data, context),
                                  ],
                                ),
                              );
                            }).toList(),
                            SizedBox(height: AppSizes.h30),
                            getDoneButton(context), // Final Done Button
                          ],
                        ),
                      ),
                    ),
                  )

                // getDoneButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget getRewardCard(context,data,curve){
    return   CouponCard(
      
                                height: MediaQuery.of(context).size.height/3.5,
                                backgroundColor: Colorcodes.appBarColor,
                                curveAxis: Axis.horizontal,
                                curvePosition: curve,
                                curveRadius: 20,
                                borderRadius: 16,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.greyCard.withOpacity(0.2),
                                      // color: AppColors.accentColor.withOpacity(0.09),
                                      offset: Offset(0, 3),
                                      blurRadius: 1.0,
                                      spreadRadius: 2.0,
                                    ),
                                  ],
                                ),
                                secondChild: Padding(
                                  padding: const EdgeInsets.all(AppSizes.p8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(height: AppSizes.h10),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p4),
                                        child: textStyleImage(
                                          iswrap: true,
                                          context: context,
                                          text: data['desc']!,
                                          fontsize: 14.0,
                                          lineHeight: 1.1,
                                          fontWeight: FontWeight.bold,
                                          c: AppColors.bg2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                firstChild: Padding(
                                  padding: const EdgeInsets.all(AppSizes.p8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(height: AppSizes.h30),
                                      textStyle(
                                        context: context,
                                        text: data['title']!,
                                        fontsize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        c: AppColors.primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              );
  }

  Widget getBorderDotted(curve,context){
    return Positioned(
                                top: curve+10, // Adjusts the SVG to appear above the card
                                left:AppSizes.p12,
                                child: Center(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width/1.28,
                                    child: DottedDivider(
                                          height: 1,
                                          dashWidth: 12,
                                          dashSpacing: 3,
                                          color: AppColors.grey,
                                        ),
                                  ),
                                ),
                              );
  }

  Widget getImage(data,context){
    return  Positioned(
                                top: -66, // Adjusts the SVG to appear above the card
                                left: MediaQuery.of(context).size.width/3.7,
                                child: SvgImage(
                                  context: context,
                                  url: data['url'] ?? '', // Added fallback for null safety
                                  width: 3,
                                  height: 8,
                                ),
                              );
  }


  Widget getDoneButton(context){
    return  SizedBox(
                width: MediaQuery.of(context).size.width/1.4,
                child: ElevatedButton(
                  onPressed: ()async {
                      RewardScreenStrings().isRewardNeedToShow.value=false;
                      final SharedPreferences pref = await SharedPreferences.getInstance();
                      pref.setBool("ShowReward", false);
                  },
                  child: textStyle(text: 'Done',context: context,c: AppColors.backgroundColor,fontsize: 16),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              );
  }
}