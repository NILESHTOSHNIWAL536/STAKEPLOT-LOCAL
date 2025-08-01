// import 'package:finvu_flutter_sdk/finvu_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
// import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
// import 'package:flutter_application_code_stakeplot/routes.dart';
// import 'package:get/get.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// FinvuManager finvuManager = FinvuManager();
// late IO.Socket mainPageWebSocket;
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// void main()async {
//   checkFirebaseAndValidUser();
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//       super.initState();
//       initPlatformState();
//       // adding this for status bar
//       SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);

//   }

//   Future<void> initPlatformState() async {
//     if (!mounted) return;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//        navigatorKey: navigatorKey,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: AppColors.backgroundColor),
//         scaffoldBackgroundColor: AppColors.backgroundColor,
//       ),
//       debugShowCheckedModeBanner: false,
//       initialRoute: '/splash',
//       routes: routes
//     );
//   }

// }

import 'dart:io';
import 'package:finvu_flutter_sdk/finvu_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
import 'package:flutter_application_code_stakeplot/routes.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:in_app_update/in_app_update.dart';
import 'package:app_version_update/app_version_update.dart';

FinvuManager finvuManager = FinvuManager();
late IO.Socket mainPageWebSocket;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); // Your existing key
final GlobalKey<NavigatorState> updateNavigatorKey = GlobalKey<NavigatorState>(); // New key for updates

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized
   checkFirebaseAndValidUser();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
    // Set status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
    // Initialize other platform-specific configs here if needed
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Keep your existing navigatorKey
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        scaffoldBackgroundColor: AppColors.backgroundColor,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: routes,
      // Attach updateNavigatorKey to a nested Navigator if needed (optional)
      builder: (context, child) {
        return Navigator(
          key: updateNavigatorKey, // Attach updateNavigatorKey for update dialogs
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (context) => child ?? Container(), // Fallback to empty container
          ),
        );
      },
    );
  }
}

// Update check function
Future<void> checkForUpdate() async {
  if (Platform.isAndroid) {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate(); // Force update
      }
    } catch (e)
    {
    }
  } else if (Platform.isIOS) {
    final context = updateNavigatorKey.currentContext ?? Get.context;
    if (context != null) {
      try {
        // Check for updates using app_version_update
        final result = await AppVersionUpdate.checkForUpdates(
          appleId: 'com.stakeplot.pfa', // Replace with your iOS App Store bundle ID
        );
        // Check if result and canUpdate are non-null and true
        if (result.canUpdate == true) {
          // Show update dialog
          await AppVersionUpdate.showAlertUpdate(
            appVersionResult: result,
            context: context,
            backgroundColor: Colors.white,
            title: 'Update Available',
            content:
                'A new version (${result.storeVersion ?? "unknown"}) is available. Please update the app.',
            updateButtonText: 'Update Now',
            cancelButtonText: 'Later',
            mandatory: false, // Set to true for forced update
          );
        } else {
        }
      } catch (e) {
      }
    } else {
    }
  }
}