import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/signUp.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/opt_email.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ResetPassword extends StatefulWidget {
  String name;
  String email;

  ResetPassword({Key? key, required this.email, required this.name})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<ResetPassword> {
  
  TextEditingController passwordController = TextEditingController();
  TextEditingController conformController = TextEditingController();
  // TextEditingController emailController= TextEditingController(text: "nileshtoshniwal743@gmail.com");
  //  TextEditingController passwordController= TextEditingController(text: "nilesh9849");

  Widget InputDate(lableText, keyBoard, Textcontroller) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        width: MediaQuery.of(context).size.width / 1.3,
        child: TextField(
          keyboardType: keyBoard,
          controller: Textcontroller,

          decoration: InputDecoration(
            filled: true,
            hintText: lableText,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide:
                    BorderSide(color: Color.fromRGBO(249, 246, 238, 1))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide:
                    BorderSide(color: Color.fromRGBO(249, 246, 238, 1))),
            fillColor: Color.fromRGBO(249, 246, 238, 1),
            border: InputBorder.none,
          ),


        ),
      ),
    );
  }

  Widget InputDate2(lableText, keyBoard, Textcontroller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9.0),
        child: Container(
         
          height: 60,
          width: MediaQuery.of(context).size.width / 1.3,
          child: Center(
            child: TextFormField(
              keyboardType: keyBoard,
              controller: Textcontroller,
              decoration: InputDecoration(
                filled: true,
                hintText: lableText,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: Colors.white
                        
                        )),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide:
                        BorderSide(color: Color.fromRGBO(246, 246, 246, 1))),
                fillColor: Colorcodes.appBarColor,
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colorcodes.white,
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: Colorcodes.paddingTopDesign / 1.4),
              child: Text(("Security Pin"),
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black)),
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TextFeildWidget(
                textEditingController: passwordController,
                heading: "New Password",
                keyBoard: TextInputType.visiblePassword,
                lableText: "Password",
                icon: Icons.lock_clock_outlined,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TextFeildWidget(
                textEditingController: conformController,
                heading: "Confirm New Password",
                keyBoard: TextInputType.visiblePassword,
                lableText: "Confirm Password",
                icon: Icons.lock_clock_outlined,
              ),
            ),
            SizedBox(
              height: Colorcodes.paddingSize * 4,
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      String password = passwordController.text;
                      String conform = conformController.text;
                  
                      if (password.length < 8) {
                        snackBarCalledfail(
                            context,
                           SignupData().shortPassword,
                            Colors.red);
                        return;
                      }
                       if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~])').hasMatch(password)) {
                        snackBarCalledfail(
                            context,
                           SignupData().weakPassword,
                            Colors.red);
                        return;
                      }
                      if (conform.isEmpty) {
                        snackBarCalledfail(
                            context,
                          SignupData().emptyConfirmPassword,
                            Colors.red);
                        return;
                      }
                  
                      if (password != conform) {
                        snackBarCalledfail(
                            context,
                          SignupData().passwordMismatch,
                            Colors.red);
                        return;
                      }
                  
                      changePassword(
                        context,
                        widget.email,
                        passwordController.text,
                        conformController.text,
                      );
                    },
                    child: getButton(context, SignupData().changePasswordSubLabel),
                    
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
