import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';
import 'package:flutter_application_code_stakeplot/finSpace/apisCall.dart';
import 'package:flutter_application_code_stakeplot/finSpace/marks.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isDismissible: false,
        enableDrag: false,
        builder: (BuildContext context) {
          return Container(
            height: 300,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: AppColors.finSpaceColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    getMaskedNumber(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MaskNameScreen()),
                    );
                  },
                  child: const Text("Continue"),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: SafeArea(child: BottomNavigations(data: 2)),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome to",
                style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 39.58,
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                    letterSpacing: 0,
                    color: AppColors.accentColor),
              ),
              const Text(
                "Finspace",
                style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 39.58,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                    letterSpacing: 0,
                    color: AppColors.finSpaceColor),
              ),
              const SizedBox(height: 20),
              AvatarProfileImage(
                url: FinSpaceIcons.welcome,
                height: 3,
                width: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
