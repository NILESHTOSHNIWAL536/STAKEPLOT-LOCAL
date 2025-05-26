import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/OneSignal/oneSignal_config.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/Utils/signin.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/googlesignin/google.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/headersList/textfeild.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Signin extends StatefulWidget {
  const Signin({Key? key}) : super(key: key);

  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController passwordController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    check(context, "loginuser");
    // Initialize signin data
   
  }

  @override
  void dispose() {
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

  Widget textHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: MediaQuery.of(context).size.width / 1.2,
          child: textStyle(
            context: context,
            text: SigninData().signInTitle, // Updated
            fontWeight: FontWeight.bold,
            fontsize: 30,
          ),
        ),
        const SizedBox(height: 10),
        textStyle(
          context: context,
          text: SigninData().signInSubtitle, // Updated
          fontWeight: FontWeight.w400,
          fontsize: 14,
        ),
      ],
    );
  }

  Widget forgotPassword() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Colorcodes.paddingSize / 3),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/ForgotPassword');
          },
          child: Text(
            SigninData().forgotPasswordText, // Updated
            style: FontManager().getTextStyle(
              context,
              lWeight: FontWeight.bold,
              fontSize: 12,
              color: Colorcodes.iconBackGround,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }

  Widget dontHaveAccount() {
    return Column(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: Colorcodes.paddingSize / 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  SigninData().dontHaveAccountText, // Updated
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colorcodes.iconBackGround,
                  ),
                ),
                InkWell(
                  onTap: () {
                    acceptReset.value = false;
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text(
                    SigninData().signUpText, // Updated
                    style: FontManager().getTextStyle(
                      context,
                      lWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colorcodes.cardShade5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget getTextFeilds() {
    return Column(
      children: [
        const SizedBox(height: 10),
        TextFeildWidget(
          textEditingController: emailController,
          heading: SigninData().emailLabel, // Updated
          keyBoard: TextInputType.emailAddress,
          lableText: SigninData().emailHint, // Updated
        ),
        TextFeildWidgetPassword(
          textEditingController: passwordController,
          heading: SigninData().passwordLabel, // Updated
          keyBoard: TextInputType.visiblePassword,
          lableText: SigninData().passwordHint, // Updated
          flag: false,
          icon: Icons.lock_outline_rounded,
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget signinWith() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Colorcodes.paddingSize),
      child: Column(
        children: [
          textStyle(
            context: context,
            text: SigninData().orSignInWithText, // Updated
            fontWeight: FontWeight.w400,
            fontsize: 14,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              containerIconSiginWith(FontAwesomeIcons.google, Colorcodes.white),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
            
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ShareAccountLogin(),
                ),
              );
            },
            child: Text(
              SigninData().connectBankText, // Updated
              style: FontManager().getTextStyle(
                context,
                lWeight: FontWeight.bold,
                fontSize: 15,
                color: Colorcodes.iconBackGround,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget containerIconSiginWith(IconData icon, Color color) {
    return InkWell(
      onTap: () async {
        await GoogleAuthService().signInWithGoogle();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colorcodes.greyLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: FaIcon(icon, size: 30, color: color),
      ),
    );
  }

  Widget siginButton() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width / 1.2,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(Colorcodes.borderRadius30),
        ),
        child: InkWell(
          onTap: () async {
            if (acceptReset.value) return;

            if (emailController.text.isEmpty || passwordController.text.isEmpty) {
              snackBarCalledfail(context,SnackbarData().enterAllFields); // You might want to update this to use signinData validation messages
              return;
            }

            acceptReset.value = true;
            
            await getDeviceInfo("deviceData.value".toString(), context, emailController, passwordController);
          },
          child: Obx(
            () => Center(
              child: acceptReset.value
                  ? Center(
                      child: Spinner(size: 20.0, color: Colorcodes.white),
                    )
                  : Text(
                      SigninData().signInButtonText, // Updated
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colorcodes.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}