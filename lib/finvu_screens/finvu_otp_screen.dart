import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/loginservices/login.dart';

import '../backed_connections/apis_connect.dart';
import '../backed_connections/googlesignin/credentials.dart';
import '../repository/reward_repository.dart';
import 'appbar_widget.dart';
import 'bottombar.dart';
import 'integration.dart';
import 'mobileNumber.dart';

class FinvuVerifyOtpScreen extends StatefulWidget {
  final TextEditingController otpController;
  final int otpLength;
  final RxString otpCode;
  final RxBool isOtpValid;

  const FinvuVerifyOtpScreen({
    super.key,
    required this.otpController,
    required this.otpLength,
    required this.otpCode,
    required this.isOtpValid,
  });

  @override
  State<FinvuVerifyOtpScreen> createState() => _FinvuVerifyOtpScreenState();
}

class _FinvuVerifyOtpScreenState extends State<FinvuVerifyOtpScreen> {
  void click() {
      redirectToUrl(context, Credentials.FinvuUrl);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.newbg,
      bottomNavigationBar: SafeArea(child: BottomBar()),
         appBar: getAppBar(context),
      body: SafeArea(
        child: Container(
                      height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.only(top: 10, left: 12, right: 12, bottom: 5),
           
         
          child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              
               
              
                  /// TITLE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      FinvuStrings().registerWithFinvu,
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w700,
                        fontSize: 32,
                        color: AppColors.accentColor,
                      ),
                    ),
                  ),
              
               
                  Padding(
                     padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                    child: Text(
                      "${FinvuStrings().enterOtpSentTo} ${number.value}",
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
              
             
                 
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    
                child: Column(
                  children: [
                    
                     Container(
                        width: MediaQuery.sizeOf(context).width/1.2,
                       child: PinCodeTextField(
                                         appContext: context,
                                         length: widget.otpLength,
                                         controller: widget.otpController,
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
                                           widget.otpCode.value = value;
                                           widget.isOtpValid.value = value.length == widget.otpLength;
                                       
                                           if (widget.isOtpValid.value) {
                        _checkOtp(context);
                                           }
                                         },
                                       ),
                     ),
                
                    /// ERROR
                    Obx(
                      () => isOtpWrong.value
                          ? Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                FinvuStrings().incorrectOtp,
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w300,
                                  fontSize: 10,
                                  color: Colors.red,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(
                            () => Text(
                              canResendOtp.value
                                  ? ""
                                  : " ${otpCountdown.value}s",
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w400,
                                fontSize: 12,
                                color: canResendOtp.value
                                    ? AppColors.primaryColor
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          Obx(
                            () => GestureDetector(
                              onTap: canResendOtp.value
                                  ? () {
                                      login(context);
                                      startOtpTimer();
                                      isOtpWrong.value = false;
                                    }
                                  : null,
                              child: Text(
                                
                                    FinvuStrings().resendOtp,
                                    
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: canResendOtp.value
                                      ? AppColors.accentColor
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                SizedBox(height: 20,),
                    Obx(
                      () => GestureDetector(
                        onTap: widget.isOtpValid.value
                            ? () => _checkOtp(context)
                            : null,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: widget.isOtpValid.value
                                ? AppColors.primaryColor
                                : AppColors.bg3,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              FinvuStrings().verify,
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
                    ),
                
                    const SizedBox(height: 10),
                     Padding(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                
                              text: FinvuStrings().termsAndConditionsAgreement,
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w400,
                                fontSize: 14,
                                color: AppColors.grey,
                              ),
                              children: [
                                TextSpan(
                                    text:  FinvuStrings().termsAndConditions,
                                    style: FontManager().getTextStyle(
                                      context,
                                      lWeight: FontWeight.w500,
                                      fontSize: 14,
                                      ///decoration: UnderlineInputBorder(),
                                      color: Colors.blue,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        click();
                                      }
                                    // Make it clickable
                
                                    ),
                                   
                              ],
                            ),
                          ),
                        ),
                      ),
                   
                       
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _checkOtp(BuildContext context) {
    if (!widget.isOtpValid.value) {
      snackBarCalled(context, SnackbarData().enterOtpLength);
      return;
    }

    verify(widget.otpCode.value, context).then((isValid) {
      if (!isValid) {
        isOtpWrong.value = true;
      }
    });
  }
}
