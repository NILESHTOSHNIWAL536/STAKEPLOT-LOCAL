
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
            sendNotificationsToDevice(id,context,"${userName.value} has accepted your friend request..");
            snackBarCalled(context,"Adding user as a friend...!",Colors.black);      
      }else{
           snackBarCalled(context,"Unable to add friend!",Colors.red);
      }
}

void  rejectFrdRequest(body,context)async
{
  var urlPath='${url}/user/friend/rejectRequest';
  var response=await postDataApiCall(urlPath, {});
      if(!getFlagOfResponse(response))
      {
          snackBarCalled(context,"Unfortunately, your friend request has been rejected." ,Colors.red);
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
            sendNotificationsToDevice(id,context,"${userName.value} has sent you a friend request");
            snackBarCalled(context,"Sending friend request..",Colors.black);
      }else{
           snackBarCalled(context,"can't add request!",Colors.red);
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
            snackBarCalled(context,"Friend request has been successfully removed!",Colors.black);
      }else{
           snackBarCalled(context,"unable to  remove request!",Colors.red);
      }
}



  void  getRemoveFrds(context,id)async
{   
    var urlPath='${url}/user/friend/remove/${id}';
    var response=await postDataApiCall(urlPath, {});
      if(getFlagOfResponse(response))
      {
                  snackBarCalled(context,"Friend has been successfully removed Friend!",Colors.black);
                  getUserInfomations();  
      }
}


