import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/email_sync/custom_steps.dart';

class CreditCardsScreen extends StatelessWidget {
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
          title: Text(
            "Credit Cards",
            style: TextStyle(
                color: Color(0xFF37344F),
                fontWeight: FontWeight.w600,
                fontSize: 18),
          ),
          centerTitle: false,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: w * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: h * 0.012),
            CustomStepper(activeStep: 3),
            SizedBox(height: h * 0.034),
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/axis_rewards_card.png',
                    width: w * .86,
                    fit: BoxFit.fitWidth,
                  ),
                  SizedBox(height: 16),
                  Image.asset(
                    'assets/axis_privilege_card.png',
                    width: w * .86,
                    fit: BoxFit.fitWidth,
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
