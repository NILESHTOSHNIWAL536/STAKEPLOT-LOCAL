
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

void   addUserAsFrd(id,context)async
{
    var urlPath='${url}/user/friend/add/${id}';
    var response=await postDataApiCall(urlPath, {});
      if(getFlagOfResponse(response))
      {
            sendNotificationsToDevice(id,context,"${userName.value} Has Accepted Friend Request..");
            snackBarCalled(context,"Adding user As Friend...!",Colors.black);      
      }else{
           snackBarCalled(context,"can't Add Friend!",Colors.red);
      }
}

void  rejectFrdRequest(body,context)async
{
  var urlPath='${url}/user/friend/rejectRequest';
  var response=await postDataApiCall(urlPath, {});
      if(!getFlagOfResponse(response))
      {
          snackBarCalled(context,"can't Reject error Friend!",Colors.red);
      }
}


void   addUsersendRequest(id,name,context)async
{
   
   var urlPath='${url}/user/friend/sendRequest';
   var body={
             'userName':name,
             'friendUserId':id,
       };
  var response=await postDataApiCall(urlPath, body);
      if(getFlagOfResponse(response))
      {
            sendNotificationsToDevice(id,context,"${userName.value} Has Send U a Friend Request..");
            snackBarCalled(context,"Sending Friend Request...!",Colors.black);
      }else{
           snackBarCalled(context,"can't Add Request!",Colors.red);
      }
}

void  removeRequest(id,name,context)async
{
      
    var urlPath='${url}/user/friend/unsendRequest';
    var body={
             'userName':name,
             'friendUserId':id,
       };  
      var response=await postDataApiCall(urlPath, body);
      if(getFlagOfResponse(response))
      {
            snackBarCalled(context,"Removed Friend Request...!",Colors.black);
      }else{
           snackBarCalled(context,"can't remove Request!",Colors.red);
      }
}



  void  getRemoveFrds(context,id)async
{   
    var urlPath='${url}/user/friend/remove/${id}';
    var response=await postDataApiCall(urlPath, {});
      if(getFlagOfResponse(response))
      {
                  snackBarCalled(context,"Removed Friend...!",Colors.black);
                  getUserInfomations();  
      }
}


