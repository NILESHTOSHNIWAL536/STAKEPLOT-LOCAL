import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
import 'package:flutter_application_code_stakeplot/loginservices/wave.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../Constants/app_styles.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../image_service/avatarProfile.dart';
import '../repository/auth_service/otp_service.dart';

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
    acceptReset.value = false;
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
    return Scaffold(
      backgroundColor: Colorcodes.white,
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
           color: AppColors.newbg
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     SizedBox(height: AppSizes.h20),
                    topHeader(),
                  
                   isOtpWrong2.value || _isOtpValid.value? Lottie.asset(
          "assets/splashScreen/wrongOTP.json",
          fit: BoxFit.cover,
        ): Lottie.asset(
          "assets/splashScreen/OutboundIntegrations.json",
          // fit: BoxFit.cover,
          height: 400,
         
          
        ),
                    // const SizedBox(height: 340),
                    verifyOpt(),
                    
                    SizedBox(height: AppSizes.h10),
                    resendOtp(),
                     acceptButton(),
                  ],
                ),
              ),
             
            ],
          ),
        ),
      ),
    );
  }

  Widget topHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AvatarProfileImageZero(url: Sign.appSignInimage, width: 14, height: 14),
        SizedBox(height: AppSizes.h8),
        textStyle(
            context: context,
            text: 'OTP sent to your email',
            fontWeight: FontWeight.w300,
            fontsize: 18,
            c: AppColors.accentColor
            ),
      ],
    );
  }

  Widget acceptButton() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        margin: const EdgeInsets.symmetric(vertical: AppSizes.p10, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: AppSizes.p20),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(Colorcodes.borderRadius10),
        ),
        child: InkWell(
          onTap: () async {
            verifyEmail();
          },
          child: Obx(
            () => Center(
              child: acceptReset.value
                  ? Verify()
                  : Text(
                      "Verify",
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w500,
                        fontSize: 16,
                        color: AppColors.backgroundColor,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget resendOtp() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: AppSizes.p12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
         
          Obx(
            () => GestureDetector(
              onTap: canResendOtp2.value
                  ? () {
                      resendOtpToUser(
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
                    ? ""
                    : "${otpCountdown2.value} S",
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 12,
                  color: canResendOtp2.value
                      ? AppColors.accentColor
                      : AppColors.accentColor,
                ),
              ),
            ),
          ),
        
          Obx(
            () => GestureDetector(
              onTap: canResendOtp2.value
                  ? () {
                      // resendOtpToUser(
                      //   context,
                      //   widget.data['email'],
                      //   widget.data['name'],
                      // );
                      // startOtpTimer2();
                      // isOtpWrong2.value = false;
                      // otpController.clear();
                      // _otpCode.value = "";
                      // _isOtpValid.value = false;
                    }
                  : null,
              child: Text(
                
                    "Resend OTP"
                   ,
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 12,
                  color:canResendOtp2.value
                      ? AppColors.accentColor
                      : AppColors.greyCard,
                ),
              ),
            ),
          ),
        
        ],
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
        shape: PinCodeFieldShape.underline,

        fieldHeight: MediaQuery.of(context).size.width * 0.13,
        fieldWidth: MediaQuery.of(context).size.width * 0.13,

        // underline colors
        inactiveColor: Colors.grey.shade400,
        selectedColor: AppColors.finSpaceColor,
        activeColor: AppColors.finSpaceColor,

        // these must be transparent for underline style
        inactiveFillColor: Colors.transparent,
        selectedFillColor: Colors.transparent,
        activeFillColor: Colors.transparent,
      ),

      enableActiveFill: false, // 🔴 IMPORTANT for underline
      textStyle: const TextStyle(
        fontSize: 20,
        color: AppColors.accentColor,
        fontWeight: FontWeight.w600,
      ),

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
    bool isVerified = await OtpService.verifyOTPForLogin(
      context,
      widget.data['email'],
      otpController.text,
      widget.data['response'],
      widget.data['isForcedLogin'], // Pass the login response
      isNewUser: widget.data['newUser'] ?? false, // Pass the login response
    );

    if (!isVerified) {
      isOtpWrong2.value = true;
    }
     acceptReset.value = false;
  }
}
