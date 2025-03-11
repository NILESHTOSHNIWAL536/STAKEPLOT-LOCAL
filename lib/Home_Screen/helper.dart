import 'dart:math';
import 'package:intl/intl.dart';

final Map<int, Map<String, double>> weekData = {
  for (int i = 0; i < 5; i++)
    i: {
      'Mon': Random().nextInt(500).toDouble(),
      'Tue': Random().nextInt(500).toDouble(),
      'Wed': Random().nextInt(500).toDouble(),
      'Thu': Random().nextInt(500).toDouble(),
      'Fri': Random().nextInt(500).toDouble(),
      'Sat': Random().nextInt(500).toDouble(),
      'Sun': Random().nextInt(500).toDouble(),
    },
};

int getDaysInMonth(int year, int month) {
  if (month == 12) {
    return DateTime(year + 1, 1, 0).day;
  }
  return DateTime(year, month + 1, 0).day;
}

String getFormattedDate() {
  DateTime now = DateTime.now();
  return "${now.year}-${now.month.toString().padLeft(2, '0')}";
}


String getCurrentWeekNumber() {

  DateTime now = DateTime.now();
  int weekNumber = int.parse(DateFormat('w').format(now));
  int year = now.year;
  return '$year-W${weekNumber.toString().padLeft(2, '0')}';
}



String formatWhatsAppDate(DateTime date) {
  date = date.toLocal(); // Ensure local timezone
  DateTime now = DateTime.now().toLocal();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = today.subtract(Duration(days: 1));
  DateTime weekStart = today.subtract(Duration(days: today.weekday)); // Start of the week

  String timeFormat = DateFormat('h:mm a').format(date); // Format time as "10:30 AM"

  if (date.isAfter(today)) {
    return "Today, $timeFormat";
  } else if (date.isAfter(yesterday)) {
    return "Yesterday, $timeFormat";
  } else if (date.isAfter(weekStart)) {
    return "${DateFormat('EEE').format(date)}, $timeFormat"; // Mon, 10:30 AM
  } else if (date.year == now.year) {
    return "${DateFormat('d MMM').format(date)}, $timeFormat"; // 10 Mar, 10:30 AM
  } else {
    return "${DateFormat('d MMM y').format(date)}, $timeFormat"; // 10 Mar 2024, 10:30 AM
  }
}