import 'package:flutter/material.dart';

import '../../../Constants/colors.dart';
import '../../../Constants/core/app_padding_sizes.dart';
import '../../../Constants/font_manager.dart';

class CollectionStepIndicator extends StatelessWidget {
  final int currentStep;

  const CollectionStepIndicator({
    super.key,
    required this.currentStep,
  });

  static const steps = [
    "Name",
    "Type",
    "People & role",
    "Assign roles",
    "Duration",
    "Description",
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(steps.length, (index) {
            final isCompleted = index < currentStep;
            final isActive = index == currentStep;

            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  _circle(isCompleted, isActive),
                   SizedBox(width: AppSizes.w8),
                  Text(
                    steps[index],
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 12,
                      lWeight: FontWeight.w500,
                      color: isCompleted || isActive
                          ? AppColors.primaryColor
                          : AppColors.accentColor,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _circle(bool isCompleted, bool isActive) {
    if (isCompleted) {
      return Container(
        width: 18,
        height: 18,
        decoration: const BoxDecoration(
          color: AppColors.backgroundColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check,
          size: 14,
          weight: 30,
          color: AppColors.primaryColor,
        ),
      );
    }

    if (isActive) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.accentColor,
            width: 2,
          ),
        ),
      );
    }

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.backgroundColor,
        border: Border.all(
          color: AppColors.backgroundColor,
          width: 1.5,
        ),
      ),
    );
  }
}
