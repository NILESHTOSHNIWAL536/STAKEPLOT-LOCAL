import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Utils/communityPageStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/finspaceStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
import 'package:flutter_application_code_stakeplot/Utils/profileScreenStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/signUp.dart';
import 'package:flutter_application_code_stakeplot/Utils/signin.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';


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
    CommunityScreenStrings communityScreenStrings= CommunityScreenStrings();
    FinvuStrings finvuStrings= FinvuStrings();
    ProfileScreenStrings profileScreenStrings= ProfileScreenStrings();
    FinspaceStrings finspaceStrings= FinspaceStrings();

    finspaceStrings.fetchConstants();
    signinData.fetchConstants();
    signup.fetchConstants();
    snackbarData.fetchConstants();
    plotFinanceStaticData.fetchConstants();
    communityScreenStrings.fetchConstants();
    finvuStrings.fetchConstants();
    homepageStringsDart.fetchConstants();
    profileScreenStrings.fetchConstants();

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
