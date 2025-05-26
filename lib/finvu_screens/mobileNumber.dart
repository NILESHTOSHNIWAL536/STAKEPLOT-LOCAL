
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/integration.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/login.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/appbar_widget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/bottombar.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/profile_screen/webView.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

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
  final String termsUrl = "https://finvu.in/terms"; // Replace with actual URL

  late final WebViewController controller;
  
 

  @override
  void initState() {
    super.initState();
    initFinvuManager(context);
    loadConsentId.value=false;

    // Step 1: Initialize WebView platform params
    try {
      late final PlatformWebViewControllerCreationParams params;
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        );
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }

      // Step 2: Create the WebViewController
      controller = WebViewController.fromPlatformCreationParams(params)
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse("https://finvu.in/terms"));

      // Step 3: Configure Android-specific settings
      if (controller.platform is AndroidWebViewController) {
        AndroidWebViewController.enableDebugging(true);
        (controller.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false);
      }
    } catch (e) {}
    if (widget.flag) {
      _phoneController.text = number.value.toString();
    }
  }

  Future<void> _launchURL() async {
    final Uri url = Uri.parse(termsUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $termsUrl';
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
        bottomNavigationBar: BottomBar(),
         appBar: getAppBar(context),
        body: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
                     
"Finvu will send an OTP to your mobile number.",
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
                    controller: _phoneController, // Attach the controller
                    maxLength: 10,
                    autocorrect: true,
                    keyboardType: TextInputType.phone, // Phone input keyboard
                    onChanged: (c){
                       loadConsentId.value=false;
                    },
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
                  SizedBox(
                      height: 60), // Add spacing between TextField and button
                  // Button for "Get OTP"
                  GestureDetector(
                    onTap: () async {
                      // Handle OTP logic here
                      if(loadConsentId.value)return;
                      if (_phoneController.text.length != 10) {
                        snackBarCalled(context,SnackbarData().enterValidMobile, Colorcodes.red);
                        return;
                      }
                      ;
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
                    child: Obx(()=> loadConsentId.value?  getspinner(context,""):getButton(context, "Continue")),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      text: "By clicking continue, you agree to Finvu's ",
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w500,
                        fontSize: 10,
                        color: AppColors.bg1,
                      ),
                      children: [
                        TextSpan(
                            text: "Terms & Conditions",
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
    );
  }

  void click() {
    // Step 4: Reuse the initialized controller instead of creating a new one
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(controller: controller),
      ),
    );
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
              child: textStyle("Register with Finvu to start sharing", 16,
                  AppColors.bg1, FontWeight.bold),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
            //   child: textStyle(
            //       "We recommend using the mobile number linked to the accounts you want to share", 16, AppColors.bg1, FontWeight.bold),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: textStyle("Enter the OTP sent to ${number.value}", 15,
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
                  activeFillColor: Colors.white,
                  activeColor: isOtpWrong.value ? Colors.red : Colors.blue,
                  selectedFillColor: Colors.white,
                  selectedColor: isOtpWrong.value ? Colors.red : Colors.blue,
                  inactiveFillColor: Colors.grey[200],
                  inactiveColor: isOtpWrong.value ? Colors.red : Colors.grey,
                ),
                enableActiveFill: true,
                textStyle: TextStyle(fontSize: 20, color: Colors.black),
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
                        "Incorrect OTP entered",
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
                      "Didn't you receive the OTP?  ",
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
                            ? "Resend OTP"
                            : "Resend in ${otpCountdown.value} seconds",
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