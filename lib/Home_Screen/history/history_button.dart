import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/repository/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionHistoryScreen.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';

import '../../Constants/core/app_shadows.dart';


void navToHistory(context)
{
                    HapticFeedback.selectionClick();
                    isLoadingMore.value=false;
                    clearTransactions(context: context,f: false);
                     Navigator.push(
                      context,  
                      MaterialPageRoute(
                        builder: (context) => const TransactionHistoryScreen(),
                      ),
                    );
}

// Widget historyButton(double fontSizeFactor,BuildContext context) {
//     return InkWell(
//       onTap: (){
//                     navToHistory(context);
//       },
//       child:Container(
//          width: MediaQuery.of(context).size.width / 4,
//                     height: MediaQuery.of(context).size.height / 30,
//                     decoration: BoxDecoration(
//                       color: AppColors.button,
//                       borderRadius: BorderRadius.circular(10)
//                     ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//           AvatarProfileImage(
//                     url: HomePageIcons.history,
//                     width: 36,
//                     height: 36,),
//                     Text(
//                             'History',
//                             style: FontManager().getTextStyle(context,
//                                 lWeight: FontWeight.w500,
//                                 fontSize: fontSizeFactor * 3.3,
//                                 color:
//                                     AppColors.accentColor), // Set text color based on value
//                           ),

//         ],),
//       )
//     );
    

//   }


Widget historyButton(BuildContext context) {
  return InkWell(
    onTap: () {
      navToHistory(context);
    },
    borderRadius: BorderRadius.circular(10),
    child: Container(
      width: MediaQuery.sizeOf(context).width/2.4,
      height: MediaQuery.sizeOf(context).height/21,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        // base white fill
        color: AppColors.backgroundColor,
        // semi-opaque white overlay (matches your linear-gradient with same stops)
       
        borderRadius: BorderRadius.circular(10), // nice rounded corners similar to SVG
        border: Border.all(
          color: AppColors.primaryColor, // stroke color from SVG
          width: 1,
        ),
        // subtle elevation feel — optional, remove if you don't want it
        boxShadow: [
          AppShadows.soft
        ],
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            
            AvatarProfileImageZero(
              url: HomePageIcons.history,
               width: 5,
                height: 32,
            ),
        
            const SizedBox(width: 8),
        
            // Text label
            Text(
              'History',
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w500,
                fontSize: 13,
                color: AppColors.accentColor,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
