import 'dart:convert';

import 'package:flutter_application_code_stakeplot/Hive_localstorage/finance_data/finance_model.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:hive/hive.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class FinanceLocalStorage {
  static Future<void> cacheFinanceDataLocally({
    required String period,
    required String startDate,
    String? endDate,
    required List<String> labels,
    required List<double> debited,
    required List<double> credited,
    required double totalDebitValue,
    required double totalDebitValuePercent,
    required double maxYValue,
    required String accountId,
  }) async {
    try {
      final box = await Hive.box<FinanceModel>('financeBox');
      final cacheKey =
          '${accountId}_${period}_$startDate${endDate != null ? '_$endDate' : ''}';

      // Validate data before caching
      if (labels.length != debited.length || labels.length != credited.length) {
        return;
      }

      final finance = FinanceModel(
        period: period,
        startDate: startDate,
        endDate: endDate,
        labels: labels,
        debited: debited,
        credited: credited,
        totalDebitValue: totalDebitValue,
        totalDebitValuePercent: totalDebitValuePercent,
        maxYValue: maxYValue,
      );

      await box.put(cacheKey, finance);
    } catch (e) {}
  }

  static Future<FinanceModel?> loadFinanceFromHive(
      String accountId, String period, String startDate,
      [String? endDate]) async {
    try {
      final box = await Hive.box<FinanceModel>('financeBox');
      final cacheKey =
          '${accountId}_${period}_$startDate${endDate != null ? '_$endDate' : ''}';

      final finance = box.get(cacheKey);
      if (finance != null) {
        labels.assignAll(finance.labels);
        transactionChatGraph['debited'] = finance.debited;
        transactionChatGraph['credited'] = finance.credited;
        totalDebitValue.value = finance.totalDebitValue;
        totalDebitValuePercent.value = finance.totalDebitValuePercent;
        maxYValue.value = finance.maxYValue;
        getGraphData.value = true;
      } else {
        getGraphData.value = false;
      }
      return finance;
    } catch (e) {
      getGraphData.value = false;
      return null;
    }
  }

  // Clear cache for a specific account or period
  static Future<void> clearFinanceCache(String accountId,
      [String? period, String? startDate, String? endDate]) async {
    try {
      final box = Hive.box<FinanceModel>('financeBox');
      if (period == null) {
        final keys =
            box.keys.where((key) => key.toString().startsWith(accountId));
        await box.deleteAll(keys);
      } else {
        final cacheKey =
            '${accountId}_${period}_$startDate${endDate != null ? '_$endDate' : ''}';
        await box.delete(cacheKey);
      }
    } catch (e) {}
  }
}

