


import 'dart:convert';

import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';


RxList bankAccountLinkedList=[].obs;
RxMap bankImagemap={}.obs;


void getBankAccounts()async
{
    var response=await getDataApiCall("${url}/transactionauto/get-banks-linked/");
    if(getFlagOfResponse(response))
    {
            var his = jsonDecode(response.body);
             bankAccountLinkedList.clear();
             bankAccountLinkedList.addAll(his['data']??[]);
    }

}


void storeImageinMapFinvu()async
{
  try{
    List<FinvuFIPInfo> finvuFIPInfo=await finvuManager.fipsAllFIPOptions();
    finvuFIPInfo.forEach((FinvuFIPInfo info){
               bankImagemap[info.fipId]=info.productIconUri;
    }); 
  }catch(e)
  {
      print(e);
  } 
  
}