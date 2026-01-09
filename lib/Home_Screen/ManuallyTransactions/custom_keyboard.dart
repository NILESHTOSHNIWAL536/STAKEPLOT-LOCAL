import 'package:flutter/material.dart';

import '../../Constants/colors.dart';

/// 🎨 COLORS (match your design)
const Color keyBg = Color(0xFFF2F2F2);
const Color actionKeyBg = Color(0xFFB6B4D8);
const Color submitKeyBg = AppColors.primaryColor;
const Color keyText = Colors.black;
const Color actionText = Colors.white;

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
          
          padding: EdgeInsets.only(left: 12,right: 12, bottom: 30),
          child: GridView.count(
            
            childAspectRatio: 5/3,
            shrinkWrap: true,
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 20,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Row 1
              _number("1"), _number("2"), _number("3"),
              _action("-", Icons.remove),
          
              // Row 2
              _number("4"), _number("5"), _number("6"),
              _action("enter", Icons.keyboard_return),
          
              // Row 3
              _number("7"), _number("8"), _number("9"),
              _backspace(),
          
              // Row 4
              _number(","), _number("0"), _number("."),
              _submit(),
            ],
          ),
        ),
      ],
    );
  }

  /// 🔢 NUMBER KEY
  Widget _number(String value) {
    return keyButton(
      onTap: () => onKeyTap(value),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: keyText,
        ),
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
