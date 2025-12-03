import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Hive_localstorage/apisCall/finance_apis.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/repository/home.dart';
import 'package:flutter_application_code_stakeplot/repository/home_page_apiCalls.dart';
import 'package:flutter_application_code_stakeplot/repository/transactions_repository.dart';
import 'package:flutter_application_code_stakeplot/routes/route_transactions.dart';
import 'package:intl/intl.dart';

void filterDataForSelectedMonth() {
  int monthForCalc = selectedMonth.value.clamp(1, 12);
  int daysInMonth = getDaysInMonthExpanded(selectedYear.value, monthForCalc);
  List<String> newDays = List.generate(daysInMonth, (index) {
    return (index + 1).toString();
  });
  currentDays.value = newDays;

  if (isYearView.value) {
    fetchYearlyData(selectedYear.value);
  } else {
    fetchMonthlyData(selectedYear.value, monthForCalc);
  }
}

void showYearPicker(
    BuildContext context, double fontSizeFactor, double screenWidth) {
  final currentYear = DateTime.now().year;
  final yearsCount = currentYear - 2020 + 1;

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 300.0,
        padding: EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
          childAspectRatio: 2.5,
          children: List.generate(yearsCount, (index) {
            final year = currentYear - index;
            return GestureDetector(
              onTap: () async {
                selectedYear.value = year;
                isYearView.value = true;
                isLoadingMore.value = false;
                Navigator.pop(context);
                transactionsHistory.clear();
                currentPage = 1;
                getAllTransactionHistory(context, true, true);
                updateMonthLabels();
                await fetchYearlyData(year);
                // setState(() {});
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.button,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    year.toString(),
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.normal,
                        fontSize: 14,
                        color: AppColors.accentColor),
                  ),
                ),
              ),
            );
          }),
        ),
      );
    },
  );
}

void showMonthPicker(
    BuildContext context, double fontSizeFactor, double screenWidth) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: 220.0,
        padding: EdgeInsets.all(8.0),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 2.0,
          mainAxisSpacing: 2.0,
          childAspectRatio: 2.5,
          children: List.generate(12, (index) {
            final month = index + 1;
            return GestureDetector(
              onTap: () async {
                selectedMonth.value = month;
                isYearView.value = false;
                // loadChatdataOnChnage.value = !loadChatdataOnChnage.value;
                Navigator.pop(context);
                transactionsHistory.clear();
                currentPage = 1;
                isLoadingMore.value = false;
                getAllTransactionHistory(context, true, false);
                await fetchMonthlyData(selectedYear.value, month);
                // setState(() {});
              },
              child: Container(
                height: 20,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.button,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    DateFormat('MMMM')
                        .format(DateTime(selectedYear.value, month, 1)),
                    style: FontManager().getTextStyle(context,
                        lWeight: FontWeight.normal,
                        fontSize: 16,
                        color: AppColors.accentColor),
                  ),
                ),
              ),
            );
          }),
        ),
      );
    },
  );
}

Future<void> fetchYearlyData(int year) async {
  String period = 'Year';
  String startDate = DateFormat('yyyy-MM-dd').format(DateTime(year, 1, 1));
  String? endDate = null; // Year view doesn’t use endDate
  List<String> labels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  // Try loading from Hive first
  final cachedFinance = await FinanceLocalStorage.loadFinanceFromHive(
    accountId.value,
    period,
    startDate,
    endDate,
  );

  if (cachedFinance != null) {
    currentChartData.value = {
      'credited': cachedFinance.credited,
      'debited': cachedFinance.debited,
    };
    currentDays.value = cachedFinance.labels;
    maxYValue.value = cachedFinance.maxYValue;
    totalExpandedValue.value = cachedFinance.totalDebitValue;
    totalDebitValuePercent.value = cachedFinance.totalDebitValuePercent;
    getGraphData.value = true;
    // isLoading.value = false;
    return;
  }

  try {
    // isLoading.value = true;
    String yearString = year.toString().padLeft(4, '0');
    String endpoint = BankTransactionRoutes.getAllCustomTransactions(accountId: accountId.value, type: 'year', value: yearString);
   

    var response = await getDataApiCall(endpoint);

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        var data = jsonDecode(response.body);

        if (data['success'] == true) {
          Map<String, List<double>> yearlyData = {
            'credited': List.filled(12, 0.0),
            'debited': List.filled(12, 0.0),
          };

          try {
            if (data['data'] != null && data['data']['result'] != null) {
              data['data']['result'].forEach((key, value) {
                int monthIndex = monthNameToIndex[key] ?? -1;

                if (monthIndex >= 0 && monthIndex < 12) {
                  yearlyData['credited']![monthIndex] =
                      getDouble(value['credit']);
                  yearlyData['debited']![monthIndex] =
                      getDouble(value['debit']);
                } else {}
              });

              currentChartData.value = yearlyData;
              maxYValue.value = data['data']['maxAmount']?.toDouble() ?? 500.0;
              totalExpandedValue.value =
                  data['data']['totalCredit']?.toDouble() ?? 500.0;
              if (maxYValue.value == 0) maxYValue.value = 500.0;
              await FinanceLocalStorage.cacheFinanceDataLocally(
                period: period,
                startDate: startDate,
                endDate: endDate,
                labels: labels,
                debited: yearlyData['debited']!,
                credited: yearlyData['credited']!,
                totalDebitValue: totalExpandedValue.value,
                totalDebitValuePercent: totalDebitValuePercent.value,
                maxYValue: maxYValue.value,
                accountId: accountId.value,
              );
            } else {
              throw Exception('Invalid data structure received from API');
            }
          } catch (e) {
            maxYValue.value = 500.0;
            currentChartData.value = {
              'credited': List.filled(12, 0.0),
              'debited': List.filled(12, 0.0),
            };
          }
        } else {
          currentChartData.value = {
            'credited': List.filled(12, 0.0),
            'debited': List.filled(12, 0.0),
          };
        }
      } catch (e) {
        currentChartData.value = {
          'credited': List.filled(12, 0.0),
          'debited': List.filled(12, 0.0),
        };
      }
    } else {
      try {
        var errorData = jsonDecode(response.body);
      } catch (e) {}
      currentChartData.value = {
        'credited': List.filled(12, 0.0),
        'debited': List.filled(12, 0.0),
      };
    }
  } catch (e) {
    currentChartData.value = {
      'credited': List.filled(12, 0.0),
      'debited': List.filled(12, 0.0),
    };
    final cachedFinance = await FinanceLocalStorage.loadFinanceFromHive(
      accountId.value,
      period,
      startDate,
      endDate,
    );
  } finally {
    isLoading.value = false;
  }
}

Future<void> fetchMonthlyData(int year, int month) async {
  String period = 'Month';
  String startDate = DateFormat('yyyy-MM-dd').format(DateTime(year, month, 1));
  String endDate =
      DateFormat('yyyy-MM-dd').format(DateTime(year, month + 1, 0));
  int daysInMonth = getDaysInMonthExpanded(year, month);
  List<String> labels = List.generate(daysInMonth,
      (index) => DateFormat('MMM d').format(DateTime(year, month, index + 1)));

  // Try loading from Hive first
  final cachedFinance = await FinanceLocalStorage.loadFinanceFromHive(
    accountId.value,
    period,
    startDate,
    endDate,
  );

  if (cachedFinance != null) {
    currentChartData.value = {
      'credited': cachedFinance.credited,
      'debited': cachedFinance.debited,
    };
    currentDays.value = cachedFinance.labels;
    maxYValue.value = cachedFinance.maxYValue;
    totalExpandedValue.value = cachedFinance.totalDebitValue;
    totalDebitValuePercent.value = cachedFinance.totalDebitValuePercent;
    getGraphData.value = true;
    isLoading.value = false;
    return;
  }
  try {
    // isLoading.value = true;
    String formattedDate = DateFormat('yyyy-MM').format(DateTime(year, month));
    String endpoint = BankTransactionRoutes.getAllCustomTransactions(accountId: accountId.value, type: 'month', value: formattedDate);
    var response = await getDataApiCall(endpoint);

    if (getFlagOfResponse(response)) {
      var data = jsonDecode(response.body);
      int daysInMonth = getDaysInMonthExpanded(year, month);
      Map<String, List<double>> monthlyData = {
        'credited': List.filled(daysInMonth, 0.0),
        'debited': List.filled(daysInMonth, 0.0),
      };

      try {
        data['data']['result'].forEach((key, value) {
          try {
            int dayIndex = int.parse(key.split('-')[2]) - 1;

            if (dayIndex >= 0 && dayIndex < daysInMonth) {
              monthlyData['credited']![dayIndex] = getDouble(value['credit']);
              monthlyData['debited']![dayIndex] = getDouble(value['debit']);
            } else {}
          } catch (e) {}
        });

        currentChartData.value = monthlyData;
        maxYValue.value = data['data']['maxAmount']?.toDouble() ?? 500.0;
        totalExpandedValue.value =
            data['data']['totalDebit']?.toDouble() ?? 500.0;
        if (maxYValue.value == 0) maxYValue.value = 500.0;
        await FinanceLocalStorage.cacheFinanceDataLocally(
          period: period,
          startDate: startDate,
          endDate: endDate,
          labels: labels,
          debited: monthlyData['debited']!,
          credited: monthlyData['credited']!,
          totalDebitValue: totalExpandedValue.value,
          totalDebitValuePercent: totalDebitValuePercent.value,
          maxYValue: maxYValue.value,
          accountId: accountId.value,
        );
      } catch (e) {
        maxYValue.value = 500.0;
        currentChartData.value = {
          'credited': List.filled(daysInMonth, 0.0),
          'debited': List.filled(daysInMonth, 0.0),
        };
      }
    } else {
      int daysInMonth = getDaysInMonthExpanded(year, month);
      currentChartData.value = {
        'credited': List.filled(daysInMonth, 0.0),
        'debited': List.filled(daysInMonth, 0.0),
      };
    }
  } catch (e) {
    int daysInMonth = getDaysInMonthExpanded(year, month);
    currentChartData.value = {
      'credited': List.filled(daysInMonth, 0.0),
      'debited': List.filled(daysInMonth, 0.0),
    };
    final cachedFinance = await FinanceLocalStorage.loadFinanceFromHive(
      accountId.value,
      period,
      startDate,
      endDate,
    );
  } finally {
    isLoading.value = false;
  }
}

