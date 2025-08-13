import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Profile/notifications.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/controllers/controllerManagement.dart';
import 'package:flutter_application_code_stakeplot/controllers/user-controller.dart';
import 'package:flutter_application_code_stakeplot/model/post_model.dart';
import 'package:flutter_application_code_stakeplot/signInOut/avatar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../Hive_localstorage/apisCall/post_apis.dart';
import '../../Hive_localstorage/hive_storage.dart';


void approveBill(context, id, type, notifyId) async {
  String urlPath = "${url}/bill/acceptBill/${id}/${type}/${notifyId}";

  var responce = await getDataApiCall(urlPath);

  if (getFlagOfResponse(responce)) {}
}

Future<void> getRemainders(context) async {
  String urlPath = "${url}/reminders";
  var responce = await getDataApiCall(urlPath);
  if (getFlagOfResponse(responce)) {
    var his = jsonDecode(responce.body);
    var userDue = his['data']['payables'] ?? [];
    var userDue2 = his['data']['owed'] ?? [];
    dueAmountRemainders.clear();
    lendAmountRemainders.clear();
    dueAmountRemainders.addAll(userDue); //payables
    lendAmountRemainders.addAll(userDue2); //owed
    dueAmountRemainders.refresh();
    lendAmountRemainders.refresh();
    getdueUsers.value = !getdueUsers.value;
  } else {}
}

Future<void> getFoodieFundsDetails(BuildContext context, String id) async {
  String urlPath = "${url}/reminders/$id";
  var response = await getDataApiCall(urlPath);
  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    var data = his['data'] ?? {};

    foodieFundsDetailsRemainders.clear();

    // Add the entire data object as a single item (or adjust to extract friends + currentUser)
    foodieFundsDetailsRemainders.add(data);

    foodieFundsDetailsRemainders.refresh();
    getFoodieFundsUsers.value = !getFoodieFundsUsers.value;
  } else {
    snackBarCalledfail(context, SnackbarData().failedToFetchFoodieFundsDetails);
  }
}

void getNotifications(context) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  final response = await http.get(
    Uri.parse('${url}/user/myNotifications'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
  );
  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    notificationList.clear();
    notificationList.addAll(his['data']);
    notificationList.forEach((req) {
      String type = req['notificationMessage']['type'];
      var e = req['notificationMessage'];
      if (type == "friendRequest") {
        friendRequestList.add(e['from_id']);
      }
    });

    hasGetNewNotifications.value = false;
    myNotificationBool.value = !myNotificationBool.value;
    notificationsFlag.value = false;
  } else {}
}

void getuserPost(id) async {
  String urlPath = '${url}/post/myDiscussions';
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
  } else {}
}

void getMaskendUsers(bool flag) async {
  String urlPath = "${url}/user/getMaskedUsers/${flag}";
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
  String urlPath = "${url}/post/saved";
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

String getCurrentFormattedDate() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(now);
  return formattedDate;
}

void aboutuser(context, String about) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.patch(
    Uri.parse('${url}/user/updateprofile'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      "aboutMe": about,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    snackBarCalled(context, SnackbarData().userInfoUpdated, Colors.black);
  } else {
    snackBarCalledfail(context, SnackbarData().errorUpdatingUserInfo, Colors.red);
  }
}

void addAccount(context, String account, String money) async {
  var urlPath = Uri.parse('${url}/user/addAccount');
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");

  final response = await http.post(
    Uri.parse('${urlPath}'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "$accessToken",
    },
    body: jsonEncode({
      'newAccount': account,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    snackBarCalled(
        context, SnackbarData().accountAddedSuccessfully, Colors.black);
    Navigator.pushNamed(context, '/home');
  } else {
    snackBarCalledfail(context, SnackbarData().errorAddingAccount, Colors.red);
  }
}

void editUserDetails(
    context, Map<String, TextEditingController> controller) async {
  final SharedPreferences _pref = await SharedPreferences.getInstance();
  var accessToken = _pref.getString("accessToken");
  UserController userController = ControllerManagement.userController;

  try {
    final response = await http.post(
      Uri.parse('${url}/user/updateprofile'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "$accessToken",
      },
      body: jsonEncode({
        "name": controller['name']!.text.toString(),
        "phone": controller['Number']!.text.toString(),
        "dob": controller['dob']!.text.toString(),
        "avatarType":
            (changeAvater.value == "Loading..." || changeAvater.value == "")
                ? userController.avatar.value
                : changeAvater.value,
      }),
    );

    var responce = jsonDecode(response.body);

    bool boolvar = responce['success'];
    if (!boolvar) {
      snackBarCalledfail(context, responce['error']['explanation'], Colors.red);
      return;
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      snackBarCalled(context, SnackbarData().userInfoUpdated, Colors.black);

      userController.avatar.value = changeAvater.value;
      userController.userName.value = controller['name']!.text.toString();
      userController.phone.value = controller['Number']!.text.toString();
      number.value = controller['Number']!.text.toString();
      userController.dob.value = controller['dob']!.text.toString();
    } else {}
  } catch (e) {}
}




