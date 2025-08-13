import 'package:flutter_application_code_stakeplot/Hive_localstorage/card_swipe_data/card_insights_model.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/finora/chart_data_model.dart'
    as hive_model;
import 'package:flutter_application_code_stakeplot/Hive_localstorage/hive_storage.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/categoriseSpending.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:hive/hive.dart';

import 'package:flutter/material.dart';

class CategoryStorage {
  // static const String chartDataBoxName = 'chartDataBox';

  static Box<hive_model.ChartDataModel> get chartDataBox =>
      Hive.box<hive_model.ChartDataModel>(HiveStorage.finoraBoxName);

  static Future<void> cacheChartDataLocally() async {
    final box = await chartDataBox;
    await box.clear(); // Clear existing data
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
  }

  static Future<void> cacheCardInsightsDataLocally() async {
    final box = await HiveStorage.cardInsightsBox;

    print("📦 Before caching, box has ${box.length} items");

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
    final box = await chartDataBox;
    final chartDataModels = box.values.toList();
    chartData.value = chartDataModels
        .map((model) => ChartData(
              model.category,
              model.value,
              Color(int.parse(model.color.replaceFirst('#', '0xff'))),
              model.percentage,
            ))
        .toList();
    totalValue.value = chartData.fold(0.0, (sum, item) => sum + item.value);
  }

 static Future<void> loadCardInsightsDataFromHive() async {
  final box = await HiveStorage.cardInsightsBox;

  print("Box contents: ${box.values}");

  if (box.isNotEmpty) {
    // Reset values to avoid duplicate accumulation
    totalDebitThisMonth.value = 0;
    totalDebitThisWeek.value = 0;
    moreDrasticChange.value = [];
    moreDrasticChangeWeek.value = [];
    frequentPayments.value = [];
    frequentPaymentsWeek.value = [];

    // Loop through all stored insights
    for (var cardInsightsData in box.values) {
      totalDebitThisMonth.value += cardInsightsData.totalDebitThisMonth;
      totalDebitThisWeek.value += cardInsightsData.totalDebitThisWeek;

      moreDrasticChange.value.addAll(
        List<Map<String, dynamic>>.from(cardInsightsData.moreDrasticChange),
      );

      moreDrasticChangeWeek.value.addAll(
        List<Map<String, dynamic>>.from(cardInsightsData.moreDrasticChangeWeek),
      );

      frequentPayments.value.addAll(
        List<Map<String, dynamic>>.from(cardInsightsData.frequentPayments),
      );

      frequentPaymentsWeek.value.addAll(
        List<Map<String, dynamic>>.from(cardInsightsData.frequentPaymentsWeek),
      );
    }

    isFinoraVisible.value = totalDebitThisMonth.value > 0;
    print('All card insights data loaded from Hive');
  } else {
    print('No card insights data found in Hive');
  }
}

  static Future<void> closeChartDataBox() async {
    if (Hive.isBoxOpen(HiveStorage.finoraBoxName)) {
      await Hive.box<hive_model.ChartDataModel>(HiveStorage.finoraBoxName)
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
