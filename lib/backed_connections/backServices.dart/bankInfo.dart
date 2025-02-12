
import 'dart:convert';

import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';

RxString balance="0".obs;
RxString accountName="0".obs;


void getSummary() async
{
    
    var res=await getDataApiCall("${url}/transactionauto/user-details");
         print("data transactionauto :");
    printData(res);
    if(getFlagOfResponse(res)){
         var data=jsonDecode(res.body);
         data=data['data'];
         print(data['Bank']['fipName']);
         print(data['summaries'][0]['data']['currentBalance']);
         accountName.value=data['Bank']['fipName'];
         balance.value=data['summaries'][0]['data']['currentBalance'].toString();
    }
}