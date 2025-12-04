import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

import 'colors.dart';

class CustomKeypad extends StatelessWidget {
  // Called when a number is pressed
  final void Function(String value) onKeyTap;

  // Called when backspace is pressed
  final VoidCallback? onBackspace;

  // Optional: long press backspace -> clear all
  final VoidCallback? onClearAll;

  // Called when submit (✔) is pressed
  final VoidCallback? onSubmit;

  // Overall keypad height (controls button size)
  final double height;

  const CustomKeypad({
    super.key,
    required this.onKeyTap,
    this.onBackspace,
    this.onClearAll,
    this.onSubmit,
    this.height = 190, // tweak as you like
  });

  @override
  Widget build(BuildContext context) {
  

    // 3 x 4 layout
    final keys = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '⌫', '0', '✔', // backspace, 0, submit
    ];

    return SizedBox(
      height: height,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: keys.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          // width / height → bigger = shorter buttons
          childAspectRatio: 2.4, // adjust between 2.0–3.0
        ),
        itemBuilder: (context, index) {
          final keyLabel = keys[index];
          final isActionKey = keyLabel == '⌫' || keyLabel == '✔';

          return Material(
            color: isActionKey
                ? const Color(0xFF373737)
                : const Color(0xFF222222),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                HapticFeedback.lightImpact(); // small vibration like system kb
                if (keyLabel == '⌫') {
                  if (onBackspace != null) onBackspace!();
                } else if (keyLabel == '✔') {
                  if (onSubmit != null) onSubmit!();
                } else {
                  onKeyTap(keyLabel);
                }
              },
              onLongPress: () {
                if (keyLabel == '⌫' && onClearAll != null) {
                  HapticFeedback.mediumImpact();
                  onClearAll!();
                }
              },
              child: Center(
                child: Text(
                  keyLabel,
                  style: FontManager().getTextStyle(context, fontSize: 12, color: AppColors.accentColor),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
