import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/core/app_shadows.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/Constants/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/googlesignin/google.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/repository/referral_repository.dart';
import 'package:flutter_application_code_stakeplot/signInOut/onboarding_user.dart';
import 'package:flutter_application_code_stakeplot/signInOut/userName.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../Constants/app_styles.dart';
import '../Constants/core/app_padding_sizes.dart';
import '../Constants/theme_helper.dart';
import '../backed_connections/apiAutomations/install_apk_api.dart';
import '../repository/auth_service/login_apis.dart';
import '../services/secure_storage.dart';
import 'googl_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController =
      TextEditingController(text: "testusernilesh@gmail.com");
  final AuthService authService = AuthService();
  RxString isLoggedIn = "".obs;

  @override
  void initState() {
    super.initState();
    acceptReset.value = false;
    googleSignInBool.value = false;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      isLoggedIn.value =
          await SecureStorageService().read("Screen") ?? "Not found";
      _persistReferralCodeFromArguments();
    });
  }

  Future<void> _persistReferralCodeFromArguments() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['refCode'] != null) {
      await ReferralRepository.saveIncomingReferralCode(
        args['refCode'].toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(color: context.appColors.background),
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                // Main Content

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppSizes.h100),
                      // Welcome Text
                      _buildWelcomeText(),
                      Lottie.asset(
                        "assets/splashScreen/loginScreen.json",
                        fit: BoxFit.cover,
                      ),

                      SizedBox(height: AppSizes.h30), // Email Field

                      _buildEmailField(),

                      SizedBox(height: AppSizes.h20),

                      // Sign In Button
                      _buildSignInButton(),

                      SizedBox(height: AppSizes.h20),

                      // Or login with
                      _buildDivider(),
                      SizedBox(height: AppSizes.h20),
                      // Google Sign In
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          containerIconSiginWith(FontAwesomeIcons.google,
                              context.appColors.surface, context),
                          // buildGoogleSignIn(),
                          SizedBox(width: AppSizes.w20),
                          kIsWeb
                              ? Text("")
                              : Platform.isAndroid || Platform.isWindows
                                  ? Text('')
                                  : Container(
                                      width: MediaQuery.sizeOf(context).width /
                                          2.5,
                                      height:
                                          MediaQuery.sizeOf(context).height /
                                              16,
                                      // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: context.appColors.border,
                                          width: 1,
                                        ),
                                        boxShadow: [AppShadows.soft],
                                      ),
                                      child: SignInWithAppleButton(
                                        text: '',
                                        onPressed: () async {
                                          if (Platform.isAndroid) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        UserOnboarding()));
                                          }
                                          if (appleSignInBool.value)
                                            return; // Prevent multiple clicks
                                          appleSignInBool.value =
                                              true; // Set loading state
                                          try {
                                            final userdataApple =
                                                await AuthService()
                                                    .signInWithApple(context);

                                            if (userdataApple != null &&
                                                userdataApple['data']
                                                        ['accessToken'] !=
                                                    null) {
                                              LoginService.loginCalledData(
                                                  userdataApple, context,
                                                  flag: true);
                                            } else if (userdataApple != null) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        UserDetailsPage(
                                                          data: userdataApple,
                                                          isAppleUser: true,
                                                        )),
                                              );
                                            } else {}
                                          } finally {
                                            appleSignInBool.value =
                                                false; // Reset loading state
                                          }
                                        },
                                      ),
                                    ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Bottom Wave Design
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AvatarProfileImageZero(url: Sign.appSignInimage, width: 14, height: 14),
        SizedBox(height: AppSizes.h8),
        textStyle(
            context: context,
            text: 'Sign in to continue to your account',
            fontWeight: FontWeight.w400,
            fontsize: 16,
            lineHeight: 20 / 16,
            c: context.appColors.secondaryText),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: emailController,
      onChanged: (c) {
        acceptReset.value = false;
      },
      cursorColor: context.appColors.primary,
      style: TextStyle(color: context.appColors.onBackground),
      decoration: InputDecoration(
        // fillColor: Color.fromRGBO(255, 255, 255, 0.23),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: context.appColors.border),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: context.appColors.primary),
        ),
        hintText: 'Enter your email',
        hintStyle: FontManager().getTextStyle(context,
            lWeight: FontWeight.w400,
            fontSize: 14,
            color: context.appColors.hintText),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 0,
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return Obx(() {
      return GestureDetector(
        onTap: () async {
          // IMPORTANT: Remove keyboard focus so first tap works

          FocusScope.of(context).unfocus();

          if (acceptReset.value) return;

          if (emailController.text.isEmpty) {
            snackBarCalledfail(context, SnackbarData().enterAllFields);
            return;
          }

          acceptReset.value = true;

          await getDeviceInfo(
            "deviceData.value".toString(),
            context,
            emailController,
          );
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.06,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.appColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: acceptReset.value
              ? Spinner(size: 30)
              : Text(
                  "Send OTP",
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
        ),
      );
    });
  }

  Widget _buildDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or login with',
            style: FontManager()
                .getTextStyle(
                    context,
                    color: context.appColors.secondaryText,
                    fontSize: 14),
          ),
        ),
      ],
    );
  }
}
