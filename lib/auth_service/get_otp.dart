import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/auth_service/force_logout.dart';
import 'package:flutter_application_code_stakeplot/auth_service/login_apis.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import '../../Utils/snackBar.dart';

class OtpService {
  static void getOTP(context, String name, String email) async {
    var response = await postDataApiCallwithOutSharedPref('${url}/otp/send', {
      'email': email,
      'name': name,
    });
    if (getFlagOfResponse(response)) {
      snackBarCalled(context, SnackbarData().sentOtpToEmail, Colors.black);
    } else {
      snackBarCalledfail(context, SnackbarData().cantSendOtp, Colors.red);
    }
  }

  static void getOTPForTwoFactorAuth(
    context,
    String name,
    String email,
  ) async {
    var response = await postDataApiCallwithOutSharedPref(
      '$url/otp/send',
      {'email': email, 'name': name, 'isTwoFactor': true, "type": 'twoFactor'},
    );

    // Try decoding JSON safely
    dynamic decodedResponse;
    try {
      decodedResponse = jsonDecode(response.body);
    } catch (e) {
      decodedResponse = null;
    }

    if (getFlagOfResponse(response)) {
      snackBarCalled(context, decodedResponse['data'], Colors.black);
    } else if (response.statusCode == 429) {
      if (decodedResponse != null &&
          decodedResponse is Map &&
          decodedResponse['message'] != null) {
        snackBarCalledfail(context, decodedResponse['message'], Colors.red);
      } else {
        snackBarCalledfail(context,
            "Too many OTP requests. Please try again later.", Colors.red);
      }
    } else {
      snackBarCalledfail(context, decodedResponse['message'], Colors.red);
    }
  }

  static Future<bool> getOTPDeleteCall(
      BuildContext context, String name, String email) async {
    try {
      var response = await postDataApiCallwithOutSharedPref(
          '${url}/otp/resend-otp',
          {'email': email, 'name': name, 'type': "deleteAccount"});
      if (getFlagOfResponse(response)) {
        snackBarCalled(context, SnackbarData().sentOtpToEmail, Colors.black);
        return true;
      } else {
        snackBarCalledfail(context, SnackbarData().cantSendOtp, Colors.red);
        return false;
      }
    } catch (e) {
      snackBarCalledfail(context, 'Failed to send OTP: $e', Colors.red);
      return false;
    }
  }

// this is for two factor auth in login

  static Future<bool> verifyDeleteOTP(
      BuildContext context, String email, String deleteOtp) async {
    try {
      var response = await postDataApiCallwithOutSharedPref(
          '${url}/otp/verify-otp', {'email': email, 'otp': deleteOtp});
      if (getFlagOfResponse(response)) {
        snackBarCalled(context, 'OTP verified successfully',
            Colors.black); // Adjusted message for clarity
        return true;
      } else {
        snackBarCalledfail(
            context, 'Invalid OTP', Colors.red); // Adjusted message for clarity
        return false;
      }
    } catch (e) {
      snackBarCalledfail(context, 'Failed to verify OTP: $e', Colors.red);
      return false;
    }
  }

  static Future<bool> verifyOTPForLogin(
      BuildContext context,
      String email,
      String password,
      String otp,
      dynamic loginResponse,
      bool isForcedLogin) async {
    try {
      var response =
          await postDataApiCallwithOutSharedPref('${url}/otp/verify-otp', {
        'email': email,
        'otp': otp,
      });
      if (getFlagOfResponse(response)) {
        if (!isForcedLogin) {
          LoginService.loginUser(
            TextEditingController(text: email),
            TextEditingController(text:password), // Password not available, adjust backend if needed
            context,
            apis_flag,
          );
        } else {
          var loggedInDevice = loginResponse['loggedInDevice'];
          if (loggedInDevice != null &&
              loggedInDevice is Map<String, dynamic>) {
            ForceLogout.forceLogoutUser(
                loginResponse['existingSessionId'],
                email,
                password,
                context,
                loggedInDevice['deviceId'] ??
                    "", // Check if deviceId exists and use it
                (loggedInDevice['brand'] ?? "").toString() +
                    " " +
                    (loggedInDevice['device'] ?? "").toString());
          } else {
            ForceLogout.forceLogoutUser(
                loginResponse['existingSessionId'],
                email,
                password,
                context,
                "", // Empty string if loggedInDevice is not a Map or is null
                "");
          }
        }
        return true;
      } else {
        snackBarCalledfail(context, 'Invalid OTP. Please try again.', Colors.red);
        return false;
      }
    } catch (e) {
      snackBarCalledfail(context, 'OTP verification failed. Please try again.', Colors.red);
      return false;
    }
  }
}
