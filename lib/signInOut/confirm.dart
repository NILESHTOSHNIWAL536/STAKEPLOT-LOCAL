import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/opt_email.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/signInOut/avatar.dart';
import 'package:flutter_application_code_stakeplot/userSignInAndSignUp/wave.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class conform extends StatefulWidget {
  var data;
  String url;
  conform({Key? key, required this.data, required this.url}) : super(key: key);

  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<conform> {
  final int _otpLength = 6;
  late List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  late List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());
  final int _otpCodeLength = 6;
  RxString _otpCode = "".obs;
  RxBool _isOtpValid = false.obs;
  TextEditingController otpController = TextEditingController();

  // Timer-related variables
  RxInt otpCountdown2 = 30.obs;
  RxBool canResendOtp2 = false.obs;
  RxBool isOtpWrong2 = false.obs;
  Timer? otpTimer2;

  @override
  void initState() {
    super.initState();
    if (acceptReset.value) acceptReset.value = false;
    startOtpTimer2(); // Start the timer on init
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    otpTimer2?.cancel();
    super.dispose();
  }

  void startOtpTimer2() {
    canResendOtp2.value = false;
    otpCountdown2.value = 30;
    otpTimer2?.cancel(); // Cancel any existing timer
    otpTimer2 = Timer.periodic(Duration(seconds: 1), (timer) {
      if (otpCountdown2.value > 0) {
        otpCountdown2.value--; // Decrement the countdown
      } else {
        canResendOtp2.value = true;
        timer.cancel(); // Stop the timer when it reaches 0
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colorcodes.white,
        body: Container(
          // padding: const EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                // Color(0xFF9B8BC6),
                // Color(0xFF6568A7),
                // Color(0xFF272841),
                Color(0xFF6568A7),
                Color(0xFF272841),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    topHeader(),
                    textStyleOnly2(
                        context: context,
                        text: "Enter the 6-digit OTP sent to your email",
                        fontWeight: FontWeight.w300,
                        fontsize: 14,
                        color: Colorcodes.white),
                    const SizedBox(height: 40),
                    verifyOpt(),
                    acceptButton(),
                    SizedBox(height: Colorcodes.paddingSize * 2),
                    resendOtp(),

                    // Simplified structure
                  ],
                ),
              ),
              buildBottomWaves(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget topHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Text(
        "Verify Your Email",
        style: FontManager().getTextStyle(context,
            lWeight: FontWeight.bold, fontSize: 22, color: Colorcodes.white),
      ),
    );
  }

  void _handleTextChanged(String value, int index) {
    if (value.length == 1 && index < _otpLength - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  Widget acceptButton() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colorcodes.white,
          borderRadius: BorderRadius.circular(Colorcodes.borderRadius10),
        ),
        child: InkWell(
          onTap: () {
            // Add validation to check if OTP is not empty and all digits are filled
            if (otpController.text.isEmpty) {
              // Show error message for empty field
              snackBarCalledfail(context, 'Please enter the OTP');
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text('Please enter the OTP'),
              //     backgroundColor: Colors.red,
              //   ),
              // );
              return;
            }

            if (otpController.text.length != 6) {
              // Show error message for incomplete OTP
              snackBarCalledfail(context, 'Please enter all 6 digits of the OTP');
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text('Please enter all 6 digits of the OTP'),
              //     backgroundColor: Colors.red,
              //   ),
              // );
              return;
            }

            // Check if all characters are digits
            if (!RegExp(r'^[0-9]{6}$').hasMatch(otpController.text)) {
               snackBarCalledfail(context, 'Please enter only numeric digits');
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text('Please enter only numeric digits'),
              //     backgroundColor: Colors.red,
              //   ),
              // );
              return;
            }

            acceptReset.value = true;
          },
          child: Obx(
            () => Center(
              child: acceptReset.value
                  ? Verify()
                  : Text(
                      "Verify & Accept",
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colorcodes.black),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget resendOtp() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Colorcodes.paddingSize / 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Didn't you receive the OTP? ",
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.w400,
                fontSize: 14,
                color: Colorcodes.white,
              ),
            ),
            Obx(
              () => GestureDetector(
                onTap: canResendOtp2.value
                    ? () {
                        resendOptUser(
                            context, widget.data['email'], widget.data['name']);
                        startOtpTimer2();
                        isOtpWrong2.value = false;
                        otpController.clear(); // Clear OTP field on resend
                        _otpCode.value = ""; // Reset OTP code
                        _isOtpValid.value = false; // Reset validity
                      }
                    : null,
                child: Text(
                  canResendOtp2.value
                      ? "Resend OTP"
                      : "Resend in ${otpCountdown2.value} seconds",
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 12,
                    color:
                        canResendOtp2.value ? Colorcodes.black : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget verifyOpt() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
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
          fieldHeight: MediaQuery.of(context).size.width * 0.13,
          fieldWidth: MediaQuery.of(context).size.width * 0.13,
          activeFillColor: Colors.white,
          activeColor: AppColors.finSpaceColor,
          selectedFillColor: Colors.white,
          selectedColor: Colors.blue,
          inactiveFillColor: Colors.grey[200],
          inactiveColor: Colors.white,
        ),
        enableActiveFill: true,
        textStyle: TextStyle(fontSize: 20, color: Colors.black),
        onChanged: (value) {
          _otpCode.value = value;
          _isOtpValid.value = value.length == _otpCodeLength;
          if (_isOtpValid.value) {
            acceptReset.value = true;
            storeData(context, widget.data, _otpCode.value, widget.url);
          }
        },
      ),
    );
  }
}
