import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';








void resendOptUser(context, email, name) async
{
   var response=await postDataApiCallwithOutSharedPref('${url}/otp/resend-otp',{
      'email': email,
      "name": name,
    });

  if (getFlagOfResponse(response)) {
    acceptReset.value = false;
    snackBarCalled(context,SnackbarData().otpResent,);
  } else {
    snackBarCalledfail(context,SnackbarData().otpSendFail1,);
  }
}



