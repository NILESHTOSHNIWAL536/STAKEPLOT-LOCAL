import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';

import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:flutter_application_code_stakeplot/model/post_model.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';
import '../Hive_localstorage/apisCall/post_apis.dart';
import '../Hive_localstorage/hive_storage.dart';
import '../loginservices/login.dart';
import '../routes/route_post.dart';


void getuserPost(id) async {
  String urlPath = PostRoutes.myDiscussions;
  var response = await getDataApiCall(urlPath);
  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    UserController userController = ControllerManagement.userController;
    userController.myPostList.clear();
    userController.myPostList.addAll(PostModel.listFromJson(obj));
    userController.myPostList.forEach((element) {
      postController.postCount[element.id] = element.upvotes;
      postController.postCommentCount[element.id] = element.comments;
    });
    PostLocalStorage.savePostsToHive(postList: userController.myPostList, isPostTranding: false,isUserPost: true);
  } else {
    PostLocalStorage.loadPostsFromHive(isPostTranding: false,isUserPost: true);
  }
}


void getMaskendUsers(bool flag) async {
  String urlPath = "${UserRoutes.getMaskedUsers}/${flag}";
  var response = await getDataApiCall(urlPath);
  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    UserController userController = ControllerManagement.userController;
    if (flag) {
      userController.maskedConnections.clear();
      userController.maskedConnections.addAll(obj);
    } else {
      userController.maskedConnected.clear();
      userController.maskedConnected.addAll(obj);
    }
  }
}




void getSaved() async {
  try{
  String urlPath = PostRoutes.saved;
  var response = await getDataApiCall(urlPath);
  if (response.statusCode == 200 || response.statusCode == 201) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    addSavedPostList(obj);

  } else {}
  }catch(e)
  {
    if(HiveStorage.isBoxOpen(HiveStorage.savedPostName))
    {
      PostLocalStorage.loadPostsFromHive(isPostTranding: true,isSavedPost: true);
    }
  }
}



void aboutuser(context, String about) async {
  
  final response = await updateDataApiCall2(UserRoutes.updateprofile,{
      "aboutMe": about,
    }
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    snackBarCalled(context, SnackbarData().userInfoUpdated, );
  } else {
    snackBarCalledfail(context, SnackbarData().errorUpdatingUserInfo,  AppColors.redColor);
  }
}



void editUserDetails(
    context, Map<String, TextEditingController> controller) async {
  
  UserController userController = ControllerManagement.userController;

  try {
    final response = await postDataApiCall(UserRoutes.updateprofile, 
    
        {
        "name": controller['name']!.text.toString(),
        "phone": controller['Number']!.text.toString(),
        "dob": controller['dob']!.text.toString(),
        "avatarType":
            (changeAvater.value == "Loading..." || changeAvater.value == "")
                ? userController.avatar.value
                : changeAvater.value,
      }
    );

    var responce = jsonDecode(response.body);

    bool boolvar = responce['success'];
    if (!boolvar) {
      snackBarCalledfail(context, responce['error']['explanation'],  AppColors.redColor);
      return;
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      snackBarCalled(context, SnackbarData().userInfoUpdated, );

      userController.avatar.value = changeAvater.value;
      userController.userName.value = controller['name']!.text.toString();
      userController.phone.value = controller['Number']!.text.toString();
      number.value = controller['Number']!.text.toString();
      userController.dob.value = controller['dob']!.text.toString();
    } else {}
  } catch (e) {}
}




