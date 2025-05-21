import 'dart:convert';
import 'package:finvu_flutter_sdk/finvu_config.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchTransaction.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/discoverAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/mobileNumber.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void initFinvuManager(BuildContext context) async {
  finvuManager.initialize(
    FinvuConfig(
           finvuEndpoint: 'wss://wsslive.finvu.in/consentapi',
       //finvuEndpoint: 'wss://webvwdev.finvu.in/consentapi',
      certificatePins: 
      [
            //  "R6wXZnQsKKyg56qFKQNytvygyr/o4Mkq1VXL5LenBYI=",
            //  "bdrBhpj38ffhxpubzkINl0rG+UyossdhcBYj+Zx2fcc="
      ],
    ),
  );

  await finvuManager.connect();
  var isConnected = await finvuManager.isConnected();
  if (!isConnected) {
    isConnected = await finvuManager.isConnected();
  }
  
}


Future<String> login(context) async {
  try{
  otpReference="";
  var login = await finvuManager.loginWithUsernameOrMobileNumberAndConsentHandle(
    '${number.value}@finvu',
    '${number.value}',
    handleId.value,
  );
  otpReference = login.reference;

  }catch(e){
      print(e);
      snackBarCalled(context, e.toString());
  }
  return otpReference;
}


Future<void> getConsentHandleId(context) async 
{

  final String apiUrl ="${url}/finvu/login"; 
  final String custId ="${number.value}@finvu"; 
  var body={"custId": custId,'number':number.value};

  try {
            var response=await postDataApiCall(apiUrl, body);
            if (getFlagOfResponse(response))
            {
              final data = jsonDecode(response.body);
              String consentHandleId = data["consentHandleId"];
              handleId.value=consentHandleId;
            } 
  } catch (error){
      print(error);
      snackBarCalled(context, error.toString());
  }
}

Future<void> FetchTransactionFromFinvuApi(BuildContext context) async {
 try {

    final String apiUrl ="${url}/finvu/fetchData"; 
    final String custId ="${number.value}@finvu"; 

    // print({
    //     "token": "",
    //     "handleId": handleId.value,
    //     "custId": custId,
    //     "images": bankImgMap,
    //   });

   final SharedPreferences pref = await SharedPreferences.getInstance();
   String accessToken=pref.getString("accessToken").toString(); 
  //  flagToFetchData.value=false;
   clearStackShared(context);
   Navigator.pushNamed(context, "/OnboardingScreen"); 

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json", "Authorization": "$accessToken",},
      body: jsonEncode({
        "token": "",
        "handleId": handleId.value,
        "custId": custId,
        // "images": bankImgMap,
      }),
    );

    if (response.statusCode == 200) 
    {
       final data = json.decode(response.body);
       logoutAndDisconnect();
    } else {
    
      sessionId.value=true;
     
    }
  }catch(e){
      print("error in FetchTransactionFromFinvuApi");
  }

 

}



 void storeMapOfImagesInBackend() async
 {
    //  var urlPath = url +"/transaction/storeBankUrl/" ;
    //  var body = bankImageAndid ;
    //  print(body);
    //  var response =await postDataApiCall(urlPath, body);
    //  if(getFlagOfResponse(response))
    //  {
    //     var json=jsonDecode(response.body);
    //     print(json);
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


  void logoutAndDisconnect() async
  {
       try{
           clearLocalData();
           await finvuManager.logout();
           finvuManager.disconnect();
       }catch(e){
          print("error in logoutAndDisconnect");
          print(e);
       }
  }

  void  clearLocalData() async
 {
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
 count.value=0;
 addBank.value = false;
 getBanks.value=false;
 getFetch.value =false;
 number.value="";
 consentUserId.value="";
 handleId.value="";
   debugPrint('getConsentHandleStatus');
}



Future<bool> verify(String otp, BuildContext context) async {
  try {
    var login = await finvuManager.verifyLoginOtp(
      otp,
      otpReference,
    );

    clearStackLocalInfo();
    getLinkedAccountInfo();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DiscoverAccount(
        ),
      ),
    );

    return true; // Return true if verification succeeds
  } catch (e) {
   isOtpWrong.value = true;
    return false; // Return false if verification fails
  }
}