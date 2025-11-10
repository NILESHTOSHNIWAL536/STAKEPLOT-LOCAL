// import 'dart:io';
// import 'dart:async';
// import 'package:finvu_flutter_sdk/finvu_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/init_hive.dart';
// import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
// import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
// import 'package:flutter_application_code_stakeplot/routes.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:get/get.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:in_app_update/in_app_update.dart';
// import 'package:app_version_update/app_version_update.dart';

// FinvuManager finvuManager = FinvuManager();
// late IO.Socket mainPageWebSocket;
// final GlobalKey<NavigatorState> navigatorKey =
//     GlobalKey<NavigatorState>(); // Your existing key
// final GlobalKey<NavigatorState> updateNavigatorKey =
//     GlobalKey<NavigatorState>(); // New key for updates

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   securityCheck();
//   checkFirebaseAndValidUser();
//   loadEnvs();
//   initializeGlobalErrorHandling();
//    runZonedGuarded(() {
//     runApp(const MyApp());
//   }, (Object error, StackTrace stack) {
//     // Handle uncaught async errors here
//     handleError(error, stack);
//   });
// }

// /// Method to initialize Flutter error handling
// void initializeGlobalErrorHandling() {
//   FlutterError.onError = (FlutterErrorDetails details) {
//     // Print to console
//     FlutterError.dumpErrorToConsole(details);
//     // Handle Flutter framework errors
//     handleError(details.exception, details.stack);
//   };
// }

// /// Centralized error handling method
// void handleError(Object error, StackTrace? stack) {
//   if (stack != null) {
//     print("Stack trace: $stack");
//   }
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     // initPlatformState();
//     // Set status bar
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: [SystemUiOverlay.top]);
//   }

//   // Future<void> initPlatformState() async {
//   //   if (!mounted) return;
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return MediaQuery(
//       data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
//       child: MaterialApp(
//         navigatorKey: navigatorKey,
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
//           scaffoldBackgroundColor: AppColors.backgroundColor,
//         ),
//         debugShowCheckedModeBanner: false,
//         initialRoute: '/splash',
//         routes: routes,
//         // Attach updateNavigatorKey to a nested Navigator if needed (optional)
//         builder: (context, child) {
//           return Navigator(
//             key:updateNavigatorKey, // Attach updateNavigatorKey for update dialogs
//             onGenerateRoute: (settings) => MaterialPageRoute(
//               builder: (context) =>
//                   child ?? Container(), // Fallback to empty container
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // Update check function

// Future<void> checkForUpdate() async {
//   if (Platform.isAndroid) {
//     try {
//       final updateInfo = await InAppUpdate.checkForUpdate();
//       if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
//         await InAppUpdate.performImmediateUpdate(); // Force update
//       }
//     } catch (e)
//     {
//     }
//   } else if (Platform.isIOS) {
//     final context = updateNavigatorKey.currentContext ?? Get.context;
//     if (context != null) {
//       try {
//         // Check for updates using app_version_update
//         final result = await AppVersionUpdate.checkForUpdates(
//           appleId: 'com.stakeplot.pfa', // Replace with your iOS App Store bundle ID
//         );
//         // Check if result and canUpdate are non-null and true
//         if (result.canUpdate == true) {
//           // Show update dialog
//           await AppVersionUpdate.showAlertUpdate(
//             appVersionResult: result,
//             context: context,
//             backgroundColor: AppColors.backgroundColor,
//             title: 'Update Available',
//             content:
//                 'A new version (${result.storeVersion ?? "unknown"}) is available. Please update the app.',
//             updateButtonText: 'Update Now',
//             cancelButtonText: 'Later',
//             mandatory: false, // Set to true for forced update
//           );
//         } else {
//         }
//       } catch (e) {
//       }
//     } else {
//     }
//   }
// }


// import 'dart:io';
// import 'dart:async';
// import 'package:finvu_flutter_sdk/finvu_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/init_hive.dart';
// import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
// import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
// import 'package:flutter_application_code_stakeplot/routes.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:get/get.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:in_app_update/in_app_update.dart';
// import 'package:app_version_update/app_version_update.dart';
// import 'package:workmanager/workmanager.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:home_widget/home_widget.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart'; // Import for 'url' global

// FinvuManager finvuManager = FinvuManager();
// late IO.Socket mainPageWebSocket;
// final GlobalKey<NavigatorState> navigatorKey =
//     GlobalKey<NavigatorState>(); // Your existing key
// final GlobalKey<NavigatorState> updateNavigatorKey =
//     GlobalKey<NavigatorState>(); // New key for updates

// // Top-level callback for WorkManager (runs in background isolate)
// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     try {
//       print("Background task started: $task");
      
//       // Restore base URL and token from SharedPreferences (stored during app init)
//       final prefs = await SharedPreferences.getInstance();
    
//       String? token = prefs.getString('accessToken'); 
//       // Adjust to your exact token key from LoginService
//       print("token: $token");
//       print("url: $url");

//       if (url.isEmpty || token == null || token.isEmpty) {
//         print("Missing base URL or token—skipping fetch");
//         await _updateWidgetWithFallback(prefs);
//         return Future.value(false);
//       }
      
//       // Fetch remainders data directly (replicating getRemainders logic)
//       String urlPath = "${url}/reminders";
//       print("urlPath in  widget: $urlPath");
//       var response = await http.get(
//         Uri.parse(urlPath),
//         headers: {
//           'Authorization': '$token',
//           'Content-Type': 'application/json',
//         },
//       );
//       print("response in  widget: ${response.body}");
      
//       String toReceive = 'None: ₹0';
//       String toPay = 'None: ₹0';
     
//       if (response.statusCode == 200) {
//         // Assuming getFlagOfResponse checks for success; here we assume 200 is good
//         var his = json.decode(response.body);
//         print("his in  widget: $his");
//         var payables = his['data']['payables'] ?? <Map<String, dynamic>>[];
//         print("payables in  widget: $payables");
//         var owed = his['data']['owed'] ?? <Map<String, dynamic>>[];
//         print("owed in  widget: $owed");
        
//         // Build toPay from payables (first item)
//         if (payables.isNotEmpty) {
//           print("payables in  widget: $payables");
//           final data = payables.first;
//           toPay = '${data['name'] ?? data['userName'] ?? "Unknown"}: ₹${(data['amount'] ?? 0).toStringAsFixed(2)}';
//         }
        
//         // Build toReceive from owed (first item)
//         if (owed.isNotEmpty) {
//           print("owed in  widget: $owed");
//           final data = owed.first;
//           toReceive = '${data['name'] ?? data['userName'] ?? "Unknown"}: ₹${(data['amount'] ?? 0).toStringAsFixed(2)}';
//         }
//       } else {
//         print("API call failed with status: ${response.statusCode}");
//       }
      
//       // Save to SharedPreferences (widget reads this)
//       await prefs.setString('to_receive', toReceive);
//       await prefs.setString('to_pay', toPay);
      
//       // Trigger widget update (broadcasts to native provider)
//       await HomeWidget.saveWidgetData<String>('to_receive', toReceive);
//       await HomeWidget.saveWidgetData<String>('to_pay', toPay);
//       await HomeWidget.updateWidget(
//         name: 'PayableWidgetProvider',
//         androidName: 'PayableWidgetProvider',
//         iOSName: 'PayableWidget',  // If supporting iOS
//       );
      
//       print("Background task completed: Widget updated with fresh data");
//       return Future.value(true);
//     } catch (e) {
//       print("Background task failed: $e");
//       final prefs = await SharedPreferences.getInstance();
//       await _updateWidgetWithFallback(prefs);
//       return Future.value(false);
//     }
//   });
// }

// // Helper: Update widget with error/fallback values
// Future<void> _updateWidgetWithFallback(SharedPreferences prefs) async {
//   String errorMsg = 'Error: Check app';
//   await prefs.setString('to_receive', errorMsg);
//   await prefs.setString('to_pay', errorMsg);
//   await HomeWidget.saveWidgetData<String>('to_receive', errorMsg);
//   await HomeWidget.saveWidgetData<String>('to_pay', errorMsg);
//   await HomeWidget.updateWidget(
//     name: 'PayableWidgetProvider',
//     androidName: 'PayableWidgetProvider',
//     iOSName: 'PayableWidget',
//   );
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized(); 
//   securityCheck();
//   checkFirebaseAndValidUser();
//   loadEnvs();
  
//   // Store base URL in SharedPreferences for background access (after loadEnvs)
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.setString('api_base_url', url); // Assuming 'url' is the global base URL from apis_connect.dart
  
//   initializeGlobalErrorHandling();
  
//   // Initialize WorkManager
//   Workmanager().initialize(
//     callbackDispatcher,
//      // More logs in debug
//   );

//   // Register periodic task (runs ~every 15 mins, even when app is closed)
//   Workmanager().registerPeriodicTask(
//     "widget-refresh-unique-id",  // Unique name
//     "periodic-widget-update",    // Task label
//     frequency: const Duration(minutes: 15),  // Minimum interval
//     constraints: Constraints(
//       networkType: NetworkType.connected,    // Requires internet
//       requiresBatteryNotLow: true,           // Skip if battery low
//       requiresCharging: false,               // Can run unplugged
//       requiresDeviceIdle: false,             // Run even if active
//       requiresStorageNotLow: false,
//     ),
//     backoffPolicy: BackoffPolicy.exponential,  // Retry on failure
//     backoffPolicyDelay: const Duration(seconds: 10),
//   );

//   // Optional: Immediate one-off sync on app start (unique ID with timestamp)
//   Workmanager().registerOneOffTask(
//     "initial-widget-sync-${DateTime.now().millisecondsSinceEpoch}",
//     "one-off-widget-update",
//     constraints: Constraints(networkType: NetworkType.connected),
//   );
  
//    runZonedGuarded(() {
//     runApp(const MyApp());
//   }, (Object error, StackTrace stack) {
//     // Handle uncaught async errors here
//     handleError(error, stack);
//   });
// }


// /// Method to initialize Flutter error handling
// void initializeGlobalErrorHandling() {
//   FlutterError.onError = (FlutterErrorDetails details) {
//     // Print to console
//     FlutterError.dumpErrorToConsole(details);
//     // Handle Flutter framework errors
//     handleError(details.exception, details.stack);
//   };
// }

// /// Centralized error handling method
// void handleError(Object error, StackTrace? stack) {
//   if (stack != null) {
//     print("Stack trace: $stack");
//   }
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     // initPlatformState();
//     // Set status bar
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: [SystemUiOverlay.top]);
//   }

//   // Future<void> initPlatformState() async {
//   //   if (!mounted) return;
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return MediaQuery(
//       data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
//       child: MaterialApp(
//         navigatorKey: navigatorKey,
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
//           scaffoldBackgroundColor: AppColors.backgroundColor,
//         ),
//         debugShowCheckedModeBanner: false,
//         initialRoute: '/splash',
//         routes: routes,
//         // Attach updateNavigatorKey to a nested Navigator if needed (optional)
//         builder: (context, child) {
//           return Navigator(
//             key:updateNavigatorKey, // Attach updateNavigatorKey for update dialogs
//             onGenerateRoute: (settings) => MaterialPageRoute(
//               builder: (context) =>
//                   child ?? Container(), // Fallback to empty container
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // Update check function

// Future<void> checkForUpdate() async {
//   if (Platform.isAndroid) { 
//     try {
//       final updateInfo = await InAppUpdate.checkForUpdate();
//       if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
//         await InAppUpdate.performImmediateUpdate(); // Force update
//       }
//     } catch (e)
//     {
//     }
//   } else if (Platform.isIOS) {
//     final context = updateNavigatorKey.currentContext ?? Get.context;
//     if (context != null) {
//       try {
//         // Check for updates using app_version_update
//         final result = await AppVersionUpdate.checkForUpdates(
//           appleId: 'com.stakeplot.pfa', // Replace with your iOS App Store bundle ID
//         );
//         // Check if result and canUpdate are non-null and true
//         if (result.canUpdate == true) {
//           // Show update dialog
//           await AppVersionUpdate.showAlertUpdate(
//             appVersionResult: result,
//             context: context,
//             backgroundColor: AppColors.backgroundColor,
//             title: 'Update Available',
//             content:
//                 'A new version (${result.storeVersion ?? "unknown"}) is available. Please update the app.',
//             updateButtonText: 'Update Now',
//             cancelButtonText: 'Later',
//             mandatory: false, // Set to true for forced update
//           );
//         } else {
//         }
//       } catch (e) {
//       }
//     } else {
//     }
//   }
// }


// import 'dart:io';
// import 'dart:async';
// import 'package:finvu_flutter_sdk/finvu_manager.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
// import 'package:flutter_application_code_stakeplot/routes.dart';
// import 'package:get/get.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:in_app_update/in_app_update.dart';
// import 'package:app_version_update/app_version_update.dart';
// import 'package:workmanager/workmanager.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:home_widget/home_widget.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart'; // Import for 'url' global

// FinvuManager finvuManager = FinvuManager();
// late IO.Socket mainPageWebSocket;
// final GlobalKey<NavigatorState> navigatorKey =
//     GlobalKey<NavigatorState>(); // Your existing key
// final GlobalKey<NavigatorState> updateNavigatorKey =
//     GlobalKey<NavigatorState>(); // New key for updates

// // Top-level callback for WorkManager (runs in background isolate)
// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     try {
     
      
//       // Restore full API URL and token from SharedPreferences (stored during app init)
//       final prefs = await SharedPreferences.getInstance();
    
//       String? token = prefs.getString('accessToken'); 
//       // Your exact token key from LoginService
//       String fullApiUrl = prefs.getString('full_api_url') ?? ''; // Stored full URL with /api/v1
     

//       if (fullApiUrl.isEmpty || token == null || token.isEmpty) {
      
//         await _updateWidgetWithFallback(prefs);
//         return Future.value(false);
//       }
      
//       // Fetch remainders data directly (replicating getRemainders logic)
//       String urlPath = "${fullApiUrl}/reminders";
     
//       var response = await http.get(
//         Uri.parse(urlPath),
//         headers: {
//           // Handle Bearer prefix based on how it's stored
//           'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
    
      
//       String toReceive = 'None: ₹0';
//       String toPay = 'None: ₹0';
     
//       if (response.statusCode == 200) {
//         // Assuming getFlagOfResponse checks for success; here we assume 200 is good
//         var his = json.decode(response.body);
      
//         var payables = his['data']['payables'] ?? <Map<String, dynamic>>[];
       
//         var owed = his['data']['owed'] ?? <Map<String, dynamic>>[];
        
        
//         // Build toPay from payables (first item)
//         if (payables.isNotEmpty) {
        
//           final data = payables.first;
//           toPay = '${data['name'] ?? data['userName'] ?? "Unknown"}: ₹${(data['amount'] ?? 0).toStringAsFixed(2)}';
//         }
        
//         // Build toReceive from owed (first item)
//         if (owed.isNotEmpty) {
        
//           final data = owed.first;
//           toReceive = '${data['name'] ?? data['userName'] ?? "Unknown"}: ₹${(data['amount'] ?? 0).toStringAsFixed(2)}';
//         }
//       } else {
       
//       }
      
//       // Save to SharedPreferences (widget reads this)
//       await prefs.setString('to_receive', toReceive);
//       await prefs.setString('to_pay', toPay);
      
//       // Trigger widget update (broadcasts to native provider)
//       await HomeWidget.saveWidgetData<String>('to_receive', toReceive);
//       await HomeWidget.saveWidgetData<String>('to_pay', toPay);
//       await HomeWidget.updateWidget(
//         name: 'PayableWidgetProvider',
//         androidName: 'PayableWidgetProvider',
//         iOSName: 'PayableWidget',  // If supporting iOS
//       );
      
     
//       return Future.value(true);
//     } catch (e) {
     
//       final prefs = await SharedPreferences.getInstance();
//       await _updateWidgetWithFallback(prefs);
//       return Future.value(false);
//     }
//   });
// }

// // Helper: Update widget with error/fallback values
// Future<void> _updateWidgetWithFallback(SharedPreferences prefs) async {
//   String errorMsg = 'Error: Check app';
//   await prefs.setString('to_receive', errorMsg);
//   await prefs.setString('to_pay', errorMsg);
//   await HomeWidget.saveWidgetData<String>('to_receive', errorMsg);
//   await HomeWidget.saveWidgetData<String>('to_pay', errorMsg);
//   await HomeWidget.updateWidget(
//     name: 'PayableWidgetProvider',
//     androidName: 'PayableWidgetProvider',
//     iOSName: 'PayableWidget',
//   );
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized(); 
//   securityCheck();
//   checkFirebaseAndValidUser();
//   loadEnvs();
  
//   // Store full API URL (with /api/v1) in SharedPreferences for background access (after loadEnvs)
//   final prefs = await SharedPreferences.getInstance();
//   // Full URL is already built as "${urlWithLocallHost}api/v1" in apis_connect.dart after loadEnvs
//   await prefs.setString('full_api_url', url); // 'url' is the global full path from apis_connect.dart
  
//   initializeGlobalErrorHandling();
  
//   // Initialize WorkManager
//   Workmanager().initialize(
//     callbackDispatcher,
//     isInDebugMode: false,  // More logs in debug
//   );

//   // Register periodic task (runs ~every 15 mins, even when app is closed)
//   Workmanager().registerPeriodicTask(
//     "widget-refresh-unique-id",  // Unique name
//     "periodic-widget-update",    // Task label
//     frequency: const Duration(minutes: 15),  // Minimum interval
//     constraints: Constraints(
//       networkType: NetworkType.connected,    // Requires internet
//       requiresBatteryNotLow: true,           // Skip if battery low
//       requiresCharging: false,               // Can run unplugged
//       requiresDeviceIdle: false,             // Run even if active
//       requiresStorageNotLow: false,
//     ),
//     backoffPolicy: BackoffPolicy.exponential,  // Retry on failure
//     backoffPolicyDelay: const Duration(seconds: 10),
//   );

//   // Optional: Immediate one-off sync on app start (unique ID with timestamp)
//   Workmanager().registerOneOffTask(
//     "initial-widget-sync-${DateTime.now().millisecondsSinceEpoch}",
//     "one-off-widget-update",
//     constraints: Constraints(networkType: NetworkType.connected),
//   );
  
//    runZonedGuarded(() {
//     runApp(const MyApp());
//   }, (Object error, StackTrace stack) {
//     // Handle uncaught async errors here
//     handleError(error, stack);
//   });
// }


// /// Method to initialize Flutter error handling
// void initializeGlobalErrorHandling() {
//   FlutterError.onError = (FlutterErrorDetails details) {
//     // Print to console
//     FlutterError.dumpErrorToConsole(details);
//     // Handle Flutter framework errors
//     handleError(details.exception, details.stack);
//   };
// }

// /// Centralized error handling method
// void handleError(Object error, StackTrace? stack) {
//   if (stack != null) {
   
//   }
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     // initPlatformState();
//     // Set status bar
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: [SystemUiOverlay.top]);
//   }

//   // Future<void> initPlatformState() async {
//   //   if (!mounted) return;
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return MediaQuery(
//       data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
//       child: MaterialApp(
//         navigatorKey: navigatorKey,
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
//           scaffoldBackgroundColor: AppColors.backgroundColor,
//         ),
//         debugShowCheckedModeBanner: false,
//         initialRoute: '/splash',
//         routes: routes,
//         // Attach updateNavigatorKey to a nested Navigator if needed (optional)
//         builder: (context, child) {
//           return Navigator(
//             key:updateNavigatorKey, // Attach updateNavigatorKey for update dialogs
//             onGenerateRoute: (settings) => MaterialPageRoute(
//               builder: (context) =>
//                   child ?? Container(), // Fallback to empty container
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // Update check function

// Future<void> checkForUpdate() async {
//   if (Platform.isAndroid) { 
//     try {
//       final updateInfo = await InAppUpdate.checkForUpdate();
//       if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
//         await InAppUpdate.performImmediateUpdate(); // Force update
//       }
//     } catch (e)
//     {
//     }
//   } else if (Platform.isIOS) {
//     final context = updateNavigatorKey.currentContext ?? Get.context;
//     if (context != null) {
//       try {
//         // Check for updates using app_version_update
//         final result = await AppVersionUpdate.checkForUpdates(
//           appleId: 'com.stakeplot.pfa', // Replace with your iOS App Store bundle ID
//         );
//         // Check if result and canUpdate are non-null and true
//         if (result.canUpdate == true) {
//           // Show update dialog
//           await AppVersionUpdate.showAlertUpdate(
//             appVersionResult: result,
//             context: context,
//             backgroundColor: AppColors.backgroundColor,
//             title: 'Update Available',
//             content:
//                 'A new version (${result.storeVersion ?? "unknown"}) is available. Please update the app.',
//             updateButtonText: 'Update Now',
//             cancelButtonText: 'Later',
//             mandatory: false, // Set to true for forced update
//           );
//         } else {
//         }
//       } catch (e) {
//       }
//     } else {
//     }
//   }
// }


// import 'dart:io';
// import 'dart:async';
// import 'package:finvu_flutter_sdk/finvu_manager.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
// import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
// import 'package:flutter_application_code_stakeplot/routes.dart';
// import 'package:get/get.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:in_app_update/in_app_update.dart';
// import 'package:app_version_update/app_version_update.dart';
// import 'package:workmanager/workmanager.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:home_widget/home_widget.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart'; // Import for 'url' global

// FinvuManager finvuManager = FinvuManager();
// late IO.Socket mainPageWebSocket;
// final GlobalKey<NavigatorState> navigatorKey =
//     GlobalKey<NavigatorState>(); // Your existing key
// final GlobalKey<NavigatorState> updateNavigatorKey =
//     GlobalKey<NavigatorState>(); // New key for updates

// const List<String> monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

// int daysInMonth(int year, int month) {
//   return DateTime(year, month + 1, 0).day;
// }

// String getMonthlyRange() {
//   final now = DateTime.now();
//   final firstDay = 1;
//   final lastDay = now.day;
//   return '01 ${monthNames[now.month - 1]} - ${lastDay.toString().padLeft(2, '0')} ${monthNames[now.month - 1]}';
// }

// // Top-level callback for WorkManager (runs in background isolate)
// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     try {
//       // Restore full API URL and token from SharedPreferences (stored during app init)
//       final prefs = await SharedPreferences.getInstance();
    
//       String? token = prefs.getString('accessToken'); 
//       // Your exact token key from LoginService
//       String fullApiUrl = prefs.getString('full_api_url') ?? ''; // Stored full URL with /api/v1
     

//       if (fullApiUrl.isEmpty || token == null || token.isEmpty) {
//         await _updateWidgetWithFallback(prefs);
//         return Future.value(false);
//       }
      
//       // Fetch remainders data directly (replicating getRemainders logic)
//       String urlPath = "${fullApiUrl}/reminders";
     
//       var response = await http.get(
//         Uri.parse(urlPath),
//         headers: {
//           // Handle Bearer prefix based on how it's stored
//           'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
    
      
//       String toReceive = 'None: ₹0';
//       String toPay = 'None: ₹0';
     
//       if (response.statusCode == 200) {
//         // Assuming getFlagOfResponse checks for success; here we assume 200 is good
//         var his = json.decode(response.body);
      
//         var payables = his['data']['payables'] ?? <Map<String, dynamic>>[];
       
//         var owed = his['data']['owed'] ?? <Map<String, dynamic>>[];
        
        
//         // Build toPay from payables (first item)
//         if (payables.isNotEmpty) {
        
//           final data = payables.first;
//           toPay = '${data['name'] ?? data['userName'] ?? "Unknown"}: ₹${(data['amount'] ?? 0).toStringAsFixed(2)}';
//         }
        
//         // Build toReceive from owed (first item)
//         if (owed.isNotEmpty) {
        
//           final data = owed.first;
//           toReceive = '${data['name'] ?? data['userName'] ?? "Unknown"}: ₹${(data['amount'] ?? 0).toStringAsFixed(2)}';
//         }
//       }

//       // Save payable data to SharedPreferences (widget reads this)
//       await prefs.setString('to_receive', toReceive);
//       await prefs.setString('to_pay', toPay);
      
//       // Trigger payable widget update (broadcasts to native provider)
//       await HomeWidget.saveWidgetData<String>('to_receive', toReceive);
//       await HomeWidget.saveWidgetData<String>('to_pay', toPay);
//       await HomeWidget.updateWidget(
//         name: 'PayableWidgetProvider',
//         androidName: 'PayableWidgetProvider',
//         iOSName: 'PayableWidget',  // If supporting iOS
//       );

//       // Fetch spending categories data using the correct endpoint
//       String? accountId = prefs.getString('accountId'); // Assuming accountId is stored; adjust key if needed (e.g., 'selectedAccountId')
//       final now = DateTime.now();
//       final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}-01'; // YYYY-MM-01 for current month
//       Uri spendingUri = Uri.parse("${fullApiUrl}/transactionauto/categorize").replace(queryParameters: {
//         if (accountId != null && accountId.isNotEmpty) 'accountId': accountId,
//         'startDate': currentMonth,
//         'endDate': '${now.year}-${now.month.toString().padLeft(2, '0')}-${daysInMonth(now.year, now.month).toString().padLeft(2, '0')}',
//       });
//       var spendingResponse = await http.get(
//         spendingUri,
//         headers: {
//           'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );

//       String totalSpending = '₹0';
//       String categoriesStr = 'None';
//       String timestamp = getMonthlyRange();

//       if (spendingResponse.statusCode == 200) {
//         var data = json.decode(spendingResponse.body);
//         if (data['data'] != null) {
//           double total = double.tryParse(data['data']['totalDebitThisMonth']?.toString() ?? '0') ?? 0.0;
//           print('Total spending: $total');
//           // Prioritize top-level 'categorized' (monthly, as in getCategoryData); fallback to 'week' if empty
//           var categorized = data['data']['categorized'] ?? data['data']['week']?['categorized'] ?? <Map<String, dynamic>>[];

//           totalSpending = '₹${total.toStringAsFixed(2)}';
//           if (categorized.isNotEmpty) {
//             categoriesStr = categorized.map((cat) {
//               double debit = double.tryParse(cat['total_debit']?.toString() ?? '0') ?? 0.0;
//               return '${cat['category'] ?? 'Unknown'}: ₹${debit.toStringAsFixed(2)}';
//             }).join('\n');
//           }
//         }
//       }

//       // Save spending data to SharedPreferences
//       await prefs.setString('total_spending', totalSpending);
//       await prefs.setString('categories', categoriesStr);
//       await prefs.setString('timestamp', timestamp);

//       // Trigger spending widget update
//       await HomeWidget.saveWidgetData<String>('total_spending', totalSpending);
//       await HomeWidget.saveWidgetData<String>('categories', categoriesStr);
//       await HomeWidget.saveWidgetData<String>('timestamp', timestamp);
//       await HomeWidget.updateWidget(
//         name: 'StakeplotWidgetProvider',
//         androidName: 'StakeplotWidgetProvider',
//         iOSName: 'StakeplotWidget',
//       );
      
     
//       return Future.value(true);
//     } catch (e) {
     
//       final prefs = await SharedPreferences.getInstance();
//       await _updateWidgetWithFallback(prefs);
//       return Future.value(false);
//     }
//   });
// }

// // Helper: Update widget with error/fallback values
// Future<void> _updateWidgetWithFallback(SharedPreferences prefs) async {
//   // Fallback for payable widget
//   String payableErrorMsg = 'Error: Check app';
//   await prefs.setString('to_receive', payableErrorMsg);
//   await prefs.setString('to_pay', payableErrorMsg);
//   await HomeWidget.saveWidgetData<String>('to_receive', payableErrorMsg);
//   await HomeWidget.saveWidgetData<String>('to_pay', payableErrorMsg);
//   await HomeWidget.updateWidget(
//     name: 'PayableWidgetProvider',
//     androidName: 'PayableWidgetProvider',
//     iOSName: 'PayableWidget',
//   );

//   // Fallback for spending widget
//   String totalSpendingFallback = '₹0';
//   String categoriesFallback = 'None';
//   String timestampFallback = getMonthlyRange();
//   await prefs.setString('total_spending', totalSpendingFallback);
//   await prefs.setString('categories', categoriesFallback);
//   await prefs.setString('timestamp', timestampFallback);
//   await HomeWidget.saveWidgetData<String>('total_spending', totalSpendingFallback);
//   await HomeWidget.saveWidgetData<String>('categories', categoriesFallback);
//   await HomeWidget.saveWidgetData<String>('timestamp', timestampFallback);
//   await HomeWidget.updateWidget(
//     name: 'StakeplotWidgetProvider',
//     androidName: 'StakeplotWidgetProvider',
//     iOSName: 'StakeplotWidget',
//   );
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized(); 
//   securityCheck();
//   checkFirebaseAndValidUser();
//   loadEnvs();
  
//   // Store full API URL (with /api/v1) in SharedPreferences for background access (after loadEnvs)
//   final prefs = await SharedPreferences.getInstance();
//   // Full URL is already built as "${urlWithLocallHost}api/v1" in apis_connect.dart after loadEnvs
//   await prefs.setString('full_api_url', url); // 'url' is the global full path from apis_connect.dart
  
//   // Store accountId if available (adjust key/source as needed, e.g., from login service)
//   String? accountId = prefs.getString('accountId'); // Fetch existing; set during login if needed
//   if (accountId != null && accountId.isNotEmpty) {
//     await prefs.setString('accountId', accountId);
//   }
  
//   initializeGlobalErrorHandling();
  
//   // Initialize WorkManager
//   Workmanager().initialize(
//     callbackDispatcher,
//     isInDebugMode: false,  // More logs in debug
//   );

//   // Register periodic task (runs ~every 15 mins, even when app is closed)
//   Workmanager().registerPeriodicTask(
//     "widget-refresh-unique-id",  // Unique name
//     "periodic-widget-update",    // Task label
//     frequency: const Duration(minutes: 15),  // Minimum interval
//     constraints: Constraints(
//       networkType: NetworkType.connected,    // Requires internet
//       requiresBatteryNotLow: true,           // Skip if battery low
//       requiresCharging: false,               // Can run unplugged
//       requiresDeviceIdle: false,             // Run even if active
//       requiresStorageNotLow: false,
//     ),
//     backoffPolicy: BackoffPolicy.exponential,  // Retry on failure
//     backoffPolicyDelay: const Duration(seconds: 10),
//   );

//   // Optional: Immediate one-off sync on app start (unique ID with timestamp)
//   Workmanager().registerOneOffTask(
//     "initial-widget-sync-${DateTime.now().millisecondsSinceEpoch}",
//     "one-off-widget-update",
//     constraints: Constraints(networkType: NetworkType.connected),
//   );
  
//    runZonedGuarded(() {
//     runApp(const MyApp());
//   }, (Object error, StackTrace stack) {
//     // Handle uncaught async errors here
//     handleError(error, stack);
//   });
// }


// /// Method to initialize Flutter error handling
// void initializeGlobalErrorHandling() {
//   FlutterError.onError = (FlutterErrorDetails details) {
//     // Print to console
//     FlutterError.dumpErrorToConsole(details);
//     // Handle Flutter framework errors
//     handleError(details.exception, details.stack);
//   };
// }

// /// Centralized error handling method
// void handleError(Object error, StackTrace? stack) {
//   if (stack != null) {
   
//   }
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   void initState() {
//     super.initState();
//     // initPlatformState();
//     // Set status bar
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
//         overlays: [SystemUiOverlay.top]);
//   }

//   // Future<void> initPlatformState() async {
//   //   if (!mounted) return;
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return MediaQuery(
//       data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
//       child: MaterialApp(
//         navigatorKey: navigatorKey,
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
//           scaffoldBackgroundColor: AppColors.backgroundColor,
//         ),
//         debugShowCheckedModeBanner: false,
//         initialRoute: '/splash',
//         routes: routes,
//         // Attach updateNavigatorKey to a nested Navigator if needed (optional)
//         builder: (context, child) {
//           return Navigator(
//             key:updateNavigatorKey, // Attach updateNavigatorKey for update dialogs
//             onGenerateRoute: (settings) => MaterialPageRoute(
//               builder: (context) =>
//                   child ?? Container(), // Fallback to empty container
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // Update check function

// Future<void> checkForUpdate() async {
//   if (Platform.isAndroid) { 
//     try {
//       final updateInfo = await InAppUpdate.checkForUpdate();
//       if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
//         await InAppUpdate.performImmediateUpdate(); // Force update
//       }
//     } catch (e)
//     {
//     }
//   } else if (Platform.isIOS) {
//     final context = updateNavigatorKey.currentContext ?? Get.context;
//     if (context != null) {
//       try {
//         // Check for updates using app_version_update
//         final result = await AppVersionUpdate.checkForUpdates(
//           appleId: 'com.stakeplot.pfa', // Replace with your iOS App Store bundle ID
//         );
//         // Check if result and canUpdate are non-null and true
//         if (result.canUpdate == true) {
//           // Show update dialog
//           await AppVersionUpdate.showAlertUpdate(
//             appVersionResult: result,
//             context: context,
//             backgroundColor: AppColors.backgroundColor,
//             title: 'Update Available',
//             content:
//                 'A new version (${result.storeVersion ?? "unknown"}) is available. Please update the app.',
//             updateButtonText: 'Update Now',
//             cancelButtonText: 'Later',
//             mandatory: false, // Set to true for forced update
//           );
//         } else {
//         }
//       } catch (e) {
//       }
//     } else {
//     }
//   }
// }


import 'dart:io';
import 'dart:async';
import 'package:finvu_flutter_sdk/finvu_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
import 'package:flutter_application_code_stakeplot/Profile/friends.dart';
import 'package:flutter_application_code_stakeplot/animated/widget_bridge.dart';
import 'package:flutter_application_code_stakeplot/routes.dart';
import 'package:flutter_application_code_stakeplot/widget_service.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:in_app_update/in_app_update.dart';
import 'package:app_version_update/app_version_update.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart'; // Import for 'url' global


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
  
  // Store full API URL (with /api/v1) in SharedPreferences for background access (after loadEnvs)
  final prefs = await SharedPreferences.getInstance();
  // Full URL is already built as "${urlWithLocallHost}api/v1" in apis_connect.dart after loadEnvs
  await prefs.setString('full_api_url', url); // 'url' is the global full path from apis_connect.dart
  
  // Store accountId if available (adjust key/source as needed, e.g., from login service)
  String? accountId = prefs.getString('accountId'); // Fetch existing; set during login if needed
  if (accountId != null && accountId.isNotEmpty) {
    await prefs.setString('accountId', accountId);
  }
  
  initializeGlobalErrorHandling();
  
  // Initialize widget service (handles WorkManager and widgets only)
  initializeWidgetService();
  
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
     WidgetBridge.getLastWidgetSelection().then((opt) {
    if (opt != null) {
      print('Last widget option: $opt');
      // react: maybe show a toast or set UI state
    }
  });

  // 2) Listen for runtime events when Android calls into Flutter (onNewIntent)
  WidgetBridge.setMethodCallHandler((args) {
    if (args.containsKey('tab')) {
      final tab = args['tab'];
      // navigate to tab in your HomeShell, e.g. set selectedIndex
    } else if (args.containsKey('option')) {
      final option = args['option'];
      // react to raw clicked option
    } else if (args.containsKey('navigate_to_tab')) {
      final nav = args['navigate_to_tab'];
      // handle older getInitialRoute map
    }
  });
 try {
    final friendNames = globalFriendsList
        .take(4)
        .map((e) => (e != null && e['name'] != null) ? e['name'].toString() : '')
        .where((s) => s.isNotEmpty)
        .toList();
    WidgetBridge.setWidgetFriends(friendNames);
  } catch (e) {
    // ignore
  }
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

// Update check function (kept in main as requested)
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
            backgroundColor: AppColors.white,
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