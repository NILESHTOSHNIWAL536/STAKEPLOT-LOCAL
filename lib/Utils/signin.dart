import 'dart:convert';

import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

class SigninData {
  static final SigninData _instance = SigninData._internal();

  factory SigninData() => _instance;

  SigninData._internal();

  // Field labels
  String signInTitle = "Sign In";
  String signInSubtitle = "Sign in to your account.";
  String emailLabel = "Email";
  String passwordLabel = "Password";
  String forgotPasswordText = "Forgot Password?";
  String dontHaveAccountText = "Don’t have an account ?";
  String signUpText = "Sign Up";
  String orSignInWithText = "or Sign In with";
  String signInButtonText = "Sign In";
  String connectBankText = "Connect your bank account ";

  // Field hints
  String emailHint = "johndoe@gmail.com";
  String passwordHint = "Password";

  // Validation messages
  String emptyEmail = "Please enter an email address.";
  String invalidEmail = "Please enter a valid email address.";
  String emptyPassword = "Please enter a password.";

  Future<bool> fetchConstants() async {
    try {
      
      final response = await getDataApiCall("$url/constant/signin");
      printData(response);


      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        data = data['data'] ?? {};

        signInTitle = data['signInTitle'] ?? signInTitle;
        signInSubtitle = data['signInSubtitle'] ?? signInSubtitle;
        emailLabel = data['emailLabel'] ?? emailLabel;
        passwordLabel = data['passwordLabel'] ?? passwordLabel;
        forgotPasswordText = data['forgotPasswordText'] ?? forgotPasswordText;
        dontHaveAccountText = data['dontHaveAccountText'] ?? dontHaveAccountText;
        signUpText = data['signUpText'] ?? signUpText;
        orSignInWithText = data['orSignInWithText'] ?? orSignInWithText;
        signInButtonText = data['signInButtonText'] ?? signInButtonText;
        connectBankText = data['connectBankText'] ?? connectBankText;

        emailHint = data['emailHint'] ?? emailHint;
        passwordHint = data['passwordHint'] ?? passwordHint;

        emptyEmail = data['emptyEmail'] ?? emptyEmail;
        invalidEmail = data['invalidEmail'] ?? invalidEmail;
        emptyPassword = data['emptyPassword'] ?? emptyPassword;

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
