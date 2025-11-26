import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_AppBar.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/indexScreen.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/init_Api_Calls.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/noaccountSelected.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/weeklyPopUp.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/Utils/rewardscreen.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/nextFetch.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/rewardsplashscreen.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:get/get.dart';

RxBool sectionReached = false.obs;
RxString weekOfThis = "This week".obs;
late AppLifecycleHandler lifecycleHandler;

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool flag = true;
  final ScrollController _scrollControllerPage = ScrollController();
  @override
  void initState() {
    super.initState();
    // initializeData(context, mounted);
    // getTopThreeTransactions(context);
    HomeWidgetBindUpdate();
    if (!Get.isRegistered<WeeklyPopupController>(
        tag: 'weeklyPopup_${userController.userId.value}')) {
      Get.put(WeeklyPopupController(),
          tag: 'weeklyPopup_${userController.userId.value}');
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        showWeeklyPopup(context, userController.userId.value);
      } else {}
    });
    storeBankDataApi();
    requestNotificationPermissionOncePerDay();
  }

  void _scrollToTop() {
    _scrollControllerPage.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          exit(0);
        },
        child: Obx(
          () => (RewardScreenStrings().isRewardNeedToShow.value)
              ? RewardsScreen()
              : Scaffold(
                  bottomNavigationBar: SafeArea(
                      child: BottomNavigations(
                    data: 0,
                    onHomeDoubleTap: _scrollToTop,
                  )),
                  backgroundColor: AppColors.backgroundColor,
                  appBar: getAppBar(context),
                  body: Obx(() => isBankLinked.value
                      ? IndexScreen(scrollControllerHome: _scrollControllerPage)
                      : NoAccountScreen()),
                ),
        ));
  }
}
