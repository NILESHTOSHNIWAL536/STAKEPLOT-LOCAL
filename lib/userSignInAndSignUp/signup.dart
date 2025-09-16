import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/signUp.dart';
import 'package:flutter_application_code_stakeplot/animated/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/googlesignin/google.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/signInOut/confirm.dart';
import 'package:flutter_application_code_stakeplot/signInOut/userName.dart';
import 'package:flutter_application_code_stakeplot/userSignInAndSignUp/wave.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController dobController = TextEditingController(text: '');
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  RxBool flag = false.obs;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // Color(0xFF9B8BC6),
              // Color(0xFF6568A7),
              // Color(0xFF272841),
              Color(0xFF6568A7),
              Color(0xFF272841),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Positioned(
                      bottom: 40, left: 0, child: buildBottomWaves(context)),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Welcome Text
                        _buildWelcomeText(),

                        const SizedBox(height: 20),

                        // Username Field
                        _buildUsernameField(),

                        const SizedBox(height: 10),

                        // Date of Birth Field
                        _buildDateOfBirthField(),

                        const SizedBox(height: 10),

                        // Email Field
                        _buildEmailField(),

                        const SizedBox(height: 10),

                        // Password Field
                        _buildPasswordField(),

                        const SizedBox(height: 10),

                        // Confirm Password Field
                        _buildConfirmPasswordField(),

                        const SizedBox(height: 20),

                        // Sign Up Button
                        _buildSignUpButton(),

                        const SizedBox(height: 20),

                        // Or login with
                        _buildDivider(),

                        const SizedBox(height: 15),

                        // Google Sign In
                        // _buildGoogleSignIn(),
                        containerIconSiginWith(
                            FontAwesomeIcons.google, Colorcodes.white, context),

                        const SizedBox(height: 20),

                        // Sign In Link
                        _buildSignInLink(),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  // Bottom Wave Design
                ],
              ),
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
            text: 'Create an Account',
            fontWeight: FontWeight.bold,
            fontsize: 26,
            c: Colorcodes.white),
        const SizedBox(height: 8),
        textStyle(
            context: context,
            text: 'to get started',
            fontWeight: FontWeight.w300,
            fontsize: 18,
            c: Colorcodes.white),
      ],
    );
  }

  Widget _buildUsernameField() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.whiteOpacity03, width: 1),
      ),
      child: TextField(
        controller: usernameController,
        onChanged: (c) {
          flag.value = false;
        },
        style: const TextStyle(color: Colors.white),
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
          LowerCaseTextFormatter(),
        ],
        decoration: InputDecoration(
          hintText: 'Username',
          hintStyle: TextStyle(color: AppColors.whiteOpacity07),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDateOfBirthField() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.whiteOpacity03, width: 1),
      ),
      child: TextField(
        controller: dobController,
        style: const TextStyle(color: Colors.white),
        readOnly: true,
        onTap: () => _selectDate(context),
        decoration: InputDecoration(
          hintText: 'Date of Birth',
          hintStyle: TextStyle(color: AppColors.whiteOpacity07),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          suffixIcon: Icon(
            Icons.calendar_today,
            color: AppColors.whiteOpacity07,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget containerIconSiginWith(IconData icon, Color color, context) {
    return InkWell(
      onTap: () async {
        if (googleSignInBool.value) return; // Prevent multiple clicks
        googleSignInBool.value = true; // Set loading state
        try {
          final userdata = await AuthService().signInWithGoogle(context);
          if (userdata != null && userdata['data']['accessToken'] != null) {
          } else if (userdata != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UserDetailsPage(data: userdata)),
            );
          } else {}
        } finally {
          googleSignInBool.value = false; // Reset loading state
        }
      },
      child: Container(
        width: MediaQuery.sizeOf(context).width / 5,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Obx(
          () => googleSignInBool.value
              ? Spinner(size: 30) // Show spinner when loading
              : AvatarProfileImage(
                  url: Sign.googleIcon,
                  width: 40,
                  height: 30,
                ), // Show icon when not loading
        ),
      ),
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
        style: const TextStyle(color: Colors.white),
        keyboardType: TextInputType.emailAddress,
        onChanged: (c) {
          flag.value = false;
        },
        decoration: InputDecoration(
          hintText: 'Email',
          hintStyle: TextStyle(color: AppColors.whiteOpacity07),
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
        obscureText: !_isPasswordVisible,
        style: const TextStyle(color: Colors.white),
        onChanged: (c) {
          flag.value = false;
        },
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: TextStyle(color: AppColors.whiteOpacity07),
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

  Widget _buildConfirmPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.whiteOpacity03, width: 1),
      ),
      child: TextField(
        controller: confirmPasswordController,
        obscureText: !_isConfirmPasswordVisible,
        onChanged: (c) {
          flag.value = false;
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Confirm Password',
          hintStyle: TextStyle(color: AppColors.whiteOpacity07),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: AppColors.whiteOpacity07,
            ),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
          onPressed: () {
            _handleSignUp();
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
            () => flag.value
                ? Spinner(
                    size: 20,
                    color: AppColors.primaryColor,
                  )
                : Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          )),
    );
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

  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(
            color: AppColors.whiteOpacity07,
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Sign In Now',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B5B95),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dobController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
      flag.value = false;
    }
  }

  void _handleSignUp() {
    storeData();
  }

  void storeData() async {
    String name = usernameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String conform = confirmPasswordController.text;
    String phone = "";
    // String dob = dobController.text;

    if (name.isEmpty) {
      snackBarCalledfail(context, SignupData().emptyUsername, Colors.red);
      return;
    }
    if (!RegExp(r'^[a-zA-Z]').hasMatch(name)) {
      snackBarCalledfail(context, SignupData().invalidUsername, Colors.red);
      return;
    }

    if (name.length < 3) {
      snackBarCalledfail(context, SignupData().shortUsername, Colors.red);
      return;
    }

    if (email.isEmpty) {
      snackBarCalledfail(context, SignupData().emptyEmail, Colors.red);
      return;
    }

    // Email format validation
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email)) {
      snackBarCalledfail(context, SignupData().invalidEmail, Colors.red);
      return;
    }

    if (password.isEmpty) {
      snackBarCalledfail(context, SignupData().emptyPassword, Colors.red);
      return;
    }

    if (password.length < 8) {
      snackBarCalledfail(context, SignupData().shortPassword, Colors.red);
      return;
    }

    if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~])')
        .hasMatch(password)) {
      snackBarCalledfail(context, SignupData().weakPassword, Colors.red);
      return;
    }

    if (conform.isEmpty) {
      snackBarCalledfail(
          context, SignupData().emptyConfirmPassword, Colors.red);
      return;
    }

    if (password != conform) {
      snackBarCalledfail(context, SignupData().passwordMismatch, Colors.red);
      return;
    }

    flag.value = true;
    final Map<String, dynamic> body = {
      'name': usernameController.text,
      'email': emailController.text,
      'userpassword': passwordController.text,
      'confirmPassword': confirmPasswordController.text,
      'otp': 'opts',
    };

// Add dob only if not empty
    if (dobController.text.trim().isNotEmpty) {
      body['dob'] = dobController.text.trim();
    }

// Add phone only if not empty
    if (phone.trim().isNotEmpty) {
      body['phone'] = phone.trim();
    }

    final response = await http.post(
      Uri.parse('$url/user/register'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );

    // final response = await http.post(
    //   Uri.parse('${url}/user/register'),
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8',
    //   },
    //   body: jsonEncode({
    //     'name': usernameController.text,
    //     'email': emailController.text,
    //     'userpassword': passwordController.text,
    //     'phone': phone,
    //     'confirmPassword': confirmPasswordController.text,
    //     'dob': dobController.text,
    //     'otp': "opts",
    //   }),
    // );

    var responce = jsonDecode(response.body);

    bool boolvar = responce['success'];
    if (response.statusCode == 409) {
      // Specific case: user already exists
      snackBarCalledfail(context, responce['error']['explanation'], Colors.red);
      flag.value = false;
      return;
    }

    if (!boolvar && responce['error'] == "Invalid Otp") {
      flag.value = false;
      call();
    }

    if (!boolvar) {
      snackBarCalledfail(context, responce['error']['explanation']);
      flag.value = false;
      return;
    }
  }

  void call() {
    var data = {
      'name': usernameController.text,
      'email': emailController.text,
      'userpassword': passwordController.text,
      // 'phone': phoneController.text,
      'confirmPassword': confirmPasswordController.text,
      'dob': dobController.text,
    };
    flag.value = false;
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => Avatar(data: data),
    //   ),
    // );
    getOTP(context, usernameController.text, emailController.text);
    // openShowModal();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => conform(
          data: data,
          url: "",
        ),
      ),
    );
  }
}
