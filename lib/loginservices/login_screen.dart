import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/Constants/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/googlesignin/google.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/signInOut/userName.dart';
import 'package:flutter_application_code_stakeplot/loginservices/wave.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../auth_service/login_apis.dart';
import 'googl_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController(text: "testuser2@gmail.com");
  final AuthService authService = AuthService();
  
  @override
  void initState() {
    super.initState();
    acceptReset.value = false;
    googleSignInBool.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
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
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                // Main Content
                Positioned(
                    bottom: 20, left: 0, child: buildBottomWaves(context)),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      // Welcome Text
                      _buildWelcomeText(),

                      const SizedBox(height: 20),

                      // Email Field
                      _buildEmailField(),

                      const SizedBox(height: 20),


                      const SizedBox(height: 10),

                      // Sign In Button
                      _buildSignInButton(),

                      const SizedBox(height: 40),

                      // Or login with
                      _buildDivider(),
                      const SizedBox(height: 20),
                      // Google Sign In
                      containerIconSiginWith(
                          FontAwesomeIcons.google, Colorcodes.white, context),
                      // buildGoogleSignIn(),
                      const SizedBox(height: 20),
                      Platform.isAndroid
                          ? Text('')
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: SignInWithAppleButton(
                                onPressed: () async {
                                  if (appleSignInBool.value)
                                    return; // Prevent multiple clicks
                                  appleSignInBool.value =
                                      true; // Set loading state
                                  try {
                                    final userdataApple = await AuthService()
                                        .signInWithApple(context);
                            
                                    if (userdataApple != null &&
                                        userdataApple['data']['accessToken'] !=
                                            null) {
                                      LoginService.loginCalledData(
                                          userdataApple, context,
                                          flag: true);
                                    } else if (userdataApple != null) {
                                      Navigator.push(context,MaterialPageRoute(builder: (context) =>UserDetailsPage2(data: userdataApple)),
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
      children: [
        textStyle(
            context: context,
            text: 'Welcome',
            fontWeight: FontWeight.bold,
            fontsize: 32,
            // c: Theme.of(context).appBarTheme.iconTheme?.color ??  Colorcodes.white
            // c: Theme.of(context).textTheme.bodyMedium?.color ??  Colorcodes.white
            c: Colorcodes.white
          ),
        const SizedBox(height: 8),
        textStyle(
            context: context,
            text: 'Glad to see you',
            fontWeight: FontWeight.w300,
            fontsize: 18,
            c: Colorcodes.white),
      ],
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.whiteOpacity03, width: 1),
      ),
      child: TextField(
        controller: emailController,
        onChanged: (c) {
          acceptReset.value = false;
        },
        cursorColor: AppColors.backgroundColor,
        style: const TextStyle(color: AppColors.backgroundColor),
        decoration: InputDecoration(
          fillColor: Color.fromRGBO(255, 255, 255, 0.23),
          hintText: 'Email Address',
          hintStyle: FontManager().getTextStyle(context,
              lWeight: FontWeight.normal,
              fontSize: 14,
              color: AppColors.backgroundColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
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
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),

        child: acceptReset.value
            ? Spinner(size: 30)
            : Text(
                "Sign In",
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.finSpaceColor,
                ),
              ),
      ),
    );
  });
}
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.whiteOpacity03,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or login with',
            style: TextStyle(
              color: AppColors.whiteOpacity07,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.whiteOpacity03,
          ),
        ),
      ],
    );
  }

}
