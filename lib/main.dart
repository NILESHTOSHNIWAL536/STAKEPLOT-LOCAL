import 'package:finvu_flutter_sdk/finvu_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
import 'package:flutter_application_code_stakeplot/routes.dart';
import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


FinvuManager finvuManager = FinvuManager();
late IO.Socket mainPageWebSocket;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main()async {
  checkFirebaseAndValidUser();
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
      // adding this for status bar 
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]);

  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       navigatorKey: navigatorKey, 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.finSpaceColor),
        scaffoldBackgroundColor: AppColors.backgroundColor,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/animatedAppScreen', 
      routes: routes
    );
  }

}
