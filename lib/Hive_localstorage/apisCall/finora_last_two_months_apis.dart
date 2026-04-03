// import 'package:flutter_application_code_stakeplot/Hive_localstorage/finora_prev_months/finora_last_two_months_model.dart';
// import 'package:flutter_application_code_stakeplot/Hive_localstorage/hive_storage.dart';
// import 'package:hive/hive.dart';
// import '../../Home_Screen/finora_analytics/finora_last2months_dashboard.dart';
// import 'init_hive.dart';

// class FinoraLastTwoMonthsStorage {
//   static Future<void> cacheFinoraLastTwoMonthsDataLocally(
//       Map<String, dynamic> data) async {
//     HiveHelper.openBoxIfNot<FinoraLastTwoMonthsModel>(
//         HiveStorage.finoraLastTwoMonthsBoxName);
//     final box = await HiveStorage.finoraLastTwoMonthsBox;
//     await box.clear();
//     final model = FinoraLastTwoMonthsModel(
//       month1Name: data['month1Name']?.toString(),
//       month2Name: data['month2Name']?.toString(),
//       month1Avg: data['month1Avg'].toString(),
//       month2Avg: data['month2Avg'].toString(),
//       month1DailySums: (data['month1DailySums'] as List<dynamic>?)
//               ?.cast<Map<String, dynamic>>() ??
//           [],
//       month2DailySums: (data['month2DailySums'] as List<dynamic>?)
//               ?.cast<Map<String, dynamic>>() ??
//           [],
//     );

//     await box.add(model);
//   }

//   static Future<void> loadFinoraLastTwoMonthsDataFromHive() async {
//     HiveHelper.openBoxIfNot<FinoraLastTwoMonthsModel>(
//         HiveStorage.finoraLastTwoMonthsBoxName);
//     final box = await HiveStorage.finoraLastTwoMonthsBox;
//     if (box.isNotEmpty) {
//       // Convert all values to a list
//       final models = box.values.toList();

//       // Map all models into a list of maps
//       final dataList = models.map((model) {
//         return {
//           'month1Name': model.month1Name,
//           'month2Name': model.month2Name,
//           'month1Avg': model.month1Avg,
//           'month2Avg': model.month2Avg,
//           'month1DailySums': model.month1DailySums,
//           'month2DailySums': model.month2DailySums,
//         };
//       }).toList();

//       finoraTransactionData.clear();
//       finoraTransactionData.addAll(dataList[0]);
//       FinoraLoading.value = !FinoraLoading.value;
//     } else {
//       finoraTransactionData = {};
//     }
//   }

//   static Future<void> closeFinoraLastTwoMonthsBox() async {
//     if (Hive.isBoxOpen(HiveStorage.finoraLastTwoMonthsBoxName)) {
//       await Hive.box<FinoraLastTwoMonthsModel>(
//               HiveStorage.finoraLastTwoMonthsBoxName)
//           .close();
//     }
//   }
// }
