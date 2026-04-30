import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import '../Constants/app_styles.dart';
import '../Utils/homepageStrings.dart.dart';
import '../Constants/booleanFlag.dart';
import '../image_service/avatarProfile.dart';
import '../backed_connections/googlesignin/google.dart';
import 'add_credit_card_bank.dart';
import 'custom_steps.dart';
import 'email_loading_screen.dart';

import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: AppBar(
          elevation: 0,
          backgroundColor: AppColors.backgroundColor,
          leading: leadIcon(context),
          title: textStyle(
            context: context,
            text: "Sign in",
            c: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontsize: 22,
          ),
          centerTitle: false,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomStepper(activeStep: 1),
            SizedBox(height: h * 0.02),

            // ── Headline ──────────────────────────────────────────────────
            textStyle(
              context: context,
              text: "Connect your Gmail",
              c: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
              fontsize: 22,
            ),
            const SizedBox(height: 8),
            textStyleImage(
              context: context,
              text:
                  "We'll scan your inbox for credit card statements — read-only, nothing is stored on-device.",
              c: AppColors.grey,
              fontWeight: FontWeight.w400,
              fontsize: 14,
              iswrap: true,
            ),

            SizedBox(height: h * 0.03),

            // ── Google Sign-In button ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () async {
                  if (googleSignInBool.value) return;
                  googleSignInBool.value = true;
                  try {
                    final userdata = await AuthService().signInWithGoogle(
                      context,
                      flag: false,
                      isEmail: true,
                    );
                    if (userdata != null) {
                      pushnameToRoute(context, GettingDataScreen());
                    }
                  } finally {
                    googleSignInBool.value = false;
                  }
                  // pushnameToRoute(context, GettingDataScreen());
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: const Color(0xFF37344F), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AvatarProfileImage(
                        url: Sign.googleIcon, width: 24, height: 24),
                    const SizedBox(width: 4),
                    textStyleImage(
                      context: context,
                      text: "Continue with Google",
                      c: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontsize: 15,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: h * 0.035),

            // ── Security callouts ─────────────────────────────────────────
            _SecurityRow(
              icon: Icons.lock_outline_rounded,
              color: const Color(0xFF4285F4),
              title: "Read-only Gmail access",
              subtitle: "We never send emails on your behalf.",
            ),
            const SizedBox(height: 14),
            _SecurityRow(
              icon: Icons.shield_outlined,
              color: const Color(0xFF0F9D58),
              title: "End-to-end encrypted",
              subtitle: "Your data is encrypted at rest and in transit.",
            ),
            const SizedBox(height: 14),
            _SecurityRow(
              icon: Icons.delete_outline_rounded,
              color: const Color(0xFFF4B400),
              title: "Delete anytime",
              subtitle: "Remove your account and all data in one tap.",
            ),

            SizedBox(height: h * 0.03),

            // ── Fine print ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 8),
                  Expanded(
                    child: textStyleImage(
                      context: context,
                      text: HomepageStringsDart().creditcardSigninData,
                      c: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                      fontsize: 12,
                      iswrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _SecurityRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: FontManager().getTextStyle(context,
                    fontSize: 14,
                    lWeight: FontWeight.w600,
                    color: Color(0xFF37344F)),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: FontManager().getTextStyle(context,
                    fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
