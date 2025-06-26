// //  import 'package:flutter/material.dart';
// // import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// // import 'package:flutter_application_code_stakeplot/Utils/profileScreenStrings.dart';
// // import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// // import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
// // import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
// // import 'package:local_auth/local_auth.dart';

// //  void resetCupertinoPin(BuildContext context) async {
// //   final LocalAuthentication auth = LocalAuthentication();

// //   bool isAuthenticated = false;

// //   try {
// //     bool canCheckBiometrics = await auth.canCheckBiometrics;
// //     bool isDeviceSupported = await auth.isDeviceSupported();

// //     if (canCheckBiometrics || isDeviceSupported) {
// //       isAuthenticated = await auth.authenticate(
// //         localizedReason: ProfileScreenStrings().resetPinAuthReason,
// //         options: const AuthenticationOptions(
// //           biometricOnly: false, // allow PIN fallback
// //           stickyAuth: true,
// //           useErrorDialogs: true,
// //         ),
// //       );
// //     } else {
// //        isAuthenticated = true;
// //     }
// //   } catch (e) {
// //      isAuthenticated = true;
// //   }

// //   if (!isAuthenticated) {
// //     return; // stop execution if not authenticated
// //   }

// //   // Proceed to show the Reset PIN dialog only if authenticated
// //   showDialog(
// //     context: context,
// //     builder: (BuildContext dialogContext) {
// //       return AlertDialog(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //         backgroundColor: AppColors.backgroundColor,
// //         title: Row(
// //           children: [
// //             Icon(Icons.lock_reset, color: AppColors.primaryColor),
// //             SizedBox(width: 8),
// //             textStyleOnly2(
// //               context: context,
// //               text:  ProfileScreenStrings().resetPinLabel,
// //               fontsize: 18,
// //               color: AppColors.bg2,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ],
// //         ),
// //         content: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             textStyleOnly2(
// //                 context: context,
// //                 text: ProfileScreenStrings().resetPinSubLabel, // Direct access
// //                 fontsize: 14,
// //                 color: AppColors.bg3,
// //                 fontWeight: FontWeight.w400,
// //               ),
// //               SizedBox(height: 8),
// //               textStyleOnly2(
// //                 context: context,
// //                 text: ProfileScreenStrings().resetPinInstructionSubLabel, // Direct access
// //                 fontsize: 12,
// //                 color: AppColors.bg3.withOpacity(0.7),
// //                 fontWeight: FontWeight.w400,
// //               ),
// //           ],
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () {

// //               Navigator.of(dialogContext).pop();
// //             },
// //             child: textStyleOnly2(
// //               context: context,
// //               text:ProfileScreenStrings().cancelLabel,
// //               fontsize: 14,
// //               color: AppColors.primaryColor,
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //           GestureDetector(

// //             onTap: () async {

// //               try {
// //                 final response = await updateDataApiCall3(
// //                   '$url/user/updateCupertino',
// //                   data: {
// //                     'pin': '0',
// //                   },
// //                 );

// //                 if (response.statusCode == 200) {
// //                 //  hideBackAccountPassword.value=false;
// //                   userController.cupertinoPin.value = "0";
// //                   hideBackAccountPassword.value =true;
// //                   userController.cupertinoAttemptCount.value = false;
// //                   Navigator.of(dialogContext).pop();
// //                 } else {

// //                 }
// //               } catch (e) {

// //               }
// //             },
// //             child: textStyleOnly2(
// //               context: context,
// //               text:ProfileScreenStrings().resetLabel,
// //               fontsize: 14,
// //               color: AppColors.primaryColor,
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //         ],
// //       );
// //     },
// //   );
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/Utils/profileScreenStrings.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
// import 'package:local_auth/local_auth.dart';

// void resetCupertinoPin(BuildContext context) async {
//   final LocalAuthentication auth = LocalAuthentication();
//   bool isAuthenticated = false;

//   try {
//     // Check if biometric authentication is available
//     bool canCheckBiometrics = await auth.canCheckBiometrics;
//     bool isDeviceSupported = await auth.isDeviceSupported();

//     if (canCheckBiometrics && isDeviceSupported) {
//       // Attempt biometric or PIN authentication
//       isAuthenticated = await auth.authenticate(
//         localizedReason: ProfileScreenStrings().resetPinAuthReason,
//         options: const AuthenticationOptions(
//           biometricOnly: false, // Allow PIN fallback
//           stickyAuth: true,
//           sensitiveTransaction: true,
//           useErrorDialogs: true,

//         ),
//       );
//     } else {
//       // If biometrics are not supported, show an error or handle appropriately

//       return; // Exit the function if biometrics are not supported
//     }
//   } catch (e) {
//     // Log the error for debugging, but don't set isAuthenticated to true
//     print('Authentication error: $e');

//     return; // Exit the function on authentication error
//   }

//   // Only proceed if authentication was successful
//   if (!isAuthenticated) {
//     return; // Stop execution if not authenticated
//   }

//   // Show the Reset PIN dialog
//   showDialog(
//     context: context,
//     builder: (BuildContext dialogContext) {
//       return AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         backgroundColor: AppColors.backgroundColor,
//         title: Row(
//           children: [
//             Icon(Icons.lock_reset, color: AppColors.primaryColor),
//             SizedBox(width: 8),
//             textStyleOnly2(
//               context: context,
//               text: ProfileScreenStrings().resetPinLabel,
//               fontsize: 18,
//               color: AppColors.bg2,
//               fontWeight: FontWeight.bold,
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             textStyleOnly2(
//               context: context,
//               text: ProfileScreenStrings().resetPinSubLabel,
//               fontsize: 14,
//               color: AppColors.bg3,
//               fontWeight: FontWeight.w400,
//             ),
//             SizedBox(height: 8),
//             textStyleOnly2(
//               context: context,
//               text: ProfileScreenStrings().resetPinInstructionSubLabel,
//               fontsize: 12,
//               color: AppColors.bg3.withOpacity(0.7),
//               fontWeight: FontWeight.w400,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(dialogContext).pop();
//             },
//             child: textStyleOnly2(
//               context: context,
//               text: ProfileScreenStrings().cancelLabel,
//               fontsize: 14,
//               color: AppColors.primaryColor,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           GestureDetector(
//             onTap: () async {
//               try {
//                 final response = await updateDataApiCall3(
//                   '$url/user/updateCupertino',
//                   data: {
//                     'pin': '0',
//                   },
//                 );

//                 if (response.statusCode == 200) {
//                   userController.cupertinoPin.value = "0";
//                   hideBackAccountPassword.value = true;
//                   userController.cupertinoAttemptCount.value = false;
//                   Navigator.of(dialogContext).pop();

//                 } else {

//                 }
//               } catch (e) {
//                 print('API error: $e');

//               }
//             },
//             child: textStyleOnly2(
//               context: context,
//               text: ProfileScreenStrings().resetLabel,
//               fontsize: 14,
//               color: AppColors.primaryColor,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       );
//     },
//   );
// }

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
    // Check if the device supports biometrics or authentication
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    bool isDeviceSupported = await auth.isDeviceSupported();
    print("Can check biometrics: $canCheckBiometrics");
    print("Device supports authentication: $isDeviceSupported");

    if (canCheckBiometrics || isDeviceSupported) {
      // Check if any biometrics are enrolled
      List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
      print("Available biometrics: $availableBiometrics");

      // Attempt authentication regardless of availableBiometrics to handle face lock
      isAuthenticated = await auth.authenticate(
        localizedReason: ProfileScreenStrings().resetPinAuthReason,
        options: const AuthenticationOptions(
          biometricOnly: false, // Allow PIN/password fallback
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      print("Authentication result: $isAuthenticated");
    } else {
      // Device does not support biometrics or authentication, bypass authentication
      print("Device does not support authentication. Bypassing authentication.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No authentication methods available. Proceeding to reset PIN.'),
          backgroundColor: AppColors.accentColor,
        ),
      );
      isAuthenticated = true;
    }
  } catch (e) {
    // Log the error for debugging and show error message
    print('Authentication error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Authentication failed or canceled. Please try again.'),
        backgroundColor: AppColors.accentColor,
      ),
    );
    return; // Exit on authentication error or cancel
  }

  // Only proceed if authentication was successful or bypassed
  if (!isAuthenticated) {
    print("Authentication failed or canceled. Exiting.");
    return; // Stop execution if not authenticated
  }

  // Show the Reset PIN dialog
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
                  '$url/user/updateCupertino',
                  data: {
                    'pin': '0',
                  },
                );

                if (response.statusCode == 200) {
                  userController.cupertinoPin.value = "0";
                  hideBackAccountPassword.value = true;
                  userController.cupertinoAttemptCount.value = false;
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('PIN reset successfully.'),
                      backgroundColor: AppColors.accentColor,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to reset PIN. Please try again.'),
                      backgroundColor: AppColors.accentColor,
                    ),
                  );
                }
              } catch (e) {
                print('API error: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('An error occurred. Please try again.'),
                    backgroundColor: AppColors.accentColor,
                  ),
                );
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