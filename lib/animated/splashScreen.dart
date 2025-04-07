import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/home_page.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({ Key? key }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

 

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedSplashScreen(
          backgroundColor: Colors.white,
          duration: 2000,
          splashIconSize:500,
          nextScreen: HomePage(),
          splash: Center(
              child: Lottie.asset("assets/splashScreen/splash.json"),
          ),
      ),
    );
  }
}