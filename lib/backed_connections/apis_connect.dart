import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Utils/shakewidget.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/controllers/post-controller.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter_application_code_stakeplot/model/autopay_model.dart';
import 'package:flutter_application_code_stakeplot/model/user_activity_model.dart';
import 'package:get/get.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import '../controllers/controllerManagement.dart';
import 'googlesignin/credentials.dart';
part '../Constants/snackBars.dart';

// bool apis_flag = true;
// String urlWithLocallHost = apis_flag ? Credentials.LIVE_API:Credentials.LIVE_API_TEST; // main backend api
// String urlWithLocallHost2 = apis_flag ? Credentials.LIVE_API2:Credentials.LIVE_API_TEST2; // email sync api
// String urlWithLocallHost3 = apis_flag ? Credentials.FINVU_LIVE:Credentials.FINVU_TEST; // bank api
// String url = "${urlWithLocallHost}api/v1";
// String EmailUrl = "${urlWithLocallHost2}api";
// String BankApiUrl = "${urlWithLocallHost3}api";

UserController get userController => Get.find<UserController>();
PostController get postController => Get.find<PostController>();
RxMap deviceData = {}.obs;
RxBool isBankAccountLink = false.obs;
RxInt scrollBankPage = 0.obs;
double maxDC = 0;
double minDC = 0;
RxList notificationList = [].obs;
RxList<String> listofLinkedAccount = <String>[].obs;
RxList trasactionsData = [].obs;
// RxList finoraTransactionData = [].obs;
RxList autoPayData = [].obs;
RxList listOfRecentTrasactionsData = [].obs;
RxList trasactionsHideData = [].obs;
RxList trasactionsHistory = [].obs;
RxBool getHistory = false.obs;
RxBool getAutopays = false.obs;
RxList lendAmountRemainders = [].obs;
RxBool getlendUsers = false.obs;
List<double> trasactionsDataMonthlyCredit = [];
List<double> trasactionsDataMonthlyDebit = [];
List<double> trasactionsDataCustomCredit = [];
List<double> trasactionsDataCustomDebit = [];
List<String> trasactionsDataCustomLabel = [];
RxBool flagTrasaction = false.obs;
RxBool isFromEditDeatils = false.obs;
RxString range = ''.obs;
RxString filterText = ''.obs;
RxString defaultBackGround = "#68B2A0".obs;
List<double> trasactionsDataCreditWeekly = [];
List<double> trasactionsDataDebitWeekly = [];
RxList trasactionsDataWeekly = [].obs;
RxList friendRequestList = [].obs;
RxList messages = [].obs;
RxList messagesTemp = [].obs;
RxList roomBills = [].obs;
RxList questionRoom = [].obs;
RxList productList = [].obs;
RxList userPostList = [].obs;
RxList chatList = [].obs;
RxList chatListOriginal = [].obs;
RxList chatListMasked = [].obs;
RxList chatListOriginalMasked = [].obs;
RxList customCategoryList = [].obs;
RxList customCategoryUnUsedList = [].obs;
RxMap friendsListDetails = {}.obs;
RxMap chatOfUserList = {}.obs;
RxMap chatOfUserListData = {}.obs;
List<Map<String, dynamic>> custom = [];
RxBool hideTransactionReload = false.obs;
RxBool aboutMe = false.obs;
RxBool myNotificationBool = false.obs;
RxBool clickedLinkedBackAccount = false.obs;
RxBool setBankAccountPassword = false.obs;
RxBool hideBackAccountPassword = false.obs;
bool sizeRoom = false;
double fontSize = 20;
RxInt budgetLength = 0.obs;
RxInt billLength = 0.obs;
RxInt debtLength = 0.obs;
RxInt paymentLength = 0.obs;
RxString splitID = "".obs;
RxString openTrasactions = "Bills".obs;
RxString targetString = "".obs;
RxList categoriesList = [].obs;
RxList moreDrasticChange = [].obs;
RxList frequentPayments = [].obs;
RxDouble totalDebitThisMonth = 0.0.obs;
RxDouble totalDebitThisWeek = 0.0.obs;
RxList categoriesListWeek = [].obs;
RxList moreDrasticChangeWeek = [].obs;
RxList frequentPaymentsWeek = [].obs;
Map<String, dynamic> loginUsersList = Map<String, dynamic>();
RxList dueAmountRemainders = [].obs;
RxBool getdueUsers = false.obs;
RxBool canMessageUser = false.obs;
RxInt selectedYear = DateTime.now().year.obs;
RxInt selectedMonth = DateTime.now().month.obs;
RxList inSights = [].obs;
RxBool getInsights = false.obs;
RxBool getCreditCardBudgetDebts = false.obs;
RxBool allOrGroupTransactions = true.obs;
RxString accountId = "".obs;
RxString searchAccountId = "".obs;
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
RxBool loadMoreData = false.obs;
bool hasMoreData = true;
int m = DateTime.now().month;
List targetsData = [];
List arr = [];
List scrollAbleList = [].obs;
List scrollAbleListALl = [].obs;
RxBool bol = false.obs;
String tabAmount = "";
RxInt listIndex = 0.obs;
RxBool reRender = false.obs;
RxBool reGraph = false.obs;
RxBool setDonectChat = false.obs;
List room = [];
List<String> account = [];
RxBool acceptReset = false.obs;
RxBool LoadTag = false.obs;
RxList budgetList = [].obs;
final RxList<Debt> debts = <Debt>[].obs;
RxList debtsList = [].obs;
RxList historyListData = [].obs;
RxBool hasGetNewNotifications = false.obs;
RxBool getGraphData = false.obs;
RxBool loadBanks = true.obs;
RxBool loadBalance = true.obs;
RxBool isSplit = false.obs;
RxBool isLend = false.obs;
RxBool stopTonavigate = true.obs;
final GlobalKey targetKey = GlobalKey();
RxString selectedButton2 = 'Month'.obs;
RxString selectedButton = 'Month'.obs; // Default view is "Month"
DateTimeRange? selectedDateRange; // Default view is "Month"
int selectedDay = 1;
int year = DateTime.now().year; // Current year
Map<int, List<double>> creditedData = {};
Map<int, List<double>> debitedData = {};
double totalSpent = 0.0;
RxMap<String, List<double>> transactionChatGraph = new RxMap();
RxBool graphTransaction = false.obs;
List<String> labels = [];
List<String> labels2 = [];
RxDouble maxYValue = 0.0.obs;
RxList<TransactionModel> hiddentrasactionsHistory = <TransactionModel>[].obs;
RxList<TransactionModel> topThreeTransactions = <TransactionModel>[].obs;
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
List<double> trasactionsDataDebitWeeklyoverall = [];
RxMap<String, List<double>> transactionChatGraphoverall = new RxMap();
RxDouble maxYValueoverall = 0.0.obs;
RxBool getGraphDataoverall = false.obs;
RxDouble totalDebitValuePercent = 0.0.obs;

final RxList<String> monthLabels = <String>[].obs;
final Rx<Map<String, List<double>>> currentChartData = Rx<Map<String, List<double>>>({});
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
RxInt transactionsLength = 0.obs;
RxList chatSplitAccount = [].obs;
RxBool getChatSplit = false.obs;

DateTime startDateCustom = DateTime.now().subtract(const Duration(days: 7));
DateTime endDateCustom = DateTime.now();
List<CardData> allAutoPayData = [];
RxBool isAutoPayFected = false.obs;
RxBool isFectedDonetChat = false.obs;
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
final RxList<Map<String, dynamic>> inflationPredictions = <Map<String, dynamic>>[].obs;
var showResults = false.obs;
RxBool isLoadingInflation = false.obs;
RxString changeAvater = ControllerManagement.userController.avatar.value.obs;



  List<FlSpot> budgetLineSpots = [];
   Map<String, double> spendingCategories = {};
   List categoryGraphObjects = [];
   List<BudgetChartDataPoint> budgetChartData = [];
   String selectedBudgetPeriod = 'monthly';
   List<dynamic> budgetTransactions = []; // Store raw transactions from API
   Map<String, dynamic>? currentBudgetInfo;
   List<String>? budgetInsights;
   List<Map<String, dynamic>> categorySpendings = [];
   List<Map<String, dynamic>> pieGraphData = [];
   bool isBudgetDeleting = false;

  /// Renamed from _ChartData to BudgetChartDataPoint and made it a static inner class
   class BudgetChartDataPoint {
    BudgetChartDataPoint({required this.x, required this.y, required this.xString});
    final int x;
    final double y;
    final String xString;

    @override
    String toString() => '($x, $y, $xString)';
  }