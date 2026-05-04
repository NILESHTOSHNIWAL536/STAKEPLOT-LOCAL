import 'package:flutter/material.dart';
import '../../Constants/colors.dart';
import '../../Constants/core/app_padding_sizes.dart';

import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';

/// 🎨 COLORS (match your design)
const Color keyBg = Color(0xFFF2F2F2);
const Color actionKeyBg = Color(0xFFB6B4D8);
const Color submitKeyBg = AppColors.primaryColor;
const Color keyText = AppColors.bg1;
const Color actionText = AppColors.backgroundColor;

/// 🔘 REUSABLE KEY BUTTON
Widget keyButton({
  required Widget child,
  required VoidCallback onTap,
  Color bgColor = keyBg,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    ),
  );
}

/// ⌨️ CUSTOM NUMERIC KEYBOARD
class CustomNumericKeyboard extends StatelessWidget {
  final Function(String) onKeyTap;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;
  final VoidCallback onDismiss;

  const CustomNumericKeyboard({
    super.key,
    required this.onKeyTap,
    required this.onBackspace,
    required this.onSubmit,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ⬇️ Dismiss handle
        GestureDetector(
          onTap: onDismiss,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),

        // 🔢 Keyboard grid
        Container(
          color: AppColors.backgroundColor,
          padding: EdgeInsets.only(
              left: AppSizes.p12, right: AppSizes.p12, bottom: 30),
          child: GridView.count(
            childAspectRatio: 5 / 3,
            shrinkWrap: true,
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 20,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Row 1
              _number(context, "1"), _number(context, "2"),
              _number(context, "3"),
              _action("-", Icons.remove),

              // Row 2
              _number(context, "4"), _number(context, "5"),
              _number(context, "6"),
              _action("enter", Icons.keyboard_return),

              // Row 3
              _number(context, "7"), _number(context, "8"),
              _number(context, "9"),
              _backspace(),

              // Row 4
              _number(context, ","), _number(context, "0"),
              _number(context, "."),
              _submit(),
            ],
          ),
        ),
      ],
    );
  }

  /// 🔢 NUMBER KEY
  Widget _number(BuildContext context, String value) {
    return keyButton(
      onTap: () => onKeyTap(value),
      child: Text(
        value,
        style: FontManager().getTextStyle(context,
            fontSize: 18, lWeight: FontWeight.w500, color: keyText),
      ),
    );
  }

  /// ➖ ACTION KEY
  Widget _action(String value, IconData icon) {
    return keyButton(
      bgColor: actionKeyBg,
      onTap: () => onKeyTap(value),
      child: Icon(icon, color: actionText),
    );
  }

  /// ⌫ BACKSPACE
  Widget _backspace() {
    return keyButton(
      bgColor: actionKeyBg,
      onTap: onBackspace,
      child: const Icon(Icons.backspace_outlined, color: actionText),
    );
  }

  /// ➡️ SUBMIT
  Widget _submit() {
    return keyButton(
      bgColor: submitKeyBg,
      onTap: onSubmit,
      child: const Icon(Icons.arrow_forward, color: Colors.white),
    );
  }
}
