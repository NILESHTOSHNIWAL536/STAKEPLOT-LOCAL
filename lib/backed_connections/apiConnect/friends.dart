import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/controllers/userController.dart';


void addUserAsFrd(id,context,[type="friend"])async
{
    UserController controller =ControllerManagement.userController;
    var urlPath='${url}/user/friend/add/${id}/${type}';

    var response=await postDataApiCall(urlPath, {});
      if(getFlagOfResponse(response))
      {
            if(type=="Masked"){
              sendNotificationsToDevice(id,context,"${controller.maskedName.value} has connected to you.","/friends");

            }
            else{
                            sendNotificationsToDevice(id,context,"${controller.userName.value} has  accepted your friend request..","/friends");
            }
            
            snackBarCalled(context,SnackbarData().addingFriend,Colors.black);  
           userController.fetchUserInfo();    
      }else{
           snackBarCalled(context,SnackbarData().addFriendFail,Colors.red);
      }
}

void  rejectFrdRequest(body,context)async
{
  var urlPath='${url}/user/friend/rejectRequest';
  var response=await postDataApiCall(urlPath, {});
      if(!getFlagOfResponse(response))
      {
          snackBarCalled(context,SnackbarData().friendRejected ,Colors.red);
      }
}


void   addUsersendRequest(id,name,context)async
{
   
   var urlPath='${url}/user/friend/sendRequest';
   var body={
             'userName':name,
             'friendUserId':id,
       };
    UserController controller =ControllerManagement.userController;

     var response=await postDataApiCall(urlPath, body);
      if(getFlagOfResponse(response))
      {
            sendNotificationsToDevice(id,context,"${controller.userName.value} has sent you a friend request");
            snackBarCalled(context,SnackbarData().sendingRequest,Colors.black);
      }else{
           snackBarCalled(context,SnackbarData().requestAddFail,Colors.red);
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
            snackBarCalled(context,SnackbarData().requestRemoved,Colors.black);
      }else{
           snackBarCalled(context,SnackbarData().requestRemoveFail,Colors.red);
      }
}



  void  getRemoveFrds(context,id,[type="friend"])async
{   
    var urlPath='${url}/user/friend/remove/${id}/${type}';
    var response=await postDataApiCall(urlPath, {});
      if(getFlagOfResponse(response))
      {
                  snackBarCalled(context,SnackbarData().friendRemoved,Colors.black);
                   userController.fetchUserInfo();  
      }
}


