// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/discoverAccount.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/linkedAccounts.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/otpScreen.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
// import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';

// class VerifyOtp extends StatefulWidget {
//   const VerifyOtp({super.key});

//   @override
//   State<VerifyOtp> createState() => _VerifyOtpState();
// }

// class _VerifyOtpState extends State<VerifyOtp> {
//   final int _otpCodeLength = 4; // Updated OTP length to 4
//   String _otpCode = ""; // Captured OTP code
//   bool _isOtpValid = false; // Validate OTP length
//   final TextEditingController _otpController = TextEditingController();

//   @override
//   void dispose() {
//     _otpController.dispose(); // Dispose controller to avoid memory leaks
//     super.dispose();
//   }

//   /// Method to validate OTP and proceed
//   void _onOtpSubmit() {
//     if (_otpCode.length == _otpCodeLength) {
//       print("OTP Entered: $_otpCode");
//       // Add your OTP verification API logic here
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("OTP Verified: $_otpCode")),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Please enter a valid OTP")),
//       );
//     }
//   }

//   /// Callback for OTP field
//   void _onOtpChanged(String otp) {
//     setState(() {
//       _otpCode = otp;
//       _isOtpValid = otp.length == _otpCodeLength;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double boxSize = MediaQuery.of(context).size.width * 0.15;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Verify OTP'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           //mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Text(
//             //   "Enter the OTP sent to your mobile number",
//             //   style: TextStyle(fontSize: 16),
//             //   textAlign: TextAlign.center,
//             // ),
//             SizedBox(height: 20),
//             TextFieldPin(
//               textController: _otpController, // Controller for the OTP field
//               autoFocus: true, // Automatically focus on the OTP field
//               codeLength: _otpCodeLength, // Set OTP length to 4
//               alignment: MainAxisAlignment.center, // Align center
//               defaultBoxSize: boxSize, // Size of each OTP box
//               margin: 8.0, // Spacing between boxes
//               selectedBoxSize: boxSize, // Highlighted box size
//               textStyle: TextStyle(fontSize: 18, color: Colors.black),
//               defaultDecoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Colors.grey),
//               ),
//               selectedDecoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Colors.blue, width: 2),
//               ),
//               onChange: _onOtpChanged, // Callback on OTP change
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 //Text("Didn't received OTP? "),
//                 // TextButton(
//                 //     onPressed: () {
//                 //       showModalBottomSheet(
//                 //           context: context,
//                 //           builder: (BuildContext context) {
//                 //             return VerifyOtp();
//                 //           });
//                 //     },
//                 //     child: Text("Didn't received OTP? ")),
//                 TextButton(onPressed: () {}, child: Text("Resend"))
//               ],
//             ),
//             SizedBox(height: 20),
//             GestureDetector(
//               onTap: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ShareAccountLogin(
//                       flag: true,
//                     ),
//                   ),
//                 );
//                 // Call ShareAccountLogin
//               }, // Enable only if valid
//               child: Container(
//                 width: MediaQuery.of(context).size.width / 1.1,
//                 padding: EdgeInsets.symmetric(
//                     horizontal: 10, vertical: 20), // Vertical padding
//                 decoration: BoxDecoration(
//                   color: _isOtpValid
//                       ? AppColors.accentColor
//                       : Colors.grey, // Button color based on validity
//                   borderRadius: BorderRadius.circular(30), // Rounded corners
//                 ),
//                 child: Center(
//                   child: Text(
//                     "Verify",
//                     style: FontManager().getTextStyle(
//                       context,
//                       lWeight: FontWeight.bold,
//                       fontSize: 18,
//                       color: AppColors.bg5,
//                     ),
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:finvu_flutter_sdk_core/finvu_linked_accounts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/access.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/LinkingAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/discoverAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/finvuAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/linkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/otpScreen.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
// import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/access.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyOtp extends StatefulWidget {
  int flag;
  final FinvuAccountLinkingRequestReference? linkingReference;
  String fid = "";
  VerifyOtp({super.key, this.flag = 0, this.linkingReference, this.fid = ""});

  @override
  State<VerifyOtp> createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  final int _otpCodeLength = 6; // OTP length
  String _otpCode = ""; // Captured OTP code
  bool _isOtpValid = false; // Validate OTP length
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose(); // Dispose controller to avoid memory leaks
    super.dispose();
  }

  /// Method to validate OTP and proceed
  // void _onOtpSubmit() {
  //   if (_otpCode.length == _otpCodeLength) {
  //     print("OTP Entered: $_otpCode");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("OTP Verified: $_otpCode")),
  //     );
  //     // Navigate to next screen or perform verification
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Please enter a valid OTP")),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final double boxSize = MediaQuery.of(context).size.width * 0.12;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: Text(
          'Verify OTP',
          style: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.accentColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            PinCodeTextField(
              appContext: context,
              length: _otpCodeLength,
              controller: _otpController,
              keyboardType: TextInputType.number,
              autoFocus: true,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(10),
                fieldHeight: boxSize,
                fieldWidth: boxSize,
                activeFillColor: Colors.white,
                activeColor: Colors.blue,
                selectedFillColor: Colors.white,
                selectedColor: Colors.blue,
                inactiveFillColor: Colors.grey[200],
                inactiveColor: Colors.grey,
              ),
              enableActiveFill: true,
              textStyle: TextStyle(fontSize: 18, color: Colors.black),
              onChanged: (value) {
                setState(() {
                  _otpCode = value;
                  _isOtpValid = value.length == _otpCodeLength;
                });
              },
              // onCompleted: (value) {
              //   _onOtpSubmit();
              // },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive OTP?",
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.bg1,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => Access(),
                    //   ),
                    // );
                    loginToAutoTractions(context);
                  },
                  child: Text(
                    "Resend",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.w400,
                      fontSize: 14,
                      color: AppColors.bg3,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _isOtpValid
                  ? () {
                      int f = widget.flag;
                      if (f == 0)
                        verify(_otpCode, context);
                      else if (f == 1) {
                        //  linkingReference
                        linkAccount(_otpCode);
                      }
                    }
                  : null,
              child: Container(
                width: MediaQuery.of(context).size.width / 1.1,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                decoration: BoxDecoration(
                  color: _isOtpValid
                      ? AppColors.accentColor
                      : Colors.grey, // Button color based on validity
                  borderRadius: BorderRadius.circular(12),
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
            ),
          ],
        ),
      ),
    );
  }

  void linkAccount(otp) async {
    try {
      // print(_controller.text);
      var data = await finvuManager.confirmAccountLinking(
          widget.linkingReference!, otp);

      snackBarCalled(context, "Linked Found SuccessFully...");
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Access(),
        ),
      );
    } catch (e) {
      snackBarCalled(context,
          "Error while Linking verify Otp/ Or Already Linked...", Colors.red);
    }

    void linkAccount(otp) async {
      try {
        // print(_controller.text);
        var data = await finvuManager.confirmAccountLinking(
            widget.linkingReference!, otp);

        snackBarCalled(context, "Linked Bank SuccessFully...");
        Navigator.pop(context);
        accountLinked.add(widget.fid);
      } catch (e) {
        snackBarCalled(context,
            "Error while Linking verify Otp/ Or Already Linked...", Colors.red);
      }
    }
  }
}
