import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../animated/booleanFlag.dart';
import '../avatarProfile.dart';
import '../backed_connections/apiConnect/signInAndOut.dart';
import '../backed_connections/googlesignin/google.dart';
import '../colorcodes.dart';
import 'add_credit_card_bank.dart';
import 'custom_steps.dart';
import 'data_loading.dart';

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: leadIcon(context),
          title: Text("Sign in",
              style: TextStyle(
                  color: Color(0xFF37344F),
                  fontWeight: FontWeight.w600,
                  fontSize: 18)),
          centerTitle: false,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: h * 0.012),
            CustomStepper(activeStep: 1),
            SizedBox(height: 28),
            Center(
              child: SizedBox(
                width: w * .95,
                child: OutlinedButton.icon(
                  onPressed: ()async {
                    

                       if (googleSignInBool.value) return; // Prevent multiple clicks
                        googleSignInBool.value = true; // Set loading state
                        try {
                          final userdata = await AuthService().signInWithGoogle(context);
                          if (userdata != null && userdata['data']['accessToken'] != null) {
                            loginCalledDataForApple(userdata, context);
                          } else if (userdata != null) 
                          {
                              pushnameToRoute(context,GettingDataScreen());
                          }
                        } finally {
                          googleSignInBool.value = false; // Reset loading state
                        }
                      // pushnameToRoute(context,GettingDataScreen());
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFF37344F), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 13.5),
                  ),
                  icon: Icon(
                    FontAwesomeIcons.google,
                    color: Color(0xFF37344F),
                    size: 27,
                  ),
                  label: Text(
                    "Sign in with goggle",
                    style: TextStyle(
                      color: Color(0xFF37344F),
                      fontSize: 16.2,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 25),
            Text("Is it safe?",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
            SizedBox(height: 9),
              Image.asset(
                      svgIconPath.g_person2,
                      width: w /1.1,
                      fit: BoxFit.fitWidth,
              ),
              // AvatarProfileImage(url: svgIconPath.g_person, width: 10, height: 10),
            SizedBox(height: 13),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.check_box_rounded, color: Color(0xFF37344F), size: 19),
                SizedBox(width: 8),
                Text(
                  'your data is safe with us',
                  style:
                      TextStyle(color: Color(0xFF38394A), fontSize: 14.0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}