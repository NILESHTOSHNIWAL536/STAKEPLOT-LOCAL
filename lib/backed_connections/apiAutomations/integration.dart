import 'dart:convert';
import 'package:finvu_flutter_sdk/finvu_config.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchTransaction.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/discoverAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/linkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/mobileNumber.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// List listOfTransactions=[];


void initFinvuManager(BuildContext context) async {
  finvuManager.initialize(
    FinvuConfig(
        finvuEndpoint: 'wss://wsslive.finvu.in/consentapi',
     // finvuEndpoint: 'wss://webvwdev.finvu.in/consentapi',
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


Future<void> login(consenthandleId,context) async {
  try{
  var login = await finvuManager.loginWithUsernameOrMobileNumberAndConsentHandle(
    '${number.value}@finvu',
    '${number.value}',
    consenthandleId,
  );
  otpReference = login.reference;
  debugPrint('LoggedIn');
  }catch(e){
    print(e);
      snackBarCalled(context, e.toString());
  }
}


void getConsentHandleId(context) async 
{

  final String apiUrl ="${url}/finvu/login"; // Change to your actual server URL
  final String custId ="${number.value}@finvu"; // Replace with dynamic value if needed
     
   final SharedPreferences _pref = await SharedPreferences.getInstance();
   var accessToken = _pref.getString("accessToken");

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "$accessToken",
      },
      body: jsonEncode({"custId": custId,'number':number.value}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String consentHandleId = data["consentHandleId"];
      handleId.value=consentHandleId;
      login(consentHandleId,context);
    } 
  } catch (error) {
       snackBarCalled(context, error.toString());
  }
}

Future<void> FetchTransactionFromFinvuApi(BuildContext context) async {
 try {
    final String apiUrl ="${url}/finvu/fetchData"; 
    final String custId ="${number.value}@finvu"; 
  

   final SharedPreferences pref = await SharedPreferences.getInstance();
   String accessToken=pref.getString("accessToken").toString(); 

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json", "Authorization": "$accessToken",},
      body: jsonEncode({
        "token": "",
        "handleId": handleId.value,
        "custId": custId,
      }),
    );

    if (response.statusCode == 200) 
    {
       final data = json.decode(response.body);
       logoutAndDisconnect();
    } else {
    
      sessionId.value=true;
     
    }
  } catch (e) {
  
  }

   clearStackShared(context);
   Navigator.pushNamed(context, "/OnboardingScreen"); 

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
          LOGOUT();
          finvuManager.disconnect();
       }catch(e){
          print(e);
       }
  }



  void  LOGOUT() async
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

              try{
                await finvuManager.logout(); 
              }
              catch(e)
              {
                print(e);
              }
      
    debugPrint('getConsentHandleStatus');
}


// void verify(String otp, context) async {
 
//   try {
   
//     var login = await finvuManager.verifyLoginOtp(
//       otp,
//       otpReference,
//     );
   
  
//     clearStackLocalInfo();
//     getLinkedAccountInfo();

//     Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => DiscoverAccount(),
//         ),
//      );
                  
//   } catch (e) {

//     ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: textStyle(context: context, text: "Invalid OTP..."),
//           duration: Duration(seconds: 2),
//         ),
//       );
//   }
// }
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
        builder: (context) => DiscoverAccount(),
      ),
    );
    return true; // Return true if verification succeeds
  } catch (e) {
   isOtpWrong.value = true;
    return false; // Return false if verification fails
  }
}