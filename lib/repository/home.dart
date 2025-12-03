import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/banksCardsSlider.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/routes/route_user_login.dart';




void setPasswordApiCalled(context, String password) async {
  if (password == "00") {
    snackBarCalledfail(context, SnackbarData().pinSetFail00,);
    return; // Exit the function without setting the PIN
  }

  var urlPath = UserRoutes.cupertino;
  final response = await postDataApiCall(urlPath, {
    'pin': password.toString(),
  });

  if (getFlagOfResponse(response)) {
    userController.cupertinoPin.value = password;
    hideBackAccountPassword.value = false;

    snackBarCalled(context, SnackbarData().pinSetSuccess,);
  } else {
    snackBarCalledfail(context, SnackbarData().pinSetFail);
  }
  Navigator.pop(context);
}

// Lock flag to prevent duplicate API calls
bool _isVerifyingPin = false;

// Debounce timer (optional, if you want to debounce the API call)
Timer? _verifyDebounce;

/// Call this function instead of [pinPasswordVerify] to apply debounce
void pinPasswordVerifyDebounced(
    String password, BuildContext context, Function setBack) {
  if (_verifyDebounce?.isActive ?? false) _verifyDebounce?.cancel();

  _verifyDebounce = Timer(const Duration(milliseconds: 800), () {
    pinPasswordVerify(password, context, setBack);
  });
}

/// Main PIN verification function with locking and error handling
void pinPasswordVerify(
    String password, BuildContext context, Function setBack) async {
  if (_isVerifyingPin) return; // Prevent multiple calls
  _isVerifyingPin = true;

  try {
    final response = await getDataApiCall(UserRoutes.cupertino + "$password");

    if (response.statusCode == 200) {
      hideBackAccountPassword.value = true;

      // Auto-hide after 5 seconds
      Timer(const Duration(seconds: 5), () {
        hideBackAccountPassword.value = false;

        // Reset values
        firstDigit.value = 0;
        secondDigit.value = 0;
        digitLoad.value = !digitLoad.value;

        setBack(); // Callback
      });
      return;
    } else {
      var errorResponse = jsonDecode(response.body);

      userController.cupertinoAttemptCount.value =
          (errorResponse['count'] ?? 0) > 4;
      if (userController.cupertinoAttemptCount.value) {
        snackBarCalledfail(context, SnackbarData().maxLimitSetFail);
      }
      hideBackAccountPassword.value = false;
    }
  } catch (e) {
    hideBackAccountPassword.value = false;
  } finally {
    _isVerifyingPin = false;
  }
}

void seletedBankUpdateInfo(id, context) async {
  var response = await getDataApiCall(UserRoutes.selectedBank + "${id}");
  if (response.statusCode == 200 || response.statusCode == 200) {
  } else {}
}



bool isCurrentYear(String date, int y) {
  try {
    DateTime parsedDate = DateTime.parse(date); // Parse the date string
    return parsedDate.year == y; // Compare year
  } catch (e) {
    return false; // Return false if parsing fails
  }
}

bool isCurrentMonth(String date, int m) {
  try {
    DateTime parsedDate = DateTime.parse(date);
    return parsedDate.month == m; // Compare month
  } catch (e) {
    return false;
  }
}


