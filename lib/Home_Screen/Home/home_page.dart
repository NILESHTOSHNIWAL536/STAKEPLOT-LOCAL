import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_AppBar.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/indexScreen.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/init_Api_Calls.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/noaccountSelected.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/nextFetch.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

RxBool sectionReached = false.obs;
RxString weekOfThis = "This week".obs;
late AppLifecycleHandler lifecycleHandler;

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    initializeData(context, mounted);
    HomeWidgetBindUpdate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPopupOnce();
    });
  }

  Future<void> _showPopupOnce() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasShownPopup = prefs.getBool('hasShownPopup') ?? false;
    print("value of pop $hasShownPopup");

    if (!hasShownPopup) {
      // Show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Welcome!'),
            content: Text('This is a one-time pop-up message.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      // Set the flag to true so the dialog won't show again
      await prefs.setBool('hasShownPopup', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        exit(0);
      },
      child: Scaffold(
        bottomNavigationBar: SafeArea(child: BottomNavigations(data: 0)),
        backgroundColor: AppColors.backgroundColor,
        appBar: getAppBar(context),
        body:
            Obx(() => !isBankLinked.value ? NoAccountScreen() : IndexScreen()),
      ),
    );
  }
}
