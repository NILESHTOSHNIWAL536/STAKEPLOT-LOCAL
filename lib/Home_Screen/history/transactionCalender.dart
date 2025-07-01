import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:intl/intl.dart';

final TextEditingController searchController = TextEditingController();
FocusNode focusNodeSearchFeild = FocusNode();

class CalendarTransactionScreen extends StatefulWidget {
  
  const CalendarTransactionScreen({super.key});

  @override
  State<CalendarTransactionScreen> createState() =>
      _CalendarTransactionScreenState();
}

class _CalendarTransactionScreenState extends State<CalendarTransactionScreen> {
  final RxList<Map<String, dynamic>> filteredTransactions =
      RxList<Map<String, dynamic>>([]);
  final ScrollController scrollController = ScrollController();
  final ScrollController dateScrollController = ScrollController();
  final RxList<Map<String, dynamic>> dayWiseTransactions =
      RxList<Map<String, dynamic>>([]);

  final RxBool isDateSummaryView = false.obs;
  final RxString selectedDate = ''.obs;
  final RxString currentMonth = DateFormat('MMMM').format(DateTime.now()).obs;
  final RxInt currentYear = DateTime.now().year.obs;
  final RxDouble totalCredit = 0.0.obs;
  final RxDouble totalDebit = 0.0.obs;

  final RxList<Map<String, dynamic>> calendarData =
      RxList<Map<String, dynamic>>([]);
  final RxList<Map<String, dynamic>> selectedDateTransactions =
      RxList<Map<String, dynamic>>([]);

  @override
  void initState() {
    super.initState();
    _fetchDayWiseTransactions();
    
    scrollController.addListener(_onScroll);
  }

  // Future<void> _fetchDayWiseTransactions() async {
  //   final transactions = await getDayWiseTransactions(context);
  //   if (mounted) {
  //     setState(() {
  //       dayWiseTransactions.assignAll(transactions);
  //        _updateCalendarData();
  //        _calculateMonthlyTotals();
        
  //     });
  //   }
  // }
Future<void> _fetchDayWiseTransactions() async {
     final now = DateTime(currentYear.value,
      DateFormat('MMMM').parse(currentMonth.value).month, 1);
    final transactions = await getDayWiseTransactions(context);
    if (mounted) {
      setState(() {
       dayWiseTransactions.assignAll(transactions.where((data) {
        final date = convertStringToDateTime(data['date']);
        return date.month == now.month && date.year == now.year;
      }).toList());
         _updateCalendarData();
         _calculateMonthlyTotals();
        
      });
    }
  }
  void _updateCalendarData() {
    final now = DateTime(currentYear.value,
        DateFormat('MMMM').parse(currentMonth.value).month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    List<Map<String, dynamic>> data = [];
    // Add days of the month starting from 1
    for (int i = 1; i <= lastDayOfMonth.day; i++) {
      final date = DateTime(now.year, now.month, i);
      final apiDate = dayWiseTransactions.firstWhere(
        (data) =>
            convertStringToDateTime(data['date']).day == i &&
            convertStringToDateTime(data['date']).month == now.month,
        orElse: () => {
          'count': 0,
          'date': date.toIso8601String(),
          'creditAmount': 0,
          'debitAmount': 0
        },
      );
      data.add({
        'date': i,
        'dayOfWeek': DateFormat('EEE')
            .format(date)
            .toUpperCase(), // Add day abbreviation
        'transactionCount': apiDate['count'] ?? 0, // Map 'count' from API
        'fullDate': date.toIso8601String(),
      });
    }
    // Pad with empty days to complete the last row if needed
    int totalCells = ((lastDayOfMonth.day + 6) / 7).ceil() * 7;
    while (data.length < totalCells) {
      data.add({'date': null, 'dayOfWeek': '', 'transactionCount': 0, 'fullDate': null});
    }
    calendarData.assignAll(data);
  }

  void _onScroll() {
    // Handle scroll for pagination if needed
  }

  void _onDateTapped(Map<String, dynamic> dateData) async {
   
      selectedDate.value = dateData['date'].toString();
      isDateSummaryView.value = true;
      await _loadTransactionsForDate(dateData['fullDate']);
      _calculateDateTotals();
      _scrollToSelectedDate();
    
  }

  Future<void> _loadTransactionsForDate(String date) async {
    final transactions = await getDayWiseTransactionsForDate(context, date);
    if (mounted) {
      setState(() {
        selectedDateTransactions.assignAll(transactions
            .map((tx) => TransactionModel.fromJson(tx).toJson())
            .toList());
      });
       _calculateDateTotals();
    }
  }

  void _calculateMonthlyTotals() {
    totalCredit.value = dayWiseTransactions.fold(0.0, (sum, transaction) {
      final amount = transaction['creditAmount'] ?? 0;
      return sum + (amount is num ? amount.toDouble() : 0.0);
    });
    totalDebit.value = dayWiseTransactions.fold(0.0, (sum, transaction) {
      final amount = transaction['debitAmount'] ?? 0;
      return sum + (amount is num ? amount.toDouble() : 0.0);
    });
  }
 void _calculateDateTotals() {
    final selectedDay = int.tryParse(selectedDate.value) ?? 1;
    final now = DateTime(currentYear.value, DateFormat('MMMM').parse(currentMonth.value).month, 1);
    final selectedDateTime = DateTime(now.year, now.month, selectedDay);
    final dayTransactions = dayWiseTransactions.where((tx) {
      final txDate = convertStringToDateTime(tx['date']);
      return txDate.day == selectedDay && txDate.month == now.month && txDate.year == now.year;
    }).toList();

    totalCredit.value = dayTransactions.fold(0.0, (sum, transaction) {
      final amount = transaction['creditAmount'] ?? 0;
      return sum + (amount is num ? amount.toDouble() : 0.0);
    });
    totalDebit.value = dayTransactions.fold(0.0, (sum, transaction) {
      final amount = transaction['debitAmount'] ?? 0;
      return sum + (amount is num ? amount.toDouble() : 0.0);
    });
  }
  void _changeMonth(int delta) {
    final newMonth = DateTime(currentYear.value,
        DateFormat('MMMM').parse(currentMonth.value).month + delta, 1);
    currentMonth.value = DateFormat('MMMM').format(newMonth);
    currentYear.value = newMonth.year;
    selectedDate.value = ''; // Reset selected date when changing months
  isDateSummaryView.value = false; 
    _fetchDayWiseTransactionsForMonth(newMonth);
  }

  Future<void> _fetchDayWiseTransactionsForMonth(DateTime month) async {
    final transactions = await getDayWiseTransactions(context);
    if (mounted) {
      setState(() {
        dayWiseTransactions.assignAll(transactions.where((data) {
          final date = convertStringToDateTime(data['date']);
          return date.month == month.month && date.year == month.year;
        }).toList());
        _updateCalendarData();
        _calculateMonthlyTotals();
      });
    }
  }
 void _scrollToSelectedDate() {
  final selectedDay = int.tryParse(selectedDate.value) ?? 1;
  final now = DateTime(currentYear.value, DateFormat('MMMM').parse(currentMonth.value).month, 1);
  final index = selectedDay - 1; // 0-based index
  final totalDays = DateTime(now.year, now.month + 1, 0).day;

  if (index >= 0 && index < totalDays) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = 58.0; // Approximate width including margin (50 + 8)
    final maxScrollExtent = (totalDays * itemWidth) - screenWidth;
    final targetPosition = index * itemWidth;

    // Center the selected date in the view
    final centeredOffset = (targetPosition - (screenWidth / 2) + (itemWidth / 2)).clamp(0.0, maxScrollExtent);

    dateScrollController.animateTo(
      centeredOffset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() => isDateSummaryView.value
                  ? _buildDateBreakdownView(context)
                  : _buildCalendarView(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(BuildContext context) {
     final now = DateTime.now();
  final isCurrentMonth = currentYear.value == now.year &&
      currentMonth.value == DateFormat('MMMM').format(now);
    return Column(
      children: [
        // Month Header with Navigation
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: AppColors.accentColor),
                onPressed: () => _changeMonth(-1),
              ),
              Obx(() => Text(
                    '$currentMonth $currentYear',
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 18,
                      lWeight: FontWeight.w600,
                      color: AppColors.accentColor,
                    ),
                  )),
              IconButton(
              icon: Icon(
                Icons.chevron_right,
                color: isCurrentMonth
                    ? AppColors.grey
                    : AppColors.accentColor,
              ),
              onPressed: isCurrentMonth ? null : () => _changeMonth(1),
            ),
            ],
          ),
        ),

        // Credit/Debit Summary
        _buildCreditDebitSummary(context),

        // Calendar Grid
        Expanded(
          child: Obx(() => GridView.builder(
                padding: EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 8,

                ),
                itemCount: calendarData.length,
                itemBuilder: (context, index) {
                  final dateData = calendarData[index];
                  return _buildCalendarDateItem(context, dateData);
                },
              )),
        ),
      ],
    );
  }

  Widget _buildCalendarDateItem(
      BuildContext context, Map<String, dynamic> dateData) {
    return GestureDetector(
      onTap: () => _onDateTapped(dateData),
      child: Container(
        decoration: BoxDecoration(
          color: dateData['date'] != null
              ? AppColors.backgroundColor
              : AppColors.backgroundColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          border: dateData['date'] != null
              ? Border.all(color: AppColors.accentColor.withOpacity(0.1))
              : null,
          boxShadow: [
            BoxShadow(
              color: AppColors.backgroundColor,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dateData['date']?.toString().padLeft(2, '0') ?? '',
              style: FontManager().getTextStyle(
                context,
                fontSize: 16,
                lWeight: FontWeight.w800,
                color: dateData['date'] != null
                    ? AppColors.finSpaceColor
                    : AppColors.likesharecommentCount,
              ),
            ),
            SizedBox(height: 2),
            if (dateData['date'] != null)
              Text(
                dateData['dayOfWeek'], // Display day abbreviation
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 14,
                  color: AppColors.grey,
                ),
              ),
              SizedBox(height: 2),
             if (dateData['date'] != null) _buildDottedDivider(),
            SizedBox(height: 2),
            if (dateData['date'] != null)
              Text(
                '${dateData['transactionCount']} tnxs',
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 16,
                  color: AppColors.accentColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBreakdownView(BuildContext context) {
     final now = DateTime(currentYear.value, DateFormat('MMMM').parse(currentMonth.value).month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final totalDays = lastDayOfMonth.day;
    return Column(
      children: [
        // Date Navigation with Back Button
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.accentColor),
                onPressed: () {
                  isDateSummaryView.value = false;
                  selectedDate.value = '';
                },
              ),
              Obx(() => Text(
                    'Date: $selectedDate, $currentMonth $currentYear',
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 16,
                      lWeight: FontWeight.w600,
                      color: AppColors.accentColor,
                    ),
                  )),
              SizedBox.shrink(), // Placeholder for symmetry
            ],
          ),
        ),
        Container(
          height: 60,
          child:  ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: totalDays,
                itemBuilder: (context, index) {
              final day = (index + 1).toString();
              final isSelected = selectedDate.value == day;
              final date = DateTime(now.year, now.month, index + 1);
              final apiDate = dayWiseTransactions.firstWhere(
                (data) => convertStringToDateTime(data['date']).day == (index + 1) && convertStringToDateTime(data['date']).month == now.month,
                orElse: () => {'count': 0, 'date': date.toIso8601String(), 'creditAmount': 0, 'debitAmount': 0},
              );
                  return GestureDetector(
                    onTap: () {
                  selectedDate.value = day;
                  _loadTransactionsForDate(apiDate['date']);
                  _scrollToSelectedDate();
                },
                    child: Container(
                      width: 50,
                      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.primaryColor : AppColors.bg5,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.accentColor,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
        ),

        // Credit/Debit Summary
        _buildCreditDebitSummary(context),

        // Transaction List
        Expanded(
          child: Obx(() {
          if (selectedDateTransactions.isEmpty) {
              return Center(
                child:  Column(
                  children: [
                    AvatarProfileImage(
                                          url: "assets/icons/Home-page/nullTransactions.svg",
                                          height: 5,
                                          width: 5,
                                        ),
                  
          
                    Text('No transactions found on this selected date',
                        style: FontManager().getTextStyle(context,
                            lWeight: FontWeight.w500,
                            fontSize: 14,
                            color: AppColors.accentColor)),
                  ])
              );
            }
            return ListView.builder(
                controller: scrollController,
                itemCount: selectedDateTransactions.length,
                itemBuilder: (context, index) {
                  final transactionData = selectedDateTransactions[index];
                  final transaction =
                      TransactionModel.fromJson(transactionData);
                  return historyTransactions(
                    transaction,
                    transaction.transactionTimestamp.toIso8601String(),
                    index,
                    context,
                    true,
                    true,
                  );
                },
              );
          }
          ),
        ),
      ],
    );
  }
  Widget _buildDottedDivider() {
    return Container(
      height: 1,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final boxWidth = constraints.constrainWidth();
          final dashWidth = 2.0;
          final dashHeight = 1.0;
          final dashCount = (boxWidth / (2 * dashWidth)).floor();
          return Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: List.generate(dashCount, (_) {
              return SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.finSpaceColor.withOpacity(0.4),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildCreditDebitSummary(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Credit',
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 14,
                  color: AppColors.accentColor,
                ),
              ),
             
             
              SizedBox(width: 16),
              Obx(() => Text(
                    '₹ ${totalCredit.value.toStringAsFixed(0)}',
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 14,
                      lWeight: FontWeight.w600,
                      color: AppColors.accentColor,
                    ),
                  )),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Debit',
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 14,
                  color: AppColors.accentColor,
                ),
              ),
             
             
              SizedBox(width: 16),
              Obx(() => Text(
                    '₹ ${totalDebit.value.toStringAsFixed(0)}',
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 14,
                      lWeight: FontWeight.w600,
                      color: AppColors.accentColor,
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    focusNodeSearchFeild.dispose();
    super.dispose();
  }
}
