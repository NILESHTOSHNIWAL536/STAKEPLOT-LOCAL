import 'dart:convert';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

class ProfileScreenStrings {
  // 1. Static instance
  static final ProfileScreenStrings _instance = ProfileScreenStrings._internal();

  // 2. Private constructor
  ProfileScreenStrings._internal();

  // 3. Factory constructor
  factory ProfileScreenStrings() => _instance;

  // ✅ Field labels
  String profileTitle = "Profile";
  String editProfileLabel = "Edit";
  String communityProfileLabel = "Community profile";
  String friendsListLabel = "Friends list";
  String friendsListLabelMasked = "Masked list";
  String historyArchivesLabel = "History archives";
  String termsConditionsLabel = "Terms & conditions";
  String logoutLabel = "Log out";
  String appVersionLabel = "Stakeplot\nApp version 2.0.0";

  // ✅ Sublabels
  String communityProfileSubLabel = "Check your community profile";
  String friendsListSubLabel = "Check your friends list here";
  String friendsListSubLabelMasked = "Check your Masked list here";
  String historyArchivesSubLabel = "Find your hidden history here";
  String termsConditionsSubLabel = "Please follow our terms and conditions";
  String logoutSubLabel = "You can login and log out from your account";

  // ✅ Validation/Error Messages
  String authenticationFailed = "Authentication failed. Please try again.";
  String biometricNotSupported = "Biometric authentication is not supported on this device.";
  String logoutError = "Error occurred while logging out. Please try again.";
  String profileLoadError = "Failed to load profile data.";

   // ✅ Field labels (for EditDetails)
  String editProfileTitle = "Edit Profile";
  String personalDetailsLabel = "Personal details";
  String accountDetailsLabel = "Account Details";
  String resetPinLabel = "Reset PIN";
  String addBankLabel = "+ Add Bank";
  String emailLabel = "Email";
  String nameLabel = "name";
  String numberLabel = "Number";
  String dobLabel = "dob";

  // ✅ Sublabels (for EditDetails)
  String resetPinSubLabel = "Are you sure you want to reset your PIN?";
  String resetPinInstructionSubLabel = "You'll need to set a new PIN after reset.";

  // ✅ Validation/Error Messages (for EditDetails)
  String resetPinAuthReason = "Authenticate to reset your PIN";
  String resetPinSuccess = "PIN reset successfully.";
  String resetPinError = "Failed to reset PIN. Please try again.";
  String cancelLabel = "Cancel";
  String resetLabel = "Reset";

    // ✅ Field labels (for Friends List or similar screen)
  String networkLabel = "Connections";
  String postsLabel = "Posts";
  String friendsListTitle = "Friends list";
  String friendsListTitleMaked = "Masked Friends list";
  String searchHint = "Search...";

  Future<bool> fetchConstants() async {
    try {
      final response = await getDataApiCall("${url}/constant/profile");
      printData(response);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        data = data['data'] ?? {};
        profileTitle = data['profileTitle'] ?? profileTitle;
        editProfileLabel = data['editProfileLabel'] ?? editProfileLabel;
        communityProfileLabel = data['communityProfileLabel'] ?? communityProfileLabel;
        friendsListLabel = data['friendsListLabel'] ?? friendsListLabel;
        historyArchivesLabel = data['historyArchivesLabel'] ?? historyArchivesLabel;
        termsConditionsLabel = data['termsConditionsLabel'] ?? termsConditionsLabel;
        logoutLabel = data['logoutLabel'] ?? logoutLabel;
        appVersionLabel = data['appVersionLabel'] ?? appVersionLabel;
        communityProfileSubLabel = data['communityProfileSubLabel'] ?? communityProfileSubLabel;
        friendsListSubLabel = data['friendsListSubLabel'] ?? friendsListSubLabel;
        historyArchivesSubLabel = data['historyArchivesSubLabel'] ?? historyArchivesSubLabel;
        termsConditionsSubLabel = data['termsConditionsSubLabel'] ?? termsConditionsSubLabel;
        logoutSubLabel = data['logoutSubLabel'] ?? logoutSubLabel;
        authenticationFailed = data['authenticationFailed'] ?? authenticationFailed;
        biometricNotSupported = data['biometricNotSupported'] ?? biometricNotSupported;
        logoutError = data['logoutError'] ?? logoutError;
        profileLoadError = data['profileLoadError'] ?? profileLoadError;

         // EditDetails strings
        editProfileTitle = data['editProfileTitle'] ?? editProfileTitle;
        personalDetailsLabel = data['personalDetailsLabel'] ?? personalDetailsLabel;
        accountDetailsLabel = data['accountDetailsLabel'] ?? accountDetailsLabel;
        resetPinLabel = data['resetPinLabel'] ?? resetPinLabel;
        addBankLabel = data['addBankLabel'] ?? addBankLabel;
        emailLabel = data['emailLabel'] ?? emailLabel;
        nameLabel = data['nameLabel'] ?? nameLabel;
        numberLabel = data['numberLabel'] ?? numberLabel;
        dobLabel = data['dobLabel'] ?? dobLabel;
        resetPinSubLabel = data['resetPinSubLabel'] ?? resetPinSubLabel;
        resetPinInstructionSubLabel = data['resetPinInstructionSubLabel'] ?? resetPinInstructionSubLabel;
        resetPinAuthReason = data['resetPinAuthReason'] ?? resetPinAuthReason;
        resetPinSuccess = data['resetPinSuccess'] ?? resetPinSuccess;
        resetPinError = data['resetPinError'] ?? resetPinError;
        cancelLabel = data['cancelLabel'] ?? cancelLabel;
        resetLabel = data['resetLabel'] ?? resetLabel;
  // Friends List or similar screen strings
        networkLabel = data['networkLabel'] ?? networkLabel;
        postsLabel = data['postsLabel'] ?? postsLabel;
        friendsListTitle = data['friendsListTitle'] ?? friendsListTitle;
        friendsListTitleMaked = data['friendsListTitleMaked'] ?? friendsListTitleMaked;
        searchHint = data['searchHint'] ?? searchHint;
        return true;
      } else {
        print("Failed to load constants: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error fetching constants: $e");
      return false;
    }
  }
}