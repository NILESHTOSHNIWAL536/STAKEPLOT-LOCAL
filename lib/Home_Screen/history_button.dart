import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import './colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transactionHistoryScreen.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';



Widget historyButton(double fontSizeFactor,BuildContext context) {
    return InkWell(
      onTap: (){
  
                    // getAllTransaction(context);
                    isLoadingMore.value=false;
                    getGroupTransactions();
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionHistoryScreen(),
                      ),
                    );

      },
      child:Container(
         width: MediaQuery.of(context).size.width / 4,
                    height: MediaQuery.of(context).size.height / 30,
                    decoration: BoxDecoration(
                      color: AppColors.button,
                      borderRadius: BorderRadius.circular(10)
                    ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
          AvatarProfileImage(
                    url: HomePageIcons.history,
                    width: 36,
                    height: 36,),
                    Text(
                            'History',
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w500,
                                fontSize: fontSizeFactor * 3.3,
                                color:
                                    AppColors.accentColor), // Set text color based on value
                          ),

        ],),
      )
    );
    
  }