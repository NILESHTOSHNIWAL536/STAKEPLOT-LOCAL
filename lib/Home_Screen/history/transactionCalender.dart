import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/dotted_Border.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionHistoryScreen.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/model/autopay_model.dart';
import 'package:get/get.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:intl/intl.dart';

// final TextEditingController searchController = TextEditingController();
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
  final RxBool isTap = false.obs;
  final RxMap<String, dynamic> selectedDateFormat = <String, dynamic>{}.obs;
  final RxString currentMonth = DateFormat('MMMM').format(DateTime.now()).obs;
  final RxInt currentYear = DateTime.now().year.obs;
  final RxDouble totalCredit = 0.0.obs;
  final RxDouble totalDebit = 0.0.obs;

  final RxList<Map<String, dynamic>> calendarData =
      RxList<Map<String, dynamic>>([]);
  final RxList<Map<String, dynamic>> selectedDateTransactions =
      RxList<Map<String, dynamic>>([]);
  final RxInt startYear =
      (DateTime.now().year - 1).obs; // Start from previous year
  final RxInt endYear = (DateTime.now().year + 1).obs;
  List dateList = [];
  final RxList<CardData> cards = <CardData>[].obs;

  @override
  void initState() {
    super.initState();
    _fetchDayWiseTransactions();
    _generateDateList();
    _fetchAutoPayData();
    scrollController.addListener(_onScroll);
    dateScrollController.addListener(_onDateScroll);
  }

 Future<void> _fetchAutoPayData() async {
  final fetchedCards = await getAutoPayInfo();
  if (mounted) {
    setState(() {
      cards.assignAll(fetchedCards);
    });
  }
}

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
    // final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final isCurrentMonth =
        now.year == DateTime.now().year && now.month == DateTime.now().month;
    final lastDayOfMonth = // Limit to current day for current month
        DateTime(now.year, now.month + 1, 0).day;
    List<Map<String, dynamic>> data = [];
    // Add days of the month starting from 1
    for (int i = 1; i <= lastDayOfMonth; i++) {
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
    int totalCells = ((lastDayOfMonth + 6) / 7).ceil() * 7;
    while (data.length < totalCells) {
      data.add({
        'date': null,
        'dayOfWeek': '',
        'transactionCount': 0,
        'fullDate': null
      });
    }
    calendarData.assignAll(data);
  }

  void _onScroll() {
    // Handle scroll for pagination if needed
  }
  void _onDateScroll() {
    if (dateScrollController.position.pixels >=
        dateScrollController.position.maxScrollExtent - 200) {
      // Load next year's data when nearing the end
      endYear.value++;
      _fetchDayWiseTransactionsForRange();
    } else if (dateScrollController.position.pixels <= 200) {
      // Load previous year's data when nearing the start
      startYear.value--;
      _fetchDayWiseTransactionsForRange();
    }
  }

  void _onDateTapped(Map<String, dynamic> dateData) async {
    selectedDate.value = dateData['date'].toString();
    isDateSummaryView.value = true;
    selectedDateFormat.value = dateData;
    isTap.value = true;
    await _loadTransactionsForDate(dateData['fullDate']);
    if (dateList.isEmpty) _generateDateList();
    _calculateDateTotals();
    int index = dateList
        .indexWhere((dateObj) => dateObj['fullDate'] == dateData['fullDate']);
    _scrollToIndex(index, true);
  }

  Future<void> _loadTransactionsForDate(String date) async {
    final transactions = await getDayWiseTransactionsForDate(context, date);
    if (mounted) {
      // setState(() {
      selectedDateTransactions.assignAll(transactions
          .map((tx) => TransactionModel.fromJson(tx).toJson())
          .toList());
      // });
      _calculateDateTotals();
    }
  }

  Future<void> _fetchDayWiseTransactionsForMonth(DateTime month) async {
    final transactions = await getDayWiseTransactions(context);
    if (mounted) {
      // setState(() {
      dayWiseTransactions.assignAll(transactions.where((data) {
        final date = convertStringToDateTime(data['date']);
        return date.month == month.month && date.year == month.year;
      }).toList());
      _updateCalendarData();
      _calculateMonthlyTotals();
      // });
    }
  }

  // New method to fetch transactions for the entire date range
  Future<void> _fetchDayWiseTransactionsForRange() async {
    final transactions = await getDayWiseTransactions(context);
    if (mounted) {
      setState(() {
        dayWiseTransactions.assignAll(transactions.where((data) {
          final date = convertStringToDateTime(data['date']);
          return date.year >= startYear.value && date.year <= endYear.value;
        }).toList());
      });
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
    final now = DateTime(currentYear.value,
        DateFormat('MMMM').parse(currentMonth.value).month, 1);
    final dayTransactions = dayWiseTransactions.where((tx) {
      final txDate = convertStringToDateTime(tx['date']);
      return txDate.day == selectedDay &&
          txDate.month == now.month &&
          txDate.year == now.year;
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
    selectedDateFormat.clear(); // Reset selected date when changing months
    isDateSummaryView.value = false;
    _fetchDayWiseTransactionsForMonth(newMonth);
  }

  String formatMonthYear(String isoDateString) {
    if (isoDateString.trim().isEmpty) return '';
    final date =
        DateTime.parse(isoDateString).toLocal(); // Adjusts to local timezone
    final month = getFullMonthName(date.month);
    final year = date.year;
    return '$month $year';
  }

  // Future<void> _fetchDayWiseTransactionsForMonth(DateTime month) async {
  //   final transactions = await getDayWiseTransactions(context);
  //   if (mounted) {
  //     setState(() {
  //       dayWiseTransactions.assignAll(transactions.where((data) {
  //         final date = convertStringToDateTime(data['date']);
  //         return date.month == month.month && date.year == month.year;
  //       }).toList());
  //       _updateCalendarData();
  //       _calculateMonthlyTotals();
  //     });
  //   }
  // }
// Helper method to generate the date list including previous and next month's dates
  void _generateDateList() {
    final List<Map<String, dynamic>> tempDateList = [];

    final DateTime today = DateTime.now();

    late DateTime startDate;
    final String isoDate = userController.firstFetchedDate.value.trim();

    if (isoDate == '') {
      // Default to 1 year before today
      startDate = DateTime(today.year - 1, today.month, today.day);
    } else {
      final parsedDate =
          DateTime.parse(isoDate).toLocal(); // Converts from UTC to local
      startDate =
          DateTime(parsedDate.year, parsedDate.month, 1); // Start of that month
    }

    DateTime currentDate = startDate;

    while (currentDate.isBefore(today) || currentDate.isAtSameMomentAs(today)) {
      final apiDate = dayWiseTransactions.firstWhere(
        (data) {
          final dataDate = convertStringToDateTime(data['date']);
          return dataDate.year == currentDate.year &&
              dataDate.month == currentDate.month &&
              dataDate.day == currentDate.day;
        },
        orElse: () => {
          'count': 0,
          'date': currentDate.toIso8601String(),
          'creditAmount': 0,
          'debitAmount': 0,
        },
      );

      tempDateList.add({
        'day': currentDate.day,
        'month': currentDate.month,
        'year': currentDate.year,
        'fullDate': currentDate.toIso8601String(),
        'transactionCount': apiDate['count'] ?? 0,
      });

      currentDate = currentDate.add(const Duration(days: 1));
    }

    tempDateList.sort((a, b) =>
        DateTime.parse(a['fullDate']).compareTo(DateTime.parse(b['fullDate'])));

    dateList = tempDateList;
  }

  void _generateDateList2() {
    final now = DateTime(currentYear.value,
        DateFormat('MMMM').parse(currentMonth.value).month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final prevMonth =
        DateTime(now.year, now.month, 0); // Last day of previous month
    final daysInPrevMonth = prevMonth.day;
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    // List<Map<String, dynamic>> dateList = [];

    // Add 5 days from the previous month for context
    for (int i = daysInPrevMonth - 27; i <= daysInPrevMonth; i++) {
      if (i >= 1) {
        final date = DateTime(prevMonth.year, prevMonth.month, i);
        final apiDate = dayWiseTransactions.firstWhere(
          (data) =>
              convertStringToDateTime(data['date']).day == i &&
              convertStringToDateTime(data['date']).month == prevMonth.month &&
              convertStringToDateTime(data['date']).year == prevMonth.year,
          orElse: () => {
            'count': 0,
            'date': date.toIso8601String(),
            'creditAmount': 0,
            'debitAmount': 0
          },
        );
        dateList.add({
          'day': i,
          'month': prevMonth.month,
          'year': prevMonth.year,
          'fullDate': date.toIso8601String(),
          'transactionCount': apiDate['count'] ?? 0,
        });
      }
    }

    // Add all dates of the current month
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(now.year, now.month, i);
      final apiDate = dayWiseTransactions.firstWhere(
        (data) =>
            convertStringToDateTime(data['date']).day == i &&
            convertStringToDateTime(data['date']).month == now.month &&
            convertStringToDateTime(data['date']).year == now.year,
        orElse: () => {
          'count': 0,
          'date': date.toIso8601String(),
          'creditAmount': 0,
          'debitAmount': 0
        },
      );
      dateList.add({
        'day': i,
        'month': now.month,
        'year': now.year,
        'fullDate': date.toIso8601String(),
        'transactionCount': apiDate['count'] ?? 0,
      });
    }

    // Add 5 days from the next month for context
    for (int i = 1; i <= 5; i++) {
      final date = DateTime(nextMonth.year, nextMonth.month, i);
      final apiDate = dayWiseTransactions.firstWhere(
        (data) =>
            convertStringToDateTime(data['date']).day == i &&
            convertStringToDateTime(data['date']).month == nextMonth.month &&
            convertStringToDateTime(data['date']).year == nextMonth.year,
        orElse: () => {
          'count': 0,
          'date': date.toIso8601String(),
          'creditAmount': 0,
          'debitAmount': 0
        },
      );
      dateList.add({
        'day': i,
        'month': nextMonth.month,
        'year': nextMonth.year,
        'fullDate': date.toIso8601String(),
        'transactionCount': apiDate['count'] ?? 0,
      });
    }

    // return dateList;
  }

// Updated _scrollToSelectedDate
  void _scrollToSelectedDate() {
    final selectedDay = int.tryParse(selectedDate.value) ?? 1;
    final now = DateTime(currentYear.value,
        DateFormat('MMMM').parse(currentMonth.value).month, 1);

    // Find the index of the selected date in the current month
    final selectedIndex = dateList.indexWhere((date) =>
        date['day'] == selectedDay &&
        date['month'] == now.month &&
        date['year'] == now.year);

    if (selectedIndex >= 0) {
      final screenWidth = MediaQuery.of(context).size.width;
      const itemWidth = 48.0; // 40px width + 8px margin (4px left + 4px right)
      final maxScrollExtent = (dateList.length * itemWidth) - screenWidth;
      final targetPosition = selectedIndex * itemWidth;

      // Center the selected date in the view
      final centeredOffset =
          (targetPosition - (screenWidth / 2) + (itemWidth / 2))
              .clamp(0.0, maxScrollExtent);

      dateScrollController.jumpTo(0); // Reset to avoid offset stacking
      dateScrollController.animateTo(
        centeredOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {}
  }

  Widget _buildDateBreakdownView(BuildContext context) {
    final now = DateTime(currentYear.value,
        DateFormat('MMMM').parse(currentMonth.value).month, 1);

    return Column(
      children: [
        // Date Navigation with Back Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: AppColors.accentColor),
                onPressed: () {
                  isDateSummaryView.value = false;
                  selectedDate.value = '';
                  selectedDateFormat.clear();
                  _calculateMonthlyTotals();
                  _updateCalendarData();
                },
              ),
              Obx(() => Text(
                    '$selectedDate, $currentMonth ${currentYear.value}',
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 16,
                      lWeight: FontWeight.w600,
                      color: AppColors.accentColor,
                    ),
                  )),
              const SizedBox.shrink(), // Placeholder for symmetry
            ],
          ),
        ),
        getListOfDateScroll(now),

        _buildCreditDebitSummary(context),
        Container(
          height: MediaQuery.of(context).size.height / 1.69,
          child: Obx(() {
            if (selectedDateTransactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AvatarProfileImage(
                      url: "assets/icons/Home-page/nullTransactions.svg",
                      height: 5,
                      width: 5,
                    ),
                    Text(
                      'No transactions found on this selected date',
                      style: FontManager().getTextStyle(
                        context,
                        lWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.accentColor,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              controller: scrollController,
              itemCount: selectedDateTransactions.length,
              itemBuilder: (context, index) {
                final transactionData = selectedDateTransactions[index];
                final transaction = TransactionModel.fromJson(transactionData);
                return GestureDetector(
                  child: HistoryTransactions(
                    transaction: transaction,
                    date: transaction.transactionTimestamp.toIso8601String(),
                    index: index,
                    context: context,
                    hideReview: true,
                    isExpanded: true,
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              // color: Colors,
              height: MediaQuery.sizeOf(context).height / 1.35,
              child: Obx(() => isDateSummaryView.value
                  ? _buildDateBreakdownView(context)
                  : _buildCalendarView(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget getListOfDateScroll(DateTime now) {
    return Container(
      height: MediaQuery.sizeOf(context).height / 18,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          // Scrollable date list

          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              _updateCenterSelection(dateList);
              if (notification is ScrollEndNotification) {
                _snapToCenter(dateList);
              }
              return true;
            },
            child: ListView.builder(
              controller: dateScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: dateList.length,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(context).width / 2 -
                    20, // Center first and last items
              ),
              itemBuilder: (context, index) {
                final dateData = dateList[index];
                final day = dateData['day'].toString();
                final isSelected = selectedDate.value == day &&
                    dateData['month'] == now.month &&
                    dateData['year'] == currentYear.value;
                // Disable future dates in current month
                final isFutureDate = dateData['year'] == DateTime.now().year &&
                    dateData['month'] == DateTime.now().month &&
                    dateData['day'] > DateTime.now().day;

                return GestureDetector(
                  onTap:
                      isFutureDate ? null : () => _scrollToIndex(index, false),
                  child: Container(
                    width: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color:
                          AppColors.backgroundColor, // Remove background color
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        day,
                        style: FontManager().getTextStyle(
                          context,
                          fontSize: 16,
                          lWeight: FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : AppColors.historyCalenderText,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Fixed center highlight indicator

          Positioned.fill(
            child: Center(
              child: Container(
                width: 40,
                height: double.infinity,
                child: Center(
                  child: Text(
                    selectedDate.value,
                    style: FontManager().getTextStyle(context,
                        fontSize: 16,
                        lWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(75, 77, 115, 0.25),
                      blurRadius: 2,
                      offset: Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Helper method to check if item is in center
  bool _isItemInCenter(int index) {
    if (!dateScrollController.hasClients) return index == 0;

    final itemWidth = 48.0; // 40 width + 8 margin
    final screenWidth = MediaQuery.sizeOf(context).width;
    final centerPosition = screenWidth / 2;
    final scrollOffset = dateScrollController.offset;
    final padding = screenWidth / 2 - 20;

    final itemPosition = (index * itemWidth) + (itemWidth / 2) + padding;
    final itemScreenPosition = itemPosition - scrollOffset;

    return (itemScreenPosition - centerPosition).abs() < itemWidth / 2;
  }

// Method to update selection based on center item
  void _updateCenterSelection(dateList) {
    if (!dateScrollController.hasClients) return;

    final itemWidth = 48.0;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final centerPosition = screenWidth / 2;
    final scrollOffset = dateScrollController.offset;
    final padding = screenWidth / 2 - 20;

    // Find which item is currently in center
    for (int i = 0; i < dateList.length; i++) {
      final itemPosition = (i * itemWidth) + (itemWidth / 2) + padding;
      final itemScreenPosition = itemPosition - scrollOffset;

      if ((itemScreenPosition - centerPosition).abs() < itemWidth / 2) {
        final dateData = dateList[i];

        // Update selection only if it's different
        if (selectedDate.value != dateData['day'].toString()) {
          selectedDate.value = dateData['day'].toString();
          final selectedDateTime = DateTime.parse(dateData['fullDate']);
          currentMonth.value = DateFormat('MMMM').format(selectedDateTime);
          currentYear.value = selectedDateTime.year;
          _loadTransactionsForDate(isTap.value
              ? selectedDateFormat['fullDate']
              : dateData['fullDate']);
        }
        break;
      }
    }
    _calculateDateTotals();
  }

// Method to snap to center
  void _snapToCenter(dateList) {
    if (!dateScrollController.hasClients) return;

    final itemWidth = 48.0;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final centerPosition = screenWidth / 2;
    final currentOffset = dateScrollController.offset;
    final padding = screenWidth / 2 - 20;

    // Find the closest item to center
    int closestIndex = 0;
    double closestDistance = double.infinity;

    for (int i = 0; i < dateList.length; i++) {
      final itemPosition = (i * itemWidth) + (itemWidth / 2) + padding;
      final itemScreenPosition = itemPosition - currentOffset;
      final distance = (itemScreenPosition - centerPosition).abs();

      if (distance < closestDistance) {
        closestDistance = distance;
        closestIndex = i;
      }
    }

    _scrollToIndex(closestIndex);
  }

// Method to scroll to specific index
  void _scrollToIndex(int index, [bool flag = false]) {
    isTap.value = flag;
    if (!dateScrollController.hasClients) return;
    final itemWidth = 48.0;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final padding = screenWidth / 2 - 20;
    final targetOffset =
        (index * itemWidth) + padding - (screenWidth / 2) + (itemWidth / 2);
    flag
        ? dateScrollController.jumpTo(targetOffset)
        : dateScrollController.animateTo(
            targetOffset.clamp(
                0.0, dateScrollController.position.maxScrollExtent),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
  }

  Widget _buildCalendarView(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth = currentYear.value == now.year &&
        currentMonth.value == DateFormat('MMMM').format(now);

    bool isPrevMonth = formatMonthYear(userController.firstFetchedDate.value) ==
        '$currentMonth $currentYear';

    return Column(
      children: [
        // Month Header with Navigation
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left,
                    color:
                        isPrevMonth ? AppColors.grey : AppColors.accentColor),
                onPressed: () => isPrevMonth ? null : _changeMonth(-1),
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
                  color:
                      isCurrentMonth ? AppColors.grey : AppColors.accentColor,
                ),
                onPressed: isCurrentMonth ? null : () => _changeMonth(1),
              ),
            ],
          ),
        ),

        // Credit/Debit Summary
        _buildCreditDebitSummary(context),

        // Calendar Grid
        Container(
          height: MediaQuery.of(context).size.height / 1.3,
          child: Obx(() => GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: .8,
                  crossAxisSpacing: 7,
                  mainAxisSpacing: 7,
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
Widget _buildCalendarDateItem(BuildContext context, Map<String, dynamic> dateData) {
  if (dateData['date'] == null || dateData['fullDate'] == null) {
    return Container();
  }

  String displayText = '${dateData['transactionCount']} tnxs';
  final parsedDate = DateTime.parse(dateData['fullDate']);
  final formattedDate = "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";

  // Calculate fontScale for responsive sizing
  final screenSize = MediaQuery.of(context).size;
  final fontScale = screenSize.width / 375;

  // Find active CardData with matching nextReminderAt
  final activeCard = cards.firstWhere(
    (card) {
      if (card.isActive != true || card.nextReminderAt == null) return false;
      final reminderDate = card.nextReminderAt!;
      final formattedReminderDate = "${reminderDate.year}-${reminderDate.month.toString().padLeft(2, '0')}-${reminderDate.day.toString().padLeft(2, '0')}";
      bool isMatch = formattedReminderDate == formattedDate;
      return isMatch;
    },
    orElse: () => CardData(
      id: '',
      title: '',
      amount: '',
      date: '',
      occuranceDate: [],
      frequency: '',
      narration: '',
      gradient: const LinearGradient(colors: [Colors.transparent, Colors.transparent]),

      isActive: false,
      isDaily:false
    ),
  );

  return GestureDetector(
    onTap: () => _onDateTapped(dateData),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(27),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(75, 77, 115, 0.25),
            blurRadius: 2,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 7),
          Text(
            dateData['date'].toString().padLeft(2, '0'),
            style: FontManager().getTextStyle(
              context,
              fontSize: 16,
              lWeight: FontWeight.w800,
              color: AppColors.finSpaceColor,
            ),
          ),
          const SizedBox(height: 2),
          Divider(color: Colorcodes.greyLight),
          const SizedBox(height: 2),

          (activeCard.isActive == true ||  activeCard.isDaily==true)
              ? 
              Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        // SizedBox(width: 4 * fontScale),
                      chatAvatartImage(
                        url: 'assets/icons/Home-page/autoPayDate.svg',
                        height: 60 * fontScale, // Reduced size to fit calendar item
                        width: 60 * fontScale,
                      ),
                     SizedBox(width: 2),  // Space between icon and text
                      Flexible(
                        child: Text(
                          activeCard.title.length > 4 ? activeCard.title.substring(0, 4) : activeCard.title,
                          style: FontManager().getTextStyle(
                            context,
                            fontSize: 12,
                            color: AppColors.accentColor,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
              )
              : Text(
                  displayText,
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 12,
                    color: AppColors.accentColor,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
          SizedBox(height: 7),
        ],
      ),
    ),
  );
}

  // Widget _buildCalendarDateItem(
  //     BuildContext context, Map<String, dynamic> dateData) {
  //   return GestureDetector(
  //     onTap: () => _onDateTapped(dateData),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         color: dateData['date'] != null
  //             ? AppColors.backgroundColor
  //             : AppColors.backgroundColor,
  //         borderRadius: BorderRadius.circular(27),
  //         boxShadow: dateData['date'] != null
  //             ? [
  //                 const BoxShadow(
  //                   color: Color.fromRGBO(75, 77, 115, 0.25),
  //                   blurRadius: 2,
  //                   offset: Offset(0, 2),
  //                   spreadRadius: 0,
  //                 ),
  //               ]
  //             : null,
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           SizedBox(height: 7),
  //           Text(
  //             dateData['date']?.toString().padLeft(2, '0') ?? '',
  //             style: FontManager().getTextStyle(
  //               context,
  //               fontSize: 16,
  //               lWeight: FontWeight.w800,
  //               color: dateData['date'] != null
  //                   ? AppColors.finSpaceColor
  //                   : AppColors.likesharecommentCount,
  //             ),
  //           ),
  //           SizedBox(height: 2),
  //           if (dateData['date'] != null)
  //             Divider(
  //               color: Colorcodes.greyLight,
  //             ),
  //           SizedBox(height: 2),
  //           if (dateData['date'] != null)
  //             Text(
  //               '${dateData['transactionCount']} tnxs',
  //               style: FontManager().getTextStyle(
  //                 context,
  //                 fontSize: 12,
  //                 color: AppColors.accentColor,
  //               ),
  //             ),
  //           SizedBox(height: 7),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildDottedDivider() {
    return Container(
      height: 1,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final boxWidth = constraints.constrainWidth();
          final dashWidth = 1.7;
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
                    color: AppColors.historyCalenderDivider,
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
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          getContainerCreditDebit('Credit', totalCredit.value),
          getContainerCreditDebit('Debit', totalDebit.value),
        ],
      ),
    );
  }

  Widget getContainerCreditDebit(title, amount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: Container(
        child: DottedBorderBox(
          dashWidth: 7,
          space: 5,
          dashHeight: 1,
          color: AppColors.primaryColor,
          child: Row(
            children: [
              Text(
                title,
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 14,
                  color: AppColors.accentColor,
                ),
              ),
              SizedBox(width: 16),
              Obx(() => Text(
                    '₹ ${title == 'Credit' ? totalCredit.value.toStringAsFixed(0) : totalDebit.value.toStringAsFixed(0)}',
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 14,
                      lWeight: FontWeight.w600,
                      color: AppColors.accentColor,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // @override
  // void dispose() {
  //   scrollController.dispose();
  //   searchController.dispose();
  //   focusNodeSearchFeild.dispose();
  //   super.dispose();
  // }
}

class OvalTransactionWidget extends StatelessWidget {
  final String day;
  final String transactionCount;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const OvalTransactionWidget({
    Key? key,
    required this.day,
    required this.transactionCount,
    this.width = 120,
    this.height = 120,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFE5E7EB),
    this.textColor = const Color(0xFF374151),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(width / 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Top section - Day
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ),
          // Divider line
          Container(
            height: 1,
            width: width * 0.7,
            color: borderColor,
          ),
          // Bottom section - Transaction count
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                '$transactionCount tnxs',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
