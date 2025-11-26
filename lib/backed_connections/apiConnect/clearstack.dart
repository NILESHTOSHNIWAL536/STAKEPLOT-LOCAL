import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/hive_storage.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/categoriseSpending.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactions_ui_component.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_page.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/insightsController.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionHistoryScreen.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/FriendsUi.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/nextFetch.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/post.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/controllers/post-controller.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:flutter_application_code_stakeplot/finSpace/apisCall.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';

import '../../controllers/credit_card_controller.dart';
import '../../controllers/theme_controller.dart';
import '../apiAutomations/secure_storage.dart';

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
  // //  if (!f && flag != "loginuser") Navigator.pushReplacementNamed(context, '/');
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
  var json = await getUserStats();
  var responce = await postDataApiCall("${url}/deviceScreenTime/", json);
  if (getFlagOfResponse(responce)) {}
  try {
    await postDataApiCall(AuthApiRoutes.logout, {});
  } catch (e)
   {
      logoutUserFromDevice(context);
  }
}

Future<void> storeDeviceInfoLocalBackState() async {
  var json = await getUserStats();
  var responce = await postDataApiCall("${url}/deviceScreenTime/", json);

  if (getFlagOfResponse(responce)) {}
}

void clearTransactions({required BuildContext context, bool f = false}) {
  searchController.clear();
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
  roomBills.clear();
  questionRoom.clear();
  productList.clear();
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
  billLength = 0.obs;
  debtLength = 0.obs;
  paymentLength = 0.obs;
  room = [];
  account = [];
  notificationList.clear();
  hasGetNewNotifications.value = false;
  targetString = "".obs;
  isBankAccountLink.value = true;
  trasactionsData.clear();
  addedMembers.clear();
  addedUser.clear();
  isBankAccountLink.value = false;
  balance.value = "";
  accountName.value = "";
  transactionChatGraph.clear();
  labels.clear();
  selectedButton.value = "Month";
  graphTransaction.value = false;
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
  spendingsOnCategories.clear();
  isLoadingMore.value = false;
  isFected.value = false;
  currentPage = 1;
  consentAndHandleDetails.clear();
  isBankLinked.value = false;
  clearGraph();
  loadBanks.value = true;
  deleteGetControllers();
  HiveStorage.closeAllBoxes();
}

RxMap<String, String> ListOfBankImages = RxMap();

void getAllContstant(context) async {
  var responce = await getDataApiCall("${url}/constant/weekmonth");
  expire(responce, context);
  if (getFlagOfResponse(responce)) {
    var data = jsonDecode(responce.body);
    weekOfThis.value = data['data']['week'];
  }
}

void logoutUserFromDevice(context2) async {
  BuildContext context = navigatorKey.currentContext ?? context2;

  try {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    clearGetX();
    // added this for logout to prevent red screen
    if (!Get.isRegistered<UserController>()) {
      Get.lazyPut(() => UserController());
    }
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    Navigator.pushReplacementNamed(context, '/');
    await _pref.remove("token");
    await _pref.remove("accessToken");
    await SecureStorageService().deleteAll();
  } catch (e) {}
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
  Get.put(CardDueController());
  Get.put(ThemeController());
}

void deleteGetControllers() {
  Get.delete<UserController>();
  Get.delete<PostController>();
  Get.delete<CardDueController>();
  Get.delete<ThemeController>();
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
}
