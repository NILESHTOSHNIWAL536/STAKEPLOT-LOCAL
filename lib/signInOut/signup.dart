import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/signUp.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/signInOut/confirm.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<SignUp> {
  RxBool flag = false.obs;
  RxString passwordError = ''.obs;
  RxString confirmError = ''.obs;
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController passwordController = TextEditingController(text: "");
  TextEditingController confirmController = TextEditingController(text: "");
  TextEditingController usernameController = TextEditingController(text: "");
  TextEditingController dobController = new TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()).toString());
  TextEditingController phoneController = TextEditingController(text: "");
  @override
  void initState() {
    super.initState();
    // Add listeners for real-time validation
    passwordController.addListener(validatePassword);
    confirmController.addListener(validateConfirmPassword);
  }

  @override
  void dispose() {
    passwordController.removeListener(validatePassword);
    confirmController.removeListener(validateConfirmPassword);
    super.dispose();
  }

  void validatePassword() {
    String password = passwordController.text;
    if (password.isEmpty) {
      passwordError.value = 'Password cannot be empty';
    } else if (password.length < 8) {
      passwordError.value = 'Password must be at least 8 characters';
    } else if (!RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~])')
        .hasMatch(password)) {
      passwordError.value =
          'Must include uppercase, lowercase, number, and special character';
    } else {
      passwordError.value = '';
    }
    validateConfirmPassword(); // Check confirmation whenever password changes
  }

  void validateConfirmPassword() {
    String password = passwordController.text;
    String confirm = confirmController.text;

    if (confirm.isEmpty) {
      confirmError.value = 'Please confirm your password';
    } else if (password != confirm) {
      confirmError.value = 'Passwords do not match';
    } else {
      confirmError.value = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorcodes.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                topHeader(),
                getTextFeilds(),
                signUpButton(),
                allReadyHaveAccount()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget allReadyHaveAccount() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Colorcodes.paddingSize / 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text((SignupData().accountExit),
                style: FontManager().getTextStyle(
                  context,
                  lWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colorcodes.iconBackGround,
                  // decoration: TextDecoration.underline
                )),
            InkWell(
              onTap: () {
                acceptReset.value = false;
                clearStack(context);
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text(("Sign In"),
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colorcodes.cardShade5,
                    // decoration: TextDecoration.underline
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget signUpButton() {
    return Center(
      child: Container(
        width: flag.value
            ? MediaQuery.of(context).size.width / 1.3
            : MediaQuery.of(context).size.width / 1.3,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(Colorcodes.borderRadius30)),
        child: InkWell(
          onTap: () {
            storeData();
          },
          child: Obx(() => Center(
                child: flag.value
                    ? Spinner(
                        size: 20,
                        color: Colorcodes.white,
                      )
                    : Text((SignupData().Continue),
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colorcodes.white)),
              )),
        ),
      ),
    );
  }

  Widget getTextFeilds() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Colorcodes.paddingSize),
      child: Column(
        children: [
          TextFeildWidget(
            textEditingController: usernameController,
            heading: SignupData().usernameLabel,
            keyBoard: TextInputType.name,
            lableText: SignupData().usernameSubLabel,
            icon: Icons.person_2_outlined,
          ),
          TextFeildCalender(
            textEditingController: dobController,
            heading: SignupData().dobLabel,
            keyBoard: TextInputType.visiblePassword,
            lableText: SignupData().dobSubLabel,
          ),
          // TextFeildWidget(
          //     textEditingController: phoneController,
          //     heading: "PhoneNo",
          //     keyBoard: TextInputType.phone,
          //     lableText: "Phone No"),
          TextFeildWidget(
            textEditingController: emailController,
            heading: SignupData().emailLabel,
            keyBoard: TextInputType.emailAddress,
            lableText: SignupData().emailSubLabel,
          ),
          Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFeildWidgetPassword(
                    textEditingController: passwordController,
                    heading: SignupData().passwordLabel,
                    keyBoard: TextInputType.visiblePassword,
                    lableText: SignupData().passwordSubLabel,
                    flag: false,
                    icon: Icons.lock_clock_outlined,
                  ),
                  if (passwordError.value.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: 20, top: 5),
                      child: Text(
                        passwordError.value,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              )),
          Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFeildWidgetPassword(
                    textEditingController: confirmController,
                    heading: SignupData().confirmPasswordLabel,
                    keyBoard: TextInputType.visiblePassword,
                    lableText: SignupData().confirmPasswordSubLabel,
                    flag: false,
                    icon: Icons.lock_clock_outlined,
                  ),
                  if (confirmError.value.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(left: 20, top: 5),
                      child: Text(
                        confirmError.value,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              )),
        ],
      ),
    );
  }

  Widget topHeader() {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: Colorcodes.paddingTopDesign / 1.4),
      child: Text((SignupData().createAccount),
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.bold, fontSize: 22, color: Colors.black)),
    );
  }

  void call() {
    var data = {
      'name': usernameController.text,
      'email': emailController.text,
      'userpassword': passwordController.text,
      // 'phone': phoneController.text,
      'confirmPassword': confirmController.text,
      'dob': dobController.text.substring(0, 10),
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

  Future<http.Response> createUser() async {
    final response = await http.post(
      Uri.parse('${url}/user/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': usernameController.text,
        'email': emailController.text,
        'userpassword': passwordController.text,
        'phone': phoneController.text,
        'confirmPassword': confirmController.text,
        'dob': '12-03-2022',
      }),
    );

    return response;
  }

  void storeData() async {
    String name = usernameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String conform = confirmController.text;
    String phone = phoneController.text;
    String dob = dobController.text;


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
      print("Error: Invalid email format"); // Debugging statement
      snackBarCalledfail(context, SignupData().invalidEmail, Colors.red);
      return;
    }

    if (password.isEmpty) {
      print("Error: Password is empty"); // Debugging statement
      snackBarCalledfail(context, SignupData().emptyPassword, Colors.red);
      return;
    }

    if (password.length < 8) {
      print("Error: Password is too short"); // Debugging statement
      snackBarCalledfail(context, SignupData().shortPassword, Colors.red);
      return;
    }

    if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~])')
        .hasMatch(password)) {
      print("Error: Weak password"); // Debugging statement
      snackBarCalledfail(context, SignupData().weakPassword, Colors.red);
      return;
    }

    if (conform.isEmpty) {
      print("Error: Confirm password is empty"); // Debugging statement
      snackBarCalledfail(
          context, SignupData().emptyConfirmPassword, Colors.red);
      return;
    }

    if (password != conform) {
      print("Error: Passwords do not match"); // Debugging statement
      snackBarCalledfail(context, SignupData().passwordMismatch, Colors.red);
      return;
    }

    if (dob.isEmpty) {
      print("Error: Date of birth is empty"); // Debugging statement
      snackBarCalledfail(context, SignupData().emptyDob, Colors.red);
      return;
    }

    flag.value = true;
    final response = await http.post(
      Uri.parse('${url}/user/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'name': usernameController.text,
        'email': emailController.text,
        'userpassword': passwordController.text,
        'phone': phone,
        'confirmPassword': confirmController.text,
        'dob': dobController.text.substring(0, 10),
        'avatarType': url,
        'otp': "opts",
      }),
    );

    var responce = jsonDecode(response.body);
    print("Response from server: $responce"); // Debugging statement

    bool boolvar = responce['success'];

    if (!boolvar && responce['error'] == "Invalid Otp") {
      flag.value = false;
      call();
    }

    if (!boolvar) {
      print(
          "Error: ${responce['error']['explanation']}"); // Debugging statement
      snackBarCalledSignup(
          context, responce['error']['explanation'], Colors.red);
      flag.value = false;
      return;
    }
  }
}
