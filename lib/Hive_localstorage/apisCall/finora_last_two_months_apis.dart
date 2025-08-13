import 'package:flutter_application_code_stakeplot/Hive_localstorage/finora_prev_months/finora_last_two_months_model.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/hive_storage.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class FinoraLastTwoMonthsStorage {
  static final RxMap<String, dynamic> finoraTransactionData =
      <String, dynamic>{}.obs;

  static Future<void> cacheFinoraLastTwoMonthsDataLocally(
      Map<String, dynamic> data) async {
    final box = await HiveStorage.finoraLastTwoMonthsBox;
    // await box.clear();
    final model = FinoraLastTwoMonthsModel(
      month1Name: data['month1Name']?.toString(),
      month2Name: data['month2Name']?.toString(),
      month1Avg: data['month1Avg'] is num
          ? (data['month1Avg'] as num).toDouble()
          : null,
      month2Avg: data['month2Avg'] is num
          ? (data['month2Avg'] as num).toDouble()
          : null,
      month1DailySums: (data['month1DailySums'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [],
      month2DailySums: (data['month2DailySums'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [],
    );
    await box.add(model);
    finoraTransactionData.value = data;
    print('Finora last two months data cached');
  }

  static Future<void> loadFinoraLastTwoMonthsDataFromHive() async {
    final box = await HiveStorage.finoraLastTwoMonthsBox;

    if (box.isNotEmpty) {
      // Convert all values to a list
      final models = box.values.toList();

      // Map all models into a list of maps
      final dataList = models.map((model) {
        return {
          'month1Name': model.month1Name,
          'month2Name': model.month2Name,
          'month1Avg': model.month1Avg,
          'month2Avg': model.month2Avg,
          'month1DailySums': model.month1DailySums,
          'month2DailySums': model.month2DailySums,
        };
      }).toList();

      finoraTransactionData.value = {
        'data': dataList,
      };

      print('All Finora last two months data loaded from Hive: $dataList');
    } else {
      finoraTransactionData.value = {};
      print('No finora last two months data found in Hive');
    }
  }

  static Future<void> closeFinoraLastTwoMonthsBox() async {
    if (Hive.isBoxOpen(HiveStorage.finoraLastTwoMonthsBoxName)) {
      await Hive.box<FinoraLastTwoMonthsModel>(
              HiveStorage.finoraLastTwoMonthsBoxName)
          .close();
      print('finoraLastTwoMonthsBox closed');
    }
  }
}
