
import 'dart:convert';
import 'package:finvu_flutter_sdk_core/finvu_consent_info.dart';
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/otpScreen.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


  // FinvuManager finvuManager = FinvuManager();
  String otpReference = "";
  String displayText = '';
  String custId="8978958221@finvu";
  String number="8978958221";
  RxString handleId="0393a738-3d64-4860-b5ca-ea687ac74d18".obs;
  RxString consentUserId="0393a738-3d64-4860-b5ca-ea687ac74d18".obs;
  RxBool fetchedData=false.obs;
  late FinvuConsentRequestDetailInfo finvuConsentRequestDetailInfo;
  late List<FinvuLinkedAccountDetailsInfo> finvuLinkedAccountDetailsInfo;
  List<String> fiTypes=[];

 

  var baseUrl="https://dhanaprayoga.fiu.finfactor.in/finsense/API/V2";

  var headers={
          "rid": "42c06b9f-cc5b-4a53-9119-9ca9d8e9acdb",
          "ts": "2019-07-15T11:03:44.427+0000",
          "channelId": "finsense",
    };

  Future<http.Response>   loginToAutoTractionsGetData(context)async
  {
      
      final response = await http.post(
            Uri.parse('${baseUrl}/User/Login'),

              body:jsonEncode({
             "header":headers,
              "body": {
                    "userId": "channel@dhanaprayoga",
                    "password": "7777"
              }
          } 
       ));
     return response;
  }


  
  void login(handleId) async {
  
  
    var login =
        await finvuManager.loginWithUsernameOrMobileNumberAndConsentHandle(
      '8978958221@finvu',
      '8978958221',
      handleId,
    );

      
    otpReference = login.reference;
    print("otpReference");
    print(login);
    print(otpReference);


    debugPrint('LoggedIn');
  }

  void   loginToAutoTractions(context,number)async
  {
        String custId="${"8978958221"}@finvu";
        // String custId="${number}@finvu";
      
        final SharedPreferences _pref = await SharedPreferences.getInstance();
         _pref.setString("custId", custId);
     if(_pref.containsKey("token"))
     {
          ConsentRequestPlus(context, _pref.getString("token"),custId);
     }else{
        final response =await loginToAutoTractionsGetData(context);

        if(response.statusCode==200 || response.statusCode==201){
              final body = json.decode(response.body);
              String token="Bearer "+body['body']['token'];
               _pref.setString("token", token);
               print("token-----------------------------------");
               print(token);
               ConsentRequestPlus(context, token,custId);
        } else{
            //  snackBarCalled(context,"can't Add Friend!",Colors.red);
        }
     }
  }


  void   ConsentRequestPlus(context,accessToken,custId)async
  {
    
        final SharedPreferences _pref = await SharedPreferences.getInstance();
      
        if(_pref.containsKey("ConsentHandleId")){
             ConsentStatus(context, accessToken, _pref.getString("ConsentHandleId"),custId);
        }else{
      
      final response = await http.post(
              Uri.parse('${baseUrl}/ConsentRequestPlus'),
                // headers: headers,
                headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                      "Authorization": "$accessToken",
                },
                body:jsonEncode({
              "header":headers,
                "body": {
                      "custId": "${custId}",
                      "consentDescription": "Personal finance management",
                      "templateName": "FINVUDEMO_TESTING",
                      "userSessionId": "sessionid123",
                      "redirectUrl": "http://localhost:57783/",
                      "fip" : [""],
                      "ConsentDetails": {
                      },
                      "aaId": "cookiejar-aa@finvu.in"
                }
  }
       ));
        // printData(response, context);
        if(response.statusCode==200 || response.statusCode==201){
              final body = json.decode(response.body);
               String ConsentHandleId=(body['body']['ConsentHandle']);
               String url=(body['body']['url']);
                _pref.setString("ConsentHandleId", ConsentHandleId);
                // clickedLinkedBackAccount.value=true;
                print("ConsentHandleId");
                print(ConsentHandleId);
                login(ConsentHandleId);
                handleId.value=ConsentHandleId;
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Otpscreen(),
                    ),
                );
                ConsentStatus(context, accessToken, ConsentHandleId,custId);
            } else{
                
            }
        }
  }


  void   ConsentStatus(context,accessToken,ConsentHandleId,custId)async
  {
        print("ConsentStatus");
        final SharedPreferences _pref = await SharedPreferences.getInstance();
        if(_pref.containsKey("consentId"))
        {
              ConsentFromAndToRequest(context, accessToken, ConsentHandleId, custId,(_pref.getString("consentId")));
        }else{
      final response = await http.get(
              Uri.parse('${baseUrl}/ConsentStatus/${ConsentHandleId}/${custId}'),
                // headers: headers,
                headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                      "Authorization": "$accessToken",
                },
       );
        // printData(response, context);
    
        if(response.statusCode==200 || response.statusCode==201){
              final body = json.decode(response.body);
              if(body['body']['consentStatus']=="ACCEPTED"){
                   print("accepted.........");
                   String consentId=body['body']['consentId'];
                   _pref.setString("consentId", consentId);
                   ConsentFromAndToRequest(context, accessToken, ConsentHandleId, custId,consentId);
              }else{
                  
              }
        } else{
            //  snackBarCalled(context,"can't Add Friend!",Colors.red);
            print(response.statusCode);
            print(response.body);
        }
      }
  }

  void   getData(context,custId,consentId,sessionId,token)async
  {
    
        final SharedPreferences _pref = await SharedPreferences.getInstance();
         String urlFetch="${baseUrl}/FIFetch/${custId}/${consentId}/${sessionId}";
        
        
      final response = await http.get(
              Uri.parse("${urlFetch}"),
              // Uri.parse('https://dhanaprayoga.fiu.finfactor.in/finsense/API/V2/FIFetch/8978958221@finvu/222a0f24-0b78-4b16-ae49-f6990aa9bf02/bf389dd0-ada0-4545-b603-7112b574cb4d'),
                // headers: headers,
                headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                      "Authorization": token,
                },
       );
        // printData(response, context);
        if(response.statusCode==200 || response.statusCode==201){
              final body = json.decode(response.body);
            
      }
  }

  void   ConsentFromAndToRequest(context,accessToken,ConsentHandleId,custId,consentId)async
  {
          
        final SharedPreferences _pref = await SharedPreferences.getInstance();

       if(_pref.containsKey("from") && _pref.containsKey("to"))
        {
               FIRequest(context, accessToken, ConsentHandleId, custId, _pref.getString("from"),_pref.getString("to"), consentId);

        }else{
      
      final response = await http.get(
              Uri.parse('${baseUrl}/Consent/${consentId}'),
                // headers: headers,
                headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                      "Authorization": "$accessToken",
                },
       );
        // printData(response, context);
        if(response.statusCode==200 || response.statusCode==201){
              final body = json.decode(response.body);
              print('ConsentDetail-----------');
              print(body);
              String from=body['body']['ConsentDetail']['FIDataRange']['from'];
              String to=body['body']['ConsentDetail']['FIDataRange']['to'];
              _pref.setString("from", from);  
              _pref.setString("to", to);  
              FIRequest(context, accessToken, ConsentHandleId, custId, from,to, consentId);
        } else{
            //  snackBarCalled(context,"can't Add Friend!",Colors.red);
        }
      }
  }





  void   FIRequest(context,accessToken,consentHandleId,custId,from,to,consentId)async
  {
        print("FIRequest called..............");
        final SharedPreferences _pref = await SharedPreferences.getInstance();
         if(_pref.containsKey("sessionId"))
        {
              FIRequestStatus(context, accessToken, consentHandleId, custId, from, to, consentId, _pref.getString("sessionId"));  
        }else{
      final response = await http.post(
              Uri.parse('${baseUrl}/FIRequest'),
                // headers: headers,
                headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                      "Authorization": "$accessToken",
                },
                body: jsonEncode({
              "header":headers,
                "body": {
                     "custId": custId,
                      "consentId": consentId, 
                      "consentHandleId":consentHandleId, 
                      "dateTimeRangeFrom":from, 
                      "dateTimeRangeTo": to

                }
              }));
        if(response.statusCode==200 || response.statusCode==201)
        {
              final body = json.decode(response.body);
              String sessionId= body['body']['sessionId']; 
              _pref.setString("sessionId", sessionId);  
              FIRequestStatus(context, accessToken, consentHandleId, custId, from, to, consentId, sessionId);
        } else{
               print("FIRequest called error..............");
        }
      }
  }

  void   FIRequestStatus(context,accessToken,consentHandleId,custId,from,to,consentId,sessionId)async
  {
        final SharedPreferences _pref = await SharedPreferences.getInstance();
      final response = await http.get(
              Uri.parse('${baseUrl}/FIStatus/${consentId}/${sessionId}/${consentHandleId}/${custId}'),
                // headers: headers,
                headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                      "Authorization": "$accessToken",
                },
              );
        if(response.statusCode==200 || response.statusCode==201)
        {
              final body = json.decode(response.body);
              print("body"); 
              print(body); 
              FetchData(context, accessToken, consentHandleId, custId, from, to, consentId, sessionId);

        } else{
            
        }
  }


  void   FetchData(context,accessToken,consentHandleId,custId,from,to,consentId,sessionId)async
  {
           print("FetchData called..............");
        String urlFetch="${baseUrl}/FIFetch/${custId}/${consentId}/${sessionId}";
        print(urlFetch);
        final SharedPreferences _pref = await SharedPreferences.getInstance();
      final response = await http.get(
              Uri.parse('${urlFetch}'),
                // headers: headers,
                headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                      "Authorization": "$accessToken",
                },
              );
        if(response.statusCode==200 || response.statusCode==201)
        {
              final body = json.decode(response.body);
              //  isBankAccountLink.value=true;
               print("data ------------");
               print(body);
              storeDataOfTransactions(context,body['body'],consentHandleId,from,to,accessToken,custId,consentId,sessionId);

        } else{
            
        }
  }


  void storeDataOfTransactions(context,data,consentHandleId,from,to,accessToken,custId,consentId,sessionId)async
  {
        print(data);
        if(data=="Account data not found."){
            fetchedData.value=false;
        }else{
            fetchedData.value=true;
        }
             
        //     final response = await http.post(
        //       Uri.parse('${url}/transactionauto/'),
        //         // headers: headers,
        //         headers: <String, String>{
        //               'Content-Type': 'application/json; charset=UTF-8',
        //               'userId':currentId.value, //"6756956ecb56e4dfcc6ee5a6" 
        //               'consenthandleid':consentHandleId,
        //               'from':from,
        //               'to':to,
        //         },
        //          body:jsonEncode(data)
        //   );
        
        // //  printData(response, context);
        // if(response.statusCode==200 || response.statusCode==201)
        // {
        //       final body = json.decode(response.body);
        //       // isBankAccountLink.value=true;
            
        //       Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
        // } else{
            
        // }

  }



   Future<void> _redirectToURL(String url) async {
      // final Uri uri = Uri.parse(url);
      // if (await canLaunchUrl(uri)) {
      //   await launchUrl(uri, mode: LaunchMode.externalApplication);
      // } else {
      //   throw 'Could not launch $url';
      // }
    }
