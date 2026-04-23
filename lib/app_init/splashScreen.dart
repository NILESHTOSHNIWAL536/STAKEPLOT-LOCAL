import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
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
import 'package:flutter_application_code_stakeplot/components/main_helper.dart';
import 'package:flutter_application_code_stakeplot/repository/clearstack.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import '../Hive_localstorage/apisCall/init_hive.dart';
import '../Home_Screen/Home/init_Api_Calls.dart';
import '../Home_Screen/home_screen_state/home_page.dart';
import '../Utils/credit_card.dart';
import '../finance_screen/Budgets/Budget.dart';
import '../finance_screen/Calculators/veg_nonveg.dart';
import '../loginservices/login_screen.dart';
import '../main.dart';
import '../repository/auth_service/login_apis.dart';
import '../services/secure_storage.dart';
import '../signInOut/referral_code_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initGetControllers();
    _loadStaticData();
    _checkForUpdates();
  }

  void _loadStaticData() async {
    try {
      await initAllHive();
      await Future.wait([
        SigninData().fetchConstants().then((_) {}),
        SignupData().fetchConstants().then((_) {}),
        SnackbarData().fetchConstants().then((_) {}),
        PlotFinanceStaticData().fetchConstants().then((_) {}),
        CommunityScreenStrings().fetchConstants().then((_) {}),
        FinvuStrings().fetchConstants().then((_) {}),
        HomepageStringsDart().fetchConstants().then((_) {}),
        ProfileScreenStrings().fetchConstants().then((_) {}),
        PdfStrings().fetchConstants().then((_) {}),
        FinspaceStrings().fetchConstants().then((_) {}),
        RewardScreenStrings().fetchConstants().then((_) {}),
        CreditCardScreenStrings().fetchConstants().then((_) {}),
      ]);
    } catch (e) {
      debugPrint("Static data load error: $e");
    }
  }

  // Runs all static-data fetches concurrently — does NOT block navigation.

  Future<void> _checkForUpdates() async {
    if (SnackbarData().showUpdatecall) await checkForUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedSplashScreen.withScreenFunction(
      backgroundColor: AppColors.backgroundColor,
      duration: 1800,
      splashIconSize: size.height,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
      splash: SizedBox(
        width: size.width,
        height: size.height,
        child: Lottie.asset("assets/splashScreen/appScreen.json",
            fit: BoxFit.cover),
      ),
      // Single source of truth for navigation decisions.
      screenFunction: checkAuthAndNavigate,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// checkAuthAndNavigate
//
// Called once by AnimatedSplashScreen after the animation finishes.
//
// Decision priority:
//   1. No token            → LoginScreen
//   2. Token + "Screen"    → deep-link target (written by AppsflyerService
//                            during a cold start before navigator was ready)
//   3. Token, no screen    → HomePage
//
// callApi is always fired in the background so it NEVER delays transition.
// ─────────────────────────────────────────────────────────────────────────────
Future<Widget> checkAuthAndNavigate() async {
  final bool isLoggedIn =
      await SecureStorageService().containsKey("accessToken");

  if (!isLoggedIn) return LoginScreen();

  // Read and immediately clear the pending deep-link screen.
  final String? pendingScreen = await SecureStorageService().read("Screen");
  if (pendingScreen != null && pendingScreen.trim().isNotEmpty) {
    await SecureStorageService().delete("Screen");
  }

  // ⚡ Background API load — never awaited, never blocks the screen transition.
  Future(() {
    try {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) callApi(ctx);
    } catch (_) {}
  });

  return (pendingScreen != null && pendingScreen.trim().isNotEmpty)
      ? navigatePath(pendingScreen)
      : HomePage();
}

Widget navigatePath(String navigate) {
  switch (navigate) {
    case "home":
    case "/home":
    case "signup":
      return HomePage();
    case "budget":
      return Budget();
    case "calculator":
    case "veg_nonveg":
      return VegNonVegCalculator();
    case "code":
      return ReferralCodeScreen();
    default:
      return HomePage();
  }
}
