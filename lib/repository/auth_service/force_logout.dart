import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/loginservices/userLoginedAlready.dart';
import 'package:flutter_application_code_stakeplot/repository/auth_service/login_apis.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/repository/notification_repository.dart';

import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';

class ForceLogout {
  static void forceLoginShowModal(
      context, response, emailController) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return UserLoginedAlready(
            data: response['error'],
            email: emailController,
          );
      },
    );
  }

  static Future<void> forceLogoutUser(
      {
       required String sessionId,
       required String email,
       required BuildContext context,
       required String existingDeviceName,
       required String otp
      }
    ) async {
    try {
      if(deviceData['deviceId']==""){
         deviceData['deviceId']="Niklewnknwk";
      }
      updateDeviceData(deviceData);
      var response =
          await postDataApiCallwithOutSharedPref(AuthApiRoutes.forceLogin, {
        "sessionId": sessionId,
        "email": email,
        "otp": otp.toString(),
        "deviceInfo": deviceData,
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
        snackBarCalled(context, 'Existing session logged out.',);
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
