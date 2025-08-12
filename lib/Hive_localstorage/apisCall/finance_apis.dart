


import 'package:flutter_application_code_stakeplot/Hive_localstorage/finance_data/finance_model.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:hive/hive.dart';
import 'package:get/get.dart';

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
      final box = Hive.box<FinanceModel>('financeBox');
      final cacheKey = '${accountId}_${period}_$startDate${endDate != null ? '_$endDate' : ''}';
      print('Caching finance data for key: $cacheKey');

      // Validate data before caching
      if (labels.length != debited.length || labels.length != credited.length) {
        print('Error: Inconsistent data lengths - labels: ${labels.length}, debited: ${debited.length}, credited: ${credited.length}');
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
      print('Successfully cached finance data for $cacheKey');
    } catch (e) {
      print('Error caching finance data: $e');
    }
  }

  static Future<FinanceModel?> loadFinanceFromHive(String accountId, String period, String startDate, [String? endDate]) async {
    try {
      final box = Hive.box<FinanceModel>('financeBox');
      final cacheKey = '${accountId}_${period}_$startDate${endDate != null ? '_$endDate' : ''}';
      print('Loading finance data for key: $cacheKey');

      final finance = box.get(cacheKey);
      if (finance != null) {
        print('Finance data loaded from cache: $cacheKey');
        labels.assignAll(finance.labels);
        transactionChatGraph['debited'] = finance.debited;
        transactionChatGraph['credited'] = finance.credited;
        totalDebitValue.value = finance.totalDebitValue;
        totalDebitValuePercent.value = finance.totalDebitValuePercent;
        maxYValue.value = finance.maxYValue;
        getGraphData.value = true;
      } else {
        print('No finance data found in cache for: $cacheKey');
        getGraphData.value = false;
      }
      return finance;
    } catch (e) {
      print('Error loading finance data from Hive: $e');
      getGraphData.value = false;
      return null;
    }
  }

  // Clear cache for a specific account or period
  static Future<void> clearFinanceCache(String accountId, [String? period, String? startDate, String? endDate]) async {
    try {
      final box = Hive.box<FinanceModel>('financeBox');
      if (period == null) {
        // Clear all data for the account
        final keys = box.keys.where((key) => key.toString().startsWith(accountId));
        await box.deleteAll(keys);
        print('Cleared all finance cache for account: $accountId');
      } else {
        final cacheKey = '${accountId}_${period}_$startDate${endDate != null ? '_$endDate' : ''}';
        await box.delete(cacheKey);
        print('Cleared finance cache for key: $cacheKey');
      }
    } catch (e) {
      print('Error clearing finance cache: $e');
    }
  }
}