import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/core/app_shadows.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Utils/shakewidget.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/controllers/collections_controller.dart';
import 'package:flutter_application_code_stakeplot/controllers/post-controller.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter_application_code_stakeplot/model/autopay_model.dart';
import 'package:flutter_application_code_stakeplot/model/user_activity_model.dart';
import 'package:get/get.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../controllers/controllerManagement.dart';
import '../controllers/credit_card_controller.dart';
import '../model/device_model.dart';
import 'googlesignin/credentials.dart';
part '../Constants/snackBars.dart';

UserController get userController => ControllerManagement.userController;
PostController get postController => ControllerManagement.postController;
CardDueController get cardController => Get.isRegistered<CardDueController>()
    ? Get.find<CardDueController>()
    : Get.put(CardDueController());
CollectionsController get collectionsController =>
    Get.isRegistered<CollectionsController>()
        ? Get.find<CollectionsController>()
        : Get.put(CollectionsController());

Rx<DeviceModel> deviceData = DeviceModel(
  deviceId: "",
  brand: "",
  device: "",
  model: "",
  os: "",
).obs;

RxBool isBankAccountLink = false.obs;
RxInt scrollBankPage = 0.obs;

RxList notificationList = [].obs;
RxList<String> listofLinkedAccount = <String>[].obs;
RxList trasactionsHideData = [].obs; // hidden tnx
RxBool getHistory = false.obs;
RxList lendAmountRemainders = [].obs;
RxBool getlendUsers = false.obs;
RxBool isFromEditDeatils = false.obs;
RxString range = ''.obs;
RxString defaultBackGround = "#68B2A0".obs;
RxList friendRequestList = [].obs;
RxList messages = [].obs;
RxList messagesTemp = [].obs;
RxList userPostList = [].obs;
RxList chatList = [].obs;
RxList chatListOriginal = [].obs;
RxList customCategoryList = [].obs;
RxList customCategoryUnUsedList = [].obs;
RxMap friendsListDetails = {}.obs;
RxMap chatOfUserList = {}.obs;
RxMap chatOfUserListData = {}.obs;
List<Map<String, dynamic>> custom = [];
RxBool hideTransactionReload = false.obs;
RxBool aboutMe = false.obs;
RxBool myNotificationBool = false.obs;
RxBool hideBackAccountPassword = false.obs;
bool sizeRoom = false;
double fontSize = 20;
RxInt budgetLength = 0.obs;
RxString splitID = "".obs;
RxList dueAmountRemainders = [].obs;
RxBool getdueUsers = false.obs;
RxBool canMessageUser = false.obs;
RxInt selectedYear = DateTime.now().year.obs;
RxInt selectedMonth = DateTime.now().month.obs;
RxList inSights = [].obs;
RxBool getInsights = false.obs;
RxBool getCreditCardBudgetDebts = false.obs;

RxString accountId = "".obs;
RxString fetchingHandleId = "".obs;
RxString fetchingBankName = "".obs;
RxMap<String, String> fetchingBankNamesByHandle = <String, String>{}.obs;

void markBankFetchStarted(String handleId, String bankName) {
  if (handleId.isEmpty) return;
  final incomingName = bankName.trim();
  final existingName = fetchingBankNamesByHandle[handleId]?.trim() ?? "";
  final shouldKeepExisting = existingName.isNotEmpty &&
      (incomingName.isEmpty || incomingName == "New bank account");

  fetchingBankNamesByHandle[handleId] =
      shouldKeepExisting ? existingName : incomingName;
  fetchingHandleId.value = fetchingBankNamesByHandle.keys.first;
  fetchingBankName.value =
      fetchingBankNamesByHandle[fetchingHandleId.value] ?? "";
  isFected.value = fetchingBankNamesByHandle.isNotEmpty;
  userController.fetchInProgress.value = isFected.value;
}

void markBankFetchCompleted(String handleId) {
  if (handleId.isNotEmpty) {
    fetchingBankNamesByHandle.remove(handleId);
  } else {
    fetchingBankNamesByHandle.clear();
  }

  fetchingHandleId.value = fetchingBankNamesByHandle.isEmpty
      ? ""
      : fetchingBankNamesByHandle.keys.first;
  fetchingBankName.value = fetchingHandleId.value.isEmpty
      ? ""
      : fetchingBankNamesByHandle[fetchingHandleId.value] ?? "";
  isFected.value = fetchingBankNamesByHandle.isNotEmpty;
  userController.fetchInProgress.value = isFected.value;
}

bool isBankHandleFetching(String handleId) {
  return handleId.isNotEmpty && fetchingBankNamesByHandle.containsKey(handleId);
}

String fetchingBankNameForHandle(String handleId, [String fallback = ""]) {
  return fetchingBankNamesByHandle[handleId] ?? fallback;
}

RxString accountIdPdf = "".obs;
RxString accountSelected = "".obs;
RxString maskedNameLocal = "".obs;
RxString allOrGroupTransactionsName = "All".obs;
RxString searchTextController = "".obs;
RxBool searchTextControllerBool = false.obs;
RxBool searchItemClicked = false.obs;
RxList totalInSights = [].obs;
RxBool getTotalInsightsHistory = false.obs;
RxList foodieFundsDetailsRemainders = [].obs;
RxBool getFoodieFundsUsers = false.obs;
RxBool isGoogleUser = false.obs;
late BuildContext contextGlobal;
bool limitTagbool = false;
int currentPage = 1;
RxBool havingMoreData = true.obs;
RxBool isLoadingMore = false.obs;
bool hasMoreData = true;
int m = DateTime.now().month;
List arr = [];
RxBool reRender = false.obs;
RxBool setDonectChat = false.obs;
List room = [];
List<String> account = [];
RxBool acceptReset = false.obs;
RxBool LoadTag = false.obs;
RxList budgetList = [].obs;
final RxList<Debt> debts = <Debt>[].obs;
RxList historyListData = [].obs;
RxBool hasGetNewNotifications = false.obs;
RxBool getGraphData = false.obs;
RxBool loadBanks = true.obs;
RxBool loadBalance = true.obs;
RxBool isSplit = false.obs;
RxBool isLend = false.obs;

final GlobalKey targetKey = GlobalKey();
RxString selectedButton2 = 'Month'.obs;
RxString selectedButton = 'Month'.obs; // Default view is "Month"

int selectedDay = 1;
int year = DateTime.now().year; // Current year
Map<int, List<double>> creditedData = {};
Map<int, List<double>> debitedData = {};
double totalSpent = 0.0;
RxMap<String, List<double>> transactionChatGraph = new RxMap();

List<String> labels = [];
List<String> labels2 = [];
RxDouble maxYValue = 0.0.obs;
RxList<TransactionModel> hiddentrasactionsHistory = <TransactionModel>[].obs;
// RxList<TransactionModel> topThreeTransactions = <TransactionModel>[].obs;
RxList<TransactionModel> transactionsHistory = <TransactionModel>[].obs;
RxMap lastWeekjson = {}.obs;
RxMap lastmonthjson = {}.obs;
RxList<String> matchedKeywords = <String>[].obs;
RxBool getHiddenHistory = false.obs;
RxBool getTopThreeHistory = false.obs;
RxBool isYearView = false.obs;
RxBool loadChatdataOnChnage = false.obs;
RxBool loadingDelay = false.obs;
RxDouble totalDebitValue = 0.0.obs;
RxDouble totalExpandedValue = 0.0.obs;

RxMap<String, List<double>> transactionChatGraphoverall = new RxMap();
RxDouble maxYValueoverall = 0.0.obs;
RxBool getGraphDataoverall = false.obs;
RxDouble totalDebitValuePercent = 0.0.obs;

final RxList<String> monthLabels = <String>[].obs;
final Rx<Map<String, List<double>>> currentChartData =
    Rx<Map<String, List<double>>>({});
final RxList<String> currentDays = <String>[].obs;
final RxBool isLoading = false.obs;
late FinvuAccountLinkingRequestReference linkingReference;

RxString nextFecthDate = "".obs;
RxString LastFetchDate = "".obs;
RxString fetchCount = "".obs;
RxString BankName = "".obs;
RxString BankUrl = "".obs;
RxString transactionsId = "".obs;

RxBool isFected = false.obs;

RxList chatSplitAccount = [].obs;
RxBool getChatSplit = false.obs;

DateTime startDateCustom = DateTime.now().subtract(const Duration(days: 7));
DateTime endDateCustom = DateTime.now();
List<CardData> allAutoPayData = [];
RxBool isAutoPayFected = false.obs;

RxBool isFinoraVisible = false.obs;
UserActivity? userActivity;
RxMap<String, List<dynamic>> couponRequestMap = <String, List<dynamic>>{}.obs;

TextEditingController minController = TextEditingController();
TextEditingController maxController = TextEditingController();

final TextEditingController startDateController = TextEditingController();
final TextEditingController endDateController = TextEditingController();
RxBool showAmountFilter = false.obs;
RxBool showDateFilter = false.obs;

// ---------------- Toggle functions ----------------
void toggleAmountFilter() => showAmountFilter.value = !showAmountFilter.value;
void toggleDateFilter() {
  showDateFilter.value = !showDateFilter.value;
}

RxDouble originalAmount = 0.0.obs;
RxDouble inflatedYears = 0.0.obs;
RxDouble inflatedFutureValue = 0.0.obs;
final RxList<Map<String, dynamic>> inflationPredictions =
    <Map<String, dynamic>>[].obs;
var showResults = false.obs;
RxBool isLoadingInflation = false.obs;
RxString changeAvater = ControllerManagement.userController.avatar.value.obs;
final RxList<Map<String, dynamic>> yearlyMonths = <Map<String, dynamic>>[].obs;
