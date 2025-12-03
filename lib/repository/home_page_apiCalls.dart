
import "package:flutter/material.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart";
import "package:flutter_application_code_stakeplot/Utils/snackBar.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import 'package:intl/intl.dart';
import "../routes/route_transactions.dart";

// expanded finance apis and functions
final Map<String, int> monthNameToIndex = {
  'Jan': 0,
  'Feb': 1,
  'Mar': 2,
  'Apr': 3,
  'May': 4,
  'Jun': 5,
  'Jul': 6,
  'Aug': 7,
  'Sep': 8,
  'Oct': 9,
  'Nov': 10,
  'Dec': 11
};

void updateMonthLabels() {
  monthLabels.value = List.generate(12, (index) {
    return DateFormat('MMM').format(DateTime(selectedYear.value, index + 1, 1));
  });
}

int getDaysInMonthExpanded(int year, int month) {
  month = month.clamp(1, 12);
  return DateTime(year, month + 1, 0).day;
}

double getDouble(data) {
  return double.parse(data.toString());
}

String formatDateTime(String dateString) {
  DateTime dateTime = DateTime.parse(dateString).toLocal();

  String formattedDate = DateFormat("dd MMM yyyy hh:mm a").format(dateTime);
  return formattedDate;
}



String getNextDay(String endDate) {
  // Parse the input date string
  DateTime date = DateTime.parse(endDate);
  // Add one day
  DateTime nextDay = date.add(Duration(days: 1));
  // Return formatted as YYYY-MM-DD
  return nextDay.toIso8601String().split('T')[0];
}

List<String> getWeekDays() {
  return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
}

List<String> getDaysInMonth(String yearMonth) {
  List<String> days = [];
  List<String> parts = yearMonth.split('-');
  if (parts.length != 2) return days;

  int year = int.tryParse(parts[0]) ?? 0;
  int month = int.tryParse(parts[1]) ?? 0;
  if (year == 0 || month == 0) return days;

  int daysInMonth = DateTime(year, month + 1, 0).day;

  for (int i = 1; i <= daysInMonth; i++) {
    days.add('${i.toString().padLeft(2, '0')}');
  }

  return days;
}


