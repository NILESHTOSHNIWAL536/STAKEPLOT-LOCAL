import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/auth_service/login_apis.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import '../../Utils/snackBar.dart';
import '../routers_api.dart';
import 'force_logout.dart';

class OtpService {
  static void getOTP(context, String name, String email) async {
    var response = await postDataApiCallwithOutSharedPref(otpRoutes.sendOtp, {
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
      var response = await postDataApiCallwithOutSharedPref(otpRoutes.sendOtp,
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
          otpRoutes.verifyOtp, {'email': email, 'otp': deleteOtp});
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

  static Future<bool> verifyOTPForLogin(BuildContext context, String email,
       String otp, dynamic loginResponse, bool isForcedLogin,
      {bool isNewUser = false}) async {
    try {
      if (isNewUser) {
        bool verify = await OtpService.verifyDeleteOTP(context, email, otp);
        acceptReset.value = false;
        if (verify) LoginService.pushToRegister(context, email);
      } else if (isForcedLogin) {
        acceptReset.value = false;
        ForceLogout.forceLogoutUser(
            sessionId: loginResponse['existingSessionId'],
            email: email,
            context: context,
            existingDeviceName: "",
            otp: otp);
      } else {
        LoginService.loginUser(
            emailController: TextEditingController(text: email),
            context: context,
            otp: otp);
      }
    } catch (error) {}

   acceptReset.value = false;
    return false;
  }
}
