import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/repository/notification_repository.dart';
import 'package:flutter_application_code_stakeplot/repository/payments.dart';
import 'package:flutter_application_code_stakeplot/repository/profileUser.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import "package:flutter_application_code_stakeplot/controllers/user-controller.dart";
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';


void addUserAsFrd(id,context,[type="friend"])async
{
    UserController controller =ControllerManagement.userController;
    var urlPath='${UserRoutes.addFriend}/${id}/${type}';

    var response=await postDataApiCall(urlPath, {});
      if(getFlagOfResponse(response))
      {
            if(type=="Masked"){
              sendNotificationsToDevice(id,context,"${controller.maskedName.value} has connected to you.","/friends");
            }
            else{
              sendNotificationsToDevice(id,context,"${controller.userName.value} has  accepted your friend request..","/friends");
            }
            
            snackBarCalled(context,SnackbarData().addingFriend,);  
           userController.fetchUserInfo();    
      }else{
           snackBarCalledfail(context,SnackbarData().addFriendFail,);
      }
}

void  rejectFrdRequest(body,context)async
{
  var urlPath=UserRoutes.rejectRequest;
  var response=await postDataApiCall(urlPath, {});
      if(!getFlagOfResponse(response))
      {
          snackBarCalledfail(context,SnackbarData().friendRejected );
      }
}


void   addUsersendRequest(id,name,context)async
{
   
   var urlPath=UserRoutes.sendRequest;
   var body={
            //  'userName':name,
             'friendUserId':id,
       };
    UserController controller =ControllerManagement.userController;

     var response=await postDataApiCall(urlPath, body);
      if(getFlagOfResponse(response))
      {
            sendNotificationsToDevice(id,context,"${controller.userName.value} has sent you a friend request");
            snackBarCalled(context,SnackbarData().sendingRequest);
      }else{
           snackBarCalledfail(context,SnackbarData().requestAddFail);
      }
}

void  removeRequest(id,name,context)async
{
      
    var urlPath=UserRoutes.unsendRequest;
    var body={
            //  'userName':name,
             'friendUserId':id,
       };  
      var response=await postDataApiCall(urlPath, body);
      if(getFlagOfResponse(response))
      {
            snackBarCalled(context,SnackbarData().requestRemoved);
      }else{
           snackBarCalledfail(context,SnackbarData().requestRemoveFail);
      }
}



  void  getRemoveFrds(context,id,[type="friend"])async
{   
    var urlPath='${UserRoutes.removeFriend}/${id}/${type}';
    var response=await postDataApiCall(urlPath, {});
      if(getFlagOfResponse(response))
      {
                  snackBarCalled(context,SnackbarData().friendRemoved);
                   userController.fetchUserInfo();  
      }
}


