import 'package:finvu_flutter_sdk/finvu_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/routes.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'appTheme.dart';
import 'backed_connections/apiConnect/clearstack.dart';
import 'controllers/controllerManagement.dart';
import 'controllers/theme_controller.dart';
import 'main_helper.dart';

FinvuManager finvuManager = FinvuManager();
late IO.Socket mainPageWebSocket;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> updateNavigatorKey = GlobalKey<NavigatorState>(); 

void main() async 
{
  WidgetsFlutterBinding.ensureInitialized();
  main_apis_call_init();
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
