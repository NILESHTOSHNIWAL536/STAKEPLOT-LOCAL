import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Utils/signUp.dart';
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

 SignupData signup= SignupData();
  @override
  void initState()
  {
    super.initState();
    signup.fetchConstants();
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
