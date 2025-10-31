import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Utils/communityPageStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/finspaceStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/finvuStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/Utils/plotFinanceStringsPage.dart';
import 'package:flutter_application_code_stakeplot/Utils/profileScreenStrings.dart';
import 'package:flutter_application_code_stakeplot/Utils/signUp.dart';
import 'package:flutter_application_code_stakeplot/Utils/signin.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/clearstack.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/signInAndOut.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppScreenAnimation extends StatefulWidget {
  const AppScreenAnimation({super.key});

  @override
  State<AppScreenAnimation> createState() => _AppScreenAnimationState();
}

class _AppScreenAnimationState extends State<AppScreenAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<Offset>> _slideAnimations;
  int _currentIndex = 0;

  final List<String> _svgAssets = [
    AnimatedAppLoaders.animate1,
    AnimatedAppLoaders.animate2,
    AnimatedAppLoaders.animate3,
    AnimatedAppLoaders.animate4,
    AnimatedAppLoaders.animate5,
    AnimatedAppLoaders.animate6,
    AnimatedAppLoaders.animate7,
  ];

  // Directions with larger offsets to start further outside the screen
  final List<Offset> _directions = [
    const Offset(-4.0, 0), // Far left
    const Offset(4.0, 0),  // Far right
    const Offset(0, -4.0), // Far top
    const Offset(0, 4.0),  // Far bottom
    const Offset(-4.0, 0), // Far left
    const Offset(4.0, 0),  // Far right
    const Offset(0, -4.0), // Far top
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400), // Very fast animation
      vsync: this,
    );

    // Custom curve for "jerk" effect (fast start, abrupt stop)
    // final jerkCurve = Cubic(0.9, 0.0, 0.95, 0.05);

    _slideAnimations = _directions.map((direction) {
      return Tween<Offset>(
        begin: direction,
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

     callApis();
     initGetControllers();
    _startAnimation();
  }

  void callApis() {
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
  }

  void _startAnimation() async {
    while (_currentIndex < _svgAssets.length) {
      _controller.forward();
      await Future.delayed(const Duration(milliseconds: 600)); // Quick display
      _controller.reset();
      setState(() {
        _currentIndex++;
      });
    }
    // Navigate to next screen
   final nextScreen = await checkAuthAndNavigate();
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
  }

 

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Match Lottie splash
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
              ),
            ),
            child: SlideTransition(
              position: _slideAnimations[_currentIndex % _svgAssets.length],
              child: SvgPicture.asset(
                _svgAssets[_currentIndex % _svgAssets.length],
                width: 50, // Match Lottie splashIconSize
                height: 50,
              ),
            ),
          ),
        ),
      ),
    );
  }
}