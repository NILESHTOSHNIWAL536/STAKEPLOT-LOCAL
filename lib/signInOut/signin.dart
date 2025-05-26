import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';


import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/googlesignin/google.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Signin extends StatefulWidget {
  const Signin({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  // TextEditingController emailController = TextEditingController();
  // TextEditingController passwordController = TextEditingController();
  // TextEditingController emailController=TextEditingController(text: "lalatoshniwal2002@gmail.com");
  // TextEditingController passwordController =TextEditingController(text: "1234567");
  TextEditingController emailController= TextEditingController(text: "");
  TextEditingController passwordController= TextEditingController(text: "");

  
  @override
  void initState() {
    check(context, "loginuser");
     // userstats
     
  }
 // userstats
  @override
  void dispose() {
    // Clean up
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorcodes.white,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                  textHeader(),
                  getTextFeilds(),
                  siginButton(),   
                  // signinWith(),  
                  forgotPassword(),
                  dontHaveAccount(),
            ],
          ),
        ),
      ),
    ); 
  }

Widget textHeader(){
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
             Container(
              width: MediaQuery.of(context).size.width/1.2,
              child: textStyle(context: context,text: "Sign In",fontWeight: FontWeight.bold,fontsize: 30)
              ),
             const SizedBox(height: 10,),
             textStyle(context: context,text: "Sign in to your account.",fontWeight: FontWeight.w400,fontsize: 14),
        ],
    );
}


Widget forgotPassword(){
     return Center(
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
                    );
}

Widget dontHaveAccount(){
    return Column(
        children: [

               Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: Colorcodes.paddingSize / 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(("Don’t have an account ? "),
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colorcodes.iconBackGround,
                                  // decoration: TextDecoration.underline
                                )),
                            InkWell(
                              onTap: () {
                                acceptReset.value=false;
                                Navigator.pushNamed(context, '/signup');
                              },
                              child: Text(("Sign Up"),
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
                    ),
           
        ],
    );
}


Widget getTextFeilds(){
    return Column(
        children: [
                   const SizedBox(
                      height: 10,
                    ),
                    TextFeildWidget(
                        textEditingController: emailController,
                        heading: "Email",
                        keyBoard: TextInputType.emailAddress,
                        lableText: "johndoe@gmail.com"),
                    TextFeildWidgetPassword(
                      textEditingController: passwordController,
                      heading: "Password",
                      keyBoard: TextInputType.visiblePassword,
                      lableText: "Password",
                      flag: false,
                      icon: Icons.lock_outline_rounded,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                  
        ],
    );
}




Widget signinWith(){
    return Padding(
      padding:  EdgeInsets.symmetric(vertical:Colorcodes.paddingSize ),
      child: Column(
          children: [
                textStyle(context: context,text: "or Sign In with",fontWeight: FontWeight.w400,fontsize: 14),
                const SizedBox(height: 10,),
                Row(
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                   children: [
                      //  containerIconSiginWith(FontAwesomeIcons.apple,Colorcodes.black),
                       containerIconSiginWith(FontAwesomeIcons.google,Colorcodes.white),
                      //  containerIconSiginWith(FontAwesomeIcons.facebook,Colorcodes.blue),
                   ],
                ),
                const SizedBox(height: 10,),
                InkWell(
                          onTap: ()async {
                           final SharedPreferences _pref = await SharedPreferences.getInstance();
                            String token = "Bearer " + "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3NWMwYWZiZmNiMTcxMDc2NWFiOGU5MCIsImlhdCI6MTc0MTc3NjU5MCwiZXhwIjoxNzQ2OTYwNTkwfQ.dm6hkBDE1xAY48hAOMLckjL0wXcCh54TpWf3wZXQ6Uc";
                            _pref.setString("accessToken", token);

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
          ],
      ),
    );
}
Widget containerIconSiginWith(IconData icon,Color color){
   return InkWell(
    onTap: ()async{
         await GoogleAuthService().signInWithGoogle();
    },
     child: Container(
       padding: EdgeInsets.symmetric(horizontal: 10,vertical: 7),
       decoration: BoxDecoration(
         color: Colorcodes.greyLight,
         borderRadius: BorderRadius.circular(10)
       ),
        child: FaIcon(icon,size: 30,color: color,),
     ),
   );
}
Widget siginButton(){
    return 
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 30),
                        decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(
                                Colorcodes.borderRadius30)),
                        child: InkWell(
                          onTap: ()async {
                            
                            if (acceptReset.value) return;

                            if (emailController.text == "" ||passwordController.text == "") {
                              snackBarCalledfail(context,SnackbarData().enterAllFields);
                              return;
                            }
                            
                            acceptReset.value = true;
                            // userstats
                           
                          
                            await getDeviceInfo("deviceData.value".toString(), context,emailController,passwordController);
                            
                           
                          },
                          child: Obx(() => Center(
                                child: acceptReset.value? Center(
                                  child: Spinner(size: 20.0,color: Colorcodes.white,),
                                ): 
                                  Text(("Sign In"),
                                        style: FontManager().getTextStyle(
                                            context,
                                            lWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colorcodes.white)),
                              )),
                        ),
                      ),
                    );
}

}




// Center(
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(
//                             vertical: Colorcodes.paddingSize / 3),
//                         child: InkWell(
//                           onTap: () {
                            
//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => ShareAccountLogin(),
//                               ),
//                           );
//                           },
//                           child: Text(("Connect your bank account "),
//                               style: FontManager().getTextStyle(context,
//                                   lWeight: FontWeight.bold,
//                                   fontSize: 15,
//                                   color: Colorcodes.iconBackGround,
//                                   decoration: TextDecoration.underline)),
//                         ),
//                       ),
//                     ),
//  Center(
//                       child: GestureDetector(
//                         onTap: () {

//                             handleSignInGoogle(context);

//                         },
//                         child: GoogleSignIn()
//                       ),
//                     )