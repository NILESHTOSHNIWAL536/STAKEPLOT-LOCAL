import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';

import '../../Constants/colors.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../Budgets/Budget.dart'; // for icons

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildFeatureIcon(Icons.calculate, 'Calculators\n ', 0, context,
            "/AllCalculator", svgIconPath.financecal),
        _buildFeatureIcon(Icons.fastfood, 'Foodie\nFund', 1, context,
            "/VegNonveg", svgIconPath.financefood),
        _buildFeatureIcon(Icons.account_balance, 'Loan\nAffordability', 2,
            context, "/LoanCalculatorUI", svgIconPath.financeloan),
        _buildFeatureIcon(Icons.currency_exchange, 'Currency\nConverter', 3,
            context, "/currencyConverterScreen", svgIconPath.financeCurrency),
      ],
    );
  }
}

// Individual circular icon widget with text
Widget _buildFeatureIcon(IconData icon, String text, int index,
    BuildContext context, String routerName, String urlPath) {
  return InkWell(
    onTap: () {
      Navigator.pushNamed(context, routerName);
    },
    child: Padding(
      padding: const EdgeInsets.only(top:AppSizes.p30),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: index == 0 || index == 3 ? 10 : 60.0),
            child: Container(
              width: 50,
              height: 50,
              padding: EdgeInsets.all(AppSizes.p4),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle, // Changed to a circle for accuracy
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentColor.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: AvatarProfileImage(url: urlPath, width: 12, height: 14),
            ),
          ),
           SizedBox(height: AppSizes.h4),
          textStyleImage(
              text: text,
              context: context,
              c: AppColors.backgroundColor,
              fontsize: 11,
              // lineHeight: 1.2,
              isCenter: true),
        ],
      ),
    ),
  );
}
