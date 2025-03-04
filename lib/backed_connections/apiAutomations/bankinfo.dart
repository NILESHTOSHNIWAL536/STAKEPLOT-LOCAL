


import 'dart:convert';

import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/integration.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/backServices.dart/bankInfo.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';


RxList bankAccountLinkedList=[].obs;
RxMap bankImagemap={}.obs;


Future<void> getBankAccounts()async
{
    var response=await getDataApiCall("${url}/transactionauto/get-banks-linked/");
    if(getFlagOfResponse(response))
    {
            var his = jsonDecode(response.body);
             bankAccountLinkedList.clear();
            his['data'].forEach((bank) {
                  bank['accounts'].forEach((account) {
                    bankAccountLinkedList.add({
                      'bankId': bank['bankId'],
                      'bankName': bank['bankName'],
                      'fipId': bank['fipId'],
                      'accountId': account['accountId'],
                      'maskedAccNumber': account['maskedAccNumber'],
                      'type': account['type'],
                      'currentBalance': account['currentBalance'],
                    });
                  });
                });

              updateInfo();
    }

}


void updateInfo(){
    var data = bankAccountLinkedList.firstWhere(
    (bank) =>  bank['bankId'] == selectedBank.value ||  bank['fipId'] == selectedBank.value,
    orElse: () => bankAccountLinkedList.isNotEmpty ? bankAccountLinkedList[0] : null,
  );
  
  if(data==null && bankAccountLinkedList.isNotEmpty)data=bankAccountLinkedList[0];

    if (data != null) {
    accountId.value=data['bankId'] ?? "";
    accountName.value = data['bankName'] ?? "";
    accountNo.value = data['fipId'] ?? "";
    balance.value = (data['accounts']?.isNotEmpty ?? false) 
        ? data['accounts'][0]['currentBalance'].toString() 
        : "0";
  } else {
             accountId.value="";
            accountName.value = "";
            accountNo.value = "0";
            balance.value = "0";
  }
}


void storeImageinMapFinvu(context)async
{
   var isConnected = await finvuManager.isConnected();
   if(!isConnected)initFinvuManager(context);
  // print("websocket connected : ");
  // print(isConnected);

  try{
   
    // List<FinvuFIPInfo> finvuFIPInfo=await finvuManager.fipsAllFIPOptions();
   
    // finvuFIPInfo.forEach((FinvuFIPInfo info){
    //            bankImagemap[info.productName]=info.productIconUri;
    // }); 
   
  }catch(e)
  {
      print("e error");
  } 
  
}


  void calledFunctionToFetchData(context) async {

    if( accountId.value.isEmpty){
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
