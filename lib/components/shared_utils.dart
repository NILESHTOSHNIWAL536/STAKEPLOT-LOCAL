import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/theme_helper.dart';
import 'package:flutter_application_code_stakeplot/image_service/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/services/secure_storage.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constants/core/app_padding_sizes.dart';
import '../Constants/font_manager.dart';

void appLog(dynamic message,
    [dynamic message2, dynamic message3, dynamic message4]) {
  if (!kReleaseMode) {
    final logs = [message, message2, message3, message4]
        .where((e) => e != null)
        .map((e) => e.toString())
        .join(" | ");
    print(logs);
  }
}

// void appLog(message) {
//   if (!kReleaseMode) {
//       print(message); // Only prints in debug
//   }
// }

void consolelog(message) {
  if (!kReleaseMode) {
    print(message); // Only prints in debug
  }
}

bool isZeroAmount(String amount) {
  try {
    double parsed = double.parse(amount.trim().toString());
    return parsed == 0.0 || parsed == 0.00 || parsed == 0;
  } catch (e) {
    return true;
  }
}

String formatDateToIST(String dateStr) {
  try {
    DateTime utcDate = DateTime.parse(dateStr).toUtc();
    DateTime istDate = utcDate.add(Duration(hours: 5, minutes: 30));
    int hour = istDate.hour % 12 == 0 ? 12 : istDate.hour % 12;
    String minute = istDate.minute.toString().padLeft(2, '0');
    String period = istDate.hour >= 12 ? 'PM' : 'AM';
    String month = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ][istDate.month - 1];
    return "$hour:$minute $period · $month ${istDate.day}, ${istDate.year}";
  } catch (e) {
    return dateStr;
  }
}

List<TextInputFormatter> allowDecimalInput({int decimalPlaces = 2}) {
  final regex = RegExp(r'^\d*\.?\d{0,' + decimalPlaces.toString() + r'}');
  return [
    FilteringTextInputFormatter.allow(regex),
  ];
}

String getMonthlyRange() {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final currentDay = now; // Use current date as the end date

  return '${_formatDateDonut(startOfMonth)} - ${_formatDateDonut(currentDay)}';
}

String _formatDateDonut(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')} ${getMonthName(date.month)} ${date.year}';
}

String getMonthName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return months[month - 1];
}

String formatDate(String dateString) {
  DateTime date = DateTime.parse(dateString);
  return DateFormat('d MMM yyyy').format(date); // Format as Aug 2024
}

String getFullMonthName(int month) {
  const monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return monthNames[month - 1];
}

String formatMoneyIndian(String value, [String pattern = "0"]) {
  if (value.isEmpty) return pattern;
  try {
    // Remove commas if user input already has them
    final number = double.parse(value.replaceAll(',', ''));

    // Format using Indian locale
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '',
      decimalDigits: number.truncateToDouble() == number ? 0 : 2,
    );
    return formatter.format(number).trim();
  } catch (e) {
    return pattern;
  }
}

DateTime convertStringToDateTime(String dateString) {
  return DateTime.parse(dateString);
}

String formatWhatsAppDate(DateTime date) {
  date = date.toLocal();
  // Adjust for 5:30 offset
  DateTime now = DateTime.now().toLocal();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = today.subtract(Duration(days: 1));
  DateTime tomorrow = today.add(Duration(days: 1));
  DateTime weekStart = today.subtract(Duration(days: today.weekday));
  DateTime weekEnd = weekStart.add(Duration(days: 7));

  String timeFormat = DateFormat('h:mm a').format(date);

  // Check if the date is today
  if (date.year == today.year &&
      date.month == today.month &&
      date.day == today.day) {
    return "Today, $timeFormat";
  }
  // Check if the date is yesterday
  else if (date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day) {
    return "Yesterday, $timeFormat";
  }
  // Check if the date is tomorrow
  else if (date.year == tomorrow.year &&
      date.month == tomorrow.month &&
      date.day == tomorrow.day) {
    return "Tomorrow, $timeFormat";
  }
  // Check if the date is within the current week (past or future)
  else if (date.isAfter(weekStart) && date.isBefore(weekEnd)) {
    return "${DateFormat('EEE').format(date)}, $timeFormat"; // e.g., Mon, 10:30 AM
  }
  // Same year, different week
  else if (date.year == now.year) {
    return "${DateFormat('d MMM').format(date)}, $timeFormat"; // e.g., 7 Apr, 10:30 AM
  }
  // Different year
  else {
    return "${DateFormat('d MMM y').format(date)}, $timeFormat"; // e.g., 7 Apr 2025, 10:30 AM
  }
}
String formatWhatsAppDateWithoutTime(DateTime date) {
  date = date.toLocal();
  // Adjust for 5:30 offset
  DateTime now = DateTime.now().toLocal();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = today.subtract(const Duration(days: 1));
  DateTime tomorrow = today.add(const Duration(days: 1));
  DateTime weekStart = today.subtract( Duration(days: today.weekday));
  DateTime weekEnd = weekStart.add(const Duration(days: 7));


  // Check if the date is today
  if (date.year == today.year &&
      date.month == today.month &&
      date.day == today.day) {
    return "Today";
  }
  // Check if the date is yesterday
  else if (date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day) {
    return "Yesterday";
  }
  // Check if the date is tomorrow
  else if (date.year == tomorrow.year &&
      date.month == tomorrow.month &&
      date.day == tomorrow.day) {
    return "Tomorrow";
  }
  // Check if the date is within the current week (past or future)
  else if (date.isAfter(weekStart) && date.isBefore(weekEnd)) {
    return "${DateFormat('EEE').format(date)}"; // e.g., Mon, 10:30 AM
  }
  // Same year, different week
  else if (date.year == now.year) {
    return "${DateFormat('d MMM').format(date)}"; // e.g., 7 Apr, 10:30 AM
  }
  // Different year
  else {
    return "${DateFormat('d MMM y').format(date)}"; // e.g., 7 Apr 2025, 10:30 AM
  }
}

String getFormattedDate() {
  DateTime now = DateTime.now();
  return "${now.year}-${now.month.toString().padLeft(2, '0')}";
}

int getDaysInMonth(int year, int month) {
  if (month == 12) {
    return DateTime(year + 1, 1, 0).day;
  }
  return DateTime(year, month + 1, 0).day;
}

bool isCurrentYear(String date, int y) {
  try {
    DateTime parsedDate = DateTime.parse(date); // Parse the date string
    return parsedDate.year == y; // Compare year
  } catch (e) {
    return false; // Return false if parsing fails
  }
}

bool isCurrentMonth(String date, int m) {
  try {
    DateTime parsedDate = DateTime.parse(date);
    return parsedDate.month == m; // Compare month
  } catch (e) {
    return false;
  }
}

Future<String?> getToken() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  var accessToken = await SecureStorageService().read("accessToken");
  if (accessToken == null) {
    return null;
  } else {
    return accessToken;
  }
}

String formatNumber(double v) {
  if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)}Cr';
  if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.toStringAsFixed(0);
}

class VerticalDashDivider extends StatelessWidget {
  final double height;
  final double dashHeight;
  final double dashGap;
  final Color color;

  const VerticalDashDivider({
    super.key,
    this.height = 100,
    this.dashHeight = 3,
    this.dashGap = 3,
    this.color = const Color(0xFF48484A), // soft grey like screenshot
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(1, height),
      painter: _VerticalDashPainter(
        dashHeight: dashHeight,
        dashGap: dashGap,
        color: color,
      ),
    );
  }
}

class _VerticalDashPainter extends CustomPainter {
  final double dashHeight;
  final double dashGap;
  final Color color;

  _VerticalDashPainter({
    required this.dashHeight,
    required this.dashGap,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double y = 0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(0, y),
        Offset(0, y + dashHeight),
        paint,
      );
      y += dashHeight + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



class RoundedWhiteContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color backgroundColor;

  const RoundedWhiteContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius = 80,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final colors=context.appPalette;
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: colors.whiteColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}


Widget textStyle({
  required BuildContext context,
  text,
  double fontsize = 12,
  Color? c,
  FontWeight fontWeight = FontWeight.w500,
  bool iswrap = false,
  double lineHeight = 1.0,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(width: AppSizes.w8),
      Text(
        text.toString(),
        style: FontManager().getTextStyle(context,
            lWeight: fontWeight,
            fontSize: fontsize,
            color: c ?? context.appColors.onBackground,
            lineHeight: lineHeight),
        overflow: iswrap ? TextOverflow.visible : TextOverflow.ellipsis,
      ),
    ],
  );
}

Widget textStyleImage({
  required BuildContext context,
  text,
  double fontsize = 12,
  Color? c,
  FontWeight fontWeight = FontWeight.w500,
  bool iswrap = false,
  bool isCenter = false,
  double lineHeight = 1.0,
}) {
  return Text(
    text.toString(),
    style: FontManager().getTextStyle(context,
        lWeight: fontWeight,
        fontSize: fontsize,
        color: c ?? context.appColors.onBackground,
        lineHeight: lineHeight,
        textAlign: isCenter ? TextAlign.center : TextAlign.start),
    overflow: iswrap ? TextOverflow.visible : TextOverflow.ellipsis,
  );
}

Widget textStyleAnimated({
  required BuildContext context,
  text,
  double fontsize = 12,
  Color? c,
  FontWeight fontWeight = FontWeight.w500,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(width: AppSizes.w8),
      Text(
        text.toString(),
        style: FontManager().getTextStyle(context,
            lWeight: fontWeight,
            fontSize: fontsize,
            color: c ?? context.appColors.onBackground),
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

Widget textStyleOnly({
  required BuildContext context,
  text,
  double fontsize = 12,
  Color? c,
  FontWeight fontWeight = FontWeight.w500,
}) {
  return Text(
    text.toString(),
    style: FontManager().getTextStyle(context,
        lWeight: fontWeight,
        fontSize: fontsize,
        color: c ?? context.appColors.onBackground),
    overflow: TextOverflow.ellipsis,
  );
}

Widget textStyleOnly2({
  required BuildContext context,
  required String text,
  required double fontsize,
  required Color color,
  required FontWeight fontWeight,
}) {
  return Text(
    text,
    style: FontManager().getTextStyle(
      context,
      lWeight: fontWeight,
      fontSize: fontsize,
      color: color,
    ),
    overflow: TextOverflow.visible,
  );
}
