import 'package:finvu_flutter_sdk_core/finvu_fip_details.dart';
import 'package:finvu_flutter_sdk_core/finvu_fip_info.dart';
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
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class MobileNumber extends StatefulWidget {
  const MobileNumber({super.key});

  @override
  State<MobileNumber> createState() => _MobileNumberState();
}

class _MobileNumberState extends State<MobileNumber> {
  // TextEditingController to capture phone number input
  final TextEditingController _phoneController = TextEditingController();
  // Validate OTP length
  final TextEditingController _otpController = TextEditingController();
  final int _otpCodeLength = 6; // OTP length
  RxString _otpCode = "".obs; // Captured OTP code
  RxBool _isOtpValid = false.obs; // Validate OTP length
  TextEditingController otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose(); // Dispose of controller to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      // appBar: AppBar(
      //   title: Text('Mobile Number'),
      // ),
      //bottomSheet: bottomSheet(context),
      body: Padding(
        padding: EdgeInsets.only(top: 100, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "OTP Verification",
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.bold,
                fontSize: 20,
                color: AppColors.bg1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "We will send you one-time OTP to your mobile number",
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppColors.bg3,
                ),
              ),
            ),
            // TextField for entering phone number
            TextField(
              controller: _phoneController, // Attach the controller
              keyboardType: TextInputType.phone, // Phone input keyboard
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone_android_outlined),
                prefixIconColor: AppColors.primaryColor,
                hintText: 'Enter 10 digit Number',
                hintStyle: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w500,
                  fontSize: 12,
                  color: AppColors.bg3,
                ),
                filled: true,
                fillColor: AppColors.button,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
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
                if (_phoneController.text.length != 10) {
                  snackBarCalled(context, "Please enter valid mobile number",
                      Colorcodes.red);
                  return;
                }
                ;
                String phoneNumber = _phoneController.text;
                number.value = phoneNumber;
                LOGOUT();
                loginToAutoTractions(context);
                otpController = TextEditingController();
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => VerifyOtp(),
                //   ),
                // );
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    
                    builder: (BuildContext context) {
                      
                      return verifyaotp(context);
                    });

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

  Widget verifyaotp(context) {
    return DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        
        builder: (context, ScrollController) {
          return SingleChildScrollView(
            controller: ScrollController,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2.7,
              decoration: const BoxDecoration(
                  color: AppColors.mt,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  )),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: 10),
                  //   child: Center(
                  //       child: textStyle("Securely authorize each selected account", 14,
                  //           Colorcodes.black, FontWeight.bold)),
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 25, horizontal: 20),
                    child: textStyle(
                        "OTP Verification", 20, AppColors.bg1, FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    child: textStyle("Enter the OTP sent to ${number.value}",
                        15, AppColors.bg1, FontWeight.w400),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: PinCodeTextField(
                      appContext: context,
                      length: _otpCodeLength,
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      autoFocus: true,
                      animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(10),
                        fieldHeight: MediaQuery.of(context).size.width * 0.12,
                        fieldWidth: MediaQuery.of(context).size.width * 0.12,
                        activeFillColor: Colors.white,
                        activeColor: Colors.blue,
                        selectedFillColor: Colors.white,
                        selectedColor: Colors.blue,
                        inactiveFillColor: Colors.grey[200],
                        inactiveColor: Colors.grey,
                      ),
                      enableActiveFill: true,
                      textStyle: TextStyle(fontSize: 20, color: Colors.black),
                      onChanged: (value) {
                        _otpCode.value = value;
                        _isOtpValid.value = value.length == _otpCodeLength;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: GestureDetector(
                        onTap: _isOtpValid.value
                            ? () {
                                if (_isOtpValid.value) {
                                  verify(_otpCode.value, context);
                                } else {
                                  snackBarCalled(
                                      context, "please enter otp of length 6");
                                }
                              }
                            : null,
                        child: Obx(
                          () => _isOtpValid.value
                              ? getColorVerify()
                              : getColorVerify(),
                        )),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget textStyle(text,
      [double fontsize = 12,
      Color c = AppColors.bg1,
      FontWeight fontWeight = FontWeight.w500]) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 7,
        ),
        Text(
          text.toString(),
          style: FontManager().getTextStyle(context,
              lWeight: fontWeight, fontSize: fontsize, color: c),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget getColorVerify() {
    return Container(
      width: MediaQuery.of(context).size.width / 1.1,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: _isOtpValid.value
            ? AppColors.primaryColor
            : AppColors.bg3, // Button color based on validity
        borderRadius: BorderRadius.circular(16),
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
    );
  }
}
