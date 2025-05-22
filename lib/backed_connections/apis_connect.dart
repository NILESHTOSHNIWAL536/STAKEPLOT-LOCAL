import 'dart:io';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Debts/CreateDebtScreen.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:get/get.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

bool flag = true;
String portNo = flag ? "192.168.1.8" : "localhost";
String urlWithLocallHost = !flag ? "https://stakeplot.in/" : "http://${portNo}:5000/";
String url = "${urlWithLocallHost}api/v1";
String valid = "Please Enter All Fields";
RxString expenses = "Loading".obs;
RxString aboutUS = "".obs;
RxString avatar = "assets/avatar/FRAME-2.svg".obs;
RxString avatarUser = "assets/avatar/menp1.svg".obs;
RxMap deviceData={}.obs;
RxList frdsList = [].obs;
RxList frdsListOrigin = [].obs;
RxBool isBankAccountLink = false.obs;
RxInt income = 0.obs;
double maxDC = 0;
double minDC = 0;
RxList notificationList = [].obs;
RxList<String> listofLinkedAccount = <String>[].obs;
RxList trasactionsData = [].obs;
RxList listOfRecentTrasactionsData = [].obs;
RxList trasactionsHideData = [].obs;
RxList trasactionsHistory = [].obs;
RxBool getHistory = false.obs;
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
RxList savedList = [].obs;
RxList myPostList = [].obs;
RxList friendsList = [].obs;
RxList chatList = [].obs;
RxList chatListOriginal = [].obs;
RxList customCategoryList = [].obs;
RxMap friendsListDetails = {}.obs;
RxMap chatOfUserList = {}.obs;
RxMap chatOfUserListData = {}.obs;
List<Map<String, dynamic>> custom=[];

RxBool aboutMe = false.obs;
RxBool myNotificationBool = false.obs;
RxBool clickedLinkedBackAccount = false.obs;
RxBool setBankAccountPassword = false.obs;
RxBool hideBackAccountPassword = false.obs;
var coin = "Loading....";

bool sizeRoom = false;
double fontSize = 20;
RxInt budgetLength = 0.obs;
RxInt billLength = 0.obs;
RxInt debtLength = 0.obs;
RxInt paymentLength = 0.obs;
String userAvatar = "assets/avatars/a.svg";
RxString userAvatarProfile = "assets/images2/user.svg".obs;
RxString userAvatarBackGround = "#FA7070".obs;
RxString userName = "".obs;
RxString dob = "".obs;
RxString currentId = "".obs;
RxString Phone = "".obs;
RxString currency = "".obs;
RxString score = "0".obs;
RxString email = "Loading...".obs;
String userId = "";
RxString splitID = "".obs;
RxString openTrasactions = "Bills".obs;
RxString targetString = "".obs;
RxString cupertinoPin = "".obs;
RxList categoriesList = [].obs;
RxList moreDrasticChange  = [].obs;
RxList  frequentPayments = [].obs;
RxDouble totalDebitThisMonth  = 0.0.obs; 
RxDouble totalDebitThisWeek  = 0.0.obs; 
RxList categoriesListWeek = [].obs;
RxList moreDrasticChangeWeek  = [].obs;
RxList  frequentPaymentsWeek = [].obs;
Map<String, dynamic> loginUsersList = Map<String, dynamic>();
RxList dueAmountRemainders = [].obs;
RxBool getdueUsers = false.obs;
 RxInt selectedYear = DateTime.now().year.obs;
 RxInt selectedMonth = DateTime.now().month.obs;
RxList inSights = [].obs;
RxBool getInsights = false.obs;
RxBool allOrGroupTransactions = true.obs;
RxString accountId = "".obs;
RxString searchAccountId = "".obs;
RxString accountIdPdf = "".obs;
RxString allOrGroupTransactionsName = "All".obs;
RxList totalInSights = [].obs;
RxBool getTotalInsightsHistory = false.obs;
RxList foodieFundsDetailsRemainders = [].obs;
RxBool getFoodieFundsUsers = false.obs;
late BuildContext contextGlobal;
List<String> month = [
  "",
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];
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
RxList likedList = [].obs;
RxList likedCommentList = [].obs;
RxList likedProducts = [].obs;
RxMap<String, int> postCount = <String, int>{}.obs;
RxMap<String, int> postCommentCount = <String, int>{}.obs;
RxMap<String, int> supportCount = <String, int>{}.obs;
RxMap<String, bool> postData = <String, bool>{}.obs;

List room = [];
List<String> account = [];

RxBool postInter = false.obs;
RxBool postDis = false.obs;
RxBool posting=false.obs;
RxBool getPosted=false.obs;
RxBool acceptReset = false.obs;
RxBool LoadTag = false.obs;
RxList budgetList = [].obs;
final RxList<Debt> debts = <Debt>[].obs;
RxList debtsList = [].obs;
RxList historyListData = [].obs;
RxList getTrendingData = [].obs;
RxBool hasGetNewNotifications = false.obs;
RxBool getGraphData=false.obs;
RxBool loadBanks=true.obs;
RxBool isSplit = false.obs;
  RxBool isLend = false.obs;
  RxBool stopTonavigate = true.obs;
// final ScrollController scrollController = ScrollController();
final GlobalKey targetKey = GlobalKey(); // Key to identify the target widget


RxString selectedButton2 = 'Month'.obs; 
 RxString selectedButton = 'Month'.obs; // Default view is "Month"
  DateTimeRange? selectedDateRange; // Default view is "Month"
  int selectedDay = 1;
  int year = DateTime.now().year; // Current year
  // int month =DateTime.now().month; // Default selected day for "Month" button (Day 1)
  Map<int, List<double>> creditedData = {};
  Map<int, List<double>> debitedData = {};
 double totalSpent=0.0;
   RxMap<String, List<double>> transactionChatGraph=new RxMap();
   RxBool graphTransaction=false.obs;
     List<String> labels=[];
     List<String> labels2=[];
    RxDouble maxYValue = 0.0.obs;
RxList hiddentrasactionsHistory = [].obs;
RxBool getHiddenHistory = false.obs;
RxBool isYearView = false.obs;
RxBool loadChatdataOnChnage = false.obs;
RxList  transactionsHistory = <dynamic>[].obs;
RxBool  loadingDelay = false.obs;
RxDouble totalDebitValue = 0.0.obs;
RxDouble totalExpandedValue = 0.0.obs;
List<double> trasactionsDataDebitWeeklyoverall = [];
RxMap<String, List<double>> transactionChatGraphoverall=new RxMap();
RxDouble maxYValueoverall = 0.0.obs;
RxBool getGraphDataoverall=false.obs;
RxDouble totalDebitValuePercent = 0.0.obs;
RxList historyExploriaListData = [].obs;
RxList getExploriaTrendingData = [].obs;
RxMap<String, int> postExploriaCount = <String, int>{}.obs;
RxMap<String, int> postExploriaCommentCount = <String, int>{}.obs;
RxMap<String, int> supportExploriaCount = <String, int>{}.obs;

  final RxList<String> monthLabels = <String>[].obs;
  final Rx<Map<String, List<double>>> currentChartData = Rx<Map<String, List<double>>>({});
  final RxList<String> currentDays = <String>[].obs;
  // final RxBool isYearView = false.obs;
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
RxBool getChatSplit= false.obs;
List avatarBackGroundList = ["#FA7070", "#FFB07A", "#4C8BF5", "#68B2A0"];

DateTime startDateCustom=DateTime.now().subtract(const Duration(days: 7));
DateTime endDateCustom =  DateTime.now();
class Message {
  Message(
      {this.text,
      required this.isMe,
      this.url,
      
      required this.type,
      this.question,
      this.image = "",
      this.poll = "",
      this.post = "",
      this.split = ""});

  String image;
  final bool isMe;
  var poll;
  var post;
  var question;
  var split;
  String? text;
  String type; //["image","text","Poll",'post']
  File? url;
}

String currentPage2(context) {
  String modalRoute = ModalRoute.of(context)?.settings.name ?? '';
  return modalRoute;
}

String toUpperCase(String str) {
  if (str.isEmpty) return str;
  return str[0].toUpperCase() + str.substring(1);
}

void printData(response, [context = ""]) {
  print("response");
  print(response);
  print(response.statusCode);
  print(response.body);
}

void snackBarCalled(BuildContext context, String text, [Color colors = const Color(0xFF43A047)]) {
 
 try{
  showTopSnackBar(
    Overlay.of(context),
    Container(
      height: 40,
      child: CustomSnackBar.success(
        message: text,
        backgroundColor: AppColors.primaryColor,
        textStyle: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
      ),
    ),
    displayDuration: const Duration(seconds: 2),
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInBack,
    animationDuration: const Duration(milliseconds: 600),
  );
 }catch(e){
    print("error in snackbar "+e.toString());
 }


}
void snackBarCalledfail(context, String text, [Color colors = Colors.black]) {
  showTopSnackBar(
    Overlay.of(context),
    Container(
      height: 40,
      child: CustomSnackBar.success(
        message: text,
        backgroundColor: Colors.red,
        textStyle: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
      ),
    ),
    displayDuration: const Duration(seconds: 2),
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInBack,
    animationDuration: const Duration(milliseconds: 600),
  );


}

void snackBarCalledSignup(context, String text, [Color colors = Colors.black]) {
  showTopSnackBar(
    Overlay.of(context),
    Container(
      height: 40,
      child: CustomSnackBar.success(
        message: text,
        backgroundColor: Colors.green.shade600,
        textStyle: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
      ),
    ),
    displayDuration: const Duration(seconds: 2),
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInBack,
    animationDuration: const Duration(milliseconds: 600),
  );
}

void snackBarCalledFrds(context, String text, [Color colors = Colors.black]) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: Duration(seconds: 2),
    action: SnackBarAction(
      label: 'Click Here',
      onPressed: () {
        //        Navigator.push(
        //   context,
        //   PageTransition(
        //     type: PageTransitionType.fade,
        //     alignment: Alignment.bottomRight,
        //      duration: Durations.long1,
        //     child: TribeSearch(),
        //     isIos: true,
        //   ),
        // );
      },
    ),
    content: Row(
      children: [
        Text(
          text,
          style: FontManager()
              .getTextStyle(context, color: Colors.white, fontSize: 13),
        ),
      ],
    ),
    backgroundColor: colors,
  ));
}

void snackBarAllFeilds(context, [Color colors = Colors.red]) {
  showTopSnackBar(
    Overlay.of(context),
    Container(
      height: 40,
      child: CustomSnackBar.success(
        message: "Enter all fields",
        backgroundColor: Colors.red,
        textStyle: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
      ),
    ),
    displayDuration: const Duration(seconds: 2),
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInBack,
    animationDuration: const Duration(milliseconds: 600),
  );
}

void snackBarAllFeilds2(context, text, [Color colors = Colors.red]) {
  showTopSnackBar(
    Overlay.of(context),
    Container(
      height: 40,
      child: CustomSnackBar.success(
        message: text,
        backgroundColor: Colors.red,
        textStyle: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
      ),
    ),
    displayDuration: const Duration(seconds: 2),
    curve: Curves.easeOutBack,
    reverseCurve: Curves.easeInBack,
    animationDuration: const Duration(milliseconds: 600),
  );
}

List getSearchData(String val, List data) {
  List findOne = [];
  data.forEach((element) {
    if (element['name'].toString().toLowerCase().contains(val.toLowerCase())) {
      findOne.add(element);
    }
  });
  return findOne;
}

RxList getSearchDataRx(String val, List data) {
  RxList findOne = [].obs;
  data.forEach((element) {
    if (element['name'].toString().toLowerCase().contains(val.toLowerCase())) {
      findOne.add(element);
    }
  });
  return findOne;
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
}
