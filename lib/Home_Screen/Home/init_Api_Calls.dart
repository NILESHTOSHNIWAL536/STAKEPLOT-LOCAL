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
import 'package:flutter_application_code_stakeplot/animated/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/budget_apis.dart';
import 'package:get/get.dart';
import '../../backed_connections/backServices.dart/bankInfo.dart';
import '../../controllers/user-controller.dart';
import '../insightsController.dart';

void callApi(context) async {
  await Get.find<UserController>().fetchUserInfo();
  final InsightsController _controller = Get.put(InsightsController());
  getBankAccounts();
  getPost(context);
  getTranding(context);
  getAck();
  contextGlobal = context;
 
  getUserLend(context);
  getBudget();
  getHiddenTransactions(context);
  _controller.getHomePageInsights(context);
  _controller.getHomePageMoneyMapInsights(context);
  getNotifications(context);
  getAllAutoTransactions();
  getAllContstant(context);
  getGroupTransactions();
  getCustomCategory(context);
  getAutoPayInfo();
  getAllTransactionHistory(context, false, false, isRefreshing: true);
  getAllTransactionHistory(context, true, false, isRefreshing: true);
  getWeeklyGraphAndCustomDateGraph(getFormattedDate(), context,
      isSplashScreen: true);
  userController.fetchUserInfo();
  custom = getthelist();
  allOrGroupTransactionsName.value = StringConstant.allTransactions;
  clearAllFlags();
  
  await getRemainders(context);
  await updateWidget();
  getCategoryData(context);
  lifecycleHandler = AppLifecycleHandler(
      userController.userId.value); // Replace with actual user ID
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
