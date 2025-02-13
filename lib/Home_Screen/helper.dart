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
