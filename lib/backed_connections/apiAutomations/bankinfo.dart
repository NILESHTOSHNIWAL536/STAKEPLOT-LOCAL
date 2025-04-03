


import 'dart:convert';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/integration.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

RxList bankAccountLinkedList=[].obs;
RxList consentAndHandleDetails=[].obs;
RxMap bankImagemap={}.obs;


Future<void> getBankAccounts()async
{
    var response=await getDataApiCall("${url}/transactionauto/get-banks-linked/");
    printData(response);
    
    if(getFlagOfResponse(response))
    {
            var his = jsonDecode(response.body);
             consentAndHandleDetails.clear(); 
             bankAccountLinkedList.clear();
             
            his['data'].forEach((bank) {
              if (bank['consentId'] != null && bank['consendHandleId'] != null) {
                 if (!consentAndHandleDetails.any((item) => 
                            item['consentId'] == bank['consentId'] &&
                            item['consendHandleId'] == bank['consendHandleId'])) {
                          consentAndHandleDetails.add({
                            "consentId": bank['consentId'],
                            "consendHandleId": bank['consendHandleId'],
                            "sessionId": bank['sessionId'],
                            "custId": bank['custId'],
                            'lastFetch':bank['accounts'][0]['lastFetch'] ?? "",
                            'nextFetch':bank['accounts'][0]['nextFetch'] ?? "",
                            'fetchCount':bank['accounts'][0]['fetchCount'] ?? "0",
                          });
                        }
              }
                  bank['accounts'].forEach((account) {
                    if(accountId.value=="")
                    accountId.value=account['accountId'];
                    bankAccountLinkedList.add({
                      'bankId': bank['bankId'],
                      'bankName': bank['bankName'],
                      'fipId': bank['fipId'],
                      'accountId': account['accountId'],
                      'maskedAccNumber': account['maskedAccNumber'],
                      'type': account['type'],
                      'currentBalance': account['currentBalance'],
                      'lastFetch':account['lastFetch'] ?? "",
                      'nextFetch':account['nextFetch'] ?? "",
                      'fetchCount':account['fetchCount'] ?? "0",
                    });
                  });
                });

    }
    loadBanks.value=false;
}


void getWeeklyfetchData(consentId,consendHandleId,sessionId, custId,from,to)async
{

   final String apiUrl ="${url}/finvu/fetchWeekly";
   final SharedPreferences pref = await SharedPreferences.getInstance();
   String accessToken=pref.getString("accessToken").toString() ; 
  
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json", "Authorization": "$accessToken",},
      body: jsonEncode({
        'from':from, 
        'to':to,
        'handleId':consendHandleId,
        'custId':custId,
        'consentId':consentId,
        'sessionId':sessionId,
        'userId':currentId.value,
      }),
    );
     printData(response);
    if (response.statusCode == 200)
    {
      print(response.body);
    }
}


void storeImageinMapFinvu(context)async
{
   var isConnected = await finvuManager.isConnected();
   if(!isConnected)initFinvuManager(context);

  try{
   
    // List<FinvuFIPInfo> finvuFIPInfo=await finvuManager.fipsAllFIPOptions();
   
    // finvuFIPInfo.forEach((FinvuFIPInfo info){
    //            bankImagemap[info.productName]=info.productIconUri;
    // }); 
   
  }catch(e)
  {
    
  } 
  
}


  void calledFunctionToFetchData(context) async {

    if(accountId.value.isEmpty){
        getGraphData.value=false;
        await getBankAccounts();
    }
    if (selectedButton.value == "Month")
    {
      getAutoMationsTransactionsCustom(getFormattedDate(), context);  
    }
    else if (selectedButton.value == "Week"){
      getAutoMationsTransactionsCustom(getCurrentWeek(), context, 'Week');
    }
    else {
      getAutoMationsTransactionsCustom(getFormattedDate(), context);
    }

  }

