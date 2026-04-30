import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';

import '../Constants/colors.dart';
import '../Constants/core/app_padding_sizes.dart';

import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

class CustomStepper extends StatelessWidget {
  final int activeStep;

  const CustomStepper({super.key, required this.activeStep});

  @override
  Widget build(BuildContext context) {
    const int totalSteps = 4;

    Color activeColor = AppColors.primaryColor;
    Color inactiveColor = const Color(0xFFE5E7EB);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (index) {
          /// 🔹 STEP CIRCLE
          if (index % 2 == 0) {
            int stepIndex = index ~/ 2;
            bool isCompleted = stepIndex < activeStep;
            bool isActive = stepIndex == activeStep;

            return Expanded(
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: isActive ? 26 : 20,
                    width: isActive ? 26 : 20,
                    decoration: BoxDecoration(
                      color:
                          isCompleted || isActive ? activeColor : Colors.white,
                      border: Border.all(
                        color: isCompleted || isActive
                            ? activeColor
                            : inactiveColor,
                        width: 2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : isActive
                              ? Container(
                                  height: 8,
                                  width: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// 🔹 STEP LABEL
                  Text(
                    "Step ${stepIndex + 1}",
                    style: FontManager().getTextStyle(context,
                        fontSize: 11,
                        lWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isCompleted || isActive
                            ? activeColor
                            : Colors.grey),
                  ),
                ],
              ),
            );
          }

          /// 🔹 CONNECTOR LINE
          else {
            int lineIndex = (index - 1) ~/ 2;

            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: lineIndex < activeStep ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        }),
      ),
    );
  }
}

Widget leadIcon(context) {
  return InkWell(
      onTap: () => Navigator.of(context).pop(),
      child: Icon(Icons.arrow_back, color: AppColors.primaryColor));
}
