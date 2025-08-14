import 'package:flutter_application_code_stakeplot/Hive_localstorage/card_swipe_data/card_insights_model.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/finora/chart_data_model.dart'
    as hive_model;
import 'package:flutter_application_code_stakeplot/Hive_localstorage/hive_storage.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/categoriseSpending.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:hive/hive.dart';

import 'package:flutter/material.dart';

class CategoryStorage {
  static Future<void> cacheChartDataLocally() async {
    // Open the box (type-safe)
    final box = await Hive.openBox<hive_model.ChartDataModel>(
        HiveStorage.categoryDataBoxName);

    await box.clear();

    final chartDataModels = chartData
        .map((data) => hive_model.ChartDataModel(
              category: data.category,
              percentage: data.persentage,
              value: data.value,
              color: '#${data.color.value.toRadixString(16).padLeft(8, '0')}',
            ))
        .toList();

    await box.addAll(chartDataModels);

    totalValue.value = chartData.fold(0.0, (sum, item) => sum + item.value);

    print("✅ Cached chart data: ${chartDataModels.length} items");
  }

  static Future<void> cacheCardInsightsDataLocally() async {
    final box = await HiveStorage.cardInsightsBox;
    await box.clear();
    final cardInsightsData = CardInsightsModel(
      totalDebitThisMonth: totalDebitThisMonth.value,
      totalDebitThisWeek: totalDebitThisWeek.value,
      moreDrasticChange: moreDrasticChange.cast<Map<String, dynamic>>(),
      moreDrasticChangeWeek: moreDrasticChangeWeek.cast<Map<String, dynamic>>(),
      frequentPayments: frequentPayments.cast<Map<String, dynamic>>(),
      frequentPaymentsWeek: frequentPaymentsWeek.cast<Map<String, dynamic>>(),
    );

    print("💾 Data being cached: $cardInsightsData");

    await box.add(cardInsightsData);

    print("📦 After caching, box has ${box.length} items");
    print("📦 Current box values: ${box.values.toList()}");

    // isFinoraVisible.value = totalDebitThisMonth.value > 0;
    print(' Card insights data cached locally');
  }

  static Future<void> loadChartDataFromHive() async {
    final box = await Hive.openBox<hive_model.ChartDataModel>(
        HiveStorage.categoryDataBoxName);

    if (box.isEmpty) {
      print("📦 ChartDataBox is empty");
      chartData.clear();
      totalValue.value = 0.0;
      return;
    }

    // Convert Hive models to UI ChartData
    chartData.value = box.values.map((model) {
      return ChartData(
        model.category,
        model.value,
        Color(int.parse(model.color.replaceFirst('#', '0xff'))),
        model.percentage,
      );
    }).toList();

    totalValue.value = chartData.fold(0.0, (sum, item) => sum + item.value);

    print("📦 Loaded ${chartData.length} chart items from Hive");
  }

  static Future<void> loadCardInsightsDataFromHive() async {
    final box = await HiveStorage.cardInsightsBox;
    print("Box contents: ${box.values}");

    if (box.isNotEmpty) {
      final latestData = box.values.last;

      totalDebitThisMonth.value = latestData.totalDebitThisMonth;
      totalDebitThisWeek.value = latestData.totalDebitThisWeek;

      moreDrasticChange.value =
          List<Map<String, dynamic>>.from(latestData.moreDrasticChange);
      moreDrasticChangeWeek.value =
          List<Map<String, dynamic>>.from(latestData.moreDrasticChangeWeek);

      frequentPayments.value =
          List<Map<String, dynamic>>.from(latestData.frequentPayments);
      frequentPaymentsWeek.value =
          List<Map<String, dynamic>>.from(latestData.frequentPaymentsWeek);

      isFinoraVisible.value = totalDebitThisMonth.value > 0;
      print('Latest card insights data loaded from Hive');
    } else {
      print('No card insights data found in Hive');
    }
  }

  static Future<void> closeChartDataBox() async {
    if (Hive.isBoxOpen(HiveStorage.categoryDataBoxName)) {
      await Hive.box<hive_model.ChartDataModel>(HiveStorage.categoryDataBoxName)
          .close();
    }
  }

  static Future<void> closeCardInsightsBox() async {
    if (Hive.isBoxOpen(HiveStorage.cardInsightsBoxName)) {
      await Hive.box<CardInsightsModel>(HiveStorage.cardInsightsBoxName)
          .close();
      print('cardInsightsBox closed');
    }
  }
}
