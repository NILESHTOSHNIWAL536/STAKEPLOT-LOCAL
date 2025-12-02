import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/model/post_model.dart';
import 'package:flutter_application_code_stakeplot/routes/route_post.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../backed_connections/apiAutomations/secure_storage.dart';

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
      snackBarCalledfail(context, data["message"], Colorcodes.red);
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
Future<String?> getToken() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  var accessToken =await SecureStorageService().read("accessToken");
  if (accessToken == null) {
    return null;
  } else {
    return accessToken;
  }
}
