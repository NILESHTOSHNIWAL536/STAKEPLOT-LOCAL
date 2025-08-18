import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/opt_email.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/userSignInAndSignUp/wave.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class TwoFactorEmailVerification extends StatefulWidget {
  final Map<String, dynamic> data;

  const TwoFactorEmailVerification({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  _TwoFactorEmailVerificationState createState() =>
      _TwoFactorEmailVerificationState();
}

class _TwoFactorEmailVerificationState
    extends State<TwoFactorEmailVerification> {
  final int _otpLength = 6;
  final TextEditingController otpController = TextEditingController();
  RxString _otpCode = "".obs;
  RxBool _isOtpValid = false.obs;

  // Timer-related variables
  RxInt otpCountdown2 = 30.obs;
  RxBool canResendOtp2 = false.obs;
  RxBool isOtpWrong2 = false.obs;
  Timer? otpTimer2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (acceptReset.value) {
        acceptReset.value = false;
      }
    });
    startOtpTimer2();
  }

  @override
  void dispose() {
    otpController.dispose();
    otpTimer2?.cancel();
    super.dispose();
  }

  void startOtpTimer2() {
    canResendOtp2.value = false;
    otpCountdown2.value = 30;
    otpTimer2?.cancel();
    otpTimer2 = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpCountdown2.value > 0) {
        otpCountdown2.value--;
      } else {
        canResendOtp2.value = true;
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colorcodes.white,
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
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
                      color: Colorcodes.white,
                    ),
                    const SizedBox(height: 40),
                    verifyOpt(),
                    acceptButton(),
                    SizedBox(height: Colorcodes.paddingSize * 2),
                    resendOtp(),
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
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        "Verify Your Email",
        style: FontManager().getTextStyle(
          context,
          lWeight: FontWeight.bold,
          fontSize: 22,
          color: Colorcodes.white,
        ),
      ),
    );
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
          onTap: () async {
            verifyEmail();
          },
          child: Obx(
            () => Center(
              child: acceptReset.value
                  ? Verify() // Your loading widget
                  : Text(
                      "Verify & Accept",
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colorcodes.black,
                      ),
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
                          context,
                          widget.data['email'],
                          widget.data['name'],
                        );
                        startOtpTimer2();
                        isOtpWrong2.value = false;
                        otpController.clear();
                        _otpCode.value = "";
                        _isOtpValid.value = false;
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
                    color: canResendOtp2.value
                        ? AppColors.backgroundColor
                        : AppColors.backgroundColor,
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
        length: _otpLength,
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
        textStyle: const TextStyle(fontSize: 20, color: Colors.black),
        onChanged: (value) {
          _otpCode.value = value;
          _isOtpValid.value = value.length == _otpLength;
          if (_isOtpValid.value) {
            verifyEmail();
          }
        },
      ),
    );
  }

  void verifyEmail() async {
    if (otpController.text.isEmpty) {
      snackBarCalledfail(context, 'Please enter the OTP');
      return;
    }
    if (otpController.text.length != 6) {
      snackBarCalledfail(context, 'Please enter all 6 digits of the OTP');
      return;
    }
    if (!RegExp(r'^[0-9]{6}$').hasMatch(otpController.text)) {
      snackBarCalledfail(context, 'Please enter only numeric digits');
      return;
    }

    acceptReset.value = true;
    // Verify OTP for login
    bool isVerified = await verifyOTPForLogin(
      context,
      widget.data['email'],
      widget.data['password'],
      otpController.text,
      widget.data['response'],
      widget.data['isForcedLogin'], // Pass the login response
    );

    if (!isVerified) {
      isOtpWrong2.value = true;
      acceptReset.value = false;
    }
  }
}
