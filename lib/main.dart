import 'dart:async';
import 'dart:ui';
import 'package:finvu_flutter_sdk/finvu_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/routes/routes.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'Constants/core/app_component_sizes.dart';
import 'app_init/AppTheme.dart';
import 'components/shared_utils.dart';
import 'deep_link_service.dart';
import 'repository/app_share_link/appsflyer_service.dart';
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
  if (!kIsWeb) {
  await Firebase.initializeApp();
  FlutterError.onError =
      FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
     await AppsflyerService.init();
   }
  await main_apis_call_init();  
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeController themeController;
  StreamSubscription<Uri>? _linkSubscription;

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

  void handleDeepLink(contextp) {
    appLog("🚀 DeepLink init called");
    DeepLinkService().init((token) {
      appLog("🚀 Token: $token");
    }, contextp);
  }

  void loadThemes() async {
    await Get.put(ThemeController());
    themeController.loadTheme();
    AppComponentSizes.init(context);
  }

  @override
  Widget build(BuildContext context) {
    handleDeepLink(context);
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
