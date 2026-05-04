import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/finance_apis.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/routes/route_transactions.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

int _financeGraphRequestId = 0;
final Map<String, Future<void>> _financeGraphRequests = {};

Future<void> getWeeklyGraphAndCustomDateGraph(String date, BuildContext context,
    {String weekORmonth = 'month',
    String? endDate,
    bool isSplashScreen = false}) async {
  final String requestKey =
      '${accountId.value}_${weekORmonth.toLowerCase()}_$date${endDate ?? ''}';
  final inFlight = _financeGraphRequests[requestKey];
  if (inFlight != null) return inFlight;

  final request = _getWeeklyGraphAndCustomDateGraph(
    date,
    context,
    weekORmonth: weekORmonth,
    endDate: endDate,
    isSplashScreen: isSplashScreen,
  ).whenComplete(() => _financeGraphRequests.remove(requestKey));

  _financeGraphRequests[requestKey] = request;
  return request;
}

Future<void> _getWeeklyGraphAndCustomDateGraph(
  String date,
  BuildContext context, {
  String weekORmonth = 'month',
  String? endDate,
  bool isSplashScreen = false,
}) async {
  final int requestId = ++_financeGraphRequestId;
  final String accountAtRequest = accountId.value;
  final String period = weekORmonth.toLowerCase();
  final String storedPeriod = period == 'month'
      ? 'Month'
      : period == 'week'
          ? 'Week'
          : 'Custom';

  // Format date to YYYY-MM
  String formattedDate = date;
  if (storedPeriod != 'Custom') {
    try {
      DateTime parsedDate = DateTime.parse(date);
      formattedDate = DateFormat('yyyy-MM').format(parsedDate);
    } catch (e) {
      // Fallback to current date if parsing fails
      formattedDate = DateFormat('yyyy-MM').format(DateTime.now());
    }
  }

  if (accountAtRequest.trim().isEmpty) {
    _setEmptyState(storedPeriod, formattedDate, endDate);
    return;
  }

  final cached = await FinanceLocalStorage.loadFinanceFromHive(
      accountAtRequest, storedPeriod, formattedDate, endDate, !isSplashScreen);
  if (requestId != _financeGraphRequestId ||
      accountAtRequest != accountId.value) {
    return;
  }
  if (cached == null && !isSplashScreen) {
    _setEmptyState(storedPeriod, formattedDate, endDate);
  }

  List<String> labelsLocal = [];
  List<double> debitList = [];
  List<double> creditList = [];

  String urlPath = endDate != null && storedPeriod == 'Custom'
      ? BankTransactionRoutes.getAllCustomTransactions(
          accountId: accountAtRequest,
          type: period,
          value: "$formattedDate,${getNextDay(endDate)}",
        )
      : BankTransactionRoutes.getAllCustomTransactions(
          accountId: accountAtRequest,
          type: period,
          value: formattedDate,
        );

  try {
    final response = await getDataApiCall(urlPath);
    if (requestId != _financeGraphRequestId ||
        accountAtRequest != accountId.value) {
      return;
    }
    if (getFlagOfResponse(response)) {
      final his = jsonDecode(response.body);
      transactionChatGraph.clear();
      try {
        final data = his['data']['result'] as Map;
        totalDebitValuePercent.value = double.tryParse(
                his['data']['debitChangePercentage']?.toString() ?? '0') ??
            0;
        totalDebitValue.value =
            double.tryParse(his['data']['totalDebit']?.toString() ?? '0') ?? 0;
        maxYValue.value =
            double.tryParse(his['data']['maxAmount']?.toString() ?? '500') ??
                500;
        if (maxYValue.value == 0) maxYValue.value = 500.0;

        if (storedPeriod == 'Custom' && endDate != null) {
          DateTime startDate = DateTime.parse(formattedDate);
          DateTime end = DateTime.parse(endDate);
          int daysDiff = end.difference(startDate).inDays + 1;
          debitList = List.filled(daysDiff, 0.0);
          creditList = List.filled(daysDiff, 0.0);

          for (int i = 0; i < daysDiff; i++) {
            DateTime currentDate = startDate.add(Duration(days: i));
            labelsLocal.add(DateFormat('MMM d').format(currentDate));
          }

          data.forEach((key, value) {
            DateTime txDate = DateTime.parse(key);
            if (txDate.isAfter(startDate.subtract(Duration(days: 1))) &&
                txDate.isBefore(end.add(Duration(days: 1)))) {
              int index = txDate.difference(startDate).inDays;
              if (index >= 0 && index < debitList.length) {
                debitList[index] = getDouble(value['debit']);
                creditList[index] = getDouble(value['credit']);
              }
            }
          });
        } else {
          data.forEach((key, value) {
            String label = storedPeriod == 'Custom'
                ? key
                : key.toString().substring(key.length - 2);
            labelsLocal.add(label);
            debitList.add(getDouble(value['debit']));
            creditList.add(getDouble(value['credit']));
          });
        }

        if (storedPeriod == 'Week') {
          labelsLocal = getWeekDays();
          if (debitList.length < 7) {
            debitList = List.filled(7, 0.0)
              ..setRange(0, debitList.length, debitList);
            creditList = List.filled(7, 0.0)
              ..setRange(0, creditList.length, creditList);
          }
        }

        // Only update if data is valid
        if (debitList.isNotEmpty || creditList.isNotEmpty) {
          transactionChatGraph['debited'] = debitList;
          transactionChatGraph['credited'] = creditList;
          labels.assignAll(labelsLocal);
          getGraphData.value = true;

          // Cache the data
          unawaited(FinanceLocalStorage.cacheFinanceDataLocally(
            period: storedPeriod,
            startDate: formattedDate,
            endDate: endDate,
            labels: labelsLocal,
            debited: debitList,
            credited: creditList,
            totalDebitValue: totalDebitValue.value,
            totalDebitValuePercent: totalDebitValuePercent.value,
            maxYValue: maxYValue.value,
            accountId: accountAtRequest,
          ));
        } else {
          _setEmptyState(storedPeriod, formattedDate, endDate);
          await FinanceLocalStorage.loadFinanceFromHive(
              accountAtRequest, storedPeriod, formattedDate, endDate);
        }
      } catch (e) {
        _setEmptyState(storedPeriod, formattedDate, endDate);
        await FinanceLocalStorage.loadFinanceFromHive(
            accountAtRequest, storedPeriod, formattedDate, endDate);
      }
    } else {
      _setEmptyState(storedPeriod, formattedDate, endDate);
      await FinanceLocalStorage.loadFinanceFromHive(
          accountAtRequest, storedPeriod, formattedDate, endDate);
    }
  } catch (e) {
    _setEmptyState(storedPeriod, formattedDate, endDate);
    await FinanceLocalStorage.loadFinanceFromHive(
        accountAtRequest, storedPeriod, formattedDate, endDate);
  }
}

void _setEmptyState(String weekORmonth, String date, String? endDate) {
  List<String> labelsLocal = [];
  List<double> debitList = [];
  List<double> creditList = [];

  if (weekORmonth == 'Custom' && endDate != null) {
    DateTime startDate = DateTime.parse(date);
    DateTime end = DateTime.parse(endDate);
    int daysDiff = end.difference(startDate).inDays + 1;
    debitList = List.filled(daysDiff, 0.0);
    creditList = List.filled(daysDiff, 0.0);
    for (int i = 0; i < daysDiff; i++) {
      labelsLocal
          .add(DateFormat('MMM d').format(startDate.add(Duration(days: i))));
    }
  } else {
    labelsLocal = weekORmonth == 'Week' ? getWeekDays() : getDaysInMonth(date);
    debitList = List.filled(labelsLocal.length, 0.0);
    creditList = List.filled(labelsLocal.length, 0.0);
  }
  transactionChatGraph['debited'] = debitList;
  transactionChatGraph['credited'] = creditList;
  labels.assignAll(labelsLocal);
  totalDebitValue.value = 0;
  totalDebitValuePercent.value = 0;
  maxYValue.value = 500.0;
  getGraphData.value = true;
}
