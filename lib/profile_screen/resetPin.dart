 import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/profileScreenStrings.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:local_auth/local_auth.dart';
 
 void resetCupertinoPin(BuildContext context) async {
  final LocalAuthentication auth = LocalAuthentication();

  bool isAuthenticated = false;

  try {
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    bool isDeviceSupported = await auth.isDeviceSupported();

    if (canCheckBiometrics || isDeviceSupported) {
      isAuthenticated = await auth.authenticate(
        localizedReason: ProfileScreenStrings().resetPinAuthReason,
        options: const AuthenticationOptions(
          biometricOnly: false, // allow PIN fallback
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } else {
       isAuthenticated = true;
    }
  } catch (e) {
     isAuthenticated = true;
  }

  if (!isAuthenticated) {
    return; // stop execution if not authenticated
  }

  // Proceed to show the Reset PIN dialog only if authenticated
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.backgroundColor,
        title: Row(
          children: [
            Icon(Icons.lock_reset, color: AppColors.primaryColor),
            SizedBox(width: 8),
            textStyleOnly2(
              context: context,
              text:  ProfileScreenStrings().resetPinLabel,
              fontsize: 18,
              color: AppColors.bg2,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textStyleOnly2(
                context: context,
                text: ProfileScreenStrings().resetPinSubLabel, // Direct access
                fontsize: 14,
                color: AppColors.bg3,
                fontWeight: FontWeight.w400,
              ),
              SizedBox(height: 8),
              textStyleOnly2(
                context: context,
                text: ProfileScreenStrings().resetPinInstructionSubLabel, // Direct access
                fontsize: 12,
                color: AppColors.bg3.withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
             
              Navigator.of(dialogContext).pop();
            },
            child: textStyleOnly2(
              context: context,
              text:ProfileScreenStrings().cancelLabel,
              fontsize: 14,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
          
            onTap: () async {
           
              try {
                final response = await updateDataApiCall3(
                  '$url/user/updateCupertino',
                  data: {
                    'pin': '0',
                  },
                );

               

                if (response.statusCode == 200) {
                //  hideBackAccountPassword.value=false;
                  userController.cupertinoPin.value = "0";
                  hideBackAccountPassword.value =true;
                 userController.cupertinoAttemptCount.value = false;
                  Navigator.of(dialogContext).pop();
                } else {
                 
                }
              } catch (e) {
              
              }
            },
            child: textStyleOnly2(
              context: context,
              text:ProfileScreenStrings().resetLabel, 
              fontsize: 14,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    },
  );
}