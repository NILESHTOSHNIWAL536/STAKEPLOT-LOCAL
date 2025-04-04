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

// String formatWhatsAppDate(DateTime date) {
//   date = date
//       .toLocal()
//       .subtract(Duration(hours: 5, minutes: 30)); // Adjust for 5:30 fast
//   DateTime now = DateTime.now().toLocal();
//   DateTime today = DateTime(now.year, now.month, now.day);
//   DateTime yesterday = today.subtract(Duration(days: 1));
//   DateTime weekStart =
//       today.subtract(Duration(days: today.weekday)); // Start of the week

//   String timeFormat =
//       DateFormat('h:mm a').format(date); // Format time as "10:30 AM"

//   if (date.isAfter(today)) {
//     return "Today, $timeFormat";
//   } else if (date.isAfter(yesterday)) {
//     return "Yesterday, $timeFormat";
//   } else if (date.isAfter(weekStart)) {
//     return "${DateFormat('EEE').format(date)}, $timeFormat"; // Mon, 10:30 AM
//   } else if (date.year == now.year) {
//     return "${DateFormat('d MMM').format(date)}, $timeFormat"; // 10 Mar, 10:30 AM
//   } else {
//     return "${DateFormat('d MMM y').format(date)}, $timeFormat"; // 10 Mar 2024, 10:30 AM
//   }
// }
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

DateTime convertStringToDateTime(String dateString) {
  return DateTime.parse(dateString);
}

String getPreviousDate(int no, String type) {
  DateTime now = DateTime.now();
  DateTime previousDate;

  switch (type) {
    case 'days':
      previousDate = now.subtract(Duration(days: no));
      break;
    case 'months':
      previousDate = DateTime(now.year, now.month - no, now.day);
      break;
    case 'year':
      previousDate = DateTime(now.year - no, now.month, now.day);
      break;
    default:
      throw ArgumentError("Invalid type. Use 'days', 'months', or 'years'.");
  }

  return DateFormat('yyyy-MM-dd').format(previousDate);
}

List getLastTenUsers(List allUsers) {
  // Determine the number of users to take
  int numberOfUsersToTake = allUsers.length < 10 ? allUsers.length : 10;

  // Get the last `numberOfUsersToTake` users
  List lastUsers = allUsers.sublist(allUsers.length - numberOfUsersToTake);

  // Reverse the list
  return lastUsers.reversed.toList();
}
