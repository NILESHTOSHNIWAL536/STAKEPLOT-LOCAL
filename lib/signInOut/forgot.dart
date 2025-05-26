import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();

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

          // decoration: InputDecoration(
          //   labelText: lableText,
          //   border:const OutlineInputBorder(
          //         borderSide: BorderSide(color:Color.fromRGBO(249, 246, 238, 1))
          //   ),
          // ),
        ),
      ),
    );
  }

  Widget InputDate2(lableText, keyBoard, Textcontroller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9.0),
        child: Container(
          // padding: EdgeInsets.symmetric(vertical: 5),
          // color:  Color.fromRGBO(246, 246, 246, 1),
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
                    borderSide: const BorderSide(color: Colors.white)),
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
    return Scaffold(
      backgroundColor: Colorcodes.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Text(("Reset Password"),
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black)),

            const SizedBox(
              height: 30,
            ),
            // Center(
            //   child: Container(
            //    width: MediaQuery.of(context).size.width/1.15,
            //    padding:  EdgeInsets.symmetric(vertical: Colorcodes.paddingSize/3),
            //    child: Text(("Reset password?"),
            //                        style: FontManager().getTextStyle(context,
            //                            lWeight: FontWeight.bold,
            //                            fontSize: 15,
            //                            color: Colorcodes.iconBackGround)),
            //                         ),
            // ),
            // Center(
            //   child: Container(
            //     width: MediaQuery.of(context).size.width/1.15,
            //     padding:  EdgeInsets.symmetric(vertical: Colorcodes.paddingSize/3),
            //     child: Text((StringConstant.resetpassword),
            //                         style: FontManager().getTextStyle(context,
            //                             lWeight: FontWeight.w400,
            //                             fontSize: 12,
            //                             color: Colors.black)),
            //   ),
            // ),

            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 10),
            //   child: TextFeildWidget(
            //     textEditingController: nameController,
            //     heading: "Username",
            //     keyBoard: TextInputType.name,
            //     lableText: "Username",
            //     icon: Icons.person_3_outlined,
            //   ),
            // ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: TextFeildWidget(
                  textEditingController: emailController,
                  heading: "Email",
                  keyBoard: TextInputType.name,
                  lableText: "johndoe@gmail.com"),
            ),

            SizedBox(
              height: Colorcodes.paddingSize ,
            ),

            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 1.3,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 30),
                    decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius:
                            BorderRadius.circular(Colorcodes.borderRadius10)),
                    child: InkWell(
                      onTap: () {

                        if (
                            emailController.text == "") {
                          snackBarCalledfail(context,SnackbarData().enterValidemail);
                          return;
                        }

                        getforgotPassword(
                            context, nameController.text, emailController.text);
                        // Navigator.pushNamed(context,'/ResetPassword');
                      },
                      child: Center(
                        child: Text(("Next step"),
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colorcodes.white)),
                      ),
                    ),
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
