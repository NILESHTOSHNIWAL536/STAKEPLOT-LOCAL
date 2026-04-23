import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/repository/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionHistoryScreen.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';

import '../../Constants/core/app_padding_sizes.dart';
import '../../Constants/core/app_shadows.dart';
import '../../Utils/homepageStrings.dart.dart';
import '../../budget/create_budget_screen.dart';

void navToHistory(context) {
  HapticFeedback.selectionClick();
  isLoadingMore.value = false;
  clearTransactions(context: context, f: false);

  Navigator.push(
    context,
    MaterialPageRoute(
      // builder: (context) => const CreateBudgetScreen(),
      builder: (context) => const TransactionHistoryScreen(),
    ),
  );
}

void navToHistoryReplacment(context) {
  HapticFeedback.selectionClick();
  isLoadingMore.value = false;
  clearTransactions(context: context, f: false);
  selectedTab.value = HomepageStringsDart().collectionscreate;
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => const TransactionHistoryScreen(),
    ),
  );
}

Widget historyButton(BuildContext context) {
  return InkWell(
    onTap: () {
      navToHistory(context);
    },
    borderRadius: BorderRadius.circular(10),
    child: Container(
      width: MediaQuery.sizeOf(context).width / 2.4,
      height: MediaQuery.sizeOf(context).height / 21,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        // base white fill
        color: AppColors.backgroundColor,
        // semi-opaque white overlay (matches your linear-gradient with same stops)

        borderRadius:
            BorderRadius.circular(10), // nice rounded corners similar to SVG
        border: Border.all(
          color: AppColors.primaryColor, // stroke color from SVG
          width: 1,
        ),
        // subtle elevation feel — optional, remove if you don't want it
        boxShadow: [AppShadows.soft],
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

            SizedBox(width: AppSizes.w8),

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

      