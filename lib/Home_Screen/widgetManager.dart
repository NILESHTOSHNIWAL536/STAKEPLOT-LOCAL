import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/profileUser.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';

class WidgetManager {
  static Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId('group.com.stakeplot.adnan.dev');
      // Fetch initial data
       getRemainders(Get.context!);
      // Update all widgets
      await updatePayableWidget();
      // Add updates for new widgets here (e.g., updateBudgetWidget())
    } catch (e) {
    }
    // Set up listeners for data changes
    ever(lendAmountRemainders, (_) => updatePayableWidget());
    ever(dueAmountRemainders, (_) => updatePayableWidget());
    // Add listeners for other data (e.g., budgetList for a budget widget)
  }

  static Future<void> updatePayableWidget() async {
    try {
      String toReceive = 'None: ₹0';
      String toPay = 'None: ₹0';
      if (lendAmountRemainders.isNotEmpty && lendAmountRemainders.first != null) {
        final data = lendAmountRemainders.first;
        toReceive =
            '${data["name"] ?? "Unknown"}: ₹${(data["amount"] ?? 0).toStringAsFixed(2)}';
      }
      if (dueAmountRemainders.isNotEmpty && dueAmountRemainders.first != null) {
        final data = dueAmountRemainders.first;
        toPay =
            '${data["name"] ?? "Unknown"}: ₹${(data["amount"] ?? 0).toStringAsFixed(2)}';
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('payable_to_receive', toReceive);
      await prefs.setString('payable_to_pay', toPay);
      await HomeWidget.saveWidgetData<String>('payable_to_receive', toReceive);
      await HomeWidget.saveWidgetData<String>('payable_to_pay', toPay);
      await HomeWidget.updateWidget(
        name: 'PayableWidgetProvider',
        androidName: 'PayableWidgetProvider',
        iOSName: 'PayableWidget',
      );
    } catch (e) {
    }
  }

  // Example for a new BudgetWidget
  
}