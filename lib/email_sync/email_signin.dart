import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import '../Constants/app_styles.dart';
import '../Utils/homepageStrings.dart.dart';
import '../Constants/booleanFlag.dart';
import '../avatarProfile.dart';
import '../backed_connections/googlesignin/google.dart';
import 'add_credit_card_bank.dart';
import 'custom_steps.dart';
import 'data_loading.dart';

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: AppBar(
          elevation: 0,
          backgroundColor: AppColors.backgroundColor,
          leading: leadIcon(context),
          title: textStyle(
              context: context,
              text: "Sign in",
              c: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
              fontsize: 22),
          centerTitle: false,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomStepper(activeStep: 1),
            Center(
              child: SizedBox(
                width: w * .95,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    if (googleSignInBool.value)
                      return; // Prevent multiple clicks
                    googleSignInBool.value = true; // Set loading state
                    try {
                      final userdata = await AuthService()
                          .signInWithGoogle(context, flag: false,isEmail: true);

                      if (userdata != null) {
                        pushnameToRoute(context, GettingDataScreen());
                      }
                    } finally {
                      googleSignInBool.value = false; // Reset loading state
                    }
                    pushnameToRoute(context, GettingDataScreen());
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFF37344F), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 0.5),
                  ),
                  // icon:  AvatarProfileImage(url: svgIconPath.google2, width: 20, height: 20),
                  icon: AvatarProfileImage(
                    url: Sign.googleIcon,
                    width: 40,
                    height: 30,
                  ),
                  label: textStyle(
                      context: context,
                      text: "Sign in with Google",
                      c: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontsize: 15),
                  //  Text(
                  //   "Sign in with goggle",
                  //   style: TextStyle(
                  //     color: Color(0xFF37344F),
                  //     fontSize: 16.2,
                  //   ),
                  // ),
                ),
              ),
            ),
            SizedBox(height: 25),

            textStyle(
                context: context,
                text: "Is it safe?",
                c: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
                fontsize: 15),
            SizedBox(height: 9),
            textStyleImage(
                context: context,
                text: HomepageStringsDart().creditcardSigninData,
                c: AppColors.grey,
                fontWeight: FontWeight.w400,
                fontsize: 14,
                iswrap: true),

            //  AvatarProfileImage(url: svgIconPath.loading_google2, width: 10, height: 10),
            SizedBox(height: 13),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.beenhere_rounded,
                    color: Color(0xFF37344F), size: 19),
                SizedBox(width: 8),
                textStyle(
                    context: context,
                    text: "Your data is safe with us",
                    c: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontsize: 17),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
