import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/signInOut/reset.dart';
import 'package:page_transition/page_transition.dart';

void checkEmail(context, email, otp, name) async {
  var response=await postDataApiCallwithOutSharedPref('${url}/otp/verify-otp', {
      'email': email,
      "otp": otp.toString(),
    });

  if (getFlagOfResponse(response))
  {
    snackBarCalled(context, "Accepted Opt...!", Colors.black);
    acceptReset.value = false;
    Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.fade,
          alignment: Alignment.bottomRight,
          duration: Durations.long1,
          child: ResetPassword(
            email: email,
            name: name,
          ),
          isIos: true,
        ));
  } else {
    acceptReset.value = false;
    snackBarCalled(context, "Invalid Opt...!", Colors.red);
  }
}

void changePassword(context, email, p1, p2) async 
{

    var response=await postDataApiCallwithOutSharedPref('${url}/user/resetPassword', {
      'email': email,
      "newPassword": p1,
      "confirmNewPassword": p2,
    });
  if (getFlagOfResponse(response)) {
    snackBarCalledSignup(context, "Password changed...!", Colors.black);
    Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    Navigator.pushNamed(context, "/");
  } else {
    snackBarCalled(context, "Can't change...!", Colors.red);
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
    snackBarCalled(context, "ReSended Otp To Email Id...!", Colors.black);
  } else {
    snackBarCalled(context, "can't send opt!", Colors.red);
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
    snackBarCalled(context, "ReSended Otp To Email Id...!", Colors.black);
  } else {
    snackBarCalled(context, "can't send opt!", Colors.red);
  }
}
