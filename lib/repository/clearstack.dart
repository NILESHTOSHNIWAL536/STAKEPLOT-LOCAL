import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/hive_storage.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactions_ui_component.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/home_screen_state/home_page.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/insightsController.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionHistoryScreen.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/FriendsUi.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/bankServices/nextFetch.dart';
import 'package:flutter_application_code_stakeplot/controllers/finora_controller.dart';
import 'package:flutter_application_code_stakeplot/repository/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/repository/post.dart';
import 'package:flutter_application_code_stakeplot/repository/referral_repository.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/controllers/post-controller.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:flutter_application_code_stakeplot/finSpace/apisCall.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:flutter_application_code_stakeplot/repository/transactions_repository.dart';
import 'package:flutter_application_code_stakeplot/routes/route_constant.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';

import '../controllers/collections_controller.dart';
import '../controllers/credit_card_controller.dart';
import '../controllers/fipmetrics-controller.dart';
import '../controllers/quick_check_controller.dart';
import '../controllers/theme_controller.dart';
import '../services/secure_storage.dart';
import '../loginservices/login.dart';
import 'budget_apis.dart';
import 'delete_banks_users.dart';

void clearStack(BuildContext context) {
  try {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  } catch (e) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }
}

void clearStackHome(BuildContext context) {
  try {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  } catch (e) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  }
}

void clearStackName(BuildContext context, String str, [String to = "/home"]) {
  try {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('${str}', (Route<dynamic> route) => false);
  } catch (e) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('${to}', (Route<dynamic> route) => false);
  }
}

void clearStackShared(BuildContext context) {
  for (int i = 0; i <= 4; i++) {
    Navigator.pop(context);
  }
}

void expire(response, BuildContext context) {
  try {
    // var body = json.decode(response.body);
    if (response.statusCode == 401) {
      logoutUserFromDevice(context);
    }
  } catch (e) {}
}

void clearPostReportHide(int index, context, [bool f = true]) {
  postController.currentPageTranding.value = 1;
  postController.currentPageFeed.value = 1;
  postController.isPostloading.value = false;
  postController.feedPostList.clear();
  postController.trandingPostList.clear();
  postController.hasMorePostTranding.value = true;
  postController.hasMorePostFeed.value = true;
  postController.isPost.value = false;
  postController.isPostTranding.value = false;
  getPost(context);
  getTranding(context);
  postController.posting.value = false;
  postController.postDis.value = false;
  postController.getPostedTranding.value =
      !postController.getPostedTranding.value;
  postController.getPosted.value = !postController.getPosted.value;
}

Future<bool> check(context, String flag) async {
  bool f = await SecureStorageService().containsKey("accessToken");
  if (!f && flag != "loginuser") {
    Navigator.pushReplacementNamed(context, '/');
    return false;
  }

  if (flag == "loginuser") {
    return false;
  }

  return true;
}

Future<void> storeDeviceInfo(context) async {
  try {
    await Future(() async {
      final json = await getUserStats();

      await postDataApiCall(
        AuthApiRoutes.logout,
        json,
      );
    });
  } catch (e) {
    print("Store Device Info Error: $e");
  }
}

Future<void> storeDeviceInfoLocalBackState() async {
  try {
    final json = await getUserStats();

    final response = await postDataApiCall(
      SendNotificationsRoutes.deviceScreenTime,
      json,
    );

    if (getFlagOfResponse(response)) {
      // success
    }
  } catch (e) {
    print("Background Device Info Error: $e");
  }
}

void clearTransactions({required BuildContext context, bool f = false}) {
  tnxSearchController.clear();
  redioButton.clear();
  redioButtonIndex.clear();
  allOrGroupTransactionsName.value = StringConstant.allTransactions;
  showCheckBox.value = false;
  accountIdPdf.value = "-";
  addManually.clear();
  maxController.text = "";
  minController.text = "";
  startDateController.text = "";
  endDateController.text = "";
  if (f) {
    currentPage = 1;
    isLoadingMore.value = false;
    getAllTransactionHistory(context, false, false, isRefreshing: true);
  }
}

void clearGraph() {
  totalDebitValue.value = 0.0;
  totalDebitValuePercent.value = 0.0;
  startDateCustom = DateTime.now().subtract(const Duration(days: 7));
  endDateCustom = DateTime.now();
}

void clearGetX() {
  messages.clear();
  messagesTemp.clear();

  userPostList.clear();
  // friendsList.clear();
  // frdsListOrigin.clear();
  chatList.clear();
  chatListOriginal.clear();
  friendsListDetails.clear();
  chatOfUserList.clear();
  chatOfUserListData.clear();
  consentAndHandleDetails.clear();
  aboutMe = false.obs;
  sizeRoom = false;
  fontSize = 20;
  budgetLength = 0.obs;

  room = [];
  account = [];
  notificationList.clear();
  hasGetNewNotifications.value = false;

  isBankAccountLink.value = true;

  addedMembers.clear();
  addedUser.clear();
  isBankAccountLink.value = false;
  balance.value = "";
  accountName.value = "";
  transactionChatGraph.clear();
  labels.clear();
  selectedButton.value = "Month";

  isSplit.value = false;
  isLend.value = false;
  accountName.value = "";
  accountNo.value = "0";
  balance.value = "0";
  selectedBank.value = "";
  accountId.value = "";
  bankAccountLinkedList.clear();
  FipIdsConnected.clear();
  transactionsHistory.clear();
  if (Get.isRegistered<FinoraController>()) {
    Get.find<FinoraController>().spendingsOnCategories.clear();
  }
  isLoadingMore.value = false;
  isFected.value = false;
  currentPage = 1;
  consentAndHandleDetails.clear();
  isBankLinked.value = false;
  clearGraph();
  loadBanks.value = true;
  HiveStorage.closeAllBoxes();
  if (Get.isRegistered<CollectionsController>()) {
    Get.find<CollectionsController>().clearAllData();
  }
}

RxMap<String, String> ListOfBankImages = RxMap();

Future<void> getAllContstant(context) async {
  var responce = await getDataApiCall(ConstantRoutes.weekMonth);
  expire(responce, context);
  if (getFlagOfResponse(responce)) {
    var data = jsonDecode(responce.body);
    weekOfThis.value = data['data']['week'];
  }
}

bool _isLogoutInProgress = false;

Future<void> logoutUserFromDevice(BuildContext? context2) async {
  _isLogoutInProgress = true;

  final context = context2 ?? navigatorKey.currentState!.context;
  final navigator = Navigator.of(context);

  try {
    await storeDeviceInfo(context);

    final pref = await SharedPreferences.getInstance();

    await Future.wait([
      pref.remove("token"),
      pref.remove("accessToken"),
      SecureStorageService().delete("token"),
      SecureStorageService().delete("accessToken"),
      SecureStorageService().deleteAll(),
      ReferralRepository.clearAllReferralCodes(),
      ReferralRepository.clearMyShareReferralCode(),
      navigator.pushNamedAndRemoveUntil(
        '/',
        (Route<dynamic> route) => false,
      )
    ]);
    _isLogoutInProgress = false;

    Future.microtask(() {
      try {
        clearGetX();
        deleteGetControllers();
      } catch (e) {
        print("Logout cleanup Error: $e");
      }
    });
  } catch (e) {
    print("Logout Error: $e");

    navigator.pushNamedAndRemoveUntil(
      '/',
      (Route<dynamic> route) => false,
    );
  } finally {
    _isLogoutInProgress = false;
  }
}

void clearStackLocalInfo() {
  fetchedData.value = false;
  listOfAccountAdded.clear();
  FinvuFIPDetailsList.clear();
  accountCountList.clear();
  accountAdded.clear();
  accountLinked.clear();
  fipDis.clear();
  fipDisOrginal.clear();
  isSeletedBankAccout.clear();
  bankImageAndid.clear();
  listOfBankAccount.clear();
  fetchAccountData.clear();
  seletedAccountInfomations.clear();
  fipDis.clear();
  seletedAccountIds.clear();
  fiTypes.clear();
  getBanks.value = false;
  addAccount.value = false;
  getFetch.value = false;
  addBank.value = false;
  directFetch.value = false;
  fetchedData.value = false;
  count.value = 0;
  //  maskedName.value="";
  //  interestedTags.clear();
  clearInterest();
}

void clearInterest() {
  selectedCategories.clear();
  selectedSubCategories.clear();
  isListEnabled.value = false;
}

void initGetControllers() {
  Get.put(UserController());
  Get.put(PostController());
  // Get.put(FinoraController());
  Get.put(CardDueController());
  Get.put(ThemeController());
}

void deleteGetControllers() {
  // Keep UserController registered while the old authenticated widget tree is
  // disposing; several widgets can still rebuild briefly during logout.
  if (Get.isRegistered<PostController>()) {
    Get.delete<PostController>();
  }
  // Get.delete<FinoraController>();
  if (Get.isRegistered<CardDueController>()) {
    Get.delete<CardDueController>();
  }
  if (Get.isRegistered<ThemeController>()) {
    Get.delete<ThemeController>();
  }
}

void initGetControllersIfisRegistered() {
  if (!Get.isRegistered<UserController>()) {
    Get.put(UserController());
  }
  if (!Get.isRegistered<PostController>()) {
    Get.put(PostController());
  }
  if (!Get.isRegistered<CardDueController>()) {
    Get.put(CardDueController());
  }
  if (!Get.isRegistered<ThemeController>()) {
    Get.put(ThemeController());
  }
  if (!Get.isRegistered<FipMetricsController>()) {
    Get.put(FipMetricsController());
  }
  if (!Get.isRegistered<CollectionsController>()) {
    Get.put(CollectionsController());
  }
  if (!Get.isRegistered<FinoraController>()) {
    Get.put(FinoraController());
  }
  if (!Get.isRegistered<QuickCheckController>()) {
    Get.put(QuickCheckController());
  }
  if (!Get.isRegistered<BankInfoController>()) {
    Get.put(BankInfoController(), permanent: true);
  }
  
  if (!Get.isRegistered<BudgetControllerScreenModel>()) {
    Get.put(BudgetControllerScreenModel());
  }
}
