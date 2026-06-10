import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/integration.dart';
import 'package:flutter_application_code_stakeplot/repository/clearstack.dart';

import '../Constants/core/app_padding_sizes.dart';
import '../Home_Screen/Home/init_Api_Calls.dart';

Future<bool?> showSkipModal2(BuildContext context) {
  final colors = context.appPalette;

  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: colors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (modalContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.bottomText.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                FinvuStrings().skipModalTitle,
                textAlign: TextAlign.center,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w600,
                  fontSize: 14,
                  lineHeight: 1.2,
                  color: colors.blackColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(modalContext).pop(false);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        backgroundColor: colors.whiteColor,
                        side: BorderSide(
                          color: colors.cardBackground,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        FinvuStrings().cancel,
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w600,
                          fontSize: 13,
                          color: colors.blackColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(modalContext).pop(true);

                        clearStack(context);
                        logoutAndDisconnect();
                        callApi(context);

                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/home',
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        minimumSize: const Size.fromHeight(40),
                        backgroundColor: colors.cardBackground,
                        foregroundColor: colors.whiteColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        FinvuStrings().yes,
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w600,
                          fontSize: 13,
                          color: colors.whiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<bool?> showSkipModal24(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
          top: Radius.circular(20)), // Rounded top corners
    ),
    backgroundColor: AppColors.backgroundColor, // Modal background
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                FinvuStrings().skipModalTitle,
                textAlign: TextAlign.center,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppColors.bg1,
                ),
              ),
              SizedBox(height: AppSizes.h20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(false); // User chose "Cancel"
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: AppSizes.p14),
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(24)),
                        child: Center(
                          child: Text(
                            FinvuStrings().cancel,
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.accentColor),
                          ),
                        ),
                      )),
                  SizedBox(width: AppSizes.w10),
                  GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(true); // User chose "Yes"
                        clearStack(context);
                        logoutAndDisconnect();
                        callApi(context);
                        Navigator.of(context).pushNamed('/home');
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width / 3,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: AppSizes.p14),
                        decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(24)),
                        child: Center(
                          child: Text(
                            FinvuStrings().yes,
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.backgroundColor),
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
