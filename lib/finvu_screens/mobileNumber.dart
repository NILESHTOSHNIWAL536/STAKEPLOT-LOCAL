import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/integration.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/discoverAccount.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/linkedAccounts.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/otpScreen.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/verifyOTP.dart';

class MobileNumber extends StatefulWidget {
  const MobileNumber({super.key});

  @override
  State<MobileNumber> createState() => _MobileNumberState();
}

class _MobileNumberState extends State<MobileNumber> {
  // TextEditingController to capture phone number input
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose(); // Dispose of controller to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text('Mobile Number'),
      ),
       bottomSheet: bottomSheet(context),
      body: Padding(
        padding: EdgeInsets.only(top: 60, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // TextField for entering phone number
            TextField(
              controller: _phoneController, // Attach the controller
              keyboardType: TextInputType.phone, // Phone input keyboard
              decoration: InputDecoration(
                hintText: 'Enter 10 digit Number',
                hintStyle: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.bg3,
                ),
                filled: true,
                fillColor: Colorcodes.greyLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                //prefixIcon: Icon(Icons.phone),
                //hintText: 'Mobile Number',
              ),
            ),
            SizedBox(height: 60), // Add spacing between TextField and button
            // Button for "Get OTP"
            GestureDetector(
              onTap: () {
                // Handle OTP logic here
                if(_phoneController.text.length!=10){
                    snackBarCalled(context, "Please enter valid mobile number....",Colorcodes.red);
                    return;
                };
                String phoneNumber = _phoneController.text;
                number.value=phoneNumber;
                LOGOUT();
                loginToAutoTractions(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerifyOtp(),
                  ),
                );

                //print("Phone Number: $phoneNumber");
                // Add your logic for sending OTP
              },
              child: getButton(context, "Get OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
