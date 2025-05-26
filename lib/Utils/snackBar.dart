import 'dart:convert';

import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

class SnackbarData {
  static final SnackbarData _instance = SnackbarData._internal();

  SnackbarData._internal();
  factory SnackbarData() => _instance;

  // Constants
  String enterValidMobile = "Please enter valid mobile number";
  String errorGeneratingOtp = "Error while generating otp Ref / or internal issue";
  String enterOtpLength = "Please enter OTP of length 6";
  String pickOneBank = "Pick at least one bank to proceed";
  String accountAdded = "The account has been successfully added for linking.";
  String maxRetries = "Maximum Retries Exceeded. Please try again after sometime.";
  String enterValidOtp = "Enter valid otp";
  String bankLinkedSuccess = "Linked Bank account Successfully...";
  String consentApproveError = "An error occurred while approving the consent request.";
  String consentApproved = "Consent request approved successfully.";
  String consentDeclined = "Successfully decline the consent request.";
  String consentDisapproveError = "Unable to disapprove the request.";

  Future<bool> fetchConstants() async {
    try {
      final response = await getDataApiCall("${url}/constant/snackbar");
      printData(response);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        data = data['data'] ?? {};

        enterValidMobile = data['enterValidMobile'] ?? enterValidMobile;
        errorGeneratingOtp = data['errorGeneratingOtp'] ?? errorGeneratingOtp;
        enterOtpLength = data['enterOtpLength'] ?? enterOtpLength;
        pickOneBank = data['pickOneBank'] ?? pickOneBank;
        accountAdded = data['accountAdded'] ?? accountAdded;
        maxRetries = data['maxRetries'] ?? maxRetries;
        enterValidOtp = data['enterValidOtp'] ?? enterValidOtp;
        bankLinkedSuccess = data['bankLinkedSuccess'] ?? bankLinkedSuccess;
        consentApproveError = data['consentApproveError'] ?? consentApproveError;
        consentApproved = data['consentApproved'] ?? consentApproved;
        consentDeclined = data['consentDeclined'] ?? consentDeclined;
        consentDisapproveError = data['consentDisapproveError'] ?? consentDisapproveError;

        return true;
      } else {
        print("Failed to load Snackbar constants: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error fetching Snackbar constants: $e");
      return false;
    }
  }
}
