import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
import 'package:flutter_application_code_stakeplot/Utils/signUp.dart';
import 'package:flutter_application_code_stakeplot/Utils/signin.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
{

 
  @override
  void initState()
  {
    super.initState();
    callApis();

  }


  void callApis(){
    SignupData signup= SignupData();
    SnackbarData snackbarData= SnackbarData();
    SigninData signinData= SigninData();
    PlotFinanceStaticData plotFinanceStaticData= PlotFinanceStaticData();
    HomepageStringsDart homepageStringsDart= HomepageStringsDart();
    signup.fetchConstants();
    snackbarData.fetchConstants();
    plotFinanceStaticData.fetchConstants();
    signinData.fetchConstants();
    homepageStringsDart.fetchConstants();

  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedSplashScreen.withScreenFunction(
        backgroundColor: Colors.white,
        duration: 2000,
        splashIconSize: 300,
        splashTransition: SplashTransition.fadeTransition,
        pageTransitionType: PageTransitionType.fade,
        splash: Center(
          child: Lottie.asset("assets/splashScreen/splash.json"),
        ),
        screenFunction: checkAuthAndNavigate,
      ),
    );
  }
}
