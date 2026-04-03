import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/categoriseSpending.dart';
import 'package:get/get.dart';

// ─── Chart Data Model ────────────────────────────────────────────────────────



// ─── Finora Controller ───────────────────────────────────────────────────────

class FinoraController extends GetxController {
  // ── Loading states ──────────────────────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool finoraLoading = false.obs;
  final RxBool isFinoraVisible = false.obs;
  final RxBool setDonectChat = false.obs;

  // ── Raw API response ────────────────────────────────────────────────────────
  final Rx<Map<String, dynamic>> finoraTransactionData =
      Rx<Map<String, dynamic>>({});

  // ── Totals ──────────────────────────────────────────────────────────────────
  final RxDouble totalDebitThisMonth = 0.0.obs;
  final RxDouble totalDebitThisWeek = 0.0.obs;

  // ── Monthly lists ───────────────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> categoriesList =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> frequentPayments =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> moreDrasticChange =
      <Map<String, dynamic>>[].obs;

  // ── Weekly lists ────────────────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> categoriesListWeek =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> frequentPaymentsWeek =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> moreDrasticChangeWeek =
      <Map<String, dynamic>>[].obs;

  // ── Insights ────────────────────────────────────────────────────────────────
  final RxList<Map<String, dynamic>> mostSpentCategoryInMonth =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> mostSpentDayInMonth =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> weeklyTrend =
      <Map<String, dynamic>>[].obs;

  // ── Chart / category spending ───────────────────────────────────────────────
  final RxList<ChartData> spendingsOnCategories = <ChartData>[].obs;
  final RxDouble totalValue = 0.0.obs;
  final RxBool spendingsOnCategoriesBool = false.obs;

  // ── UI state ────────────────────────────────────────────────────────────────
  final RxInt selectedIndex = (-1).obs;
  final RxString selectedPeriod = 'Month'.obs;

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Clear all monthly + weekly data lists before a fresh API populate.
  void clearAllLists() {
    categoriesList.clear();
    frequentPayments.clear();
    moreDrasticChange.clear();
    categoriesListWeek.clear();
    frequentPaymentsWeek.clear();
    moreDrasticChangeWeek.clear();
    mostSpentCategoryInMonth.clear();
    mostSpentDayInMonth.clear();
    weeklyTrend.clear();
  }

  /// Call after populating [categoriesList] to rebuild [spendingsOnCategories].
  void processChartData(Map<String, Color> categoryColors) {
    try {
      final List<ChartData> newData = [];
      double newTotal = 0.0;

      for (final item in categoriesList) {
        final String category =
            (item['category'] ?? 'Others').toString();
        final String percentage =
            (item['total_debit_percentage'] ?? '').toString();

        double value = 0.0;
        final dynamic raw = item['total_debit'];
        if (raw is num) {
          value = raw.toDouble();
        } else if (raw is String) {
          value = double.tryParse(raw) ?? 0.0;
        }

        final Color color = categoryColors[category] ?? Colors.grey;
        newData.add(ChartData(category, value, color, percentage));
        newTotal += value;
      }

      spendingsOnCategories
        ..clear()
        ..addAll(newData);

      totalValue.value = newTotal;

      spendingsOnCategories.refresh();
      totalValue.refresh();
    } catch (_) {}
  }
}