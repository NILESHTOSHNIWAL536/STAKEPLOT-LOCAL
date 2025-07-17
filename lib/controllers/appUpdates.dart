// import 'dart:io';
// import 'package:flutter_application_code_stakeplot/main.dart';
// import 'package:in_app_update/in_app_update.dart';
// import 'package:new_version_plus/new_version_plus.dart';

// Future<void> checkForUpdate() async {
//   if (Platform.isAndroid) {
//     try {
//       final updateInfo = await InAppUpdate.checkForUpdate();

//       if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
//         await InAppUpdate.performImmediateUpdate(); // ⬅️ Force update
//         // OR use flexible update
//         // await InAppUpdate.startFlexibleUpdate();
//         // await InAppUpdate.completeFlexibleUpdate();
//       }
//     } catch (e) {
//     }
//   } else if (Platform.isIOS) {
//     final newVersion = NewVersionPlus(
//       iOSId: 'com.yourcompany.yourapp',  // 🛠 Replace with your real iOS App ID
//     );

//     final status = await newVersion.getVersionStatus();

//     if (status != null && status.canUpdate) {
//       final context = navigatorKey.currentContext;
//       if (context != null) {
//         newVersion.showUpdateDialog(
//           context: context,
//           versionStatus: status,
//           dialogTitle: 'Update Available',
//           dialogText: 'A new version is available. Please update the app.',
//           updateButtonText: 'Update Now',
//           dismissButtonText: 'Later',
//          // set false to force update
//         );
//       }
//     }
//   }
// }
