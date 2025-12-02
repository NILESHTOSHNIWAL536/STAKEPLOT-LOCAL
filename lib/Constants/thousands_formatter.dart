import 'package:flutter/services.dart';

class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove commas from old and new values for comparison
    String oldText = oldValue.text.replaceAll(',', '');
    String newText = newValue.text.replaceAll(',', '');

    // Handle decimal part if present
    List<String> parts = newText.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.' + parts[1] : '';

    // Format integer part with commas
    final RegExp regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String formattedInteger =
        integerPart.replaceAllMapped(regExp, (Match m) => '${m[1]},');
    String finalText = formattedInteger + decimalPart;

    // Calculate new cursor position
    int oldCommaCount = oldText.split('').where((c) => c == ',').length;
    int newCommaCount = finalText.split('').where((c) => c == ',').length;
    int cursorOffset =
        newValue.selection.baseOffset + (newCommaCount - oldCommaCount);

    // Adjust cursor position to stay in the correct relative spot
    if (cursorOffset < 0) cursorOffset = 0;
    if (cursorOffset > finalText.length) cursorOffset = finalText.length;

    return newValue.copyWith(
      text: finalText,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }
}
// pending users
