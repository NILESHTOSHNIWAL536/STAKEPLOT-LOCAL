import 'dart:convert';

import 'package:finvu_flutter_sdk/finvu_config.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Community_Page/postLoad.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/insightsController.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/FriendsUi.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/integration.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:flutter_application_code_stakeplot/signInOut/avatar.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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


void expire(responce, BuildContext context) {
  try {
    var body = json.decode(responce.body);
    if (body['error'].toString() == "JsonWebTokenError") {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
      Navigator.pushReplacementNamed(context, '/');
    }
  } catch (e) {}
}

Future<bool> check(context, String flag) async
{
     final SharedPreferences _pref = await SharedPreferences.getInstance();
     bool f=_pref.containsKey("accessToken");
    //  if (!f && flag != "loginuser") Navigator.pushReplacementNamed(context, '/');
    if(!f && flag != "loginuser"){
         Navigator.pushReplacementNamed(context, '/');
         return false;
    }

    if(flag=="loginuser")
    {
         return false;
    }

    
    return true;
}


Future<void> storeDeviceInfo()async
{
    var json = await getUserStats();
    var responce=await postDataApiCall("${url}/deviceScreenTime/", json);
    if(getFlagOfResponse(responce))
    {
        printData(responce);
    }
}


void clearGetX(){
   income = 0.obs;
  messages.clear();
  messagesTemp.clear();
  roomBills.clear();
  questionRoom.clear();
  productList.clear();
  userPostList.clear();
  savedList.clear();
  myPostList.clear();
  friendsList.clear();
  frdsListOrigin.clear();
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
  userName = "Loading...".obs;
  currentId = "Loading...".obs;
  Phone = "Loading...".obs;
  currency = "Loading...".obs;
  score = "Loading...".obs;
  email = "Loading...".obs;
  changeAvater = "Loading...".obs;
  userId = "";
  targetString = "".obs;
  //  listOfCater =<Plot> [].obs;
  isBankAccountLink.value = true;
  trasactionsData.clear();
  addedMembers.clear();
  addedUser.clear();
  isBankAccountLink.value = false;
  cupertinoPin.value = '0';
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
  displayedData.clear();
  bankAccountLinkedList.clear();
  FipIdsConnected.clear();
  transactionsHistory.clear();
  isLoadingMore.value=false;
  isFected.value=false;
}

RxMap<String,String> ListOfBankImages=RxMap();

void initialMap(context)async
{
  
  // var isConnected = await finvuManager.isConnected();
  // print("isConnected");
  // if (!isConnected) {return;}
  // print(isConnected);

  
  // try{
  // List<FinvuFIPInfo>  fipDis = await finvuManager.fipsAllFIPOptions();

  // fipDis.forEach((FinvuFIPInfo bankData){
  //       ListOfBankImages[bankData.productName.toString()]=bankData.productIconUri.toString();
  // });
  // }catch(e)
  // {
  //    print(e);    
  // }

  // print("ListOfBankImages");
  // print(ListOfBankImages);

}