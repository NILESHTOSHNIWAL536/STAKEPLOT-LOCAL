import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

//  RxBool acceptReset=false.obs;

class ResetOtp extends StatefulWidget {
  String name;
  String email;

  ResetOtp({Key? key, required this.email, required this.name})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<ResetOtp> {
  Widget InputDate(lableText, keyBoard, Textcontroller, index) {
    double width = MediaQuery.of(context).size.width;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 3),
        // color: Color.fromRGBO(249, 246, 238, 1),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1, horizontal: 5),
          width: width <= 350
              ? width / 6
              : width <= 500
                  ? width / 7
                  : width / 8,
          alignment: Alignment.center,
          child: Center(
            child: TextFormField(
              keyboardType: keyBoard,
              maxLength: 1,
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              // controller: Textcontroller,

              decoration: InputDecoration(
                counterText: '', // Hide the counter
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(color: Colorcodes.budgetDarkGreen)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(color: Colorcodes.budgetDarkGreen)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(color: Colorcodes.budgetDarkGreen)),
              ),

              onChanged: (value) => _handleTextChanged(value, index),
            ),
          ),
        ),
      ),
    );
  }

  //  final int _otpLength = 6;
  // late List<TextEditingController> _controllers= List.generate(_otpLength, (_) => TextEditingController());
  // late List<FocusNode> _focusNodes=List.generate(_otpLength, (_) => FocusNode());
  final int _otpLength = 6;
  late List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  late List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());
  final int _otpCodeLength = 6; // OTP length
  RxString _otpCode = "".obs; // Captured OTP code
  RxBool _isOtpValid = false.obs; // Validate OTP length
  TextEditingController otpController = TextEditingController();

  RxInt otpCountdown3 = 30.obs;
  RxBool canResendOtp3 = false.obs;
  RxBool isOtpWrong3 = false.obs;
  Timer? otpTimer3;

  @override
  void initState() {
    super.initState();
    startOtpTimer3();
    // _controllers = List.generate(_otpLength, (_) => TextEditingController());
    // _focusNodes = List.generate(_otpLength, (_) => FocusNode());
  }

  void startOtpTimer3() {
    canResendOtp3.value = false;
    otpCountdown3.value = 30;
    otpTimer3?.cancel(); // Cancel any existing timer
    otpTimer3 = Timer.periodic(Duration(seconds: 1), (timer) {
      if (otpCountdown3.value > 0) {
        otpCountdown3.value--; // Decrement the countdown
      } else {
        canResendOtp3.value = true;
        timer.cancel(); // Stop the timer when it reaches 0
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    otpTimer3?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colorcodes.white,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height / 1.3,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              topHeader(),
              textStyle(
                  context: context,
                  text: StringConstant.otpText,
                  fontWeight: FontWeight.w400,
                  fontsize: 10),
              const SizedBox(
                height: 40,
              ),
              verifyOpt(),
              acceptButton(),
              SizedBox(
                height: Colorcodes.paddingSize * 2,
              ),
              InkWell(
                  onTap: () {
                    //  resendOptUser(context,widget.data['email'],widget.data['name']);
                  },
                  child: resendOtp()),
            ],
          ),
        ),
      ),
    );
  }

  Widget topHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Text(("Security Pin"),
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.bold, fontSize: 22, color: Colors.black)),
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
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(Colorcodes.borderRadius10)),
        child: InkWell(
          onTap: () {
            acceptReset.value = true;
            checkEmail(context, widget.email, _otpCode.value, widget.name);
          },
          child: Obx(() => Center(
                child: acceptReset.value
                    ? Spinner(
                        color: Colorcodes.white,
                        size: 20,
                      )
                    : Text(("Accept"),
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colorcodes.white)),
              )),
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
            Text(("Didn’t you receive the OTP ? "),
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.w400,
                  fontSize: 13,
                  color: Colorcodes.iconBackGround,
                  // decoration: TextDecoration.underline
                )),
            Obx(
              () => canResendOtp3.value?InkWell(
                onTap: () {
                  resendOpt(context, widget.email, widget.name);
                  startOtpTimer3();
                  isOtpWrong3.value = false;
                  otpController.clear(); // Clear OTP field on resend
                  _otpCode.value = ""; // Reset OTP code
                  _isOtpValid.value = false;
                },
                child: Text(
                   
                        "Resend OTP",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 12,
                      color: canResendOtp3.value
                          ? AppColors.primaryColor
                          : Colors.grey,
                      // decoration: TextDecoration.underline
                    )),
              )
              :Text(
                   
                        
                      "Resend in ${otpCountdown3.value} seconds",
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 12,
                      color: canResendOtp3.value
                          ? AppColors.primaryColor
                          : Colors.grey,
                      // decoration: TextDecoration.underline
                    )),
            )
          ],
        ),
      ),
    );
  }

  Widget verifyOpt() {
    return Column(
      children: [
        Padding(
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
              activeColor: Colors.blue,
              selectedFillColor: Colors.white,
              selectedColor: Colors.blue,
              inactiveFillColor: Colors.grey[200],
              inactiveColor: Colors.grey,
            ),
            enableActiveFill: true,
            textStyle: TextStyle(fontSize: 20, color: Colors.black),
            onSubmitted: (value) {
              _otpCode.value = value;
              _isOtpValid.value = value.length == _otpCodeLength;
              if (_isOtpValid.value) {
                acceptReset.value = true;
                checkEmail(context, widget.email, _otpCode.value, widget.name);
              } else {
                if( _isOtpValid.value = value.length == _otpCodeLength)
                isOtpWrong3.value = true;
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => isOtpWrong3.value
            ? Align(
              alignment: Alignment.bottomRight,
              child: Text(
                  "Incorrect OTP",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
            )
            : SizedBox.shrink()),
      ],
    );
  }
}


//  resendOpt(context, widget.email, widget.name);  


 