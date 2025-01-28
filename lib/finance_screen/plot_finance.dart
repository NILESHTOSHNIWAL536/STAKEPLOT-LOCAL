import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

import 'package:flutter_application_code_stakeplot/avatarProfile.dart';

import 'package:flutter_application_code_stakeplot/bottomNavigations.dart';

import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';

class PlotFinance extends StatefulWidget {
  const PlotFinance({super.key});

  @override
  State<PlotFinance> createState() => _PlotFinanceState();
}

class _PlotFinanceState extends State<PlotFinance> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: BottomNavigations(data: 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                AvatarProfileImage(
                  url: Finance.plot,
                  height: 5,
                  width: 1,
                ),

                SizedBox(height: 24),

                // Budget and Debt Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCard(
                      icon: AvatarProfileImage(
                        url: Finance.budget,
                        height: 7,
                        width: 12,
                      ),
                      path: "/Budget",
                    ),
                    _buildCard(
                      icon: AvatarProfileImage(
                        url: Finance.debt,
                        height: 7,
                        width: 12,
                      ),
                      path: "/Debt",
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Calculators Section
                Text('Calculators',
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppColors.bg1)),
                SizedBox(height: 16),

                // Calculator Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                  children: [
                    _buildCalculatorTile(
                      'Credit Card Payoff',
                      'Calculator',
                      url: Finance.credit,
                      path: "/CreditCard",
                    ),
                    _buildCalculatorTile(
                      'EMI',
                      'Calculator',
                      url: Finance.emi,
                      path: "/EMI",
                    ),
                    _buildCalculatorTile(
                      'Rent vs Buy',
                      'Calculator',
                      url: Finance.key,
                      path: "/Rent",
                    ),
                    _buildCalculatorTile(
                      'Savings goal',
                      'Calculator',
                      url: Finance.savings,
                      path: "/Savings",
                    ),
                    _buildCalculatorTile(
                      'Auto loan',
                      'Calculator',
                      url: Finance.auto,
                      path: "/Auto",
                    ),
                    _buildCalculatorTile(
                      'Trip cost',
                      'Calculator',
                      url: Finance.location,
                      path: "/TripCost",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({icon, required String path}) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, path);
      },
      child: icon,
    );
  }

  Widget _buildCalculatorTile(String title, String subtitle,
      {required String url, required String path}) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, path);
      },
      child: Container(
        // width: MediaQuery.of(context).size.width * 0.45, // 45% of screen width
        //height: MediaQuery.of(context).size.height * 0.1,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.mt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: AvatarProfileImage(
                  url: url,
                  height: 28,
                  width: 28,
                ),
              ),
              SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w700,
                                fontSize: 14,
                                overflow: TextOverflow.ellipsis,
                                color: AppColors.bg1)),
                        Text(subtitle,
                            style: FontManager().getTextStyle(context,
                                lWeight: FontWeight.w500,
                                fontSize: 14,
                                color: AppColors.bg1)),
                      ],
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height * 0.04,
                        width: MediaQuery.of(context).size.width * 0.09,
                        decoration: BoxDecoration(
                            color: AppColors.bg2,
                            borderRadius: BorderRadius.circular(36)),
                        child:
                            Icon(Icons.arrow_forward_ios, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
