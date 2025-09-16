import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/categoriseSpending.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/date_range_filter.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/dotted_Border.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionHistoryScreen.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/Utils/snackBar.dart';
import 'package:flutter_application_code_stakeplot/animated/pdf.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'history/amount_range.dart';

List<PredictionEntry> getUniquePredictedCategories(
    List<PredictionEntry> predictions) {
  final Set<String> seenCategories = {};
  final List<PredictionEntry> uniquePredictions = [];

  for (final keyword in predictions) {
    final category = getCategoryForKeyword(keyword.category);

    if (!seenCategories.contains(category)) {
      seenCategories.add(category);
      uniquePredictions.add(keyword); // or add category if needed
    }
  }

  return uniquePredictions;
}

String getCategoryForKeyword(String keyword) {
  final lowerKeyword = keyword.toLowerCase();

  for (final entry in categories.entries) {
    for (final item in entry.value) {
      if (lowerKeyword.contains(item.toLowerCase())) {
        return entry.key;
      }
    }
  }

  return keyword; // return original if not found
}

final Map<int, Map<String, double>> weekData = {
  for (int i = 0; i < 5; i++)
    i: {
      'Mon': Random().nextInt(500).toDouble(),
      'Tue': Random().nextInt(500).toDouble(),
      'Wed': Random().nextInt(500).toDouble(),
      'Thu': Random().nextInt(500).toDouble(),
      'Fri': Random().nextInt(500).toDouble(),
      'Sat': Random().nextInt(500).toDouble(),
      'Sun': Random().nextInt(500).toDouble(),
    },
};

int getDaysInMonth(int year, int month) {
  if (month == 12) {
    return DateTime(year + 1, 1, 0).day;
  }
  return DateTime(year, month + 1, 0).day;
}

String getFormattedDate() {
  DateTime now = DateTime.now();
  return "${now.year}-${now.month.toString().padLeft(2, '0')}";
}

String getCurrentWeekNumber() {
  DateTime now = DateTime.now();
  int weekNumber = int.parse(DateFormat('w').format(now));
  int year = now.year;
  return '$year-W${weekNumber.toString().padLeft(2, '0')}';
}

String formatWhatsAppDate2(DateTime date) {
  date = date.toLocal().subtract(Duration(hours: 5, minutes: 30));
  ;
  // Adjust for 5:30 offset
  DateTime now = DateTime.now().toLocal();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = today.subtract(Duration(days: 1));
  DateTime tomorrow = today.add(Duration(days: 1));
  DateTime weekStart = today.subtract(Duration(days: today.weekday));
  DateTime weekEnd = weekStart.add(Duration(days: 7));

  String timeFormat = DateFormat('h:mm a').format(date);

  // Check if the date is today
  if (date.year == today.year &&
      date.month == today.month &&
      date.day == today.day) {
    return "Today, $timeFormat";
  }
  // Check if the date is yesterday
  else if (date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day) {
    return "Yesterday, $timeFormat";
  }
  // Check if the date is tomorrow
  else if (date.year == tomorrow.year &&
      date.month == tomorrow.month &&
      date.day == tomorrow.day) {
    return "Tomorrow, $timeFormat";
  }
  // Check if the date is within the current week (past or future)
  else if (date.isAfter(weekStart) && date.isBefore(weekEnd)) {
    return "${DateFormat('EEE').format(date)}, $timeFormat"; // e.g., Mon, 10:30 AM
  }
  // Same year, different week
  else if (date.year == now.year) {
    return "${DateFormat('d MMM').format(date)}, $timeFormat"; // e.g., 7 Apr, 10:30 AM
  }
  // Different year
  else {
    return "${DateFormat('d MMM y').format(date)}, $timeFormat"; // e.g., 7 Apr 2025, 10:30 AM
  }
}

String formatWhatsAppDate(DateTime date) {
  date = date.toLocal();
  // Adjust for 5:30 offset
  DateTime now = DateTime.now().toLocal();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = today.subtract(Duration(days: 1));
  DateTime tomorrow = today.add(Duration(days: 1));
  DateTime weekStart = today.subtract(Duration(days: today.weekday));
  DateTime weekEnd = weekStart.add(Duration(days: 7));

  String timeFormat = DateFormat('h:mm a').format(date);

  // Check if the date is today
  if (date.year == today.year &&
      date.month == today.month &&
      date.day == today.day) {
    return "Today, $timeFormat";
  }
  // Check if the date is yesterday
  else if (date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day) {
    return "Yesterday, $timeFormat";
  }
  // Check if the date is tomorrow
  else if (date.year == tomorrow.year &&
      date.month == tomorrow.month &&
      date.day == tomorrow.day) {
    return "Tomorrow, $timeFormat";
  }
  // Check if the date is within the current week (past or future)
  else if (date.isAfter(weekStart) && date.isBefore(weekEnd)) {
    return "${DateFormat('EEE').format(date)}, $timeFormat"; // e.g., Mon, 10:30 AM
  }
  // Same year, different week
  else if (date.year == now.year) {
    return "${DateFormat('d MMM').format(date)}, $timeFormat"; // e.g., 7 Apr, 10:30 AM
  }
  // Different year
  else {
    return "${DateFormat('d MMM y').format(date)}, $timeFormat"; // e.g., 7 Apr 2025, 10:30 AM
  }
}

String formatWhatsAppDate4(DateTime date) {
  // Remove toLocal() if not needed, or adjust properly
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = today.subtract(Duration(days: 1));
  DateTime tomorrow = today.add(Duration(days: 1));
  DateTime weekStart = today.subtract(Duration(days: today.weekday));
  DateTime weekEnd = weekStart.add(Duration(days: 7));

  String timeFormat = DateFormat('h:mm a').format(date);

  // Check if the date is today
  if (date.year == today.year &&
      date.month == today.month &&
      date.day == today.day) {
    return "Today, $timeFormat";
  }
  // Check if the date is yesterday
  else if (date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day) {
    return "Yesterday, $timeFormat";
  }
  // Check if the date is tomorrow
  else if (date.year == tomorrow.year &&
      date.month == tomorrow.month &&
      date.day == tomorrow.day) {
    return "Tomorrow, $timeFormat";
  }
  // Check if the date is within the current week (past or future)
  else if (date.isAfter(weekStart) && date.isBefore(weekEnd)) {
    return "${DateFormat('EEE').format(date)}, $timeFormat"; // Mon, 10:30 AM
  }
  // Same year, different week
  else if (date.year == now.year) {
    return "${DateFormat('d MMM').format(date)}, $timeFormat"; // 7 Apr, 10:30 AM
  }
  // Different year
  else {
    return "${DateFormat('d MMM y').format(date)}, $timeFormat"; // 7 Apr 2025, 10:30 AM
  }
}

String formatWhatsAppDateWithoutTime(DateTime date) {
  // Remove toLocal() if not needed, or adjust properly
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = today.subtract(Duration(days: 1));
  DateTime tomorrow = today.add(Duration(days: 1));
  DateTime weekStart = today.subtract(Duration(days: today.weekday));
  DateTime weekEnd = weekStart.add(Duration(days: 7));

  // String timeFormat = DateFormat('h:mm a').format(date);

  // Check if the date is today
  if (date.year == today.year &&
      date.month == today.month &&
      date.day == today.day) {
    return "Today";
  }
  // Check if the date is yesterday
  else if (date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day) {
    return "Yesterday";
  }
  // Check if the date is tomorrow
  else if (date.year == tomorrow.year &&
      date.month == tomorrow.month &&
      date.day == tomorrow.day) {
    return "Tomorrow";
  }
  // Check if the date is within the current week (past or future)
  else if (date.isAfter(weekStart) && date.isBefore(weekEnd)) {
    return "${DateFormat('EEEE').format(date)}"; // Mon, 10:30 AM
  }
  // Same year, different week
  else if (date.year == now.year) {
    return "${DateFormat('d MMM').format(date)}"; // 7 Apr, 10:30 AM
  }
  // Different year
  else {
    return "${DateFormat('d MMM y').format(date)}"; // 7 Apr 2025, 10:30 AM
  }
}

String formatWhatsAppDate3(DateTime date) {
  date = date.toLocal().add(Duration(hours: 5, minutes: 30));
  ;
  // Adjust for 5:30 offset
  DateTime now = DateTime.now().toLocal();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = today.subtract(Duration(days: 1));
  DateTime tomorrow = today.add(Duration(days: 1));
  DateTime weekStart = today.subtract(Duration(days: today.weekday));
  DateTime weekEnd = weekStart.add(Duration(days: 7));

  String timeFormat = DateFormat('h:mm a').format(date);

  // Check if the date is today
  if (date.year == today.year &&
      date.month == today.month &&
      date.day == today.day) {
    return "Today, $timeFormat";
  }
  // Check if the date is yesterday
  else if (date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day) {
    return "Yesterday, $timeFormat";
  }
  // Check if the date is tomorrow
  else if (date.year == tomorrow.year &&
      date.month == tomorrow.month &&
      date.day == tomorrow.day) {
    return "Tomorrow, $timeFormat";
  }
  // Check if the date is within the current week (past or future)
  else if (date.isAfter(weekStart) && date.isBefore(weekEnd)) {
    return "${DateFormat('EEE').format(date)}, $timeFormat"; // e.g., Mon, 10:30 AM
  }
  // Same year, different week
  else if (date.year == now.year) {
    return "${DateFormat('d MMM').format(date)}, $timeFormat"; // e.g., 7 Apr, 10:30 AM
  }
  // Different year
  else {
    return "${DateFormat('d MMM y').format(date)}, $timeFormat"; // e.g., 7 Apr 2025, 10:30 AM
  }
}

DateTime convertStringToDateTime(String dateString) {
  return DateTime.parse(dateString);
}

String getPreviousDate(int no, String type) {
  DateTime now = DateTime.now();
  DateTime previousDate;

  switch (type) {
    case 'days':
      previousDate = now.subtract(Duration(days: no));
      break;
    case 'months':
      previousDate = DateTime(now.year, now.month - no, now.day);
      break;
    case 'year':
      previousDate = DateTime(now.year - no, now.month, now.day);
      break;
    default:
      throw ArgumentError("Invalid type. Use 'days', 'months', or 'years'.");
  }

  return DateFormat('yyyy-MM-dd').format(previousDate);
}

List getLastTenUsers(List allUsers) {
  // Determine the number of users to take
  int numberOfUsersToTake = allUsers.length < 10 ? allUsers.length : 10;

  // Get the last `numberOfUsersToTake` users
  List lastUsers = allUsers.sublist(allUsers.length - numberOfUsersToTake);

  // Reverse the list
  return lastUsers.reversed.toList();
}

String getTimeBasedGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return "Good morning";
  } else if (hour < 16) {
    return "Good afternoon,";
  } else {
    return "Good evening,";
  }
}

Widget getProfile() {
  return AvatarProfile(
    fontsize: 18,
    name: userController.userName.value,
    width: 8,
    height: 10,
    background: userController.avatarBackGround.value,
    flag: true,
  );
}

int getRandomValue(list) {
  return Random().nextInt(list.length);
}

String avaterUrlPath(String name) {
  if (name.isEmpty) return "assets/avatars/a.svg";
  return "assets/avatars/" + name[0].toString().toLowerCase() + ".svg";
}

String formatMoneyIndian(String value, [String pattern = "0"]) {
  if (value.isEmpty) return pattern;
  try {
    // Remove commas if user input already has them
    final number = double.parse(value.replaceAll(',', ''));

    // Format using Indian locale
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '',
      decimalDigits: number.truncateToDouble() == number ? 0 : 2,
    );
    return formatter.format(number).trim();
  } catch (e) {
    return pattern;
  }
}

Future<void> updateWidgetSpendingCategories() async {
  try {
    final total = '₹${totalValue.value?.toStringAsFixed(2) ?? '0.00'}';
    final timestamp = getMonthlyRange();
    String categories = 'None';
    if (spendingsOnCategories.isNotEmpty) {
      categories = spendingsOnCategories
          .map((data) => '${data.category}: ₹${data.value.toStringAsFixed(2)}')
          .join('\n');
    }

    await HomeWidget.saveWidgetData<String>('total_spending', total);
    await HomeWidget.saveWidgetData<String>('categories', categories);
    await HomeWidget.saveWidgetData<String>('timestamp', timestamp);

    await HomeWidget.updateWidget(
      name: 'StakeplotWidgetProvider',
      androidName: 'StakeplotWidgetProvider',
      iOSName: 'StakeplotWidget',
    );
  } catch (e) {}
}

Future<void> updateWidget() async {
  final prefs = await SharedPreferences.getInstance();
  try {
    String toReceive = 'None: ₹0';
    String toPay = 'None: ₹0';

    if (lendAmountRemainders.isNotEmpty && lendAmountRemainders.first != null) {
      final data = lendAmountRemainders.first;
      toReceive =
          '${data["name"] ?? "Unknown"}: ₹${(data["amount"] ?? 0).toStringAsFixed(2)}';
    }
    if (dueAmountRemainders.isNotEmpty && dueAmountRemainders.first != null) {
      final data = dueAmountRemainders.first;
      toPay =
          '${data["name"] ?? "Unknown"}: ₹${(data["amount"] ?? 0).toStringAsFixed(2)}';
    }
    await prefs.setString('to_receive', toReceive);
    await prefs.setString('to_pay', toPay);
    // Save to HomeWidget (updates UserDefaults for iOS)
    await HomeWidget.saveWidgetData<String>('to_receive', toReceive);
    await HomeWidget.saveWidgetData<String>('to_pay', toPay);
    await HomeWidget.updateWidget(
      name: 'PayableWidgetProvider',
      androidName: 'PayableWidgetProvider',
      iOSName: 'PayableWidget',
    );
  } catch (e) {
    await prefs.setString('to_receive', 'Error');
    await prefs.setString('to_pay', 'Error');
    await HomeWidget.saveWidgetData<String>('to_receive', 'Error');
    await HomeWidget.saveWidgetData<String>('to_pay', 'Error');
    await HomeWidget.updateWidget(
      name: 'PayableWidgetProvider',
      androidName: 'PayableWidgetProvider',
      iOSName: 'PayableWidget',
    );
  }
}

String formatDate(String dateString) {
  DateTime date = DateTime.parse(dateString);
  return DateFormat('d MMM yyyy').format(date); // Format as Aug 2024
}

String getFullMonthName(int month) {
  const monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  return monthNames[month - 1];
}

String getMonthName(int month) {
  const months = [
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
  return months[month - 1];
}

String getMonthlyRange() {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final currentDay = now; // Use current date as the end date

  return '${_formatDateDonut(startOfMonth)} - ${_formatDateDonut(currentDay)}';
}

String _formatDateDonut(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')} ${getMonthName(date.month)} ${date.year}';
}

void showModalForPdfDownloadBankUiCheckBox(BuildContext context) {
  getPdgLoader.value = false;
  final double screenWidth = MediaQuery.of(context).size.width;

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Container(
            width: MediaQuery.of(context).size.width, // Full screen width
            // height:
            //     (MediaQuery.of(context).size.height / 2.5), // Full screen height
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        textStyle(
                            context: context,
                            text: "Select a Bank Account to Download Statement",
                            fontsize: 14,
                            fontWeight: FontWeight.w500),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.close_outlined,
                            size: 20,
                            color: AppColors.accentColor,
                          ),
                        )
                      ],
                    ),
                  ),
                  getBankAccountList(context),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: InkWell(
                        onTap: () async {
                          showModalForPdfDownload(context);
                        },
                        child: getButton(context, "Continue")),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget getBankAccountList(context, [fromPdf = true]) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
    // decoration: BoxDecoration(
    //    borderRadius: BorderRadius.circular(5),
    // color: Colors.white,
    // boxShadow: [
    //   BoxShadow(
    //     color: Color.fromRGBO(156, 156, 156, 0.25),
    //     blurRadius: 4,
    //     spreadRadius: 0,
    //     offset: Offset(0, 0),
    //   ),
    // ],
    // ),
    child: Column(
      children: bankAccountLinkedList.map((account) {
        return Obx(() => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(156, 156, 156, 0.25),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              child: ListTile(
                leading: SizedBox(
                  width: 40,
                  height: 40,
                  child: Image.network(
                    account["bankLogo"],
                    width: 22,
                    height: 22,
                  ),
                ),
                title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textStyle(
                        context: context,
                        text: account["bankName"],
                        fontsize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      textStyle(
                        context: context,
                        text: "Acc No:" + account["maskedAccNumber"],
                        fontsize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ]),
                trailing: Theme(
                  data: Theme.of(context).copyWith(
                    checkboxTheme: CheckboxThemeData(
                      shape: const CircleBorder(),
                    ),
                  ),
                  child: Checkbox(
                    value: (fromPdf
                            ? accountIdPdf.value
                            : accountSelected.value) ==
                        account["accountId"].toString(),
                    onChanged: (isChecked) {
                      if (isChecked == true) {
                        if (fromPdf)
                          accountIdPdf.value = account["accountId"].toString();
                        else
                          accountSelected.value =
                              account["accountId"].toString();
                      } else {
                        if (fromPdf)
                          accountIdPdf.value = "-";
                        else
                          accountSelected.value = "-";
                      }
                    },
                  ),
                ),
              ),
            ));
      }).toList(),
    ),
  );
}

Widget getBankAccountListForFilter(context, [fromPdf = true]) {
  return Row(
    children: bankAccountLinkedList.map((account) {
      return Obx(() {
        bool isSelected =
            (fromPdf ? accountIdPdf.value : accountSelected.value) ==
                account["accountId"].toString();

        Widget content = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Image.network(
                  account["bankLogo"],
                  width: 22,
                  height: 22,
                ),
              ),
              const SizedBox(width: 6),
              Center(
                child: textStyleImage(
                    context: context,
                    text:
                        "${account["maskedAccNumber"].toString().substring(account["maskedAccNumber"].toString().length - 6)}",
                    fontsize: 12,
                    fontWeight: FontWeight.w600,
                    c: isSelected ? AppColors.backgroundColor : AppColors.bg1),
              ),
            ],
          ),
        );

        return GestureDetector(
          onTap: () {
            String accId = account["accountId"].toString();
            if (isSelected) {
              if (fromPdf)
                accountIdPdf.value = "-";
              else
                accountSelected.value = "-";
            } else {
              if (fromPdf)
                accountIdPdf.value = accId;
              else
                accountSelected.value = accId;
            }

            // Optional: auto filter on tap
            onChanedAutoTransactionStatus(context);
          },
          child: isSelected
              ? Container(
                  margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: content,
                )
              : Container(
                  margin: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: DottedBorderBox(
                    dashWidth: 4,
                    space: 5,
                    dashHeight: 1,
                    color: AppColors.grey,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    child: content,
                  ),
                ),
        );
      });
    }).toList(),
  );
}

Widget getHeader(context, text) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        textStyle(
            context: context,
            text: text,
            fontsize: 16,
            c: AppColors.accentColor,
            fontWeight: FontWeight.w500),
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.close_outlined,
            size: 20,
            color: AppColors.accentColor,
          ),
        )
      ],
    ),
  );
}

void showModalForPdfDownload(BuildContext context) {
  getPdgLoader.value = false;
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Container(
          //height: MediaQuery.of(context).size.height / 2.4,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            color: Colors.white,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(child: Container()),
                getHeader(context, "Download Statement"),
                // const SizedBox(height: 20),
                getListItemListTile("30", "days", context),
                getListItemListTile("60", "days", context),
                getListItemListTile("6", "months", context),
                // getListItemListTile("1", "year", context),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: InkWell(
                      onTap: () async {
                        getPdgLoader.value = true;
                        getPdf(context, selectedValue, selectedValueType);
                      },
                      child: Obx(() => getPdgLoader.value
                          ? getspinner(context, "")
                          : getButton(context, "Continue"))),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget getListItemListTile(String no, String MorY, context) {
  return Container(
    width: MediaQuery.of(context).size.width,
    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.primaryColor, width: 0.2),
    ),
    child: Obx(() => ListTile(
          title: textStyle(
              context: context,
              text: no + " ${MorY}",
              fontsize: 15,
              fontWeight: FontWeight.w500),
          trailing: Radio<String>(
            value: no, // Assign a unique value for each radio button
            groupValue: selectedValue.value, // The currently selected value
            onChanged: (value) {
              selectedValue.value = value!;
              selectedValueType.value = MorY;
            },
          ),
        )),
  );
}

Widget getCheckBoxwithText(BuildContext context, String text) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
    child: Obx(() {
      bool isSelected = accountIdPdf.value == text;

      Widget content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: textStyleImage(
            context: context,
            text: text,
            fontsize: 15,
            fontWeight: FontWeight.w500,
            c: isSelected ? AppColors.backgroundColor : AppColors.bg1),
      );

      return GestureDetector(
        onTap: () {
          accountIdPdf.value = isSelected ? "-" : text;
        },
        child: isSelected
            ? Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: content,
              )
            : DottedBorderBox(
                dashWidth: 4,
                space: 5,
                dashHeight: 1,
                color: AppColors.grey,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: content,
                ),
              ),
      );
    }),
  );
}

Widget getCheckBoxwithText2(
    BuildContext context, String text, VoidCallback onTap) {
  return Container(
    height: 40,
    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
    child: Obx(() {
      bool isSelected = accountIdPdf.value == text;
      Widget content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        child: Center(
          child: textStyleImage(
            context: context,
            text: text,
            fontsize: 14,
            fontWeight: FontWeight.w500,
            c: isSelected ? AppColors.backgroundColor : AppColors.bg1,
          ),
        ),
      );

      return GestureDetector(
        onTap: () {
          // Toggle selection
          accountIdPdf.value = isSelected ? "-" : text;

          // Update search text if Credit, Debit, or Cash
          if (accountIdPdf.value.toLowerCase() == "credit" ||
              accountIdPdf.value.toLowerCase() == "debit" ||
              accountIdPdf.value == "Cash") {
            searchTextController.value = accountIdPdf.value.toLowerCase();
            searchController.text = accountIdPdf.value.toLowerCase();
          } else if (accountIdPdf.value == "-") {
            searchTextController.value = "";
            searchController.text = "";
          }

          // Apply filter and close dialog
          onChanedAutoTransactionStatus(context);
        },
        child: isSelected
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: content,
              )
            : Container(
                child: DottedBorderBox(
                  dashWidth: 4,
                  space: 5,
                  dashHeight: 1,
                  color: AppColors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: content,
                  ),
                ),
              ),
      );
    }),
  );
}

Widget filterTransaction(context) {
  return Column(
    children: [
      Container(
        color: AppColors.backgroundColor,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height /
            (bankAccountLinkedList.length <= 1 ? 16 : 14),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            getCheckBoxwithText2(context, "Credit", () {
              onChanedAutoTransactionStatus(context);
              // Navigator.pop(context);
            }),
            getCheckBoxwithText2(context, "Debit", () {
              onChanedAutoTransactionStatus(context);
              // Navigator.pop(context);
            }),
            getCheckBoxwithText2(context, "Cash", () {
              onChanedAutoTransactionStatus(context);
              // Navigator.pop(context);
            }),
            bankAccountLinkedList.length >= 2
                ? getBankAccountListForFilter(context, false)
                : SizedBox.shrink(),

            Obx(
              () => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: GestureDetector(
                  onTap: toggleAmountFilter, // ✅ Entire container is tappable
                  child: Container(
                    child: showAmountFilter.value
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Filter by Amount",
                                    style: FontManager().getTextStyle(
                                      context,
                                      lWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: showAmountFilter.value
                                          ? AppColors.backgroundColor
                                          : AppColors.accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : DottedBorderBox(
                            dashWidth: 4,
                            space: 5,
                            dashHeight: 1,
                            color: AppColors.grey,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (showAmountFilter.value)
                                    const Icon(Icons.check,
                                        size: 18, color: Colors.green),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Filter by Amount",
                                    style: FontManager().getTextStyle(
                                      context,
                                      lWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: AppColors.accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // --------- Date Button ---------
            Obx(
              () => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: GestureDetector(
                  onTap: toggleDateFilter, // ✅ Whole container is tappable
                  child: Container(
                    child: showDateFilter.value
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Filter by Date",
                                    style: FontManager().getTextStyle(
                                      context,
                                      lWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: showDateFilter.value
                                          ? AppColors.backgroundColor
                                          : AppColors.accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : DottedBorderBox(
                            dashWidth: 4,
                            space: 5,
                            dashHeight: 1,
                            color: AppColors.grey,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Filter by Date",
                                    style: FontManager().getTextStyle(
                                      context,
                                      lWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: AppColors.accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      Obx(() => showAmountFilter.value
          ? AmountRangeField()
          : const SizedBox.shrink()),
      Obx(() =>
          showDateFilter.value ? DateRangeField() : const SizedBox.shrink()),
      // AmountRangeField(),
      // DateRangeField()
    ],
  );
}

String getBankLogo() {
  for (var bankAccount in bankAccountLinkedList) {
    if (bankAccount['accountId'] == accountIdPdf.value) {
      return bankAccount['bankLogo'];
    }
  }

  return bankImage; // return null if no match found
}

double getProgressValue(String text) {
  if (text.toLowerCase().contains("same as last month")) {
    return 0.0;
  }

  final match = RegExp(r'([-+]?\d+)%').firstMatch(text);
  if (match != null) {
    final value = int.tryParse(match.group(1) ?? "0") ?? 0;
    double v = value <= 0
        ? 1
        : value <= 99
            ? value / 1.0
            : 100;
    return v;
    // return (value.abs().clamp(0, 100)) / 100;
  }

  return 0.0;
}

String getDaysLeftInMonth() {
  final now = DateTime.now();
  final nextMonth = (now.month < 12)
      ? DateTime(now.year, now.month + 1, 1)
      : DateTime(now.year + 1, 1, 1);
  final lastDayOfMonth = nextMonth.subtract(const Duration(days: 1));
  final daysLeft = lastDayOfMonth.day - now.day;
  return '$daysLeft days left';
}

List<Map<String, dynamic>> getthelist() {
  final lowerSearch = searchTextController.value.toLowerCase();
  // final lowerSearch = searchController.text.toLowerCase();

  final filtered = customCategoryList.where((e) {
    final name = e['name']?.toString().toLowerCase() ?? '';
    return name.contains(lowerSearch);
  }).toList();

  return filtered.reversed.toList().cast<Map<String, dynamic>>();
}

List<Map<String, dynamic>> getthelistAll() {
  String lowerSearch = "";
  return customCategoryList
      .where((e) {
        final name = e['name']?.toString().toLowerCase() ?? '';
        return name.contains(lowerSearch);
      })
      .toList()
      .cast<Map<String, dynamic>>();
}

String getFormattedDateForScreenTime() {
  final now = DateTime.now();
  return "${now.day.toString().padLeft(2, '0')}:${now.month.toString().padLeft(2, '0')}:${now.year}";
}

List<TextInputFormatter> allowDecimalInput({int decimalPlaces = 2}) {
  final regex = RegExp(r'^\d*\.?\d{0,' + decimalPlaces.toString() + r'}');
  return [
    FilteringTextInputFormatter.allow(regex),
  ];
}

int getDaysInCurrentMonth() {
  final now = DateTime.now();
  return DateTime(now.year, now.month + 1, 0).day;
}

const List<Map<String, dynamic>> reportOptions = [
  {
    'title': 'Helps us to understand the issue and look into it',
    'subtitle': 'Provide details about the problem',
    'isDescription': true
  },
  {'title': 'Not interested', 'subtitle': ''},
  {'title': 'Harassment or hateful speech', 'subtitle': ''},
  {'title': 'Self-harm or suicide', 'subtitle': ''},
  {'title': 'Adult content', 'subtitle': ''},
  {'title': 'False information or misleading', 'subtitle': ''},
  {'title': 'Spam', 'subtitle': ''},
];

String formatDateToIST(String dateStr) {
  try {
    DateTime utcDate = DateTime.parse(dateStr).toUtc();
    DateTime istDate = utcDate.add(Duration(hours: 5, minutes: 30));
    int hour = istDate.hour % 12 == 0 ? 12 : istDate.hour % 12;
    String minute = istDate.minute.toString().padLeft(2, '0');
    String period = istDate.hour >= 12 ? 'PM' : 'AM';
    String month = [
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
    ][istDate.month - 1];
    return "$hour:$minute $period · $month ${istDate.day}, ${istDate.year}";
  } catch (e) {
    return dateStr;
  }
}

getErrorBankLogo() => (context, error, stackTrace) => const Icon(
      Icons.account_balance,
      size: 30,
      color: AppColors.primaryColor,
    );

bool checkRangeofAmount(context, [bool f = true]) {
  double f1 =
      double.parse(minController.text.isNotEmpty ? minController.text : "0");
  double f2 =
      double.parse(maxController.text.isNotEmpty ? maxController.text : "0");
  if (f1 >= f2 && maxController.text.isNotEmpty) {
    if (f) snackBarCalledfail(context, SnackbarData().maxMinAmount);
    minController.text = "";
    maxController.text = "";
  }
  return f1 < f2;
}

bool getListIsValid(String s) {
  List sdc = ["credit", "debit", "cash"];
  return sdc.contains(s);
}

bool checkRangeofDate(BuildContext context, [bool f = true]) {
  String startDateText =
      startDateController.text.isNotEmpty ? startDateController.text : '';
  String endDateText =
      endDateController.text.isNotEmpty ? endDateController.text : '';
  if (startDateText.isEmpty || endDateText.isEmpty) {
    return true;
  }
  try {
    final DateFormat formatter = DateFormat('yyyy/MM/dd');
    final DateTime startDate = formatter.parse(startDateText);
    final DateTime endDate = formatter.parse(endDateText);

    if (endDate.isBefore(startDate) && endDateText.isNotEmpty) {
      if (f) {
        snackBarCalledfail(context, 'End date must be after start date');
      }
      startDateController.text = '';
      endDateController.text = '';
      return false;
    }
    return true;
  } catch (e) {
    if (f) {
      snackBarCalledfail(context, 'Invalid date format');
    }
    startDateController.text = '';
    endDateController.text = '';
    return false;
  }
}
