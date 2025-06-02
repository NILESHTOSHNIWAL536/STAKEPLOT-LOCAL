
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finSpace/marks.dart';


Future<void> getMaskedNumber(BuildContext context) async
{
   maskNameController.clear();
    var response = await getDataApiCall("${url}/user/maskedName"); 
    printData(response);  
    if(getFlagOfResponse(response)){
         var body=jsonDecode(response.body);
         print(body);
         if(body['data']!=null)
         {
           maskNameController.text=body['data'];
         }
         else
         {
           maskNameController.text="";
         }
    }
}


Future<void> addMyIntreastAndName(String name,List list,BuildContext context) async
{

  try{
  var response =await updateDataApiCall2("${url}/user/", {
    "interestedTags":list ,
    "maskedName": maskNameController.text
  });
  printData(response);
  if (getFlagOfResponse(response))
  {
     
  }
  
  }catch(e) {
    print("Error fetching bank accounts: $e");
  }

  Navigator.of(context).pushNamedAndRemoveUntil('/interestScreen', (Route<dynamic> route) => false);
  Navigator.pushNamed(context, '/post');
 
}