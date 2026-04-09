// ============================================================
//  budget_controller.dart
//  GetX controller — owns all budget creation & display state.
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'budget_assets.dart';

// ─────────────────────────────────────────────
//  Inline API helpers (mirror your curd.dart)
// ─────────────────────────────────────────────
// Replace the import below with your real path once you integrate.
// import 'package:your_app/backed_connections/apiAutomations/curd.dart';
// import 'package:your_app/routes/route_finances.dart';

// ─────────────────────────────────────────────
//  Route constants  (matches BudgetRoutes class)
// ─────────────────────────────────────────────
class BudgetRoutes {
  // TODO: replace with your real base URL constant
  static const String _base = 'https://your-backend.com/budget';

  static String createBudget               = '$_base/';
  static String editBudget({required String id}) => '$_base/edit/$id';
  static String getAllBudgets              = '$_base/';
  static String getBudgetById({required String bid}) => '$_base/$bid';
  static String getBudgetSpents({required String bid}) =>
      '$_base/get-budget-spents/$bid';
  static String getInsights({required String bid}) =>
      '$_base/get-insights/$bid';
  static String deleteBudget({required String bid}) => '$_base/$bid';
}

// ─────────────────────────────────────────────
//  Model helpers
// ─────────────────────────────────────────────
class CategoryBudgetItem {
  final String name;
  final String icon;
  final String color;
  double amount;
  bool   isEdited; // user manually changed the amount

  CategoryBudgetItem({
    required this.name,
    required this.icon,
    required this.color,
    required this.amount,
    this.isEdited = false,
  });

  Map<String, dynamic> toJson() => {
    'category': name,
    'amount':   amount.toStringAsFixed(0),
  };
}

// ─────────────────────────────────────────────
//  Controller
// ─────────────────────────────────────────────
class BudgetController extends GetxController {

  // ── Creation step (0-indexed) ──────────────
  final RxInt currentStep = 0.obs;
  static const int totalSteps = 4; // name → amount → duration → categories

  // ── Step 1 – Budget Name ───────────────────
  final TextEditingController nameController = TextEditingController();
  final RxString budgetName = ''.obs;

  // ── Step 2 – Budget Amount ─────────────────
  final TextEditingController amountController = TextEditingController();
  final RxDouble totalAmount = 0.0.obs;

  // ── Step 3 – Duration ──────────────────────
  final RxInt selectedDurationDays = 14.obs;

  // ── Step 4 – Category selection ───────────
  final RxList<String> selectedCategoryNames = <String>[].obs;

  // ── Step 5 – Category amount allocation ───
  final RxList<CategoryBudgetItem> categoryItems = <CategoryBudgetItem>[].obs;

  // ── Budget list ───────────────────────────
  final RxList<Map<String, dynamic>> budgetList =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingList = false.obs;

  // ── Selected budget detail ────────────────
  final Rx<Map<String, dynamic>?> selectedBudget =
      Rx<Map<String, dynamic>?>(null);
  final RxList<Map<String, dynamic>> chartData =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingDetail = false.obs;

  // ── Creating / API in-flight ──────────────
  final RxBool isCreating = false.obs;

  // ─────────────────────────────────────────
  //  Computed helpers
  // ─────────────────────────────────────────

  /// Sum of all category amounts
  double get categorySum =>
      categoryItems.fold(0.0, (s, e) => s + e.amount);

  /// True when sum equals total budget (enables Done button)
  bool get isSumBalanced =>
      (totalAmount.value - categorySum).abs() < 0.01;

  /// True when every item has been manually edited  
  bool get allEdited =>
      categoryItems.isNotEmpty &&
      categoryItems.every((e) => e.isEdited);

  /// Done button enabled: amounts balance AND not all manually edited
  /// (if all are edited AND sum ≠ total the user needs to fix at least one)
  bool get isDoneEnabled => isSumBalanced;

  // ─────────────────────────────────────────
  //  Navigation helpers
  // ─────────────────────────────────────────

  bool get canGoNext {
    switch (currentStep.value) {
      case 0: return budgetName.value.trim().isNotEmpty;
      case 1: return totalAmount.value > 0;
      case 2: return true; // duration always has a selection
      case 3: return selectedCategoryNames.isNotEmpty;
      default: return false;
    }
  }

  void nextStep() {
    if (!canGoNext) return;
    if (currentStep.value == 3) {
      _buildCategoryItems();
      currentStep.value = 4; // category amount allocation page
    } else {
      currentStep.value++;
    }
  }

  void prevStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  // ─────────────────────────────────────────
  //  Step 4 – Category selection toggle
  // ─────────────────────────────────────────

  void toggleCategory(String name) {
    if (selectedCategoryNames.contains(name)) {
      selectedCategoryNames.remove(name);
    } else {
      selectedCategoryNames.add(name);
    }
  }

  // ─────────────────────────────────────────
  //  Step 5 – Category amount allocation
  // ─────────────────────────────────────────

  void _buildCategoryItems() {
    final count = selectedCategoryNames.length;
    final equalShare = count > 0 ? totalAmount.value / count : 0.0;

    categoryItems.value = selectedCategoryNames.map((name) {
      final cfg = budgetCategories.firstWhere(
        (c) => c['name'] == name,
        orElse: () => {'name': name, 'icon': '', 'color': '0xFF9B8EC4'},
      );
      return CategoryBudgetItem(
        name:     name,
        icon:     cfg['icon'] as String,
        color:    cfg['color'] as String,
        amount:   double.parse(equalShare.toStringAsFixed(2)),
        isEdited: false,
      );
    }).toList();
  }

  /// Called when user edits a category amount field.
  void onCategoryAmountChanged(int index, double newValue) {
    categoryItems[index].amount   = newValue;
    categoryItems[index].isEdited = true;
    categoryItems.refresh();
    _redistributeRemaining();
  }

  void _redistributeRemaining() {
    final editedTotal = categoryItems
        .where((e) => e.isEdited)
        .fold(0.0, (s, e) => s + e.amount);

    final uneditedItems = categoryItems.where((e) => !e.isEdited).toList();
    if (uneditedItems.isEmpty) {
      categoryItems.refresh();
      return;
    }

    final remaining    = totalAmount.value - editedTotal;
    final perUnedited  = remaining / uneditedItems.length;

    for (final item in uneditedItems) {
      item.amount = double.parse(
          (perUnedited < 0 ? 0 : perUnedited).toStringAsFixed(2));
    }
    categoryItems.refresh();
  }

  // ─────────────────────────────────────────
  //  Duration period string
  // ─────────────────────────────────────────
  String get budgetPeriod {
    final d = selectedDurationDays.value;
    if (d <= 7)  return 'weekly';
    if (d <= 31) return 'monthly';
    return 'yearly';
  }

  // ─────────────────────────────────────────
  //  API – Create Budget
  // ─────────────────────────────────────────

  Future<void> createBudget(BuildContext context) async {
    if (!isDoneEnabled) return;
    isCreating.value = true;

    final body = {
      'name':            budgetName.value.trim(),
      'amount':          totalAmount.value.toStringAsFixed(0),
      'budgetPeriod':    budgetPeriod,
      'categoryBudgets': categoryItems.map((e) => e.toJson()).toList(),
    };

    try {
      // TODO: replace with your real postDataApiCall
      // final response = await postDataApiCall(BudgetRoutes.createBudget, body);
      // if (response.statusCode == 200 || response.statusCode == 201) { ... }

      // ── DUMMY success (remove when real API is wired) ──
      await Future.delayed(const Duration(seconds: 1));
      final newBudget = {
        ...body,
        '_id':          DateTime.now().millisecondsSinceEpoch.toString(),
        'spent':        0,
        'percentage':   0,
        'daysLeft':     selectedDurationDays.value,
        'illustration': 'default',
        'createdAt':    DateTime.now().toIso8601String(),
        'endDate':      DateTime.now()
            .add(Duration(days: selectedDurationDays.value))
            .toIso8601String(),
      };
      budgetList.add(newBudget);
      _resetCreation();
      Get.back(); // close creation flow
      Get.snackbar('Success', 'Budget created successfully!',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create budget. Please try again.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isCreating.value = false;
    }
  }

  // ─────────────────────────────────────────
  //  API – Fetch All Budgets
  // ─────────────────────────────────────────

  Future<void> fetchAllBudgets() async {
    isLoadingList.value = true;
    try {
      // TODO: replace with your real getDataApiCall
      // final response = await getDataApiCall(BudgetRoutes.getAllBudgets);
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   budgetList.value = List<Map<String, dynamic>>.from(data['data']);
      // }

      // ── DUMMY data ──
      await Future.delayed(const Duration(milliseconds: 600));
      budgetList.value = List<Map<String, dynamic>>.from(dummyBudgetList);
    } catch (_) {
    } finally {
      isLoadingList.value = false;
    }
  }

  // ─────────────────────────────────────────
  //  API – Delete Budget
  // ─────────────────────────────────────────

  Future<void> deleteBudget(String id) async {
    try {
      // TODO: await deleteDataApiCall(BudgetRoutes.deleteBudget(bid: id));
      await Future.delayed(const Duration(milliseconds: 400));
      budgetList.removeWhere((b) => b['_id'] == id);
      Get.snackbar('Deleted', 'Budget deleted.',
          backgroundColor: Colors.orange, colorText: Colors.white);
    } catch (_) {}
  }

  // ─────────────────────────────────────────
  //  API – Fetch Budget Detail + Chart
  // ─────────────────────────────────────────

  Future<void> fetchBudgetDetail(Map<String, dynamic> budget) async {
    selectedBudget.value = budget;
    isLoadingDetail.value = true;
    try {
      // TODO: replace with real API call
      // final response = await getDataApiCall(
      //     BudgetRoutes.getBudgetSpents(bid: budget['_id']));
      await Future.delayed(const Duration(milliseconds: 500));
      chartData.value =
          List<Map<String, dynamic>>.from(dummyWeeklyChart);
    } catch (_) {
    } finally {
      isLoadingDetail.value = false;
    }
  }

  // ─────────────────────────────────────────
  //  Reset creation form
  // ─────────────────────────────────────────

  void _resetCreation() {
    currentStep.value = 0;
    nameController.clear();
    amountController.clear();
    budgetName.value = '';
    totalAmount.value = 0;
    selectedDurationDays.value = 14;
    selectedCategoryNames.clear();
    categoryItems.clear();
  }

  void startFreshCreation() => _resetCreation();

  @override
  void onClose() {
    nameController.dispose();
    amountController.dispose();
    super.onClose();
  }
}
