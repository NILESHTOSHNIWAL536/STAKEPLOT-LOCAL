import 'dart:io';
import 'dart:async';
import 'package:finvu_flutter_sdk/finvu_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
import 'package:flutter_application_code_stakeplot/routes.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:in_app_update/in_app_update.dart';
import 'package:app_version_update/app_version_update.dart';

import 'appTheme.dart';
import 'backed_connections/apiConnect/clearstack.dart';
import 'controllers/controllerManagement.dart';
import 'controllers/theme_controller.dart';

FinvuManager finvuManager = FinvuManager();
late IO.Socket mainPageWebSocket;
final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>(); // Your existing key
final GlobalKey<NavigatorState> updateNavigatorKey =
    GlobalKey<NavigatorState>(); // New key for updates

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  securityCheck();
  checkFirebaseAndValidUser();
  loadEnvs();
  initializeGlobalErrorHandling();
   runZonedGuarded(() {
    runApp(const MyApp());
  }, (Object error, StackTrace stack) {
    // Handle uncaught async errors here
    handleError(error, stack);
  });
}


/// Method to initialize Flutter error handling
void initializeGlobalErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    // Print to console
    FlutterError.dumpErrorToConsole(details);
    // Handle Flutter framework errors
    handleError(details.exception, details.stack);
  };
}

/// Centralized error handling method
void handleError(Object error, StackTrace? stack) {
  if (stack != null) {
    print("Stack trace: $stack");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
   late ThemeController themeController;
  @override
  void initState() {
    super.initState();
    initGetControllersIfisRegistered();
    themeController = ControllerManagement.themeController;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
  }


  @override
  Widget build(BuildContext context) {

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child:Obx(()=> MaterialApp(
        navigatorKey: navigatorKey,
         theme: AppTheme.lightTheme,      // 👈 Light Theme
         darkTheme: AppTheme.darkTheme,   // 👈 Dark Theme
        // themeMode: ThemeMode.system,     // 👈 Automatically switch based on device
          themeMode: themeController.themeMode.value,
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash',
        routes: routes,
        // Attach updateNavigatorKey to a nested Navigator if needed (optional)
        builder: (context, child) {
          return Navigator(
            key:updateNavigatorKey, // Attach updateNavigatorKey for update dialogs
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (context) =>
                  child ?? Container(), // Fallback to empty container
            ),
          );
        },
      )),
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
