import 'dart:async';
import 'dart:io';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

bool flag = true;
String portNo = flag ? "192.168.1.9" : "localhost";
String urlWithLocallHost = !flag ? "https://stakeplot.in/" : "http://${portNo}:5000/";
String url = "${urlWithLocallHost}api/v1";

String valid = "Please Enter All Feilds";
RxString expenses = "Loading....".obs;
RxString aboutUS = "".obs;

RxString avatar = "assets/avatar/menp1.svg".obs;
RxString avatarUser = "assets/avatar/menp1.svg".obs;

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
RxString range = ''.obs;
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
RxMap friendsListDetails = {}.obs;
RxMap chatOfUserList = {}.obs;
RxMap chatOfUserListData = {}.obs;

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
String userAvatar = "assets/images2/user.svg";
RxString userAvatarProfile = "assets/images2/user.svg".obs;
RxString userName = "Loading...".obs;
RxString dob = "Loading...".obs;
RxString currentId = "Loading...".obs;
RxString Phone = "Loading...".obs;
RxString currency = "Loading...".obs;
RxString score = "0".obs;
RxString email = "Loading...".obs;
String userId = "";
RxString splitID = "".obs;
RxString openTrasactions = "Bills".obs;
RxString targetString = "".obs;
RxString cupertinoPin = "".obs;
RxList categoriesList = [].obs;
Map<String, dynamic> loginUsersList = Map<String, dynamic>();
RxList dueAmountRemainders = [].obs;
RxBool getdueUsers = false.obs;
 RxInt selectedYear = DateTime.now().year.obs;
 RxInt selectedMonth = DateTime.now().month.obs;
RxList inSights = [].obs;
RxBool getInsights = false.obs;
RxString accountId = "".obs;
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
RxBool isLoadingMore = false.obs;
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
List room = [];
List<String> account = [];

RxBool postInter = false.obs;
RxBool postDis = false.obs;
RxBool posting=false.obs;
RxBool getPosted=false.obs;
RxBool acceptReset = false.obs;
RxList budgetList = [].obs;
RxList debtsList = [].obs;
RxList historyListData = [].obs;
RxList getTrendingData = [].obs;
RxBool hasGetNewNotifications = false.obs;
RxBool getGraphData=false.obs;
RxBool loadBanks=true.obs;
RxBool isSplit = false.obs;
  RxBool isLend = false.obs;
final ScrollController scrollController = ScrollController();
final GlobalKey targetKey = GlobalKey(); // Key to identify the target widget


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
    RxDouble maxYValue = 0.0.obs;
RxList hiddentrasactionsHistory = [].obs;
RxBool getHiddenHistory = false.obs;
RxBool isYearView = false.obs;
RxBool loadChatdataOnChnage = false.obs;
RxList  transactionsHistory = <dynamic>[].obs;
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

void snackBarCalled(context, String text, [Color colors = Colors.black]) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: Duration(seconds: 4),
    content: Text(
      text,
      style: FontManager()
          .getTextStyle(context, color: Colors.white, fontSize: 15),
    ),
    backgroundColor: colors,
  ));
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
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: Duration(seconds: 2),
    content: Text(
      "Please Enter All Feilds...",
      style: FontManager()
          .getTextStyle(context, color: Colors.white, fontSize: 15),
    ),
    backgroundColor: colors,
  ));
}

void snackBarAllFeilds2(context, text, [Color colors = Colors.red]) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: Duration(seconds: 2),
    content: Text(
      text,
      style:
          FontManager().getTextStyle(context, color: Colors.red, fontSize: 15),
    ),
    backgroundColor: colors,
  ));
}

List getSearchData(String val, List data) {
  List findOne = [];
  data.forEach((element) {
    if (element['name'].toString().contains(val)) {
      findOne.add(element);
    }
  });
  return findOne;
}

RxList getSearchDataRx(String val, List data) {
  RxList findOne = [].obs;
  data.forEach((element) {
    if (element['name'].toString().contains(val)) {
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
