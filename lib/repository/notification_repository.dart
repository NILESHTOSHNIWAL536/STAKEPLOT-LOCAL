
import 'dart:convert';

import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';

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
      
    String urlPath = SendNotificationsRoutes.SendNotificationsToDevice;

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
