import 'dart:async';

import 'package:finvu_flutter_sdk/finvu_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/routes/routes.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'Constants/core/app_component_sizes.dart';
import 'app_init/AppTheme.dart';
import 'controllers/finora_controller.dart';
import 'controllers/quick_check_controller.dart';
import 'repository/clearstack.dart';
import 'controllers/controllerManagement.dart';
import 'controllers/theme_controller.dart';
import 'components/main_helper.dart';
import 'widget_services/widget_service.dart';

FinvuManager finvuManager = FinvuManager();
late IO.Socket mainPageWebSocket;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> updateNavigatorKey =
    GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values, // ⬅️ THIS IS KEY
  );
  main_apis_call_init();
  // runZonedGuarded(() {
  //   runApp(const MyApp());
  // }, (Object error, StackTrace stack) {
  //   // Handle uncaught async errors here
  //   handleError(error, stack);
  // });
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

    initializeOneSignal(context);
    init_widget_main();
    themeController = ControllerManagement.themeController;
    loadThemes();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top]);
  }

  void loadThemes() async {
    await Get.put(ThemeController());
    themeController.loadTheme();
    AppComponentSizes.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: Obx(() => MaterialApp(
            navigatorKey: navigatorKey,
            theme: AppTheme.lightTheme, // 👈 Light Theme
            darkTheme: AppTheme.darkTheme, // 👈 Dark Theme
            // themeMode: ThemeMode.system,     // 👈 Automatically switch based on device
            themeMode: themeController.themeMode.value,
            debugShowCheckedModeBanner: false,
            initialRoute: '/splash',
            routes: routes,
            builder: (context, child) {
              return Navigator(
                key:
                    updateNavigatorKey, // Attach updateNavigatorKey for update dialogs
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
