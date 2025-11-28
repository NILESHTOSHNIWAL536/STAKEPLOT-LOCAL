import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

void showEarningScoreDialog(BuildContext context) {
  showDialog(
    context: context,
    useRootNavigator: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Earning Score in Stakeplot',
                 style: FontManager().getTextStyle(
                                      context,
                                      fontSize: 16, // Larger font for single coupon
                                      lWeight: FontWeight.w700,
                                      color: AppColors.primaryColor,
                                    ),
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                'Your score reflects your activity and engagement within the app. You can increase your score through the following actions:',
                style: FontManager().getTextStyle(
                                      context,
                                      fontSize: 14, // Larger font for single coupon
                                      lWeight: FontWeight.w500,
                                      color: AppColors.accentColor,
                                    ),
              ),
              const SizedBox(height: 16),
              
              // Bullet points
              _buildBulletPoint('Tagging untagged transactions in your expense history', context),
              const SizedBox(height: 8),
              _buildBulletPoint('Participating in the community by posting, commenting, or sharing', context),
              const SizedBox(height: 8),
              _buildBulletPoint('Using the bill split feature and clearing split payments', context),
              const SizedBox(height: 8),
              _buildBulletPoint('Adding a cash Transaction', context),
              const SizedBox(height: 16),
              
              // Additional info
              Text(
                'As your score increases, you become eligible to earn exclusive rewards based on your performance and activity',
                style: FontManager().getTextStyle(
                                      context,
                                      fontSize: 14, // Larger font for single coupon
                                      lWeight: FontWeight.w500,
                                      color: AppColors.accentColor,
                                    ),
              ),
              const SizedBox(height: 20),
              
            
              
              // Done button
              Center(
                child: SizedBox(
                  width: 80,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A4A68),
                      foregroundColor: AppColors.backgroundColor,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Center(
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildBulletPoint(String text, BuildContext context) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        margin: const EdgeInsets.only(top: 6, right: 8),
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[600],
          shape: BoxShape.circle,
        ),
      ),
      Expanded(
        child: Text(
          text,
           style: FontManager().getTextStyle(
                                      context,
                                      fontSize: 14, // Larger font for single coupon
                                      lWeight: FontWeight.w600,
                                      color: AppColors.primaryColor,
                                    ),
        ),
      ),
    ],
  );
}
