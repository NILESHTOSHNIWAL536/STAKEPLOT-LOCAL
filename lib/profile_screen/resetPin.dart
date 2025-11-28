import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/profileScreenStrings.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';
import 'package:local_auth/local_auth.dart';

void resetCupertinoPin(BuildContext context) async {
  final LocalAuthentication auth = LocalAuthentication();
  bool isAuthenticated = false;
  try {
    // Check if the device supports biometrics or authentication
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    bool isDeviceSupported = await auth.isDeviceSupported();
  
    if (canCheckBiometrics || isDeviceSupported) {
      // Check if any biometrics are enrolled
      List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();
      if (availableBiometrics.contains(BiometricType.strong) ||
          availableBiometrics.contains(BiometricType.face)) {
        // Specific types of biometrics are available. Use checks like this with caution!
      }

      // Attempt authentication regardless of availableBiometrics to handle face lock
      isAuthenticated = await auth.authenticate(
        localizedReason: ProfileScreenStrings().resetPinAuthReason,
        options: const AuthenticationOptions(
          biometricOnly: false, // Allow PIN/password fallback
          stickyAuth: false,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );
    } else {
      // Device does not support biometrics or authentication, bypass authentication
     

      snackBarCalledfail(context,
          "No authentication methods available. Proceeding to reset PIN.");
      return;
    }
  } catch (e) {
    // Log the error for debugging and show error message
  
   
    snackBarCalledfail(
        context, "Authentication failed or canceled. Please try again.");

    return; // Exit on authentication error or cancel
  }

  // Only proceed if authentication was successful or bypassed
  if (!isAuthenticated) {
    return; // Stop execution if not authenticated
  }

  // Show the Reset PIN dialog
  showDialog(
    context: context,
    useRootNavigator: false,
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
              text: ProfileScreenStrings().resetPinLabel,
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
              text: ProfileScreenStrings().resetPinSubLabel,
              fontsize: 14,
              color: AppColors.bg3,
              fontWeight: FontWeight.w400,
            ),
            SizedBox(height: 8),
            textStyleOnly2(
              context: context,
              text: ProfileScreenStrings().resetPinInstructionSubLabel,
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
              text: ProfileScreenStrings().cancelLabel,
              fontsize: 14,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () async {
              try {
                final response = await updateDataApiCall3(
                  UserRoutes.updateCupertino,
                  data: {
                    'pin': '0',
                  },
                );

                if (response.statusCode == 200) {
                  userController.cupertinoPin.value = "0";
                  hideBackAccountPassword.value = true;
                  userController.cupertinoAttemptCount.value = false;
                  Navigator.of(dialogContext).pop();

                  snackBarCalled(context, "PIN reset successfully.");
                } else {
                  snackBarCalledfail(
                      context, "Failed to reset PIN. Please try again.");
                }
              } catch (e) {
                
                snackBarCalledfail(
                    context, "An error occurred. Please try again.");
              }
            },
            child: textStyleOnly2(
              context: context,
              text: ProfileScreenStrings().resetLabel,
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
