
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

Future<void> addMyIntreastAndName(String name,List list,BuildContext context) async
{
 
  try{
  var response =await updateDataApiCall2("${url}/user/", {
    "interestedTags":list ,
    "maskedName": name
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