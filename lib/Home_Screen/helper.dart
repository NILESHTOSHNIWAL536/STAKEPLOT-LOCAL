import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transactionHistoryScreen.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/animated/pdf.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/bankinfo.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  date = date.toLocal().subtract(Duration(hours: 5, minutes: 30));;
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

String formatWhatsAppDate3(DateTime date) {
  date = date.toLocal().add(Duration(hours: 5, minutes: 30));;
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


int getRandomValue(list)
{
  return Random().nextInt(list.length);
}

String avaterUrlPath(String name)
{
    if(name.isEmpty)return "assets/avatars/a.svg";
    return "assets/avatars/"+name[0].toString().toLowerCase()+".svg";
}

String formatMoneyIndian(String value)
 {
  if (value.isEmpty) return '0';
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
    return '0';
  }
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
        return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              width: MediaQuery.of(context).size.width, // Full screen width
              height:( MediaQuery.of(context).size.height/2.5), // Full screen height
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
                ),
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
                  Center(child: Container(width: 50,height: 2.2,color:Colorcodes.claimColor,)),
                  Padding(
                    padding:const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        textStyle(
                            context: context,
                            text: "Select Bank Account",
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
                  const SizedBox(height: 20),
                  getBankAccountList(context),
                  SizedBox(height: 10,),
                 
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
        );
      },
    );
  }


 Widget getBankAccountList(context) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
    child: Column(
      children: bankAccountLinkedList.map((account) {
        return Obx(() => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryColor, width: 0.2),
              ),
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
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
                title: textStyle(
                  context: context,
                  text: account["bankName"],
                  fontsize: 15,
                  fontWeight: FontWeight.w500,
                ),
                trailing: Theme(
                  data: Theme.of(context).copyWith(
                    checkboxTheme: CheckboxThemeData(
                      shape: const CircleBorder(),
                    ),
                  ),
                  child: Checkbox(
                    value: accountIdPdf.value == account["accountId"].toString(),
                    onChanged: (isChecked) {
                      if (isChecked == true) {
                        accountIdPdf.value = account["accountId"].toString();
                      } else {
                        accountIdPdf.value = "-";
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



  Widget getHeader(context,text){
    return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    textStyle(
                        context: context,
                        text: text,
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
              );
  }

  void showModalForPdfDownload(BuildContext context) {
    getPdgLoader.value = false;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 2.4,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            color: Colors.white,
          ),
          child: Column(
            children: [
              Center(child: Container()),
              getHeader(context, "Download Statement"),
              const SizedBox(height: 20),
              getListItemListTile("30", "days", context),
              getListItemListTile("60", "days", context),
              getListItemListTile("6", "months", context),
              // getListItemListTile("1", "year", context),
              SizedBox(height: 10,),
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
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.primaryColor, width: 0.2),
    ),
    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
    child: Obx(() => ListTile(
          leading: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.credit_card),
          ),
          title: textStyle(
            context: context,
            text: text,
            fontsize: 15,
            fontWeight: FontWeight.w500,
          ),
          trailing: Theme(
            data: Theme.of(context).copyWith(
              checkboxTheme: CheckboxThemeData(
                shape: const CircleBorder(), // 👈 Circular shape
              ),
            ),
            child: Checkbox(
              value: accountIdPdf.value == text,
              onChanged: (isChecked) {
                if (isChecked == true) {
                  accountIdPdf.value = text;
                } else {
                  accountIdPdf.value = "-";
                }
              },
            ),
          ),
        )),
  );
}


 Widget filterTransaction(context)
 {
    return Container(
      height:  MediaQuery.of(context).size.height /(bankAccountLinkedList.length<=1? 3:2.2),
      child: SingleChildScrollView(
        child: Column(
          children: [
                   getHeader(context, "Select Filter"),
                   getCheckBoxwithText(context, "Credit"),
                   getCheckBoxwithText(context, "Debit"),
                   bankAccountLinkedList.length>=2? getBankAccountList(context):SizedBox.shrink(),
                   const SizedBox(height: 10),
                  
                   InkWell(
                    onTap: (){
                      if(accountIdPdf.value.toLowerCase().startsWith("credit") || accountIdPdf.value.toLowerCase().startsWith("debit"))
                      {
                        searchController.text=accountIdPdf.value.toLowerCase();
                      }
                      onChanedAutoTransactionStatus(context);
                      Navigator.pop(context);
                    },
                    child: getButton(context, "Apply Filter")),
          ],
        ),
      ),
    );
 }


 String getBankLogo()
  {
  for (var bankAccount in bankAccountLinkedList) {
    if (bankAccount['accountId'] == accountIdPdf.value) {
      return bankAccount['bankLogo'];
    }
  }

  return bankImage; // return null if no match found
}