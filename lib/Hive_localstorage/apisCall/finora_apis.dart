import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/card_swipe_data/card_insights_model.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/hive_storage.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/routes/routes.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../Home_Screen/categoriseSpending.dart';
import '../../backed_connections/apiAutomations/getTrasactions.dart';
import '../../controllers/controllerManagement.dart';
import '../../controllers/finora_controller.dart';
import 'init_hive.dart';

class CategoryStorage {
  //  final controller = Get.find<FinoraController>();
  //  FinoraController finoraController = ControllerManagement.finoraController;
  // finora
  Future<void> cacheCardInsightsDataLocally(FinoraController controller) async {
    HiveHelper.openBoxIfNot<CardInsightsModel>(HiveStorage.cardInsightsBoxName);
    final box = await HiveStorage.cardInsightsBox;
    await box.clear();
    try {
      final cardInsightsData = CardInsightsModel(
        totalDebitThisMonth:   controller.totalDebitThisMonth.value,
        totalDebitThisWeek:   controller.totalDebitThisWeek.value,
        moreDrasticChange:   controller.moreDrasticChange.cast<Map<String, dynamic>>(),
        moreDrasticChangeWeek:
              controller.moreDrasticChangeWeek.cast<Map<String, dynamic>>(),
        frequentPayments:   controller.frequentPayments.cast<Map<String, dynamic>>(),
        frequentPaymentsWeek:   controller.frequentPaymentsWeek.cast<Map<String, dynamic>>(),
        categoriesList:   controller.categoriesList.cast<Map<String, dynamic>>(),
      );
      await box.add(cardInsightsData);
    } catch (e) {}
  }

   Future<void> loadCardInsightsDataFromHive(FinoraController controller) async {
    HiveHelper.openBoxIfNot<CardInsightsModel>(HiveStorage.cardInsightsBoxName);
    final box = await HiveStorage.cardInsightsBox;

    if (box.isNotEmpty) {
      final latestData = box.values.last;

        controller.totalDebitThisMonth.value = latestData.totalDebitThisMonth;
        controller.totalDebitThisWeek.value = latestData.totalDebitThisWeek;

        controller.moreDrasticChange.value =
          List<Map<String, dynamic>>.from(latestData.moreDrasticChange);
        controller.moreDrasticChangeWeek.value =
          List<Map<String, dynamic>>.from(latestData.moreDrasticChangeWeek);

        controller.frequentPayments.value =
          List<Map<String, dynamic>>.from(latestData.frequentPayments);
        controller.frequentPaymentsWeek.value =
          List<Map<String, dynamic>>.from(latestData.frequentPaymentsWeek);
        controller.categoriesList.value =
          List<Map<String, dynamic>>.from(latestData.categoriesList);

        isFinoraVisible.value =   controller.totalDebitThisMonth.value > 0;
      processChartData();
    } else {}
  }

  static Future<void> closeCardInsightsBox() async {
    if (Hive.isBoxOpen(HiveStorage.cardInsightsBoxName)) {
      await Hive.box<CardInsightsModel>(HiveStorage.cardInsightsBoxName)
          .close();
    }
  }
}


void processChartData() {
    // FinoraController finoraController = ControllerManagement.finoraController;
    final controller = Get.find<FinoraController>();
  try {
    // Recompute everything from scratch
    List<ChartData> newData = [];
    double newTotalValue = 0.0;

    // categoryColors should be a Map<String, Color>
    Map<String, Color> categoryColors = colorcodes;

    for (var item in controller.categoriesList.value) {
    // for (var item in   categoriesList) {
      final String category = (item["category"] ?? "Others").toString();
      final String percentage = (item["total_debit_percentage"] ?? "").toString();

      // Defensive parsing for numeric fields
      double value = 0.0;
      final dynamic rawValue = item["total_debit"];
      if (rawValue is num) {
        value = rawValue.toDouble();
      } else if (rawValue is String) {
        value = double.tryParse(rawValue) ?? 0.0;
      }

      final Color color = categoryColors[category] ?? Colors.grey;
      newData.add(ChartData(category, value, color, percentage));

      newTotalValue += value; // accumulate into local total
    }

    // Replace the reactive list atomically so UI reacts correctly
    controller.spendingsOnCategories
      ..clear()
      ..addAll(newData);

    // Assign computed total (not incremental)
    controller.totalValue.value = newTotalValue;

    // If you want to signal any other reactive flags, refresh them:
    controller.spendingsOnCategories.refresh();
    controller.totalValue.refresh();
  } catch (e, st) {
    // Consider logging the error for debugging
  }
}


// if any problem in above function use this below function
// void processChartData() {
//   try {
//     List<ChartData> newData = [];
//     double newTotalValue = 0.0;

//     Map<String, Color> categoryColors = colorcodes;

//     for (var item in categoriesList) {
//       String category = item["category"] ?? "Others";
//       String percentage = item["total_debit_percentage"] ?? "";
//       double value = item["total_debit"].toDouble();
//       Color color = categoryColors[category] ?? Colors.grey; // Default color
//       newData.add(ChartData(category, value, color, percentage));

//       totalValue.value += value;
//     }

//     if (newData.isNotEmpty) {
//       spendingsOnCategories.clear();
//       spendingsOnCategories.addAll(newData);
//     }
//   } catch (e) {}
// }
