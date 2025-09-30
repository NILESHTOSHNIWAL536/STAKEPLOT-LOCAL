import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/animated/userLoginedAlready.dart';
import 'package:flutter_application_code_stakeplot/auth_service/login_apis.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import '../backed_connections/apiConnect/signInAndOut.dart';

class ForceLogout {
  static void forceLoginShowModal(
      context, response, emailController, passwordController) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return UserLoginedAlready(
            data: response.body,
            email: emailController,
            userpassword: passwordController);
      },
    );
  }

  static Future<void> forceLogoutUser(
      String sessionId,
      String email,
      String userpassword,
      BuildContext context,
      String existingDeviceId,
      String existingDeviceName) async {
    try {
      if(deviceData['deviceId']==""){
         deviceData['deviceId']=existingDeviceId.isEmpty?"123":existingDeviceId;
      }
      var response =
          await postDataApiCallwithOutSharedPref('${url}/user/force-login', {
        "sessionId": sessionId,
        "email": email,
        "userpassword": userpassword,
        "deviceInfo": deviceData.value,
      });
      if (getFlagOfResponse(response)) {
        final body = jsonDecode(response.body);
        // Notify the logged-out device (if applicable)
        if (body['data']?['_id'] != null)
      {
          sendNotificationsToDevice(
            body['data']['_id'],
            context,
            "You have been logged out from StakePlot!",
          );
        }
        LoginService.loginCalledData(response, context);
        await screenDataLocalStorage();
        snackBarCalled(context, 'Existing session logged out.', Colors.green);
      } 
      else {
        snackBarCalledfail(context, 'Failed to log out existing session.', Colors.red);
      }
    } catch (e)
    {
      snackBarCalledfail(context, 'Error during forced logout. Please try again.', Colors.red);
    }
  }
}
