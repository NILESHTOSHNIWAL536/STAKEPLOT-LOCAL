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
import '../services/secure_storage.dart';
import '../signInOut/referral_code_screen.dart';

Future<void>? _hiveWarmupFuture;
Future<Widget>? _authNavigationFuture;

Future<void> _ensureHiveReady() {
  return _hiveWarmupFuture ??= initAllHive();
}

Future<Widget> _ensureAuthNavigation() {
  return _authNavigationFuture ??= checkAuthAndNavigate();
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _authNavigationFuture = null;
    initGetControllersIfisRegistered();
    _loadStaticData();
    _checkForUpdates();
  }

  void _loadStaticData() async {
    try {
      await _ensureHiveReady();
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
      duration: 900,
      splashIconSize: size.height,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
      splash: SizedBox(
        width: size.width,
        height: size.height,
        child: Lottie.asset("assets/splashScreen/appScreen.json",
            fit: BoxFit.cover, repeat: false),
      ),
      // Single source of truth for navigation decisions.
      screenFunction: _ensureAuthNavigation,
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

  if (!isLoggedIn) return const LoginScreen();

  // Keep Hive warming in the background so the splash cannot be held on-screen
  // by local cache setup. Home renders cached/API data as soon as each source is ready.
  _ensureHiveReady();

  // Read and immediately clear the pending deep-link screen.
  final String? pendingScreen = await SecureStorageService().read("Screen");
  if (pendingScreen != null && pendingScreen.trim().isNotEmpty) {
    await SecureStorageService().delete("Screen");
  }

  // ⚡ Background API load — never awaited, never blocks the screen transition.
  Future(() {
    try {
      final ctx = navigatorKey.currentContext;
      // ignore: use_build_context_synchronously
      if (ctx != null) callApi(ctx);
    } catch (_) {}
  });

  return (pendingScreen != null && pendingScreen.trim().isNotEmpty)
      ? navigatePath(pendingScreen)
      : const HomePage();
}

Widget navigatePath(String navigate) {
  switch (navigate) {
    case "home":
    case "/home":
    case "signup":
      return const HomePage();
    case "budget":
      return const Budget();
    case "calculator":
    case "veg_nonveg":
      return const VegNonVegCalculator();
    case "code":
      return const ReferralCodeScreen();
    default:
      return const HomePage();
  }
}
