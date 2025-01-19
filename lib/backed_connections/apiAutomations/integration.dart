


import 'package:finvu_flutter_sdk/finvu_config.dart';
import 'package:finvu_flutter_sdk_core/finvu_discovered_accounts.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/ApproveConsentRequest.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/FetchData.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/linkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:shared_preferences/shared_preferences.dart';


  void initFinvuManager() async {
     finvuManager.initialize(
        FinvuConfig(
          finvuEndpoint: 'wss://webvwdev.finvu.in/consentapi',
          certificatePins: [],
        ),
    );

    await finvuManager.connect(); 
    var isConnected = await finvuManager.isConnected();
    print(isConnected);
    if (!isConnected) {
        isConnected = await finvuManager.isConnected();
        print(isConnected); 
    }

  }


   void login() async {

    var login = await finvuManager.loginWithUsernameOrMobileNumberAndConsentHandle(
              custId,
              number.value,
              handleId.value,
          );

      
    otpReference = login.reference;
    debugPrint('LoggedIn');
  }



  void fetch(context) async { 

       try{
             final SharedPreferences _pref = await SharedPreferences.getInstance();
             String? token=await _pref.getString("token");
             ConsentStatus(context,token,handleId.value,custId);
       }catch(e){
           print(e);
       }

  }

  void verify(String otp,context) async {

    try{
    var login = await finvuManager.verifyLoginOtp(
      otp,
      otpReference,
    );
     print("verifyLoginOtp");
     print(login.userId);
     final SharedPreferences _pref = await SharedPreferences.getInstance();
          String? token=await _pref.getString("token");

           List<FinvuFIPInfo> data=await finvuManager.fipsAllFIPOptions(); 
           data=[data[0]];
          


          // FinvuFIPInfo  finvuFIPInfo=data.first;

            // data.forEach((e)async{
            //        print("e.fipId");
            //        print(e.productName);
            //        print(e.fipId);
            //        print(e.fipFitypes);

              //  var d=await finvuManager.fetchFIPDetails(e.fipId); 

              //   print(d.fipId);
              //   d.typeIdentifiers.forEach((e){
              //         print("typeIdentifiers-------------------");
              //         print(e.fiType);
              //        e.identifiers.forEach((e){
              //               print("identifiers-------------------");
              //               print(e.category);
              //               print(e.type);    
              //        });
              //   });


                  
            // });

    //  Navigator.pushReplacement(
    //                   context,
    //                   MaterialPageRoute(
    //                     builder: (context) => ApproveConsent(),
    //         ));
    // await approveConsentRequest();
    //  ConsentStatus(context,token,handleId.value,custId);

    }
    catch(e)
    {
        print(e);
    }
  }

  void fetchLinkedAccounts() async {
    try{
    finvuLinkedAccountDetailsInfo =await  finvuManager.fetchLinkedAccounts();
    finvuLinkedAccountDetailsInfo.forEach((e){
          print("---------------------------");
          print(e.userId);
          print(e.consentIdList);
          print(e.fiType);
          print(e.fipName);
          print(e.fipId);
          print(e);
          
    });
    }catch(e){
         print(e);
    }
     
    debugPrint('fetchLinkedAccounts');
  }

  void getConsentHandleStatus() async {
    
    try{
         var d=await finvuManager.getConsentHandleStatus(handleId.value);
         print('getConsentHandleStatus = ');
         print(d.status);
        

    }catch(e){
         print(e);
    }
     
    debugPrint('getConsentHandleStatus');
  }
  void  LOGOUT() async {
    
       final SharedPreferences _pref = await SharedPreferences.getInstance();
    try{

 listOfAccountAdded.clear();

 FinvuFIPDetailsList.clear();
 accountAdded.clear();
 accountLinked.clear();
 accountLinked.clear();
 
        _pref.remove("token");
        _pref.remove("from");
        _pref.remove("to");
        _pref.remove("sessionId");
        _pref.remove("consentId");
        _pref.remove("ConsentHandleId");

        await finvuManager.logout(); 
      
        print("Logout user...");
    }catch(e){
         print(e);
    }
     
    debugPrint('getConsentHandleStatus');
  }
  
  void getConsentRequestDetails() async {
    
    try{
         finvuConsentRequestDetailInfo=await finvuManager.getConsentRequestDetails(handleId.value);
    }catch(e){
         print(e);
    }
     
    debugPrint('getConsentRequestDetails');
  }
  
  void  discoverAccounts() async
  {
    try{
        FinvuTypeIdentifierInfo finvuTypeIdentifierInfo=FinvuTypeIdentifierInfo(
             category: "Personal Finance",
             type: "DEPOSIT",
             value: "3",
        );
        List<FinvuTypeIdentifierInfo> identifiers=[finvuTypeIdentifierInfo];

         FinvuTypeIdentifier finvuTypeIdentifier=FinvuTypeIdentifier(
            category: "Personal Finance",
            type: "DEPOSIT",
         );
        List<FinvuTypeIdentifier> finvuTypeIdentifierList=[finvuTypeIdentifier];

        FinvuFIPFiTypeIdentifier finvuFIPFiTypeIdentifier=FinvuFIPFiTypeIdentifier(
          fiType: "DEPOSIT",identifiers: finvuTypeIdentifierList
        );
        List<FinvuFIPFiTypeIdentifier> typeIdentifiers=[finvuFIPFiTypeIdentifier];


        FinvuFIPDetails fipDetails=FinvuFIPDetails(fipId: "BARB0KIMXXX", typeIdentifiers: typeIdentifiers);

        List<String> fiTypes=[
                "DEPOSIT",
                 "RECURRING_DEPOSIT",
                "TERM-DEPOSIT"
              ];

        List<FinvuDiscoveredAccountInfo> info=await finvuManager.discoverAccounts(fipDetails,fiTypes,identifiers);
         info.forEach((e){
            print('e.accountType');
            print(e.accountType);
            print(e.fiType);
          
         });

    }catch(e){
         print(e);
    }
     
    debugPrint('getConsentRequestDetails');
  }

  void approveConsentRequest(context) async {
    
    try{
         var d=await finvuManager.approveConsentRequest(finvuConsentRequestDetailInfo,finvuLinkedAccountDetailsInfo);
          print("boolValue approveConsentRequest==========approveConsentRequest");
          print('d.consentIntentId');
          print(d.consentIntentId);
          consentUserId.value=d.consentIntentId.toString();
          print(finvuConsentRequestDetailInfo.consentHandle);
          print(finvuConsentRequestDetailInfo.consentId);
          Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FetchBankData(),
                      ));

          
      }
      catch(e){
         print("d.consentIntentId error");
         print(e);
    }
     
    debugPrint('approveConsentRequest');
  }




//     finvu_flutter_sdk_core:
//     git:
//       url: https://github.com/yashwantGehlot/finvu_flutter_sdk.git
//       path: core
//       ref: v2
// Yashwant Gehlot
// 17:17
// url = uri("https://maven.pkg.github.com/yashwantGehlot/finvu_android_sdk")