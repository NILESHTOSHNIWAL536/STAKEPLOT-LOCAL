import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/discoverAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/finvuAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/linkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/otpScreen.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
// import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';

class VerifyOtp extends StatefulWidget {
  const VerifyOtp({super.key});

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  final int _otpCodeLength = 4; // Updated OTP length to 4
  String _otpCode = ""; // Captured OTP code
  bool _isOtpValid = false; // Validate OTP length
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose(); // Dispose controller to avoid memory leaks
    super.dispose();
  }

  /// Method to validate OTP and proceed
  void _onOtpSubmit() {
    if (_otpCode.length == _otpCodeLength) {
      print("OTP Entered: $_otpCode");
      // Add your OTP verification API logic here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP Verified: $_otpCode")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid OTP")),
      );
    }
  }

  /// Callback for OTP field
  void _onOtpChanged(String otp) {
    setState(() {
      _otpCode = otp;
      _isOtpValid = otp.length == _otpCodeLength;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double boxSize = MediaQuery.of(context).size.width * 0.15;
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text(
            //   "Enter the OTP sent to your mobile number",
            //   style: TextStyle(fontSize: 16),
            //   textAlign: TextAlign.center,
            // ),
            SizedBox(height: 20),
            // TextFieldPin(
            //   textController: _otpController, // Controller for the OTP field
            //   autoFocus: true, // Automatically focus on the OTP field
            //   codeLength: _otpCodeLength, // Set OTP length to 4
            //   alignment: MainAxisAlignment.center, // Align center
            //   defaultBoxSize: boxSize, // Size of each OTP box
            //   margin: 8.0, // Spacing between boxes
            //   selectedBoxSize: boxSize, // Highlighted box size
            //   textStyle: TextStyle(fontSize: 18, color: Colors.black),
            //   defaultDecoration: BoxDecoration(
            //     color: Colors.grey[200],
            //     borderRadius: BorderRadius.circular(10),
            //     border: Border.all(color: Colors.grey),
            //   ),
            //   selectedDecoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(10),
            //     border: Border.all(color: Colors.blue, width: 2),
            //   ),
            //   onChange: _onOtpChanged, // Callback on OTP change
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Didn't received OTP? "),
                TextButton(onPressed: () {}, child: Text("Resend"))
              ],
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                         verify("673194",context);
              }, // Enable only if valid
              child: Container(
                width: MediaQuery.of(context).size.width / 1.1,
                padding: EdgeInsets.symmetric(
                    horizontal: 10, vertical: 20), // Vertical padding
                decoration: BoxDecoration(
                  color: _isOtpValid
                      ? AppColors.accentColor
                      : Colors.grey, // Button color based on validity
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                child: Center(
                  child: Text(
                    "Verify",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.bg5,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
