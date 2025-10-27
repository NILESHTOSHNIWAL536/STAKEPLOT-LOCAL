import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/animated/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/googlesignin/google.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
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
  final TextEditingController passwordController = TextEditingController(text: "Nilesh@1234");
  bool _isPasswordVisible = false;
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

                      // Password Field
                      // _buildPasswordField(),

                      // const SizedBox(height: 10),

                      // Forgot Password
                      // _buildForgotPassword(),

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

                      // const Spacer(),

                      // Sign Up Link
                      // buildSignUpLink(),
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

  // Widget containerIconSiginWith(IconData icon, Color color, context) {
  //   return InkWell(
  //     onTap: () async {
  //       if (googleSignInBool.value) return; // Prevent multiple clicks
  //       googleSignInBool.value = true; // Set loading state
  //       try {
  //         final userdata = await AuthService().signInWithGoogle(context);
  //         if (userdata != null && userdata['data']['accessToken'] != null) {
  //           LoginService.loginCalledData(userdata, context, flag: true);
  //         } else if (userdata != null) {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (context) => UserDetailsPage(data: userdata)),
  //           );
  //         } else {}
  //       } finally {
  //         googleSignInBool.value = false; // Reset loading state
  //       }
  //     },
  //     child: Container(
  //       width: MediaQuery.sizeOf(context).width / 5,
  //       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
  //       decoration: BoxDecoration(
  //         color: AppColors.backgroundColor,
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       child: Obx(
  //         () => googleSignInBool.value
  //             ? Spinner(size: 30) // Show spinner when loading
  //             : AvatarProfileImage(
  //                 url: Sign.googleIcon,
  //                 width: 40,
  //                 height: 30,
  //               ), // Show icon when not loading
  //       ),
  //     ),
  //   );
  // }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        textStyle(
            context: context,
            text: 'Welcome',
            fontWeight: FontWeight.bold,
            fontsize: 32,
            c: Colorcodes.white),
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
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white),
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

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.whiteOpacity03, width: 1),
      ),
      child: TextField(
        controller: passwordController,
        onChanged: (c) {
          acceptReset.value = false;
        },
        obscureText: !_isPasswordVisible,
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          fillColor: Color.fromRGBO(
              255, 255, 255, 0.23), // same as rgba(255,255,255,0.23)

          hintText: 'Password',
          hintStyle: FontManager().getTextStyle(context,
              lWeight: FontWeight.normal,
              fontSize: 14,
              color: AppColors.backgroundColor),
          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: AppColors.whiteOpacity07,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Handle forgot password
          Navigator.pushNamed(context, "/forgot");
        },
        child: Text('Forgot Password?',
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.normal,
                fontSize: 14,
                color: AppColors.backgroundColor)),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () async {
            // Handle sign in
            if (acceptReset.value) return;

            if (emailController.text.isEmpty ||
                passwordController.text.isEmpty) {
              snackBarCalledfail(
                  context,
                  SnackbarData()
                      .enterAllFields); // You might want to update this to use signinData validation messages
              return;
            }

            acceptReset.value = true;

            await getDeviceInfo(
              "deviceData.value".toString(),
              context,
              emailController,
              passwordController,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Obx(
            () => acceptReset.value
                ? Spinner(
                    size: 30,
                  )
                : Text(
                    'Sign In',
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.finSpaceColor),
                  ),
          ),
        ));
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

  Widget buildSignUpLink() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, "/signup");
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.normal,
                fontSize: 14,
                color: AppColors.backgroundColor),
          ),
          Text(
            'Sign Up Now',
            style: FontManager().getTextStyle(context,
                lWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.backgroundColor),
          ),
        ],
      ),
    );
  }
}
