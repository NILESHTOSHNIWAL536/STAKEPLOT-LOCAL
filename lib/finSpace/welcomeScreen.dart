import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
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
            height: MediaQuery.sizeOf(context).height/4,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: AppColors.finSpaceColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   Text(
                    "Finspace",
                    style: FontManager2().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.backgroundColor)
                  ),
                   Text(
                    "A safe and supportive space to share your financial thoughts, questions, and experiences—completely anonymously. No names, no pressure—just open, respectful conversations.",
                    //  textAlign: TextAlign.center,
                   style: FontManager2().getTextStyle(context,
                      lWeight: FontWeight.w500,
                      fontSize: 16,
                      color: AppColors.backgroundColor)),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     getMaskedNumber(context);
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => MaskNameScreen()),
                  //     );
                  //   },
                  //   child:  Text("Continue",style: FontManager2().getTextStyle(context,
                  //     lWeight: FontWeight.w600,
                  //     fontSize: 20,
                  //     color: AppColors.finSpaceColor)),
                  // ),
                   SizedBox(
            width: MediaQuery.sizeOf(context).width/4,
            child: ElevatedButton(
                  onPressed: () {
                      getMaskedNumber(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MaskNameScreen()),
                      );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.backgroundColor,
               
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Continue',
                  style: FontManager2().getTextStyle(context,
                      lWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.finSpaceColor)),
            ),
          ),
                ],
              ),
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
