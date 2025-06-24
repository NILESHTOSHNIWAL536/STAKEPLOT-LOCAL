import "dart:convert";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_application_code_stakeplot/Constants/font_manager.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/colors.dart";
import "package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart";
import "package:flutter_application_code_stakeplot/Utils/snackBar.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apiConnect/payments.dart";
import "package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart";
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

// expanded finance apis and functions
final Map<String, int> monthNameToIndex = {
  'Jan': 0,
  'Feb': 1,
  'Mar': 2,
  'Apr': 3,
  'May': 4,
  'Jun': 5,
  'Jul': 6,
  'Aug': 7,
  'Sep': 8,
  'Oct': 9,
  'Nov': 10,
  'Dec': 11
};

void updateMonthLabels() {
  monthLabels.value = List.generate(12, (index) {
    return DateFormat('MMM').format(DateTime(selectedYear.value, index + 1, 1));
  });
}

int getDaysInMonthExpanded(int year, int month) {
  month = month.clamp(1, 12);
  return DateTime(year, month + 1, 0).day;
}

Future<void> fetchYearlyData(int year) async {
  try {
    // isLoading.value = true;
    String yearString = year.toString().padLeft(4, '0');
    String endpoint =
        "${url}/transactionauto/getAllCustomTransactions/${accountId.value}/year/$yearString";

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
  } finally {
    isLoading.value = false;
  }
}

Future<void> fetchMonthlyData(int year, int month) async {
  try {
    // isLoading.value = true;
    String formattedDate = DateFormat('yyyy-MM').format(DateTime(year, month));
    var response = await getDataApiCall(
        "${url}/transactionauto/getAllCustomTransactions/${accountId.value}/month/$formattedDate");

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
  } finally {
    isLoading.value = false;
  }
}

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

// friends bill split

class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove commas from old and new values for comparison
    String oldText = oldValue.text.replaceAll(',', '');
    String newText = newValue.text.replaceAll(',', '');

    // Handle decimal part if present
    List<String> parts = newText.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.' + parts[1] : '';

    // Format integer part with commas
    final RegExp regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String formattedInteger =
        integerPart.replaceAllMapped(regExp, (Match m) => '${m[1]},');
    String finalText = formattedInteger + decimalPart;

    // Calculate new cursor position
    int oldCommaCount = oldText.split('').where((c) => c == ',').length;
    int newCommaCount = finalText.split('').where((c) => c == ',').length;
    int cursorOffset =
        newValue.selection.baseOffset + (newCommaCount - oldCommaCount);

    // Adjust cursor position to stay in the correct relative spot
    if (cursorOffset < 0) cursorOffset = 0;
    if (cursorOffset > finalText.length) cursorOffset = finalText.length;

    return newValue.copyWith(
      text: finalText,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }
}
// pending users

String formatDateTime(String dateString) {
  DateTime dateTime = DateTime.parse(dateString).toLocal();

  String formattedDate = DateFormat("dd MMM yyyy hh:mm a").format(dateTime);
  return formattedDate;
}

Future<http.Response> updateDataApiCall(String url, var body) async {
  try {
    var accessToken = await getToken();
    final response = await http.patch(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "$accessToken",
        },
        body: jsonEncode(body));
    return response;
  } catch (error) {
    rethrow;
  }
}

void duesPaid(BuildContext context, int index) async {
  final due = dueAmountRemainders[index];
  final dueId = due['_id']?.toString();
  final type = due['type'];

  final apiUrl = "$url/reminders/request-approval/$type/$dueId";
  try {
    final response = await updateDataApiCall(apiUrl, {});
  } catch (e) {
    snackBarCalledfail(context,SnackbarData().errorSettlingDue);
  
  }
}

void settleAmount(
    BuildContext context, String dueId, String type, String endUser) async {
  final apiUrl = "$url/reminders/settle/$type/$dueId";
  try {
    var body = {
      'splittedUserId': endUser,
    };
    final response = await updateDataApiCall(apiUrl, body);
  } catch (e) {
    snackBarCalledfail(context, SnackbarData().errorSettlingDue);
  
  }
}

void declineAmount(
    BuildContext context, String dueId, String type, String endUser) async {
  final apiUrl = "$url/reminders/decline-request/$type/$dueId";
  try {
    var body = {"splittedUserId": endUser};
    final response = await updateDataApiCall(apiUrl, body);
  } catch (e) {
    snackBarCalledfail(context, SnackbarData().errorSettlingDue);
  }
}

Future<void> getHomePageInsights(context) async {
  try {
    var response =
        await getDataApiCall("${url}/transactionauto/get-headsup-messages");

    if (response.statusCode == 200) {
      var his = jsonDecode(response.body);

      var obj = his['data'];

      totalInSights.clear();
      totalInSights.addAll(obj);

      getTotalInsightsHistory.value = !getTotalInsightsHistory.value;
    } else {}
  } catch (e) {}
}

Future<void> hideTransaction (
    int index, bool hidden, BuildContext context, String id) async {
  
  final transaction = transactionsHistory[index];
  
  final apiUrl = "$url/transactionauto/updateTransaction/$id";
 
  try {
    final response = await updateDataApiCall2(apiUrl, {"Hidden": hidden});
   // Debug print
    if (getFlagOfResponse(response)) {
      if (hidden) {

        hiddenTransactions.add(transaction);
        // hiddenTransactions.add(transaction);
        transactionsHistory.removeAt(index);
        transactionsHistory.refresh();
       
        snackBarCalled(context, SnackbarData().transactionHiddenSuccess);
      } else {
        hiddentrasactionsHistory.removeAt(index);
        hideTransactionReload.value = !hideTransactionReload.value;
        hiddentrasactionsHistory.refresh();
        
      }
    } else {
     
      snackBarCalledfail(context, SnackbarData().transactionHideFailed);
    }
  } catch (e) {
  
    snackBarCalledfail(context, SnackbarData().errorHidingTransaction);
  }
}
