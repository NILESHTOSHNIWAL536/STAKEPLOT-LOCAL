import 'package:flutter/material.dart';

import '../../Constants/colors.dart';
import '../../Constants/core/app_padding_sizes.dart';
import '../../Constants/font_manager.dart';

class UpdatesScreen extends StatelessWidget {
  const UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.border,
      body: SafeArea(
        child: Column(
          children: [
            /// -------- HEADER ----------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: AppSizes.p14),
              decoration: const BoxDecoration(
                color: AppColors.newbg,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  _circleIcon(Icons.arrow_back, context),
                   SizedBox(width: MediaQuery.sizeOf(context).width/3.6),
                   Center(
                     child: Text(
                       "Updates",
                         style: FontManager().getTextStyle(
                   context,
                   lWeight: FontWeight.w600,
                   fontSize: 20,
                   color: AppColors.accentColor,
                                     ),
                     ),
                   ),
                   // to balance back icon
                ],
              ),
            ),

            /// -------- CONTENT ----------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// -------- VERSION CARD ----------
                    // Container(
                    //   width: double.infinity,
                    //   padding: const EdgeInsets.all(AppSizes.p16),
                    //   decoration: BoxDecoration(
                    //     color: const Color(0xFFF1F3FF),
                    //     borderRadius: BorderRadius.circular(16),
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Row(
                    //         mainAxisAlignment:
                    //             MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           const Text(
                    //             "Version 3.5.0",
                    //             style: TextStyle(
                    //               fontSize: 16,
                    //               fontWeight: FontWeight.w600,
                    //               color: Color(0xFF1E1E1E),
                    //             ),
                    //           ),
                    //           Container(
                    //             padding: const EdgeInsets.symmetric(
                    //                 horizontal: 10, vertical: AppSizes.p4),
                    //             decoration: BoxDecoration(
                    //               color: Colors.white,
                    //               borderRadius: BorderRadius.circular(20),
                    //             ),
                    //             child: const Text(
                    //               "42.5 MB",
                    //               style: TextStyle(
                    //                 fontSize: 12,
                    //                 color: Color(0xFF6B6B6B),
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       const SizedBox(height: 6),
                    //       const Text(
                    //         "Released Dec 10, 2024",
                    //         style: TextStyle(
                    //           fontSize: 13,
                    //           color: Color(0xFF6B6B6B),
                    //         ),
                    //       ),
                    //       const SizedBox(height: 16),
                    //       SizedBox(
                    //         width: double.infinity,
                    //         height: 48,
                    //         child: ElevatedButton(
                    //           onPressed: () {},
                    //           style: ElevatedButton.styleFrom(
                    //             backgroundColor:
                    //                 const Color(0xFF4B4D73),
                    //             shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(14),
                    //             ),
                    //             elevation: 0,
                    //           ),
                    //           child: const Text(
                    //             "Update Now",
                    //             style: TextStyle(
                    //               fontSize: 16,
                    //               fontWeight: FontWeight.w600,
                    //               color: Colors.white,
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    // const SizedBox(height: 24),

                    /// -------- NEW FEATURES ----------
                     Text(
                      "New Features",
                      style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.accentColor,
                  )
                     
                    ),

                    SizedBox(height: AppSizes.h12),

                    _featureCard(
                      context: context,
                      icon: Icons.psychology,
                      title: "AI-Powered Expense Insights",
                      badgeText: "NEW",
                      badgeColor: AppColors.primaryColorOpacity,
                      description:
                          "Get personalized spending recommendations powered by advanced AI algorithms",
                    ),

                    _featureCard(
                      context: context,
                      icon: Icons.account_balance_wallet,
                      title: "Enhanced Budget Tracking",
                      badgeText: "IMPROVED",
                      badgeColor: AppColors.primaryColorOpacity,
                      description:
                          "Set multiple budgets with custom categories and real-time spending alerts",
                    ),

                    _featureCard(
                      context: context,
                      icon: Icons.notifications,
                      title: "Smart Notifications",
                      badgeText: "NEW",
                      badgeColor: AppColors.primaryColorOpacity,
                      description:
                          "Receive timely alerts for bill payments, unusual spending, and budget limits",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// -------- BACK ICON ----------
  Widget _circleIcon(IconData icon, BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.pop(context);
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: AppColors.backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: AppColors.accentColor),
      ),
    );
  }

  /// -------- FEATURE CARD ----------
  Widget _featureCard({
   required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String badgeText,
    required Color badgeColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(AppSizes.p14),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.backgroundColor),
          ),
          SizedBox(width: AppSizes.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.accentColor,
                  ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                         style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w700,
                    fontSize: 11,
                    color: AppColors.primaryColor,
                  ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.h6),
                Text(
                  description,
                   style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.w400,
                    fontSize: 13,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
