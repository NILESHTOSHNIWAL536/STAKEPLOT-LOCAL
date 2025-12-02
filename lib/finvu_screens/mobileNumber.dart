import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/integration.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/repository/reward.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/googlesignin/credentials.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/appbar_widget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/bottombar.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';


RxBool loadConsentId=false.obs;
RxBool isOtpWrong = false.obs;
RxInt otpCountdown = 30.obs; // Reactive integer for countdown
  RxBool canResendOtp = false.obs;
   Timer? otpTimer;
class MobileNumber extends StatefulWidget {
  bool flag;
  bool formEditDetails = false;
  MobileNumber({super.key, this.flag = false,this.formEditDetails = false});

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
  final RxBool show = true.obs;
  final regex = RegExp(r'^[0-9]*$');

  @override
  void initState() {
    super.initState();
    initFinvuManager(context);
    loadConsentId.value=false;
    if (widget.flag) {
      _phoneController.text = number.value.toString()=="0"?"":number.value.toString();
    }
  }

 

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    otpTimer?.cancel(); // Dispose of controller to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        logoutAndDisconnect();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        bottomNavigationBar: SafeArea(child: BottomBar()),
         appBar: getAppBar(context),
        body: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  
                    Text(
                      FinvuStrings().otpVerification,
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
          FinvuStrings().finvuOtpMessage,
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w400,
                          fontSize: 14,
                          color: AppColors.bg3,
                        ),
                      ),
                    ),
                    // TextField for entering phone number
                   TextFormField(
                      controller: _phoneController,
                      maxLength: 10,
                      enableInteractiveSelection: false, 
                      autocorrect: false,
                      enableSuggestions: false,
                      keyboardType: TextInputType.phone,
                      inputFormatters:  [
                        FilteringTextInputFormatter.allow(regex),
                      ],
                      onChanged: (c){
                         loadConsentId.value=false;
                      },
                      contextMenuBuilder: (context, editableTextState) {
                            return Container(); // returns empty widget to disable menu
                          },
                      decoration: InputDecoration(
                        
                        prefixIcon: const Icon(Icons.phone_android_outlined),
                        prefixIconColor: AppColors.primaryColor,
                        hintText: FinvuStrings().enter10DigitNumber,
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
                      )
                                    
                        //prefixIcon: Icon(Icons.phone),
                        //hintText: 'Mobile Number',
                      ),
                    
                    SizedBox(
                        height: 60), // Add spacing between TextField and button
                    // Button for "Get OTP"
                    GestureDetector(
                      onTap: () async {
                        // Handle OTP logic here
                        if(loadConsentId.value)return;
                        if (_phoneController.text.length != 10) {
                          snackBarCalledfail(context,SnackbarData().enterValidMobile, Colorcodes.red);
                          return;
                        }
          
                        // final uuid = Uuid();
                        // handleId.value = uuid.v4();
          
                        String phoneNumber = _phoneController.text;
                        number.value = phoneNumber;
          
                       loadConsentId.value=true;
                      await   getConsentHandleId(context);
                     String otpRef =   await login(context);
                     if(otpRef!=""){
                        otpController = TextEditingController();
                        startOtpTimer();
                        isOtpWrong.value = false;
                        showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return verifyaotp(context);
                            });
                     }else
                     {
                       snackBarCalledSignup(context, SnackbarData().errorGeneratingOtp);
                     }
                       loadConsentId.value=false;
                      },
                      child: Obx(()=> loadConsentId.value?  getspinner(context,""):getButton(context, FinvuStrings().continueButton)),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        text: FinvuStrings().termsAndConditionsAgreement,
                        style: FontManager().getTextStyle(
                          context,
                          lWeight: FontWeight.w500,
                          fontSize: 10,
                          color: AppColors.bg1,
                        ),
                        children: [
                          TextSpan(
                              text:  FinvuStrings().termsAndConditions,
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.w500,
                                fontSize: 12,
                                //decoration: UnderlineInputBorder(),
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
          ),
        ),
      ),
    );
  }



  void click() {
      redirectToUrl(context, Credentials.FinvuUrl);
  }

  Widget verifyaotp(context) {
    return AnimatedPadding(
      padding: MediaQuery.of(context)
          .viewInsets, // Adjusts padding when keyboard appears
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 3,
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
            Padding(
              padding: const EdgeInsets.only(top: 25, left: 20, right: 20),
              child: textStyle( FinvuStrings().registerWithFinvu, 16,
                  AppColors.bg1, FontWeight.bold),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
            //   child: textStyle(
            //       "We recommend using the mobile number linked to the accounts you want to share", 16, AppColors.bg1, FontWeight.bold),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: textStyle( "${FinvuStrings().enterOtpSentTo} ${number.value}", 15,
                  AppColors.bg1, FontWeight.w400),
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
                  activeFillColor: AppColors.backgroundColor,
                  activeColor: isOtpWrong.value ? Colors.red : Colors.blue,
                  selectedFillColor: AppColors.backgroundColor,
                  selectedColor: isOtpWrong.value ? Colors.red : Colors.blue,
                  inactiveFillColor: Colors.grey[200],
                  inactiveColor: isOtpWrong.value ? Colors.red : Colors.grey,
                ),
                enableActiveFill: true,
                textStyle: TextStyle(fontSize: 20, color: AppColors.accentColor),
                onChanged: (value) {
                  _otpCode.value = value;
                  _isOtpValid.value = value.length == _otpCodeLength;
                  if (_isOtpValid.value) {
                    checkOtp();
                  }
                },
              ),
            ),
            Obx(
              () => isOtpWrong.value
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(40, 0, 0, 5),
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
                  : SizedBox.shrink(), // Empty widget when OTP is not wrong
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Text(
                      FinvuStrings().didntReceiveOtp,
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w200,
                        fontSize: 12,
                        color: AppColors.bg3,
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
                              // Restart the timer on resend
                            }
                          : null,
                      child: Text(
                        canResendOtp.value
                                ? FinvuStrings().resendOtp:
                                "${FinvuStrings().resendInSeconds} ${otpCountdown.value} seconds",
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
                  ),
                ],
              ),
            ),
            Center(
              child: GestureDetector(
                  onTap: _isOtpValid.value
                      ? () {
                          checkOtp();
                        }
                      : null,
                  child: Obx(
                    () =>
                        _isOtpValid.value ? getColorVerify() : getColorVerify(),
                  )),
            ),
          ],
        ),
      ),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
      decoration: BoxDecoration(
        color: _isOtpValid.value
            ? AppColors.primaryColor
            : AppColors.bg3, // Button color based on validity
        borderRadius: BorderRadius.circular(30),
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
    );
  }

  void checkOtp() {
    if (_isOtpValid.value) {
      verify(_otpCode.value, context).then((isValid) {
        if (!isValid) {
          setState(() {
            isOtpWrong.value = true; // Set wrong OTP state
          });
        }
      });
    } else {
      snackBarCalled(context, SnackbarData().enterOtpLength);
    }
  }

  
}




 void startOtpTimer() {
    canResendOtp.value = false;
    otpCountdown.value = 30; // Reset countdown using .value
    otpTimer?.cancel(); // Cancel any existing timer
    otpTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (otpCountdown.value > 0) {
        otpCountdown.value--; // Decrease countdown reactively
      } else {
        canResendOtp.value = true;
        otpTimer?.cancel();
      }
      // setState(
      //     () {}); // Ensure the UI updates (optional, since Obx should handle it)
    });
  }