import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_page.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/Constants/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/budget_apis.dart';
import 'package:flutter_application_code_stakeplot/widget_services/widget_updation.dart';
import 'package:get/get.dart';
import '../../backed_connections/backServices.dart/bankInfo.dart';
import '../../controllers/user-controller.dart';
import '../insightsController.dart';

Future<void>  callApi(context) async {
  await Get.find<UserController>().fetchUserInfo();
  final InsightsController _controller = Get.put(InsightsController());
  getBankAccounts();
  getAck();
  contextGlobal = context;
  getUserLend(context);
  unawaited(getBudget());
  getHiddenTransactions(context);
  _controller.getHomePageInsights(context);
  _controller.getHomePageMoneyMapInsights(context);
  getNotifications(context);
  getAllAutoTransactions();
  getAllContstant(context);
  unawaited(getGroupTransactions());
  unawaited(getCustomCategory(context));
  unawaited(getAutoPayInfo());
  unawaited(getAllTransactionHistory(context, false, false, isRefreshing: true));
  unawaited(getAllTransactionHistory(context, true, false, isRefreshing: true));
  getWeeklyGraphAndCustomDateGraph(getFormattedDate(), context,isSplashScreen: true);
  custom = getthelist();
  allOrGroupTransactionsName.value = StringConstant.allTransactions;
  clearAllFlags();
  unawaited(getPost(context));
  unawaited(getTranding(context));
  await getRemainders(context);
  unawaited(updateWidget());
  getCategoryData(context);
  lifecycleHandler = AppLifecycleHandler(userController.userId.value);
  WidgetsBinding.instance.addObserver(lifecycleHandler);
  setUpSocketListenerMainPage(context);
}

void initializeData(context, mounted) {
  isLoginAlreadLogin(context, mounted);
  oneSignalAddClickListener(context);
  sectionReached.value = false;
}

void isLoginAlreadLogin(context, mounted) async {
  bool isHome = await check(context, "homeScreen");
  if (isHome) {
    await requestNotificationPermissionOncePerDay();
    if (!mounted) return;
    callApi(context);
  }
}
