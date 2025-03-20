import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/signInOut/avatar.dart';
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
  TextEditingController emailController =
      TextEditingController(text: "roshanchenna2@gmail.com");
  TextEditingController passwordController =
      TextEditingController(text: "nilesh123");
  TextEditingController conformController =
      TextEditingController(text: "nilesh123");
  TextEditingController usernameController =
      TextEditingController(text: "nilesh1212");
  TextEditingController dobController = new TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()).toString());
  TextEditingController phoneController =
      TextEditingController(text: "9347064783");

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colorcodes.white,
        body: SingleChildScrollView(
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
            Text(("Already have an account ? "),
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
                    : Text(("Continue"),
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
            heading: "User Name",
            keyBoard: TextInputType.name,
            lableText: "Enter  your Name",
            icon: Icons.person_2_outlined,
          ),
          TextFeildCalender(
            textEditingController: dobController,
            heading: "Enter Your Date of Birth",
            keyBoard: TextInputType.visiblePassword,
            lableText: "Date of Birth",
          ),
          // TextFeildWidget(
          //     textEditingController: phoneController,
          //     heading: "PhoneNo",
          //     keyBoard: TextInputType.phone,
          //     lableText: "Phone No"),
          TextFeildWidget(
              textEditingController: emailController,
              heading: "email",
              keyBoard: TextInputType.emailAddress,
              lableText: "example@example.com"),
          TextFeildWidgetPassword(
            textEditingController: passwordController,
            heading: "Password",
            keyBoard: TextInputType.visiblePassword,
            lableText: "Password",
            flag: false,
            icon: Icons.lock_clock_outlined,
          ),
          TextFeildWidgetPassword(
            textEditingController: conformController,
            heading: "Confirm Password",
            keyBoard: TextInputType.visiblePassword,
            lableText: "Confirm Password",
            flag: false,
            icon: Icons.lock_clock_outlined,
          ),
        ],
      ),
    );
  }

  Widget topHeader() {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: Colorcodes.paddingTopDesign / 1.4),
      child: Text(("Create Account"),
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
      'confirmPassword': conformController.text,
      'dob': dobController.text.substring(0, 10),
    };
    flag.value = false;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Avatar(data: data),
      ),
    );
    //  getOTP(context, usernameController.text,emailController.text);
                    // openShowModal();
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => conform(
    //       data: data,
    //       url: "assets/avatar/menp1.svg",
    //     ),
    //   ),
    // );
  }

  Future<http.Response> createUser() async {
    final response = await http.post(
      Uri.parse('https://stakeplot.in/api/v1/user/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': usernameController.text,
        'email': emailController.text,
        'userpassword': passwordController.text,
        'phone': phoneController.text,
        'confirmPassword': conformController.text,
        'dob': '12-03-2022',
      }),
    );

    return response;
  }

  void storeData() async {
    String name = usernameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String conform = conformController.text;
    String phone = phoneController.text;
    String dob = dobController.text;

    if (name == "" ||
        email == "" ||
        password == "" ||
        conform == "" ||
        phone == "" ||
        dob == "") {
      snackBarCalled(context, "Please fill in all fields.", Colors.red);
      return;
    }

    if (phone.length != 10) {
      snackBarCalled(context, "The phone number is invalid.", Colors.red);
      return;
    }
    if (password.length < 6) {
      snackBarCalled(context,
          "The password must be at least 6 characters long.", Colors.red);
      return;
    }

    if (password != conform) {
      snackBarCalled(context,
          "The password and confirmation password do not match.", Colors.red);
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
        'confirmPassword': conformController.text,
        'dob': dobController.text.substring(0, 10),
        'avatarType': url,
        'otp': "opts",
      }),
    );

    var responce = jsonDecode(response.body);

    print(responce);

    bool boolvar = responce['success'];
 print(boolvar);
    if (!boolvar && responce['error'] == "Invalid Otp") {
      flag.value = false;
      call();
    }

    if (!boolvar) {
      snackBarCalled(context, responce['error']['explanation'], Colors.red);
      flag.value = false;
      return;
    }
  }
}
