import 'dart:convert';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import '../routes/route_constant.dart';

class SignupData {
  // 1. Static instance
  static final SignupData _instance = SignupData._internal();

  // 2. Private constructor
  SignupData._internal();

  // 3. Factory constructor
  factory SignupData() => _instance;

  // ✅ Field labels
   String createAccount = "Create Account";
   String usernameLabel = "Username";
   String dobLabel = "Date of Birth";
   String emailLabel = "Email";
   String passwordLabel = "Password";
   String confirmPasswordLabel = "Confirm Password";

  String usernameSubLabel = "Enter your username";
  String dobSubLabel = "Date of Birth";
  String emailSubLabel = "johndoe@gmail.com";
  String passwordSubLabel = "Password";
  String confirmPasswordSubLabel = "Confirm Password";
  String changePasswordSubLabel = "Change Password";

  // ✅ Validation Messages
   String emptyUsername = "Please enter a username.";
   String emptyUsernameValid = "Please enter a valid  username.";
   String invalidUsername = "Username must start with a letter (A-Z or a-z).";
   String shortUsername = "Username must be at least 3 characters long.";

   String emptyEmail = "Please enter an email address.";
   String invalidEmail = "Please enter a valid email address.";

   String emptyPassword = "Please enter a password.";
   String shortPassword = "Password must be at least 8 characters long.";
   String weakPassword = "Password must include uppercase, lowercase, number, and special character.";
   String emptyConfirmPassword = "Please confirm your password.";
   String passwordMismatch = "Passwords do not match.";
   String emptyDob = "Please enter your date of birth.";
   String accountExit = "Already have an account ? ";
   String Continue = "Continue";
   String errorInvalidOtp = "Invalid Otp";



 Future<bool> fetchConstants() async {
    try {
      final response = await getDataApiCall(ConstantRoutes.signup);
      if (response.statusCode == 200)
      {
        var data = jsonDecode(response.body);
        data=data['data'] ?? {};
        createAccount = data['createAccount'] ?? createAccount;
        usernameLabel = data['usernameLabel'] ?? usernameLabel;
        emptyUsernameValid = data['emptyUsernameValid'] ?? emptyUsernameValid;
        dobLabel = data['dobLabel'] ?? dobLabel;
        emailLabel = data['emailLabel'] ?? emailLabel;
        passwordLabel = data['passwordLabel'] ?? passwordLabel;
        confirmPasswordLabel = data['confirmPasswordLabel'] ?? confirmPasswordLabel;
        usernameSubLabel = data['usernameSubLabel'] ?? usernameSubLabel;
        dobSubLabel = data['dobSubLabel'] ?? dobSubLabel;
        emailSubLabel = data['emailSubLabel'] ?? emailSubLabel;
        passwordSubLabel = data['passwordSubLabel'] ?? passwordSubLabel;
        confirmPasswordSubLabel = data['confirmPasswordSubLabel'] ?? confirmPasswordSubLabel;
        emptyUsername = data['emptyUsername'] ?? emptyUsername;
        invalidUsername = data['invalidUsername'] ?? invalidUsername;
        shortUsername = data['shortUsername'] ?? shortUsername;
        emptyEmail = data['emptyEmail'] ?? emptyEmail;
        invalidEmail = data['invalidEmail'] ?? invalidEmail;
        emptyPassword = data['emptyPassword'] ?? emptyPassword;
        shortPassword = data['shortPassword'] ?? shortPassword;
        weakPassword = data['weakPassword'] ?? weakPassword;
        emptyConfirmPassword = data['emptyConfirmPassword'] ?? emptyConfirmPassword;
        passwordMismatch = data['passwordMismatch'] ?? passwordMismatch;
        emptyDob = data['emptyDob'] ?? emptyDob;
        accountExit = data['accountExit'] ?? accountExit;
        Continue = data['Continue'] ?? Continue;
        errorInvalidOtp = data['errorInvalidOtp'] ?? errorInvalidOtp;
        changePasswordSubLabel = data['changePasswordSubLabel'] ?? changePasswordSubLabel;

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }

 }

}