import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/search.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/components/userNavigator.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';

import 'package:flutter_application_code_stakeplot/app_init/splashScreen.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/repository/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/repository/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:flutter_application_code_stakeplot/components/notification_icon.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/edit_details.dart';
import 'package:get/get.dart';

import '../../Constants/app_styles.dart';
import '../../components/shared_utils.dart';

// PreferredSizeWidget getAppBar(context) {
//   final userController = ControllerManagement.userController;

//   return PreferredSize(
//     preferredSize: const Size.fromHeight(60),
//     child: AppBar(
//       backgroundColor: AppColors.backgroundColor,
//       automaticallyImplyLeading: false,
//       actions: [
//         Padding(
//           padding: const EdgeInsets.only(right: 10, top: 6, left: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             // crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//                GestureDetector(
//                     onTap: () {
                    
//                     },
//                     child: AvatarProfileImage(
//                       url: Strides.stride,
//                       width: 30,
//                       height: 30,
                     
//                     ),
//                   )
             
//             ],
//           ),
//         ),
//         Spacer(),
//         NotificationsBudget(
//           child: Text(""),
//         ),
//       ],
//     ),
//   );
// }

class TopRightIconsWidget extends StatelessWidget {
  const TopRightIconsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// PROFILE ICON
        GestureDetector(
          onTap: () {
            // TODO: Add your navigation or action here
          },
          child: AvatarProfileImage(
            url: Strides.stride,
            width: 30,
            height: 30,
          ),
        ),

        const SizedBox(width: 16),

        /// NOTIFICATION BUTTON
        NotificationsBudget(
          child: const SizedBox(),
        ),
      ],
    );
  }
}


PreferredSizeWidget historyAppBar(context) {
  return AppBar(
    backgroundColor: AppColors.primaryColor,
    // Flat design for a modern look
    title: Text(
      HomepageStringsDart().historyTitle,
      style: FontManager().getTextStyle(
        context,
        lWeight: FontWeight.w600,
        fontSize: 18, // Slightly larger for better readability
        color: AppColors.backgroundColor,
      ),
    ),
    // Center the title for symmetry
    leading: IconButton(
      icon: Icon(
        Icons.arrow_back_ios, // More refined back icon
        color: AppColors.backgroundColor,
        size: 24, // Slightly smaller for balance
      ),
      onPressed: () {
        clearTransactions(context: context);
        Navigator.pop(context);
      },
      splashRadius: 20, // Smaller splash radius for a subtle effect
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 16.0), // Proper spacing
        child: InkWell(
          onTap: () {
            int len = bankAccountLinkedList.length;
            if (len == 0) {
              snackBarCalled(context, SnackbarData().noBankForLinking);
            }
            
          //   else {
          //     accountIdPdf.value = bankAccountLinkedList[0]['accountId'];
          //     showModalForPdfDownloadBankUiCheckBox(context);
          //   }
          // },
          else {
  if (bankAccountLinkedList.isNotEmpty) {
    accountIdPdf.value = bankAccountLinkedList[0].accountId;
    showModalForPdfDownloadBankUiCheckBox(context);
  }
}},

          splashColor:
              AppColors.accentColor.withOpacity(0.2), // Subtle splash effect
          borderRadius: BorderRadius.circular(12), // Rounded ripple effect
          child: Icon(
            Icons.download,
            size: 24,
            color: AppColors.backgroundColor,
          ),
        ),
      ),
    ],
  );
}
