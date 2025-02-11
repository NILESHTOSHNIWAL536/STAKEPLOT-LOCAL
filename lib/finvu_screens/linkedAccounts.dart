import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

// List listOfTransactions=[];
RxList fetchedTrsacntionList = [].obs;
var baseUrl = "https://dhanaprayoga.fiu.finfactor.in/finsense/API/V2";

var headers = {
  "rid": "42c06b9f-cc5b-4a53-9119-9ca9d8e9acdb",
  "ts": "2019-07-15T11:03:44.427+0000",
  "channelId": "finsense",
};

Future<http.Response> loginToAutoTractionsGetData(context) async {
  final response = await http.post(Uri.parse('${baseUrl}/User/Login'),
      body: jsonEncode({
        "header": headers,
        "body": {"userId": "channel@dhanaprayoga", "password": "7777"}
      }));
  return response;
}

void login(handleId) async {
  var login =
      await finvuManager.loginWithUsernameOrMobileNumberAndConsentHandle(
    '${number.value}@finvu',
    '${number.value}',
    handleId,
  );

  otpReference = login.reference;
  debugPrint('LoggedIn');
}

void loginToAutoTractions(context) async {
  //  String custId="${""}@finvu";
  String custId = "${number.value}@finvu";

  final SharedPreferences _pref = await SharedPreferences.getInstance();
  //  _pref.setString("custId", custId);
  //  if(_pref.containsKey("token"))
  //  {
  //       ConsentRequestPlus(context, _pref.getString("token"),custId);
  //  }else{
  final response = await loginToAutoTractionsGetData(context);

  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    String token = "Bearer " + body['body']['token'];
    _pref.setString("token", token);
     print("token-----------------------------------");
     print(token);
    ConsentRequestPlus(context, token, custId);
  } else {
    //  snackBarCalled(context,"can't Add Friend!",Colors.red);
  }
  //  }
}

void ConsentRequestPlus(context, accessToken, custId) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();

  if (_pref.containsKey("ConsentHandleId")) {
    ConsentStatus(
        context, accessToken, _pref.getString("ConsentHandleId"), custId);
  } else {
    final response = await http.post(Uri.parse('${baseUrl}/ConsentRequestPlus'),
        // headers: headers,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "$accessToken",
        },
        body: jsonEncode({
          "header": headers,
          "body": {
            "custId": "${custId}",
            "consentDescription": "Personal finance management",
            "templateName": "FINVUDEMO_TESTING",
            "userSessionId": "sessionid123",
            "redirectUrl": "http://localhost:57783/",
            "fip": [""],
            "ConsentDetails": {},
            "aaId": "cookiejar-aa@finvu.in"
          }
        }));
    // printData(response, context);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);
      String ConsentHandleId = (body['body']['ConsentHandle']);
      String url = (body['body']['url']);

      login(ConsentHandleId);
      print(ConsentHandleId);
      handleId.value = ConsentHandleId;
      ConsentStatus(context, accessToken, ConsentHandleId, custId);
    } else {}
  }
}

void ConsentStatus(context, accessToken, ConsentHandleId, custId) async {
  print("ConsentStatus");
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  if (_pref.containsKey("consentId")) {
    print(_pref.getString("consentId"));
    ConsentFromAndToRequest(context, accessToken, ConsentHandleId, custId,
        (_pref.getString("consentId")));
  } else {
    final response = await http.get(
      Uri.parse('${baseUrl}/ConsentStatus/${ConsentHandleId}/${custId}'),
      // headers: headers,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
    );
    // printData(response, context);
  
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);
      if (body['body']['consentStatus'] == "ACCEPTED") {
        //  print("accepted.........");
        String consentId = body['body']['consentId'];
        //  print("--------------- consentId=body['body']['consentId'] ------------- ");
        //  print(consentId);
        _pref.setString("consentId", consentId);
        ConsentFromAndToRequest(
            context, accessToken, ConsentHandleId, custId, consentId);
      } else {
        //72533714-0530-4ed9-87d9-eb662a49c17a
      }
    } else {
      //  snackBarCalled(context,"can't Add Friend!",Colors.red);
      // print(response.statusCode);
      // print(response.body);
    }
  }
}

void getData(context, custId, consentId, sessionId, token) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  String urlFetch = "${baseUrl}/FIFetch/${custId}/${consentId}/${sessionId}";

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
  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
  }
}

void ConsentFromAndToRequest(
    context, accessToken, ConsentHandleId, custId, consentId) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();

  if (_pref.containsKey("from") && _pref.containsKey("to")) {
     print(_pref.getString("from"));
     print(_pref.getString("to"));
    FIRequest(context, accessToken, ConsentHandleId, custId,
        _pref.getString("from"), _pref.getString("to"), consentId);
  } else {
    final response = await http.get(
      Uri.parse('${baseUrl}/Consent/${consentId}'),
      // headers: headers,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
    );
    printData(response, context);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);
      // print('ConsentDetail-----------');
      // print(body);
      String from = body['body']['ConsentDetail']['FIDataRange']['from'];
      String to = body['body']['ConsentDetail']['FIDataRange']['to'];
      _pref.setString("from", from);
      _pref.setString("to", to);
      FIRequest(
          context, accessToken, ConsentHandleId, custId, from, to, consentId);
    } else {
      //  snackBarCalled(context,"can't Add Friend!",Colors.red);
    }
  }
}

void FIRequest(
    context, accessToken, consentHandleId, custId, from, to, consentId) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  if (_pref.containsKey("sessionId")) {
    FIRequestStatus(context, accessToken, consentHandleId, custId, from, to,
        consentId, _pref.getString("sessionId"));
         print(_pref.getString("sessionId"));
  } else {
    final response = await http.post(Uri.parse('${baseUrl}/FIRequest'),
        // headers: headers,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "$accessToken",
        },
        body: jsonEncode({
          "header": headers,
          "body": {
            "custId": custId,
            "consentId": consentId,
            "consentHandleId": consentHandleId,
            "dateTimeRangeFrom": from,
            "dateTimeRangeTo": to
          }
        }));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);
      print(body);
      String sessionId = body['body']['sessionId'];
      _pref.setString("sessionId", sessionId);
      FIRequestStatus(context, accessToken, consentHandleId, custId, from, to,
          consentId, sessionId);
    } else {
      // print(error);
      print(" error..............");
    }
  }
}

void FIRequestStatus(context, accessToken, consentHandleId, custId, from, to,
    consentId, sessionId) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  final response = await http.get(
    Uri.parse('${baseUrl}/FIStatus/${consentId}/${sessionId}/${consentHandleId}/${custId}'),
    // headers: headers,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
 
  if (response.statusCode == 200 || response.statusCode == 201) {
    FetchData(context, accessToken, consentHandleId, custId, from, to,
        consentId, sessionId);
  } else {}
}

void FetchData(context, accessToken, consentHandleId, custId, from, to,
    consentId, sessionId) async {
  String urlFetch  = "${baseUrl}/FIFetch/${custId}/${consentId}/${sessionId}";
  print("FetchData..............");
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
  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
    
    storeDataOfTransactions(context, body['body'], consentHandleId, from, to,
        accessToken, custId, consentId, sessionId);
  } else {}
}

Future<void> storeDataOfTransactions(context, data, consentHandleId, from, to,
    accessToken, custId, consentId, sessionId) async {
  // print(data);
  // if (data == "Account data not found.") return;
  fetchedTrsacntionList.clear();
  fetchedTrsacntionList.add([data.toString()]);
  fetchedTrsacntionList.refresh();
  print("storeDataOfTransactions.....");
  print(data);

 String accessToken="Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3N2UxMjBhNzVhYWZiYWMyNTQ2NGFkNCIsImlhdCI6MTczODc1Nzc3OSwiZXhwIjoxNzQzOTQxNzc5fQ.5XeQtIM2CmFdyrfXiCcA5neACgSRuYScFa5ArcYhe34";

  try{
  final response = await http.post(Uri.parse('${url}/transactionauto/'),
      // headers: headers,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'userId': "677e120a75aafbac25464ad4", 
        'consenthandleid': consentHandleId,
        'from': from,
        'to': to,
        "Authorization": "$accessToken",
      },
      body: jsonEncode(data));

   printData(response, context);
  if (response.statusCode == 200 || response.statusCode == 201) {
    final body = json.decode(response.body);
   
    print("body added--------------------");
    // print(body);
     SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove("sessionId");
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
  } else {}
  }catch(e){
       print("Error : ");
       print(e);
  }
}

Future<void> _redirectToURL(String url) async {
  // final Uri uri = Uri.parse(url);
  // if (await canLaunchUrl(uri)) {
  //   await launchUrl(uri, mode: LaunchMode.externalApplication);
  // } else {
  //   throw 'Could not launch $url';
  // }
}

void fetch(context) async {
  try {
    final SharedPreferences _pref = await SharedPreferences.getInstance();
    String? token = await _pref.getString("token");
    ConsentStatus(context, token, handleId.value, custId);
  } catch (e) {
    //  print(e);
  }
}


 void  LOGOUT() async {
    
       final SharedPreferences _pref = await SharedPreferences.getInstance();
try{

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
//  number.value="";
//  consentUserId.value="";
//  handleId.value="";
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

