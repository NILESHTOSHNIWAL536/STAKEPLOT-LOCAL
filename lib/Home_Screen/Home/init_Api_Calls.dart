import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/home_screen_state/home_page.dart';
import 'package:flutter_application_code_stakeplot/repository/finance_repository.dart';

import 'package:flutter_application_code_stakeplot/OneSignal/deviceConfig.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/repository/clearstack.dart';
import 'package:flutter_application_code_stakeplot/repository/manual_transaction_repository.dart';
import 'package:flutter_application_code_stakeplot/repository/notification_repository.dart';
import 'package:flutter_application_code_stakeplot/repository/post.dart';
import 'package:flutter_application_code_stakeplot/repository/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/Constants/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/repository/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/repository/group_Api.dart';
import 'package:flutter_application_code_stakeplot/repository/autopay_repository.dart';
import 'package:flutter_application_code_stakeplot/repository/budget_apis.dart';
import 'package:flutter_application_code_stakeplot/repository/finora_repository.dart';
import 'package:flutter_application_code_stakeplot/repository/payables_repository.dart';
import 'package:flutter_application_code_stakeplot/repository/transactions_repository.dart';
import 'package:flutter_application_code_stakeplot/widget_services/widget_updation.dart';
import 'package:get/get.dart';
import '../../components/shared_utils.dart';
import '../../controllers/collections_controller.dart';
import '../../controllers/user-controller.dart';
import '../insightsController.dart';

Future<void>? _callApiFuture;

Future<void> callApi(context) async {
  if (_callApiFuture != null) return _callApiFuture!;

  _callApiFuture = _callApi(context).whenComplete(() {
    _callApiFuture = null;
  });
  return _callApiFuture!;
}

Future<void> _callApi(context) async {
  contextGlobal = context;

  final userController = Get.find<UserController>();
  final insightsController = Get.put(InsightsController());
  // final budgetController = Get.find<BudgetControllerScreenModel>();

  // ✅ STEP 1: Only CRITICAL (block minimal)
  await userController.fetchUserInfo();

  // ⚡ STEP 2: Fire everything in parallel (NON-BLOCKING)
  Future(() async {
    try {
      await Future.wait([
        getBankAccounts(),
        getAck(),
        cardController.fetchCardData(),
        cardController.getBanksListCrediCard(),
        // budgetController.getBudget(),
        getHiddenTransactions(context),
        insightsController.getHomePageInsights(context),
        insightsController.getHomePageMoneyMapInsights(context),
        getNotifications(context),
        getAllAutoTransactions(),
        getAllContstant(context),
        getGroupTransactions(),
        getCustomCategory(context),
        getAutoPayInfo(),
        getAllTransactionHistory(context, false, false, isRefreshing: true),
        getAllTransactionHistory(context, true, false, isRefreshing: true),
        getWeeklyGraphAndCustomDateGraph(
          getFormattedDate(),
          context,
          isSplashScreen: true,
        ),
        getPost(context),
        getTranding(context),
        getRemainders(context),
        updateWidget(),
        getCategoryData(),
        collectionsController.getCollections(),
        collectionsController.fetchCollectionLimitSummary()
      ]);
    } catch (e) {
      appLog("Background API error: $e");
    }
  });

  // ✅ STEP 3: Instant UI setup (no waiting)
  custom = getthelist();
  allOrGroupTransactionsName.value = StringConstant.allTransactions;
  clearAllFlags();

  lifecycleHandler = AppLifecycleHandler(userController.userId.value);
  WidgetsBinding.instance.addObserver(lifecycleHandler);

  setUpSocketListenerMainPage(context);
}

// Future<void> callApi(context) async {
//   await Get.find<UserController>().fetchUserInfo();
//   final InsightsController _controller = Get.put(InsightsController());
//   final budgetController = Get.find<BudgetControllerScreenModel>();
//   getBankAccounts();
//   getAck();
//   contextGlobal = context;
//   unawaited(budgetController.getBudget());
//   getHiddenTransactions(context);
//   _controller.getHomePageInsights(context);
//   _controller.getHomePageMoneyMapInsights(context);
//   getNotifications(context);
//   getAllAutoTransactions();
//   getAllContstant(context);
//   unawaited(getGroupTransactions());
//   unawaited(getCustomCategory(context));
//   unawaited(getAutoPayInfo());
//   unawaited(getAllTransactionHistory(context, false, false, isRefreshing: true));
//   unawaited(getAllTransactionHistory(context, true, false, isRefreshing: true));
//   getWeeklyGraphAndCustomDateGraph(getFormattedDate(), context,
//       isSplashScreen: true);
//   custom = getthelist();
//   allOrGroupTransactionsName.value = StringConstant.allTransactions;
//   clearAllFlags();
//   unawaited(getPost(context));
//   unawaited(getTranding(context));
//   await getRemainders(context);
//   unawaited(updateWidget());
//   getCategoryData();
//   lifecycleHandler = AppLifecycleHandler(userController.userId.value);
//   WidgetsBinding.instance.addObserver(lifecycleHandler);
//   setUpSocketListenerMainPage(context);
//   CollectionsController().getCollections();
//   CollectionsController().fetchCollectionLimitSummary();
// }

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
