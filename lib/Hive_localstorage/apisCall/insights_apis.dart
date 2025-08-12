import 'package:flutter_application_code_stakeplot/Hive_localstorage/insights_data/insights_model.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/insightsController.dart';
import 'package:hive/hive.dart';
import 'package:get/get.dart';

class InsightsLocalStorage {
  static const String _boxName = 'insightsBox';
  static const String _cacheKey = 'insights_data';

  static Future<void> cacheInsightsData({
    required List<Map<String, dynamic>> totalInSights,
    required List<Map<String, dynamic>> totalInSightsMoneyMap,
  }) async {
    try {
      final box = await Hive.box<InsightsModel>(_boxName);
      final insights = InsightsModel(
        totalInSights: totalInSights
            .map((item) => {
                  'insights': List<String>.from(item['insights'] ?? []),
                })
            .toList(),
        totalInSightsMoneyMap: totalInSightsMoneyMap
            .map((item) => {
                  'insights': List<String>.from(item['insights'] ?? []),
                })
            .toList(),
        lastUpdated: DateTime.now(), // Set the timestamp
      );
      await box.put(_cacheKey, insights);
    } catch (e) {}
  }

  static Future<InsightsModel?> loadInsightsFromHive() async {
    try {
      final box = await Hive.box<InsightsModel>(_boxName);
      final insights = box.get(_cacheKey);

      if (insights != null) {
        final controller = Get.find<InsightsController>();
        controller.totalInSights.assignAll(insights.totalInSights);
        controller.totalInSightsMoneyMap
            .assignAll(insights.totalInSightsMoneyMap);
        controller.getTotalInsightsHistory.value = true;
        controller.getTotalInsightsHistorytotalMoneyMap.value = true;

        if (insights.totalInSightsMoneyMap.isEmpty && Get.context != null) {
          await controller.getHomePageMoneyMapInsights(Get.context!);
        }
        return insights;
      }

      return null;
    } catch (e) {
      final controller = Get.find<InsightsController>();
      if (Get.context != null) {
        await controller.getHomePageInsights(Get.context!);
        await controller.getHomePageMoneyMapInsights(Get.context!);
      }

      return null;
    }
  }

  static Future<void> clearInsightsCache() async {
    try {
      final box = await Hive.box<InsightsModel>(_boxName);
      await box.delete(_cacheKey);
    } catch (e) {}
  }
}
