import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/search.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/NavigatorScreens/userNavigator.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/animated/appScreenAnimation.dart';
import 'package:flutter_application_code_stakeplot/animated/splashScreen.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:flutter_application_code_stakeplot/customNoti.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:get/get.dart';

PreferredSizeWidget getAppBar(context) {
  final userController = ControllerManagement.userController;

  return PreferredSize(
    preferredSize: const Size.fromHeight(60),
    child: AppBar(
      backgroundColor: AppColors.backgroundColor,
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10, top: 6, left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                  onTap: () {
                     Navigator.push(
         context,
         MaterialPageRoute(
             builder: (context) =>SplashScreen()),
       );
                      // navigatorToMyOwnPage(context);
                  },
                  child: Obx(() => AvatarProfile(
                        name: userController.userName.value,
                        width: 30,
                        height: 13,
                        background: userController.avatarBackGround.value,
                      ))),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textStyle(
                      context: context,
                      text: getTimeBasedGreeting(),
                      fontWeight: FontWeight.w500,
                      fontsize: 15),
                  Obx(() => textStyle(
                      context: context,
                      text: toUpperCase(userController.userName.value),
                      // text: toUpperCase(userName.value),
                      fontWeight: FontWeight.bold,
                      fontsize: 15)),
                ],
              )
            ],
          ),
        ),
        Spacer(),
        NotificationsBudget(
          child: Text(""),
        ),
      ],
    ),
  );
}

PreferredSizeWidget historyAppBar1(context) {
  return AppBar(
    backgroundColor: AppColors.backgroundColor,
    // Flat design for a modern look
    title: Text(
      HomepageStringsDart().historyTitle,
      style: FontManager().getTextStyle(
        context,
        lWeight: FontWeight.w600, // Slightly bolder for emphasis
        fontSize: 18, // Slightly larger for better readability
        color: AppColors.accentColor,
      ),
    ),
    // Center the title for symmetry
    leading: IconButton(
      icon: Icon(
        Icons.arrow_back_ios, // More refined back icon
        color: AppColors.accentColor,
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
        padding: const EdgeInsets.only(right: 10, top: 6, left: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: () {
                  // navigatorToMyOwnPage(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoaderApp(),
                      ));
                },
                child: Obx(() => AvatarProfile(
                      name: userController.userName.value,
                      width: 30,
                      height: 13,
                      background: userController.avatarBackGround.value,
                    ))),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textStyle(
                    context: context,
                    text: getTimeBasedGreeting(),
                    fontWeight: FontWeight.w500,
                    fontsize: 15),
                Obx(() => textStyle(
                    context: context,
                    text: toUpperCase(userController.userName.value),
                    fontWeight: FontWeight.bold,
                    fontsize: 15)),
              ],
            )
          ],
        ),
      ),
      Spacer(),
      NotificationsBudget(
        child: Text(""),
      ),
    ],
  );
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
            } else if (len == 1) {
              accountIdPdf.value = bankAccountLinkedList[0]['accountId'];
              showModalForPdfDownload(context);
            } else {
              accountIdPdf.value = bankAccountLinkedList[0]['accountId'];
              showModalForPdfDownloadBankUiCheckBox(context);
            }
          },
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
