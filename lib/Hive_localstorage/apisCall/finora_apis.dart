import 'package:flutter_application_code_stakeplot/Hive_localstorage/card_swipe_data/card_insights_model.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/hive_storage.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:hive/hive.dart';
import '../../backed_connections/apiAutomations/getTrasactions.dart';
import 'init_hive.dart';

class CategoryStorage {
  // finora
  static Future<void> cacheCardInsightsDataLocally() async {
    HiveHelper.openBoxIfNot<CardInsightsModel>(HiveStorage.cardInsightsBoxName);
    final box = await HiveStorage.cardInsightsBox;
    await box.clear();
    try {
      final cardInsightsData = CardInsightsModel(
        totalDebitThisMonth: totalDebitThisMonth.value,
        totalDebitThisWeek: totalDebitThisWeek.value,
        moreDrasticChange: moreDrasticChange.cast<Map<String, dynamic>>(),
        moreDrasticChangeWeek:
            moreDrasticChangeWeek.cast<Map<String, dynamic>>(),
        frequentPayments: frequentPayments.cast<Map<String, dynamic>>(),
        frequentPaymentsWeek: frequentPaymentsWeek.cast<Map<String, dynamic>>(),
        categoriesList: categoriesList.cast<Map<String, dynamic>>(),
      );
      await box.add(cardInsightsData);
    } catch (e) {}
  }

  static Future<void> loadCardInsightsDataFromHive() async {
    HiveHelper.openBoxIfNot<CardInsightsModel>(HiveStorage.cardInsightsBoxName);
    final box = await HiveStorage.cardInsightsBox;

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
      categoriesList.value =
          List<Map<String, dynamic>>.from(latestData.categoriesList);

      isFinoraVisible.value = totalDebitThisMonth.value > 0;
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
