import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/home_screen_state/indexScreen.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/home_screen_state/noaccountSelected.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/weeklyPopUp.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/Utils/rewardscreen.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/bankServices/nextFetch.dart';
import 'package:flutter_application_code_stakeplot/app_init/rewardsplashscreen.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/components/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/repository/referral_repository.dart';
import 'package:get/get.dart';

import '../../repository/bankinfo.dart';

RxBool sectionReached = false.obs;
RxString weekOfThis = "This week".obs;
late AppLifecycleHandler lifecycleHandler;
RxBool isBankLoading = true.obs;
// initially TRUE

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _persistReferralCodeFromArguments();
    });
  }

  Future<void> _persistReferralCodeFromArguments() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['refCode'] != null) {
      await ReferralRepository.saveIncomingReferralCode(
        args['refCode'].toString(),
      );
    }
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
    // ignore: deprecated_member_use
    return WillPopScope(
        onWillPop: () async {
          exit(0);
        },
        child: Obx(
          () => (RewardScreenStrings().isRewardNeedToShow.value)
              ? RewardsScreen()
              : Scaffold(
                  bottomNavigationBar: BottomNavigations(
                    data: 0,
                    onHomeDoubleTap: _scrollToTop,
                  ),
                  backgroundColor: AppColors.backgroundColor,
                  body: Obx(() {
                    final hasResolvedBankState =
                        bankInfoController.hasLoadedLocalData.value ||
                            bankAccountLinkedList.isNotEmpty ||
                            !isBankLoading.value;

                    if (!hasResolvedBankState) {
                      return const SizedBox.shrink();
                    }

                    return isBankLinked.value
                        ? IndexScreen(
                            scrollControllerHome: _scrollControllerPage)
                        : NoAccountScreen();
                  }),
                ),
        ));
  }
}
