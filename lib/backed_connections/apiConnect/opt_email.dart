import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';


void checkEmail(context, email, otp, name) async {
 

  var response=await postDataApiCallwithOutSharedPref('${url}/otp/verify-otp', {
      'email': email,
      "otp": otp.toString(),
    });

  if (getFlagOfResponse(response))
  {
    snackBarCalled(context,SnackbarData().otpAccepted, Colors.black);
    acceptReset.value = false;
   
  } else {
    acceptReset.value = false;
    snackBarCalledfail(context,SnackbarData().otpInvalid, Colors.red);
  }
}





void resendOptUser(context, email, name) async
{
   var response=await postDataApiCallwithOutSharedPref('${url}/otp/resend-otp',{
      'email': email,
      "name": name,
    });

  if (getFlagOfResponse(response)) {
    acceptReset.value = false;
    snackBarCalled(context,SnackbarData().otpResent, Colors.black);
  } else {
    snackBarCalledfail(context,SnackbarData().otpSendFail1, Colors.red);
  }
}


void resendOpt(context, email, name) async {
 
   var response=await postDataApiCallwithOutSharedPref('${url}/otp/resend-otp',{
      'email': email,
      "name": name,
      'type': 'resetPassword'
    });

  if (getFlagOfResponse(response)) {
    acceptReset.value = false;
    snackBarCalled(context,SnackbarData().otpResentSuccess, Colors.black);
  } else {
    snackBarCalledfail(context,SnackbarData().otpSendFail2, Colors.red);
  }
}
