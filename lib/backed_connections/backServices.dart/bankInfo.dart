
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
    print(url);
    if(getFlagOfResponse(res)){
         var data=jsonDecode(res.body);
         accountName.value=data['Bank']['fipName'];
         balance.value=data['summaries']['data']['currentBalance'];
    }
}