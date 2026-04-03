import 'dart:convert';
import 'package:finvu_flutter_sdk/finvu_config.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/repository/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchTransaction.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/discoverAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/mobileNumber.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import '../Utils/finspaceStrings.dart';
import '../controllers/fipmetrics-controller.dart';
import '../loginservices/login.dart';
import '../routes/route_finvu.dart';
import '../backed_connections/googlesignin/credentials.dart';
import 'package:get/get.dart';

void initFinvuManager(BuildContext context) async {
  String url = !FinspaceStrings().liveIntegration
      ? Credentials.Live_finvu_api
      : Credentials.Dev_finvu_api;
  finvuManager.initialize(
    FinvuConfig(
      finvuEndpoint: url,
      certificatePins: [],
    ),
  );
  await finvuManager.connect();
  var isConnected = await finvuManager.isConnected();
  if (!isConnected) {
    isConnected = await finvuManager.isConnected();
  }
}

Future<String> login(context) async {
  try {
    otpReference = "";
    var login =await finvuManager.loginWithUsernameOrMobileNumberAndConsentHandle(
      '${number.value}@finvu',
      '${number.value}',
      handleId.value,
    );
    otpReference = login.reference;
  } catch (e) {
    snackBarCalledfail(context, e.toString());
  }
  return otpReference;
}

Future<void> getConsentHandleId(context) async {
  final String apiUrl = FinvuRoutes.login;
  final String custId = "${number.value}@finvu";
  var body = {"custId": custId, 'number': number.value};
  try {
    var response = await postDataApiCall(apiUrl, body);
    if (getFlagOfResponse(response)) {
      final data = jsonDecode(response.body);
      String consentHandleId = data["consentHandleId"];
      handleId.value = consentHandleId;
      if (!Get.isRegistered<FipMetricsController>()) {
        Get.put(FipMetricsController());
      }
      FipMetricsController.to.loadFromResponse(data);
    }
  } catch (error) {
    snackBarCalledfail(context, error.toString());
  }
}

Future<void> FetchTransactionFromFinvuApi(BuildContext context) async {
  try {
    final String apiUrl = FinvuRoutes.fetchData;
    final String custId = "${number.value}@finvu";

    //  flagToFetchData.value=false;
    clearStackShared(context);
    Navigator.pushNamed(context, "/OnboardingScreen");

    final response = await postDataApiCall(apiUrl, {
      "token": "",
      "handleId": handleId.value,
      "custId": custId,
      // "images": bankImgMap,
    });

    if (response.statusCode == 200) {
      logoutAndDisconnect();
    } else {
      sessionId.value = true;
    }
  } catch (e) {}
}

//don't delete this function, it is used to store the map of images in the backend
void storeMapOfImagesInBackend() async {
  //  var urlPathw = url +"/transaction/storeBankUrl/" ;
  //  var urlPath = TransactionRoutes.storeBankUrl ;
  //  var body = bankImageAndid ;

  //  var response =await postDataApiCall(urlPath, body);
  //  if(getFlagOfResponse(response))
  //  {
  //     var json=jsonDecode(response.body);
  //  }
}

void getLinkedAccountInfo() async {
  fipDis = await finvuManager.fipsAllFIPOptions();
  List<FinvuLinkedAccountDetailsInfo> data =
      await finvuManager.fetchLinkedAccounts();
  listofLinkedAccount.clear();
  if (data.isNotEmpty) {
    data.forEach((finvu) {
      listofLinkedAccount.add(finvu.accountReferenceNumber.toString());
    });
  }
  fipDisOrginal.clear();
  fipDisOrginal.addAll(fipDis);
  getBanks.value = !getBanks.value;
}

void logoutAndDisconnect() async {
  try {
    clearLocalData();
    await finvuManager.logout();
    finvuManager.disconnect();
  } catch (e) {}
}

void clearLocalData() async {
  listOfAccountAdded.clear();
  FinvuFIPDetailsList.clear();
  accountCountList.clear();
  accountAdded.clear();
  accountLinked.clear();
  fipDis.clear();
  fipDisOrginal.clear();
  accountLinked.clear();
  isSeletedBankAccout.clear();
  bankImageAndid.clear();
  listOfBankAccount.clear();
  fetchAccountData.clear();
  fetchedTrsacntionList.clear();
  count.value = 0;
  addBank.value = false;
  getBanks.value = false;
  getFetch.value = false;
  number.value = "";
  consentUserId.value = "";
  handleId.value = "";
}

Future<bool> verify(String otp, BuildContext context) async {
  try {
    await finvuManager.verifyLoginOtp(
      otp,
      otpReference,
    );

    clearStackLocalInfo();
    getLinkedAccountInfo();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DiscoverAccount(),
      ),
    );

    return true; // Return true if verification succeeds
  } catch (e) {
    isOtpWrong.value = true;
    return false; // Return false if verification fails
  }
}
