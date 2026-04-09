import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/finvu_otp_screen.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/integration.dart';
import 'package:flutter_application_code_stakeplot/loginservices/login.dart';
import 'package:flutter_application_code_stakeplot/repository/reward_repository.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/googlesignin/credentials.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/bottombar.dart';
import 'package:get/get.dart';

import '../Constants/colorcodes.dart';
import '../Constants/core/app_padding_sizes.dart';

RxBool loadConsentId = false.obs;
RxBool isOtpWrong = false.obs;
RxInt otpCountdown = 30.obs;
RxBool canResendOtp = false.obs;
Timer? otpTimer;

class MobileNumber extends StatefulWidget {
  bool flag;
  bool formEditDetails;
  MobileNumber({super.key, this.flag = false, this.formEditDetails = false});

  @override
  State<MobileNumber> createState() => _MobileNumberState();
}

class _MobileNumberState extends State<MobileNumber> {
  final TextEditingController _phoneController = TextEditingController();
  final int _otpCodeLength = 6;
  final RxString _otpCode = ''.obs;
  final RxBool _isOtpValid = false.obs;
  TextEditingController otpController = TextEditingController();
  final regex = RegExp(r'^[0-9]*$');

  // Whether phone field has valid 10-digit input
  RxBool _isPhoneValid = false.obs;

  @override
  void initState() {
    super.initState();
    initFinvuManager(context);
    loadConsentId.value = false;
    if (widget.flag) {
      _phoneController.text =
          number.value.toString() == '0' ? '' : number.value.toString();
      _isPhoneValid.value = _phoneController.text.length == 10;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    otpTimer?.cancel();
    super.dispose();
  }

  void _onPhoneChanged(String v) {
    loadConsentId.value = false;
    _isPhoneValid.value = v.length == 10;
  }

  Future<void> _sendOtp() async {
    if (loadConsentId.value) return;
    if (_phoneController.text.length != 10) {
      snackBarCalledfail(
          context, SnackbarData().enterValidMobile, Colorcodes.red);
      return;
    }

    number.value = _phoneController.text;
    loadConsentId.value = true;

    await getConsentHandleId(context);
    final otpRef = await login(context);

    if (otpRef.isNotEmpty) {
      otpController = TextEditingController();
      startOtpTimer();
      isOtpWrong.value = false;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FinvuVerifyOtpScreen(
            otpController: otpController,
            otpLength: _otpCodeLength,
            otpCode: _otpCode,
            isOtpValid: _isOtpValid,
          ),
        ),
      );
    } else {
      snackBarCalledfail(context, SnackbarData().errorGeneratingOtp);
    }

    loadConsentId.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        logoutAndDisconnect();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F0E8),
        bottomNavigationBar: SafeArea(child: BottomBar()),
        body: SafeArea(
          child: Column(
            children: [
              // ── Top bar ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_sharp),
                      color: const Color(0xFF1C1C1E),
                      onPressed: () {
                        logoutAndDisconnect();
                        Navigator.pop(context);
                      },
                      padding: EdgeInsets.zero,
                    ),
                    const Spacer(),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD1D1D6)),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.question_mark_rounded,
                          size: 16, color: Color(0xFF8E8E93)),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // ── Title ────────────────────────────────────────
                      Text(
                        'OTP Verification',
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w700,
                            fontSize: 30,
                            color: const Color(0xFF1C1C1E)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your mobile number linked to your bank account to continue',
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w400,
                            fontSize: 14,
                            color: const Color(0xFF8E8E93)),
                      ),

                      const SizedBox(height: 36),

                      // ── Phone field ──────────────────────────────────
                      _PhoneField(
                        controller: _phoneController,
                        regex: regex,
                        onChanged: _onPhoneChanged,
                      ),

                      const Spacer(),

                      // ── Continue button ──────────────────────────────
                      Obx(() {
                        final isValid = _isPhoneValid.value;
                        final isLoading = loadConsentId.value;

                        return GestureDetector(
                          onTap: isValid && !isLoading ? _sendOtp : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: isValid
                                  ? const Color(0xFF3D3B5E)
                                  : const Color(0xFFD1D1D6),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white),
                                    )
                                  : Text(
                                      'Continue',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isValid
                                              ? Colors.white
                                              : const Color(0xFF8E8E93)),
                                    ),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 16),

                      // ── T&C ─────────────────────────────────────────
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: FinvuStrings().termsAndConditionsAgreement,
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w400,
                                fontSize: 12,
                                color: const Color(0xFF8E8E93)),
                            children: [
                              TextSpan(
                                text: FinvuStrings().termsAndConditions,
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: const Color(0xFF3D3B5E)),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => redirectToUrl(
                                      context, Credentials.FinvuUrl),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Phone input field ─────────────────────────────────────────────────────

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final RegExp regex;
  final ValueChanged<String> onChanged;

  const _PhoneField({
    required this.controller,
    required this.regex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mobile Number',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1C1C1E))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
          ),
          child: Row(
            children: [
              // Country code
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Color(0xFFE5E5EA), width: 0.8),
                  ),
                ),
                child: const Text(
                  '+91',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E)),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  maxLength: 10,
                  enableInteractiveSelection: false,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(regex),
                  ],
                  onChanged: onChanged,
                  contextMenuBuilder: (ctx, state) => const SizedBox(),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1C1C1E)),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '10-digit mobile number',
                    hintStyle:
                        const TextStyle(fontSize: 14, color: Color(0xFFAEAEB2)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── OTP timer ─────────────────────────────────────────────────────────────

void startOtpTimer() {
  canResendOtp.value = false;
  otpCountdown.value = 30;
  otpTimer?.cancel();
  otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (otpCountdown.value > 0) {
      otpCountdown.value--;
    } else {
      canResendOtp.value = true;
      otpTimer?.cancel();
    }
  });
}
