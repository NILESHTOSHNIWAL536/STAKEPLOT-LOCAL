// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/finora_apis.dart';
// import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/finora_last_two_months_apis.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/finora_analytics/finora_last2months_dashboard.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/routes/route_transactions.dart';

// import '../controllers/controllerManagement.dart';
// import '../controllers/finora_controller.dart';

//  void getFinoraPreviousMonthData() async {
//   // FinoraController finoraController = ControllerManagement.finoraController;
//     isLoading.value = true;
//     FinoraLoading.value = false;
//     try {
//       var response = await getDataApiCall(BankTransactionRoutes.getUserMonthlySpending);

//       if (getFlagOfResponse(response)) {

//         try {
//           await FinoraLastTwoMonthsStorage.cacheFinoraLastTwoMonthsDataLocally(
//               jsonDecode(response.body)['data']);
//         } catch (e) {
//         }

//         finoraTransactionData = jsonDecode(response.body)['data'] ?? {};
//         isLoading.value = false;
//       } else {
//         isLoading.value = false;
//       }
//     } catch (e) {
//       isLoading.value = false;
//       await FinoraLastTwoMonthsStorage.loadFinoraLastTwoMonthsDataFromHive();
//        isFinoraVisible.value = true;
//       // isFinoraVisible.value = true;
//     }
//   }

// void getCategoryData() async {
//   //  FinoraController finoraController = ControllerManagement.finoraController;
//   try {
//     // API call inside try
//     var res = await getDataApiCall(BankTransactionRoutes.categorizeTransactions);

//     if (getFlagOfResponse(res)) {

//       var data = jsonDecode(res.body);

//        categoriesList.clear();

//        frequentPayments.clear();
//        moreDrasticChange.clear();
//        categoriesListWeek.clear();
//        frequentPaymentsWeek.clear();
//        moreDrasticChangeWeek.clear();
//        mostSpentCategoryInMonth.clear();
//        mostSpentDayInMonth.clear();
//        weeklyTrend.clear();
//       // spendingsOnCategories.clear();
//       // throw Error();

//        categoriesList.addAll(
//         (data["data"]['categorized'] as List<dynamic>)
//             .map((e) => e as Map<String, dynamic>)
//             .toList(),
//       );

//       // frequentPayments.addAll(data["data"]['frequentPayments']);
//       // moreDrasticChange.addAll(data["data"]['moreDrasticChange']);
//        frequentPayments.addAll(
//         (data["data"]['frequentPayments'] as List<dynamic>)
//             .map((e) => e as Map<String, dynamic>)
//             .toList(),
//       );

//        moreDrasticChange.addAll(
//         (data["data"]['moreDrasticChange'] as List<dynamic>)
//             .map((e) => e as Map<String, dynamic>)
//             .toList(),
//       );

//        totalDebitThisMonth.value = double.parse(
//           doubleToFixed(data["data"]['totalDebitThisMonth'].toString()));

//        categoriesListWeek.addAll(
//         (data["data"]['week']['categorized'] as List<dynamic>)
//             .map((e) => e as Map<String, dynamic>)
//             .toList(),
//       );
//        frequentPaymentsWeek.addAll(
//         (data["data"]['week']['frequentPayments'] as List<dynamic>)
//             .map((e) => e as Map<String, dynamic>)
//             .toList(),
//       );
//        moreDrasticChangeWeek.addAll(
//         (data["data"]['week']['moreDrasticChange'] as List<dynamic>)
//             .map((e) => e as Map<String, dynamic>)
//             .toList(),
//       );
//      mostSpentCategoryInMonth.addAll(
//   (data["data"]['mostSpentCategory'] as List<dynamic>)
//       .map((e) => e as Map<String, dynamic>)
//       .toList(),
// );
// if (data["data"]['mostSpentDay'] != null) {
//    mostSpentDayInMonth.add(
//     data["data"]['mostSpentDay'] as Map<String, dynamic>,
//   );
// }
// if (data["data"]['weeklyTrend'] != null) {
//    weeklyTrend.add(
//     data["data"]['weeklyTrend'] as Map<String, dynamic>,
//   );
// }

//       // Refresh reactive lists
//        categoriesList.refresh();
//        frequentPayments.refresh();
//        moreDrasticChange.refresh();
//        categoriesListWeek.refresh();
//        frequentPaymentsWeek.refresh();
//        moreDrasticChangeWeek.refresh();
//        mostSpentCategoryInMonth.refresh();
//        mostSpentDayInMonth.refresh();
//        weeklyTrend.refresh();
//        isFinoraVisible.value = ! isFinoraVisible.value;
//        setDonectChat.value = ! setDonectChat.value;
//       processChartData();
//       unawaited(CategoryStorage().cacheCardInsightsDataLocally());
//     }
//   } catch (e)
//   {
//     await CategoryStorage().loadCardInsightsDataFromHive();
//   }
// }

import 'dart:async';
import 'dart:convert';

import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/finora_apis.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/routes/index_route.dart';
import 'package:flutter_application_code_stakeplot/routes/route_transactions.dart';
import 'package:get/get.dart';

import '../controllers/finora_controller.dart';

class FinoraRepository {
  static final String _baseUrl = '${API.BankApiUrl}/finora';

  static Future<Map<String, dynamic>> getOverview() async {
    final data = await _getFinoraData('$_baseUrl/overview');
    return _asMap(data);
  }

  static Future<Map<String, dynamic>> getMonthlySpending() async {
    final data = await _getFinoraData('$_baseUrl/monthly-spending');

    return _asMap(data);
  }

  static Future<Map<String, dynamic>> getAveragePerDay() async {
    final data = await _getFinoraData('$_baseUrl/average-per-day');

    return _asMap(data);
  }

  static Future<Map<String, dynamic>> getMostFrequentPayment({
    int? months,
    int? limit,
  }) async {
    final url = _withQuery('$_baseUrl/most-frequent-payment', {
      'months': months,
      'limit': limit,
    });

    final data = await _getFinoraData(url);

    return _asMap(data);
  }

  static Future<Map<String, dynamic>> getWeeklyTrend() async {
    final data = await _getFinoraData('$_baseUrl/weekly-trend');

    return _asMap(data);
  }

  static Future<Map<String, dynamic>?> getMostExpensiveTransaction() async {
    final data = await _getFinoraData('$_baseUrl/most-expensive-transaction');
    if (data == null) return null;
    // print("Most expensive transaction data: $data");
    return _asMap(data);
  }

  static Future<Map<String, dynamic>> getTopTransactions({
    int? limit,
    String? type,
    String? period,
    int? months,
    String? startDate,
    String? endDate,
  }) async {
    final url = _withQuery('$_baseUrl/top-transactions', {
      'limit': limit,
      'type': type,
      'period': period,
      'months': months,
      'startDate': startDate,
      'endDate': endDate,
    });

    final data = await _getFinoraData(url);

    return _asMap(data);
  }

  static Future<dynamic> _getFinoraData(String urlPath) async {
    final response = await getDataApiCall(urlPath);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (!getFlagOfResponse(response) || body['success'] == false) {
      throw Exception(
          _extractMessage(body, 'Unable to fetch Finora analytics'));
    }

    return body['data'];
  }

  static String _withQuery(String urlPath, Map<String, dynamic> params) {
    final queryParameters = <String, String>{};

    params.forEach((key, value) {
      if (value == null) return;

      final stringValue = value.toString().trim();
      if (stringValue.isEmpty) return;

      queryParameters[key] = stringValue;
    });

    if (queryParameters.isEmpty) return urlPath;

    return Uri.parse(urlPath)
        .replace(queryParameters: queryParameters)
        .toString();
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.cast<String, dynamic>();
    return <String, dynamic>{};
  }

  static String _extractMessage(Map<String, dynamic> body, String fallback) {
    final error = body['error'];

    if (error is String && error.trim().isNotEmpty) {
      return error;
    }

    if (error is Map && error['explanation'] is String) {
      return error['explanation'] as String;
    }

    if (body['message'] is String &&
        (body['message'] as String).trim().isNotEmpty) {
      return body['message'] as String;
    }

    return fallback;
  }
}

//  void getFinoraPreviousMonthData() async {

//   // FinoraController finoraController = ControllerManagement.finoraController;
//     isLoading.value = true;
//     FinoraLoading.value = false;
//     try {
//       var response = await getDataApiCall(BankTransactionRoutes.getUserMonthlySpending);

//       if (getFlagOfResponse(response)) {

//         try {
//           await FinoraLastTwoMonthsStorage.cacheFinoraLastTwoMonthsDataLocally(
//               jsonDecode(response.body)['data']);
//         } catch (e) {
//         }

//         finoraTransactionData = jsonDecode(response.body)['data'] ?? {};
//         isLoading.value = false;
//       } else {
//         isLoading.value = false;
//       }
//     } catch (e) {
//       isLoading.value = false;
//       await FinoraLastTwoMonthsStorage.loadFinoraLastTwoMonthsDataFromHive();
//        isFinoraVisible.value = true;
//       // isFinoraVisible.value = true;
//     }
//   }

Future<void> getCategoryData() async {
  //  FinoraController finoraController = ControllerManagement.finoraController;
  final controller = Get.find<FinoraController>();

  try {
    // API call inside try
    var res =
        await getDataApiCall(BankTransactionRoutes.categorizeTransactions);

    if (getFlagOfResponse(res)) {
      var data = jsonDecode(res.body);

      //  categoriesList.clear();
      controller.categoriesList.clear();


      // spendingsOnCategories.clear();
      // throw Error();

      controller.categoriesList.addAll(
        (data["data"]['categorized'] as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
      );

      // frequentPayments.addAll(data["data"]['frequentPayments']);
      // moreDrasticChange.addAll(data["data"]['moreDrasticChange']);





      // Refresh reactive lists
      controller.categoriesList.refresh();
     
      controller.isFinoraVisible.value = !controller.isFinoraVisible.value;
      controller.setDonectChat.value = !controller.setDonectChat.value;
      processChartData();
      unawaited(CategoryStorage().cacheCardInsightsDataLocally(controller));
    }
  } catch (e) {
    await CategoryStorage().loadCardInsightsDataFromHive(controller);
  }
}
