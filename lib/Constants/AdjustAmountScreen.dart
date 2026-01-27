import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/core/app_padding_sizes.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import '../Home_Screen/home_screen_state/home_page.dart';
import 'font_manager.dart';

class AdjustAmountScreen extends StatefulWidget {
  const AdjustAmountScreen({Key? key}) : super(key: key);

  @override
  State<AdjustAmountScreen> createState() => _AdjustAmountScreenState();
}

class _AdjustAmountScreenState extends State<AdjustAmountScreen> {
  String amount = "";

  void onKeyTap(String value) {
    setState(() {
      if (value == "back") {
        if (amount.isNotEmpty) {
          amount = amount.substring(0, amount.length - 1);
        }
      } else {
        amount += value;
      }
    });
  }

  /// 🔢 Key Builder (Pill Shape)
  Widget buildKey(
    String text, {
    VoidCallback? onTap,
    bool isBack = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
     
  height: MediaQuery.of(context).size.height / 22,
  width: MediaQuery.of(context).size.width / 4.2,


        // color:Colors.pink,
        decoration: BoxDecoration(
          color: isBack ? AppColors.debitedAmount: AppColors.accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Center(
          child: isBack
              ? const Icon(Icons.backspace_outlined, size: 24)
              : Text(
                  text,
                  style:  FontManager().getTextStyle(context, 
                    fontSize: 26, 
                    color: AppColors.accentColor,
                    lWeight: FontWeight.w400,
                  
                   
                   
                    ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentColor,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal:AppSizes.p22),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom:AppSizes.p14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                
            
                /// ICON
                Column(
                 children: [
                     AvatarProfileImageZero(url: Finance.coins, width: 4, height:12)

                ],
                
                ),
            
                SizedBox(
  height: MediaQuery.of(context).size.height / 50, // ≈ 16px 
),

            
                /// TEXT
                 Padding(
                   padding: const EdgeInsets.only(bottom:AppSizes.p20),
                   child: Text(
                    "Please adjust the amount below the spend\namount to reduce the overspending.",
                    textAlign: TextAlign.center,
                    style: FontManager().getTextStyle(context, 
                    fontSize: 14, 
                    color: AppColors.accentColor,
                    lWeight: FontWeight.w500,
                    lineHeight:1.5,
                   
                   
                    ),
                   
                                 ),
                 ),
            
               SizedBox(
  height: MediaQuery.of(context).size.height / 80, // ≈ 10px
),

            
              
            
                /// INPUT FIELD
                Container(
                 height: MediaQuery.of(context).size.height / 16.5, // ≈ 48px

                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    amount.isEmpty ? "Enter Amount" : amount,
                    style: FontManager().getTextStyle(context, 
                      fontSize: 14,
                         lWeight: FontWeight.w300,
                      color: amount.isEmpty
                          ? AppColors.grey
                          : Colors.black,
                    ),
                  ),
                ),
            
              SizedBox(
  height: MediaQuery.of(context).size.height / 50, // ≈ 16px
),

            
                /// DONE BUTTON
                SizedBox(
                  width: double.infinity,
               height: MediaQuery.of(context).size.height / 16.5,
                  child: ElevatedButton(
                    onPressed: () {
                      if (amount.trim().isEmpty) {
                        snackBarCalledfail(
                          context,
                          "Please enter the amount",
                        );
                        return;
                      }
            
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>  HomePage(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Done",
                      style: FontManager().getTextStyle(context, 
                    fontSize: 16, 
                    color: AppColors.backgroundColor,
                    lWeight: FontWeight.w600,
                    ),
                  ),
                ),
            
               
                ),  SizedBox(
  height: MediaQuery.of(context).size.height / 80, // ≈ 10px
),

                /// KEYPAD
                Padding(
                  padding: const EdgeInsets.only(top:AppSizes.p20),
                  child: Column(
                    children: [
                      for (var row in [
                        ["1", "2", "3"],
                        ["4", "5", "6"],
                        ["7", "8", "9"],
                        [".", "0", "back"],
                      ])
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.p12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: row.map((e) {
                              return buildKey(
                                e,
                                isBack: e == "back",
                               
                                onTap: () => onKeyTap(e),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
             
              ],
          ),
        ),
      ),
    ));
  }
}
