import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';


class Signin extends StatefulWidget {
  const Signin({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  // TextEditingController emailController = TextEditingController();
  // TextEditingController passwordController = TextEditingController();
  // TextEditingController emailController=TextEditingController(text: "user63@gmail.com");
  // TextEditingController passwordController =TextEditingController(text: "user63password");
  TextEditingController emailController= TextEditingController(text: "roshanchenna1@gmail.com");
  TextEditingController passwordController= TextEditingController(text: "nilesh123");

  
  @override
  void initState() {
    check(context, "loginuser");
  }

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
                    borderSide: const BorderSide(color: Colors.white
                        // color: Color.fromRGBO(249, 246, 238, 1)
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
    return Scaffold(
      backgroundColor: Colorcodes.budgetDarkGreen,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: Colorcodes.paddingTopDesign / 1.4),
            child: Text(("Welcome"),
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black)),
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.17333,
              padding:
                  EdgeInsets.symmetric(vertical: Colorcodes.paddingTopScroll),
              decoration: BoxDecoration(
                  color: Colorcodes.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Colorcodes.borderCut),
                    topRight: Radius.circular(Colorcodes.borderCut),
                  )),
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    TextFeildWidget(
                        textEditingController: emailController,
                        heading: "Email",
                        keyBoard: TextInputType.emailAddress,
                        lableText: "example@example.com"),
                    TextFeildWidgetPassword(
                      textEditingController: passwordController,
                      heading: "Password",
                      keyBoard: TextInputType.visiblePassword,
                      lableText: "Password",
                      flag: false,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                  
                  // InkWell(
                  //     onTap:()async{
                  //        var data=await finvuManager.fipsAllFIPOptions(); 
                  //       //  data=data[0].fipId;
                  //       print(data);
                  //       print(data.first);
                  //       print(data.first.fipFitypes);
                  //       print(data.first.fipId);
                        
                  //     },
                  //     child:Text(" fipsAllFIPOptions() ")
                  // ),


                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.6,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 30),
                        decoration: BoxDecoration(
                            color: Colorcodes.budgetDarkGreen,
                            borderRadius: BorderRadius.circular(
                                Colorcodes.borderRadius30)),
                        child: InkWell(
                          onTap: () {
                            //  home
                            //  loginToAutoTractions(context,"8978958221");
                            if (acceptReset.value) return;
                            final snackBar = SnackBar(
                              content: const Text('Pls Enter All Feilds'),
                              action: SnackBarAction(
                                label: 'Ok',
                                onPressed: () {
                                  // Some code to undo the change.
                                },
                              ),
                            );

                            if (emailController.text == "" ||
                                passwordController.text == "") {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                              return;
                            }
                            acceptReset.value = true;
                              // loginToAutoTractions(context,"8978958221");
                            loginUser(emailController, passwordController, context);
                            // loginToAutoTractions
                            
                            //  Navigator.pushNamed(context, '/home');
                          },
                          child: Obx(() => Center(
                                // child:  Text(("Log In"),
                                child: acceptReset.value? Verify(): Text(("Log In"),
                                        style: FontManager().getTextStyle(
                                            context,
                                            lWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colorcodes.iconBackGround)),
                              )),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: Colorcodes.paddingSize / 3),
                        child: InkWell(
                          onTap: () {
                            // ForgotPassword
                            Navigator.pushNamed(context, '/ForgotPassword');
                          },
                          child: Text(("Forgot Password?"),
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colorcodes.iconBackGround,
                                  decoration: TextDecoration.underline)),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: Colorcodes.paddingSize / 3),
                        child: InkWell(
                          onTap: () {
                            
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShareAccountLogin(),
                              ),
                          );
                          },
                          child: Text(("Connect your bank account "),
                              style: FontManager().getTextStyle(context,
                                  lWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colorcodes.iconBackGround,
                                  decoration: TextDecoration.underline)),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: Colorcodes.paddingSize / 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(("Don’t have an account? "),
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colorcodes.iconBackGround,
                                  // decoration: TextDecoration.underline
                                )),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              child: Text(("Sign Up"),
                                  style: FontManager().getTextStyle(
                                    context,
                                    lWeight: FontWeight.w400,
                                    fontSize: 18,
                                    color: Colorcodes.cardShade5,
                                    // decoration: TextDecoration.underline
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.6,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 30),
                        decoration: BoxDecoration(
                            color: Colorcodes.budgetLightGreen,
                            borderRadius: BorderRadius.circular(
                                Colorcodes.borderRadius30)),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/signup');
                            // handleSignInGoogle(context);
                          },
                          child: Center(
                            child: Text(("Sign Up"),
                                style: FontManager().getTextStyle(context,
                                    lWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colorcodes.iconBackGround)),
                          ),
                        ),
                      ),
                    ),

                    // Center(
                    //   child: GestureDetector(
                    //     onTap: () {

                    //         handleSignInGoogle(context);

                    //     },
                    //     child: GoogleSignIn()
                    //   ),
                    // )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    
  }

  Widget InputFeild(lableText, keyBoard, Textcontroller) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        width: MediaQuery.of(context).size.width / 1.1,
        child: TextFormField(
          keyboardType: keyBoard,
          controller: Textcontroller,
          decoration: InputDecoration(
            filled: true,
            hintText: lableText,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide(color: Colorcodes.textFeild)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide(color: Colorcodes.textFeild)),
            fillColor: Colorcodes.textFeild,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
