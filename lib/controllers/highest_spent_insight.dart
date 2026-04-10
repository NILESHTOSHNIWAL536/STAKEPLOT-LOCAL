import 'dart:convert';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:get/get.dart';


import '../routes/route_transactions.dart';

class HighestSpentInsightsController extends GetxController {
  /// -------------------------------
  /// STATES
  /// -------------------------------
  var isLoading = false.obs;
  var isError = false.obs;

  /// -------------------------------
  /// DATA
  /// -------------------------------
  var bars = <double>[].obs;
  var labels = <String>[].obs;

  var highestMonthLabel = ''.obs;
  var highestMonthIndex = 0.obs;
  var increase = 0.0.obs;

  var mostActiveDay = ''.obs;
  var message = ''.obs;

  /// -------------------------------
  /// BASE URL
  /// -------------------------------
  final String baseUrl = BankTransactionRoutes.getHighestSpentInsight;

  /// -------------------------------
  /// GET (READ)
  /// -------------------------------
  Future<void> fetchInsights() async {
    try {
      isLoading.value = true;
      isError.value = false;

      final response = await getDataApiCall( baseUrl);

      if (getFlagOfResponse(response)) {
        final data = jsonDecode(response.body);

        /// Bars + Labels
        bars.value = List<double>.from(
          data['bars'].map((e) => (e as num).toDouble()),
        );

        labels.value = List<String>.from(data['labels']);

        /// Highest Month
        highestMonthLabel.value = data['highestMonth']['label'];
        highestMonthIndex.value = data['highestMonth']['index'];
        increase.value =
            (data['highestMonth']['increase'] as num).toDouble();

        /// Most Active Day
        mostActiveDay.value = data['mostActiveDay']['day'];
        message.value = data['mostActiveDay']['message'];

      } else {
        isError.value = true;
        print("API Error: ${response.statusCode}");
      }
    } catch (e) {
      isError.value = true;
      print("Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// -------------------------------
  /// REFRESH
  /// -------------------------------
  Future<void> refreshInsights() async {
    await fetchInsights();
  }

  /// -------------------------------
  /// CLEAR DATA (optional)
  /// -------------------------------
  void clearData() {
    bars.clear();
    labels.clear();
    highestMonthLabel.value = '';
    highestMonthIndex.value = 0;
    increase.value = 0;
    mostActiveDay.value = '';
    message.value = '';
  }
}