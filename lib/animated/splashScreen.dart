import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Utils/communityPageStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/finspaceStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/Utils/pdfStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
import 'package:flutter_application_code_stakeplot/Utils/profileScreenStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/rewardscreen.dart';
import 'package:flutter_application_code_stakeplot/Utils/signUp.dart';
import 'package:flutter_application_code_stakeplot/Utils/signin.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_application_code_stakeplot/main.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';

import '../Hive_localstorage/apisCall/init_hive.dart';
import '../Home_Screen/Home/init_Api_Calls.dart';
import '../OneSignal/oneSignal_config.dart';
import '../Utils/credit_card.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
     _checkForUpdatesAndNavigate();
    callApis();
    initGetControllers();
    initializeOneSignal(context);
    initializeData(context, mounted);
  }

  Future<void> _checkForUpdatesAndNavigate() async {
      if(SnackbarData().showUpdatecall) await checkForUpdate();  
      await checkAuthAndNavigate();  // only navigate after update check
  }

  void callApis()async {
    SignupData signup = SignupData();
    SnackbarData snackbarData = SnackbarData();
    SigninData signinData = SigninData();

    PlotFinanceStaticData plotFinanceStaticData = PlotFinanceStaticData();
    HomepageStringsDart homepageStringsDart = HomepageStringsDart();
    CommunityScreenStrings communityScreenStrings = CommunityScreenStrings();
    FinvuStrings finvuStrings = FinvuStrings();
    ProfileScreenStrings profileScreenStrings = ProfileScreenStrings();
    FinspaceStrings finspaceStrings = FinspaceStrings();

    finspaceStrings.fetchConstants();
    signinData.fetchConstants();
    signup.fetchConstants();
    snackbarData.fetchConstants();
    plotFinanceStaticData.fetchConstants();
    communityScreenStrings.fetchConstants();
    finvuStrings.fetchConstants();
    homepageStringsDart.fetchConstants();
    profileScreenStrings.fetchConstants();
    PdfStrings().fetchConstants();
    RewardScreenStrings().fetchConstants();
    CreditCardScreenStrings().fetchConstants();
    await initAllHive();
  }

  @override
  Widget build(BuildContext context) {
  final size = MediaQuery.of(context).size; 

  return AnimatedSplashScreen.withScreenFunction(
    backgroundColor: Colors.white,
    duration: 1800,
    splashIconSize: size.height, 
    splashTransition: SplashTransition.fadeTransition,
    pageTransitionType: PageTransitionType.fade,
    splash: SizedBox(
      width: size.width,   
      height: size.height, 
      child: Lottie.asset(
        "assets/splashScreen/appScreen.json",
        fit: BoxFit.cover, 
      ),
    ),
    screenFunction: checkAuthAndNavigate,
  );
}

}
