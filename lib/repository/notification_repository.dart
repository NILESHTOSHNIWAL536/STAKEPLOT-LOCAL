
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/model/post_model.dart';
import 'package:flutter_application_code_stakeplot/routes/route_post.dart';

import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';

import '../Profile/notifications.dart';

void getAck() async {
  var response = await getDataApiCall(UserRoutes.newNotifications);
  if (getFlagOfResponse(response)) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    hasGetNewNotifications.value = obj != 0;
  }
}


void sendNotificationsToDevice(id, context, msg,
    [String screen = "/home",
    String title = "",
    String pic = "",
    String message = "",
    String billid = ""]) async {
  String urlPath = "${url}/reminders/sendNotifications/ToDevice";
 

  try {
    final response = await postDataApiCall(urlPath,{
        'id': id,
        'message': msg,
        'screen': screen,
        'title': title,
        'pic': pic,
        "billId": billid
      }
    );

    if (response.statusCode == 429) {
      var data = jsonDecode(response.body);
      snackBarCalledfail(context, data["message"]);
      return;
    }
    if (screen == "/remainder" || screen == "/remainders") {
      snackBarCalled(context, message);
    }
  } catch (e) {}
}

 Future<void> deleteNotification(String? notifyId, context) async {
    if (notifyId == null) return;
    String urlPath = '${UserRoutes.deleteNotifications}/$notifyId';
    var response = await getDataApiCall(urlPath);
    if (!getFlagOfResponse(response)) 
     
    {
      snackBarCalledfail(context, SnackbarData().deleteNotificationFailed);
    }
  }


Future<PostModel?> fetchPostById(String postId, BuildContext context) async {
    try {
      final response = await getDataApiCall(
          '${PostRoutes.post}$postId'); // Adjust the endpoint based on your API);
      if (getFlagOfResponse(response)) {
        var jsonData = jsonDecode(response.body);
        // Adjust based on your API response structure, e.g., jsonData['data']
        return PostModel.fromJson(jsonData['data'][0] ?? jsonData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void getNotifications(context) async {
  
  final response = await getDataApiCall(UserRoutes.myNotifications);
 
  if (getFlagOfResponse(response)) {
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

