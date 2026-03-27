

import 'dart:async';
import 'dart:io';

import 'package:app_version_update/app_version_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:flutter_application_code_stakeplot/widget_services/widget_service.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants/colors.dart';
import '../Constants/core/app_component_sizes.dart';
import '../OneSignal/deviceConfig.dart';
import '../Profile/friends.dart';
import '../backed_connections/apis_connect.dart';
import '../routes/index_route.dart';
import '../widget_services/widget_bridge.dart';

void main_apis_call_init()async{
  securityCheck();
  checkFirebaseAndValidUser();
  loadEnvs();

  // Store full API URL (with /api/v1) in SharedPreferences for background access (after loadEnvs)
  final prefs = await SharedPreferences.getInstance();
  // Full URL is already built as "${urlWithLocallHost}api/v1" in apis_connect.dart after loadEnvs
  await prefs.setString('full_api_url',API.mainBackendUrl); // 'url' is the global full path from apis_connect.dart

  // Store accountId if available (adjust key/source as needed, e.g., from login service)
  String? accountId = prefs
      .getString('accountId'); // Fetch existing; set during login if needed
  if (accountId != null && accountId.isNotEmpty) {
    await prefs.setString('accountId', accountId);
  }

  initializeGlobalErrorHandling();

  // Initialize widget service (handles WorkManager and widgets only)
  initializeWidgetService();
  // runZonedGuarded(() {
  //   runApp(const MyApp());
  // }, (Object error, StackTrace stack) {
  //   // Handle uncaught async errors here
  //   handleError(error, stack);
  // });

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
  if (stack != null) {}
}


Future<void> checkForUpdate() async {
  if (Platform.isAndroid) {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate(); // Force update
      }
    } catch (e) {}
  } else if (Platform.isIOS) {
    final context = updateNavigatorKey.currentContext ?? Get.context;
    if (context != null) {
      try {
        // Check for updates using app_version_update
        final result = await AppVersionUpdate.checkForUpdates(
          appleId:
              'com.stakeplot.pfa', // Replace with your iOS App Store bundle ID
        );
        // Check if result and canUpdate are non-null and true
        if (result.canUpdate == true) {
          // Show update dialog
          await AppVersionUpdate.showAlertUpdate(
            appVersionResult: result,
            context: context,
            backgroundColor: AppColors.backgroundColor,
            title: 'Update Available',
            content:
                'A new version (${result.storeVersion ?? "unknown"}) is available. Please update the app.',
            updateButtonText: 'Update Now',
            cancelButtonText: 'Later',
            mandatory: false, // Set to true for forced update
          );
        } else {}
      } catch (e) {}
    } else {}
  }
}

