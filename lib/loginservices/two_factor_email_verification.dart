import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../Constants/app_styles.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../Constants/theme_helper.dart';
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
  final FocusNode _otpFocusNode = FocusNode();
  RxString _otpCode = "123456".obs;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNode.requestFocus();
      _checkClipboardForOtp();
    });
  }

  @override
  void dispose() {
    otpController.dispose();
    _otpFocusNode.dispose();
    otpTimer2?.cancel();
    super.dispose();
  }

  void _handleOtpChange(String value) {
    // Clamp to otpLength in case paste brings in more digits
    final clamped = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (clamped.length > _otpLength) {
      otpController.text = clamped.substring(0, _otpLength);
      otpController.selection =
          TextSelection.collapsed(offset: _otpLength);
      return;
    }
    _otpCode.value = clamped;
    _isOtpValid.value = clamped.length == _otpLength;
    if (_isOtpValid.value) verifyEmail();
  }

  Future<void> _checkClipboardForOtp() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = (data?.text ?? '').trim();
    if (text.length == _otpLength && RegExp(r'^\d{6}$').hasMatch(text)) {
      otpController.text = text;
      _handleOtpChange(text);
    }
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
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: context.appColors.background),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSizes.h20),
                    topHeader(),

                    isOtpWrong2.value || _isOtpValid.value
                        ? Lottie.asset(
                            "assets/splashScreen/wrongOTP.json",
                            fit: BoxFit.cover,
                          )
                        : Lottie.asset(
                            "assets/splashScreen/OutboundIntegrations.json",
                            // fit: BoxFit.cover,
                            // height: 400,
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
            c: context.appColors.onBackground),
      ],
    );
  }

  Widget acceptButton() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1,
        margin:
            const EdgeInsets.symmetric(vertical: AppSizes.p10, horizontal: 10),
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
                        color: Colors.white,
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
                canResendOtp2.value ? "" : "${otpCountdown2.value} S",
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 12,
                  color: canResendOtp2.value
                      ? context.appColors.onBackground
                      : context.appColors.onBackground,
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
                "Resend OTP",
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 12,
                  color: canResendOtp2.value
                      ? context.appColors.primary
                      : context.appColors.hintText,
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
      child: AutofillGroup(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Invisible TextField ───────────────────────────────────────
            // Owns the focus and exposes autofillHints so iOS shows
            // "From Mail: 123456" in the QuickType bar above the keyboard.
            // On Android, clipboard auto-paste (see _checkClipboardForOtp)
            // covers the equivalent use-case since Android doesn't scan email.
            Positioned.fill(
              child: TextField(
                controller: otpController,
                focusNode: _otpFocusNode,
                autofillHints: const [AutofillHints.oneTimeCode],
                keyboardType: TextInputType.number,
                maxLength: _otpLength,
                style: const TextStyle(color: Colors.transparent, fontSize: 1),
                cursorColor: Colors.transparent,
                cursorWidth: 0,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: _handleOtpChange,
              ),
            ),

            // ── Visual pin boxes ──────────────────────────────────────────
            // IgnorePointer: taps pass through to the TextField above.
            IgnorePointer(
              child: PinCodeTextField(
                appContext: context,
                length: _otpLength,
                controller: otpController,
                autoFocus: false,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.underline,
                  fieldHeight: MediaQuery.of(context).size.width * 0.13,
                  fieldWidth: MediaQuery.of(context).size.width * 0.13,
                  inactiveColor: context.appColors.border,
                  selectedColor: context.appColors.primary,
                  activeColor: context.appColors.primary,
                  inactiveFillColor: Colors.transparent,
                  selectedFillColor: Colors.transparent,
                  activeFillColor: Colors.transparent,
                ),
                enableActiveFill: false,
                textStyle: TextStyle(
                  fontSize: 20,
                  color: context.appColors.onBackground,
                  fontWeight: FontWeight.w600,
                ),
                onChanged: _handleOtpChange,
              ),
            ),
          ],
        ),
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
