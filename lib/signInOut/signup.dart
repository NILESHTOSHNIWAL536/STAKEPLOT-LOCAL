import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/signInOut/avatar.dart';
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
   TextEditingController emailController= TextEditingController(text: "roshanchenna2@gmail.com");
     TextEditingController passwordController= TextEditingController(text: "nilesh123");
     TextEditingController conformController= TextEditingController(text: "nilesh123");
     TextEditingController usernameController= TextEditingController(text: "nilesh1212");
    //  TextEditingController dobController= TextEditingController();
      TextEditingController dobController=new TextEditingController(text:DateFormat('yyyy-MM-dd').format(DateTime.now()).toString() );
     TextEditingController phoneController= TextEditingController(text: "9347064783");
  // TextEditingController emailController = TextEditingController();
  // TextEditingController passwordController = TextEditingController();
  // TextEditingController conformController = TextEditingController();
  // TextEditingController usernameController = TextEditingController();
  // //  TextEditingController dobController= TextEditingController();
  // TextEditingController dobController = new TextEditingController(
  //     text: DateFormat('yyyy-MM-dd').format(DateTime.now()).toString());
  // TextEditingController phoneController = TextEditingController();

  Widget InputDatecal(lableText, keyBoard, Textcontroller) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        width: MediaQuery.of(context).size.width / 1.3,
        child: TextFormField(
          keyboardType: keyBoard,
          controller: dobController,
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
              suffixIconColor: Colors.black,
              suffixIcon: InkWell(
                  child: Icon(
                    Icons.calendar_month_outlined,
                    color: Colors.black,
                  ),
                  onTap: () async {
                    DateTime? dateTime = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1988),
                        lastDate: DateTime(2025));
                    dobController.text = dateTime.toString().substring(0, 10);
                  })),
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
                    borderSide: BorderSide(color: Colorcodes.textFeild
                        // color: Color.fromRGBO(249, 246, 238, 1)
                        )),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(color: Colorcodes.textFeild)),
                fillColor: Colorcodes.textFeild,
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget InputDate(lableText, keyBoard, TextEditingController Textcontroller) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        width: MediaQuery.of(context).size.width / 1.3,
        child: TextFormField(
          keyboardType: keyBoard,
          //  initialValue: Textcontroller.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorcodes.budgetDarkGreen,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: Colorcodes.paddingTopDesign / 1.4),
            child: Text(("Create Account"),
                style: FontManager().getTextStyle(context,
                    lWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black)),
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              //  height: MediaQuery.of(context).size.height/1.16,
              // margin:  EdgeInsets.only(top: Colorcodes.paddingTopDesign/2),
              padding:
                  EdgeInsets.symmetric(vertical: Colorcodes.paddingTopScroll),
              decoration: BoxDecoration(
                  color: Colorcodes.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Colorcodes.borderCut),
                    topRight: Radius.circular(Colorcodes.borderCut),
                  )),
              child: ListView(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  //  InputDate2("email/phone number",TextInputType.emailAddress,emailController),
                  //  InputDate2("username",TextInputType.visiblePassword,usernameController),
                  //  InputDatecal("Date of birth",TextInputType.visiblePassword,dobController),
                  //  InputDate2("PhoneNo",TextInputType.number,phoneController),
                  //  InputDate2("password",TextInputType.visiblePassword,passwordController),
                  //  InputDate2("confirm password",TextInputType.visiblePassword,conformController),

                  TextFeildWidget(
                      textEditingController: usernameController,
                      heading: "User Name",
                      keyBoard: TextInputType.name,
                      lableText: "Enter  your Name"),
                  TextFeildCalender(
                      textEditingController: dobController,
                      heading: "Enter Your Date of Birth",
                      keyBoard: TextInputType.visiblePassword,
                      lableText: "Date of Birth"),
                  TextFeildWidget(
                      textEditingController: phoneController,
                      heading: "PhoneNo",
                      keyBoard: TextInputType.phone,
                      lableText: "Phone No"),
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
                  ),
                  TextFeildWidgetPassword(
                    textEditingController: conformController,
                    heading: "Confirm Password",
                    keyBoard: TextInputType.visiblePassword,
                    lableText: "Confirm Password",
                    flag: false,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Center(
                    child: Container(
                      width: flag.value
                          ? MediaQuery.of(context).size.width / 2.2
                          : MediaQuery.of(context).size.width / 2.2,
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                      decoration: BoxDecoration(
                          color: Colorcodes.budgetLightGreen,
                          borderRadius:
                              BorderRadius.circular(Colorcodes.borderRadius30)),
                      child: InkWell(
                        onTap: () {
                          // flag.value=true;

                          storeData();
                          // call();
                            // Navigator.pushReplacement(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => LinkedBackAccount(Password: "data",email: "",),
                            //   ),
                            // );
                        },
                        child: Obx(() => Center(
                              child: flag.value? Verify()
                             :  Text(("Sign Up"),
                                      style: FontManager().getTextStyle(context,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(("Already have an account? "),
                              style: FontManager().getTextStyle(
                                context,
                                lWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colorcodes.iconBackGround,
                                // decoration: TextDecoration.underline
                              )),
                          InkWell(
                            onTap: () {
                              clearStack(context);
                              Navigator.pushReplacementNamed(context, '/');
                            },
                            child: Text(("Sign In"),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // return Scaffold(

    //   body: Container(
    //          height: MediaQuery.of(context).size.height,
    //         //  padding:const EdgeInsets.only(bottom: 20),
    //          child:   SingleChildScrollView(
    //            child: Column(
    //                mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                crossAxisAlignment: CrossAxisAlignment.center,
    //                children: [
    //                    ClipRRect(
    //                        borderRadius: BorderRadius.only(
    //                            bottomLeft: Radius.circular(100)
    //                        ),
    //                        child: Container(
    //                           padding:const EdgeInsets.all(25),
    //                             color: Colorcodes.billHeader,
    //                           // color:  Color.fromRGBO(97, 143, 214, 1),  //rgba(97, 143, 214, 1)
    //                           child: Center(child: Text(("signup"),
    //                           style: FontManager().getTextStyle(context,
    //                         lWeight: FontWeight.w400,
    //                         fontSize: 25,
    //                         color: Colors.white))),
    //                        ),
    //                      ),

    //                      SizedBox(height: 10,),

    //                      Center(
    //                        child: Column(
    //                            mainAxisAlignment: MainAxisAlignment.center,
    //                            crossAxisAlignment: CrossAxisAlignment.center,
    //                            children: [

    //                        Column(
    //                            children: [
    //        InputDate2("email/phone number",TextInputType.emailAddress,emailController),
    //        InputDate2("username",TextInputType.visiblePassword,usernameController),
    //        InputDatecal("Date of birth",TextInputType.visiblePassword,dobController),
    //        InputDate2("PhoneNo",TextInputType.number,phoneController),
    //        InputDate2("password",TextInputType.visiblePassword,passwordController),
    //        InputDate2("confirm password",TextInputType.visiblePassword,conformController),
    //  ],
    //                        ),

    //                             SizedBox(height: 14,),

    //                         Padding(
    //                           padding: const EdgeInsets.all(10.0),
    //                           child: Text((""), // email already exists..! or other errors
    //                               style: FontManager().getTextStyle(context,
    //                                                         fontSize: 14,
    //                                                         color: Colors.red)),
    //                         ),
    //                              SizedBox(height: 20,),

    //                         Row(
    //                           mainAxisAlignment: MainAxisAlignment.center,
    //                           children: [
    //                             InkWell(
    //                                 onTap: (){
    //                               //  if( await storeData())
    //                               //  {
    //                               //     return;
    //                               //  }

    //                          storeData();

    //                                   // Navigator.pushNamed(context, '/conform');
    //                                },
    //                               child: Container(
    //                                 padding:const EdgeInsets.symmetric(horizontal:35,vertical: 10),
    //                                 decoration: BoxDecoration(
    //                                 // color:const Color.fromRGBO(97, 143, 214, 1),
    //                                   color: Colorcodes.billBody,
    //                                      borderRadius: BorderRadius.circular(5)
    //                                 ),
    //                                 child: Text(("next"),
    //                                 style: FontManager().getTextStyle(context,
    //                                                             lWeight: FontWeight.w400,
    //                                                             fontSize: 20,
    //                                                             color: Colors.white)),
    //                                                    ),
    //                             ),
    //                           ],
    //                         ),

    //                           ],
    //                        ),
    //                      )

    //                       // Column(
    //                       //   mainAxisAlignment: MainAxisAlignment.center,
    //                       //   children: [
    //                       //     Text((" email already exists..! or other errors"),
    //                       //     style: FontManager().getTextStyle(context,
    //                       //                               fontSize: 14,
    //                       //                               color: Colors.red)),
    //                       //   ],
    //                       // ),

    //                ],
    //            ),
    //          ),
    //    ),
    // );
  }

  void call() {
    var data = {
      'name': usernameController.text,
      'email': emailController.text,
      'userpassword': passwordController.text,
      'phone': phoneController.text,
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
  }

  Future<http.Response> createUser() async {
    final response = await http.post(
      Uri.parse(
          'https://stakeplot.in/api/v1/user/register'),
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
      snackBarCalled(context, "Please Enter All Feilds...", Colors.red);
      return;
    }

    if (phone.length != 10) {
      snackBarCalled(context, "Phone No Invalid", Colors.red);
      return;
    }
    if (password.length < 6) {
      snackBarCalled(
          context, "Password must be atleast 6 characters", Colors.red);
      return;
    }

    if (password != conform) {
      snackBarCalled(
          context, "Password and Conform password doesn't match", Colors.red);
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
        'phone': phoneController.text,
        'confirmPassword': conformController.text,
        'dob': dobController.text.substring(0, 10),
        'avatarType': url,
        'otp': "opts",
      }),
    );
   
    var responce = jsonDecode(response.body);
   
    bool boolvar = responce['success'];

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
