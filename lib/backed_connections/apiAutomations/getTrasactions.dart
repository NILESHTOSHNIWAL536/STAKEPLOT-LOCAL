
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/repository/finance_repository.dart';
import 'package:flutter_application_code_stakeplot/repository/home_page_apiCalls.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/repository/finora_repository.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:week_of_year/week_of_year.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import '../../routes/route_transactions.dart';








// Helper function to calculate the start date of a week (Sunday)
DateTime _getWeekStartDate(int year, int weekNumber) {
  DateTime jan1 = DateTime(year, 1, 1);
  int daysOffset = jan1.weekday; // 1 = Monday, 7 = Sunday
  DateTime firstSunday = jan1.subtract(Duration(days: daysOffset % 7));
  DateTime weekStart = firstSunday.add(Duration(days: (weekNumber - 1) * 7));
  return weekStart;
}
// Helper functions



