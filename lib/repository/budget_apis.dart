import 'dart:convert';
import 'package:flutter_application_code_stakeplot/Constants/booleanFlag.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/routes/route_transactions.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/routes/route_finances.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';

import '../components/helper.dart';
import '../components/shared_utils.dart';

class BudgetService {
  static Future<void> fetchBudgetInsights(String budgetId) async {
    final String apiUrl = BudgetRoutes.getInsights(bid: budgetId);

    try {
      var response = await getDataApiCall(apiUrl);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        budgetInsights = List<String>.from(data['data'] ?? []);
      } else {}
    } catch (e) {}
  }

  static Future<void> fetchBudgetData(
      Map<String, dynamic> budgetDataParam) async {
    final String budgetId =
        budgetDataParam['_id']?.toString() ?? '67b84fdcfab72f34be29c893';

    final String apiUrl = BudgetRoutes.getBudgetSpents(bid: budgetId);

    try {
      var response = await getDataApiCall(apiUrl);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        selectedBudgetPeriod =
            budgetDataParam['budgetPeriod']?.toLowerCase() ?? 'monthly';
        budgetTransactions = data['data'] != null
            ? data['data']['finalResult']['transactions'] ?? []
            : data['transactions'] ?? [];

        categorySpendings = List<Map<String, dynamic>>.from(
            data['data']['categoryWiseSpendings'] ?? []);
        pieGraphData = categorySpendings.map((item) {
          return {
            'title':
                '${item['category']} ${item['percentage'].toStringAsFixed(1)}%',
            'value': (item['spending'] as num).toDouble(),
          };
        }).toList();

        budgetChartData.clear();

        final String createdDateStr =
            budgetDataParam['createdAt']?.toString() ??
                '2025-01-01T00:00:00.000Z';

        final String endDateStr =
            budgetDataParam['endDate'] ?? '2025-03-04T12:07:11.028Z';
        DateTime startDate = DateTime.parse(createdDateStr).toLocal();
        startDate = DateTime(startDate.year, startDate.month, startDate.day);

        DateTime endDate = DateTime.parse(endDateStr).toLocal();
        //startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = DateTime(endDate.year, endDate.month, endDate.day);

        if (selectedBudgetPeriod == 'yearly') {
          // Use backend-provided labels directly from transactions
          Map<String, double> monthlySpent = {};
          for (var transaction in budgetTransactions) {
            String monthLabel = transaction['_id']; // e.g., "March", "April"
            monthlySpent[monthLabel] =
                (transaction['debitTotalAmount'] as num?)?.toDouble() ?? 0.0;
          }

          // Populate budgetChartData with backend labels+
          List<String> xLabels =
              budgetTransactions.map((t) => t['_id'] as String).toList();

          for (int i = 0; i < xLabels.length; i++) {
            String monthLabel = xLabels[i];
            budgetChartData.add(BudgetChartDataPoint(
              x: i,
              y: monthlySpent[monthLabel] ?? 0.0,
              xString: monthLabel.substring(
                  0, 3), // Display only first 3 letters, e.g., "Mar"
            ));
          }
        } else if (selectedBudgetPeriod == 'monthly') {
          int totalDays = endDate.difference(startDate).inDays + 1;

          Map<int, double> dailySpent = {};
          for (var transaction in budgetTransactions) {
            DateTime date = DateFormat('yyyy-MM-dd').parse(transaction['_id']);
            int dayIndex = date.difference(startDate).inDays;
            if (dayIndex >= 0 && dayIndex < totalDays) {
              dailySpent[dayIndex] =
                  (transaction['debitTotalAmount'] as num?)?.toDouble() ?? 0.0;
            }
          }

          for (int i = 0; i < totalDays; i++) {
            DateTime currentDate = startDate.add(Duration(days: i));
            String dayLabel = DateFormat('dd MMM').format(currentDate);
            budgetChartData.add(BudgetChartDataPoint(
              x: i,
              y: dailySpent[i] ?? 0.0,
              xString: dayLabel,
            ));
          }
        } else if (selectedBudgetPeriod == 'weekly') {
          int totalDays = math.min(endDate.difference(startDate).inDays + 1, 7);

          Map<int, double> dailySpent = {};
          for (var transaction in budgetTransactions) {
            DateTime date = DateFormat('yyyy-MM-dd').parse(transaction['_id']);
            int dayIndex = date.difference(startDate).inDays;
            if (dayIndex >= -1 && dayIndex < totalDays) {
              dailySpent[dayIndex] =
                  (transaction['debitTotalAmount'] as num?)?.toDouble() ?? 0.0;
            }
          }

          for (int i = 0; i < totalDays; i++) {
            DateTime currentDate = startDate.add(Duration(days: i));
            String dayLabel = DateFormat('EEE').format(currentDate);
            budgetChartData.add(BudgetChartDataPoint(
              x: i,
              y: dailySpent[i] ?? 0.0,
              xString: dayLabel,
            ));
          }
        }
      } else {}
    } catch (e) {}
  }

  static Future<void> deleteBudget(
    String budgetId,
    BuildContext context, {
    required VoidCallback onDeleteSuccess,
  }) async {
    isBudgetDeleting = true;

    // final String apiUrl = '$url/budget/$budgetId';
    final String apiUrl = BudgetRoutes.deleteBudget(bid: budgetId);

    try {
      var response = await deleteDataApiCall(apiUrl);

      if (response.statusCode == 200 || response.statusCode == 201) {
        snackBarCalled(context, SnackbarData().budgetDeletionSuccess);

        onDeleteSuccess();
      } else {
        snackBarCalledfail(context, SnackbarData().budgetDeletionError);
      }
    } catch (e) {
    } finally {
      isBudgetDeleting = false;
    }
  }
}

void getTopFiveCater() async {
  String urlPath = BankTransactionRoutes.getBudgetTopFiveCategories;
  try {
    var responce = await getDataApiCall(urlPath);
    if (getFlagOfResponse(responce)) {
      var his = jsonDecode(responce.body);
      categoriesSeleted.clear();
      categoriesSeleted.addAll(his['data']);
      getCategories.value = !getCategories.value;
    }
  } catch (e) {}
}

Future<void> getBudget() async {
  String urlPath = BudgetRoutes.getAllBudgets;
  try {
    var responce = await getDataApiCall(urlPath);
    if (getFlagOfResponse(responce)) {
      var his = jsonDecode(responce.body);
      var obj = his['data'];
      budgetList.clear();
      budgetList.addAll(obj);
      budgetLength.value = obj.length;
      if (!getCreditCardBudgetDebts.value)
        getCreditCardBudgetDebts.value = budgetList.isNotEmpty;
    }
  } catch (e) {}
}

void addBudget(BuildContext context, String name, String amount,
    List expenseCategory, String budgetPeriod) async {
  List filteredCategories = expenseCategory
      .where((e) => !isZeroAmount(e['amount'].toString()))
      .toList();

  if (filteredCategories.isEmpty) {
    createBudget.value = false;
    snackBarCalledfail(context, SnackbarData().budgetAddFailed, );
    return;
  }
  var body = {
    'name': name.toString(),
    'amount': amount.toString(),
    'categoryBudgets': filteredCategories,
    'budgetPeriod': budgetPeriod.toString(),
  };

  final response = await postDataApiCall(BudgetRoutes.createBudget, body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    getBudget();
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pop(context);

    snackBarCalled(context, SnackbarData().budgetAdded);
  } else {
    snackBarCalledfail(context, SnackbarData().budgetAddFailed, );
  }

  acceptReset.value = false;
  createBudget.value = false;
}

void budgetUpdate(context, name, amount, expenseCategory, budgetType,
    budgetPeriod, id) async {
  final response = await postDataApiCall(BudgetRoutes.editBudget(id: id), {
    'name': name.toString(),
    'amount': amount.toString(),
    'expenseCategories': expenseCategory,
    'budgetType': budgetType.toString(),
    'budgetPeriod': budgetPeriod.toString(),
  });

  if (response.statusCode == 200 || response.statusCode == 201) {
    snackBarCalled(context, SnackbarData().budgetUpdated);
    Navigator.pop(context);
    Navigator.pop(context);
  } else {
    snackBarCalledfail(context, SnackbarData().budgetUpdateFailed, );
  }
}

void getInsights(context, String id) async {
  var response = await getDataApiCall(BudgetRoutes.getInsights(bid: id));
  if (response.statusCode == 200) {
    var his = jsonDecode(response.body);
    var obj = his['data'];
    inSights.clear();
    inSights.addAll(obj);
    getHistory.value = !getHistory.value;
  } else {}
}
