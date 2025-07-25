import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/rewardscreen.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:flutter_application_code_stakeplot/routes.dart';


class RewardsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width/1.1,
                height: MediaQuery.of(context).size.height/1.1,
                child: ListView.builder(
                  itemCount: RewardScreenStrings().rewardIntroList.length,
                  itemBuilder: (context, index) {
                    var data= RewardScreenStrings().rewardIntroList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: CouponCard(
                          height: MediaQuery.of(context).size.height/2.5,
                          backgroundColor: Colorcodes.white1,
                          curveAxis: Axis.horizontal,
                          curvePosition: MediaQuery.of(context).size.height/2.5/2,
                          curveRadius: 20,
                          borderRadius: 16,
                        secondChild: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                                SizedBox(height: 10.0),
                                Text(
                                   data['desc']!,
                                  style: TextStyle(fontSize: 14.0)),
                             ],
                          ),
                        ),
                        firstChild : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                               SvgImage(
                                 context: context,
                                 url:   data['url'], 
                                 width: 3, height: 8
                              ),
                              SizedBox(height: 10.0),
                               textStyle(
                                   context: context,
                                   text:   data['title']!,
                                   fontsize: 18.0,
                                   fontWeight: FontWeight.bold,
                                   c: AppColors.primaryColor
                               ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
        
              SizedBox(height: 10.0),
              SizedBox(
                width: MediaQuery.of(context).size.width/1.4,
                child: ElevatedButton(
                  onPressed: () {
                      RewardScreenStrings().isRewardNeedToShow.value=false;
                  },
                  child: textStyle(text: 'Done',context: context,c: Colorcodes.white,fontsize: 16),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
                              
            ],
          ),
        ),
      ),
    );
  }
}