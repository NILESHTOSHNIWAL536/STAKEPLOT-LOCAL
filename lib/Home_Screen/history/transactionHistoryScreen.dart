import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactions_ui_component.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_AppBar.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/tagandhidebutton.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionCalender.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/repository/clearstack.dart';
import 'package:flutter_application_code_stakeplot/repository/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/repository/transactions_repository.dart';
import 'package:get/get.dart';
import 'dart:async';

/// GLOBALS (kept unchanged)
final TextEditingController searchController = TextEditingController();
FocusNode focusNodeSearchFeild = FocusNode();
final RxBool showFilter = false.obs;

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final RxList<Map<String, dynamic>> filteredTransactions =
      RxList<Map<String, dynamic>>([]);
  final ScrollController scrollController = ScrollController();
  final RxList<Map<String, dynamic>> dayWiseTransactions =
      RxList<Map<String, dynamic>>([]);
  final RxBool isDateSummaryView = false.obs;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    /// Existing logic untouched
    currentPage = 1;
    showFilter.value = false;
    accountSelected.value = '';
    addManually.clear();
    balanceOutList.clear();
    maxController.text = "";
    minController.text = "";
    startDateController.text = "";
    endDateController.text = "";

    getAllTransactionHistory(context, false, false, isRefreshing: true);

    getDayWiseTransactions(context).then((data) {
      dayWiseTransactions.assignAll(data);
    });

    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 50) {
      getAllTransactionHistory(context, false, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.sizeOf(context).height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: historyAppBar(context),
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchAndTabsSection(context),
              Expanded(child: _buildTransactionBody(context, screenHeight)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI SECTIONS
  // ---------------------------------------------------------------------------

  Widget _buildSearchAndTabsSection(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.primaryColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(
              left: 10,
              right: 2,
              bottom: (groupTransactionList.isEmpty ? 4 : 3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildSearchField(context),
                _buildToggleDateSummaryBtn(),
                _buildFilterButton(),
              ],
            ),
          ),
          _buildTabsOrCheckbox(),
          _buildTagHideButtons(),
          _buildFilterSection(),
        ],
      ),
    );
  }

  Widget _buildTransactionBody(BuildContext context, double screenHeight) {
    return Obx(() {
      double calculatedHeight;

      if (showFilter.value || redioButton.isNotEmpty) {
        calculatedHeight = screenHeight / 1.52;
      } else if (showFilter.value && !isDateSummaryView.value) {
        calculatedHeight = screenHeight / 1.5;
      } else {
        calculatedHeight =
            (groupTransactionList.isNotEmpty || redioButton.isNotEmpty)
                ? screenHeight / 1.35
                : screenHeight / 1.25;
      }

      return SizedBox(
        width: double.infinity,
        height: calculatedHeight,
        child: IndexedStack(
          index: isDateSummaryView.value ? 0 : 1,
          children: [
            CalendarTransactionScreen(),
            NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollStartNotification) {
                  FocusScope.of(context).unfocus();
                }
                return false;
              },
              child: SingleChildScrollView(
                controller: scrollController,
                child: TransactionHistory(
                  isYearView: false,
                  isflag: true,
                  showIcon: false,
                  expandedPage: false,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Sub widgets extracted for clarity
  // ---------------------------------------------------------------------------

  Widget _buildSearchField(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.4,
      height: MediaQuery.of(context).size.width / 10,
      child: TextField(
        controller: searchController,
        focusNode: focusNodeSearchFeild,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: HomepageStringsDart().searchTransactions,
          hintStyle: FontManager().getTextStyle(
            context,
            lWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.grey,
          ),
          prefixIcon: Icon(Icons.search, color: AppColors.grey),
          suffixIcon: _buildClearButton(),
          filled: true,
          fillColor: AppColors.bg5,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
        ),
        style: const TextStyle(color: AppColors.accentColor),
      ),
    );
  }

  void _onSearchChanged(String value) {
    isDateSummaryView.value = false;
    allOrGroupTransactionsName.value = StringConstant.allTransactions;
    searchItemClicked.value = false;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      onChanedAutoTransactionStatus(context);
    });

    searchTextController.value = value;
    searchTextControllerBool.value = !searchTextControllerBool.value;
  }

  _buildClearButton() {
    return searchController.text.isNotEmpty
        ? IconButton(
            icon: Icon(Icons.clear, color: AppColors.accentColor),
            onPressed: () {
              searchController.clear();
              searchTextController.value = '';
              clearTransactions(context: context, f: true);
              searchTextControllerBool.value = !searchTextControllerBool.value;
            },
          )
        : null;
  }

  Widget _buildToggleDateSummaryBtn() {
    return InkWell(
      onTap: () => isDateSummaryView.value = !isDateSummaryView.value,
      child: Obx(
        () => AvatarProfileImage(
          url: !isDateSummaryView.value
              ? HomePageIcons.dayWiseIcon1
              : HomePageIcons.dayWiseIcon2,
          width: 70,
          height: 36,
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return InkWell(
      onTap: () => _toggleFilter(),
      child: Obx(
        () => AvatarProfileImage(
          url: !showFilter.value
              ? HomePageIcons.filterIcon
              : HomePageIcons.filterOn,
          width: 66,
          height: 30,
        ),
      ),
    );
  }

  void _toggleFilter() {
    showFilter.value = !showFilter.value;

    if (!showFilter.value) {
      searchTextController.value = "";
      searchController.text = "";
      startDateController.text = "";
      endDateController.text = "";
      showDateFilter.value = false;
      showAmountFilter.value = false;
      onChanedAutoTransactionStatus(context);
    }
  }

  Widget _buildTabsOrCheckbox() {
    return Obx(() {
      if (isDateSummaryView.value) return const SizedBox(height: 10);

      final showTabs = groupTransactionList.isNotEmpty || showCheckBox.value;

      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 2),
        child: showTabs
            ? Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Obx(() => showCheckBox.value
                    ? _buildCheckBoxButtons()
                    : getTab(context)),
              )
            : const SizedBox(height: 10),
      );
    });
  }

  Widget _buildCheckBoxButtons() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _selectButton("Selected (${redioButton.length})"),
          _cancelButton("Cancel"),
        ],
      ),
    );
  }

  Widget _selectButton(String text) {
    return _coloredButton(text, AppColors.button);
  }

  Widget _cancelButton(String text) {
    return InkWell(
      onTap: () {
        showCheckBox.value = false;
        redioButton.clear();
        redioButtonIndex.clear();
        balanceOutList.clear();
        addManually.clear();
        HapticFeedback.selectionClick();
      },
      child: _coloredButton(text, AppColors.primaryColor,
          bg: AppColors.backgroundColor),
    );
  }

  Widget _coloredButton(String text, Color color, {Color? bg}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      width: MediaQuery.of(context).size.width / 2.5,
      height: MediaQuery.of(context).size.height / 26,
      decoration: BoxDecoration(
        color: bg ?? Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: textStyleImage(
          context: context,
          text: text,
          c: color,
          fontsize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTagHideButtons() {
    return Obx(() => (redioButton.isNotEmpty && _showTagButtons())
        ? Padding(
            padding: const EdgeInsets.only(left: 10, right: 2, top: 8),
            child: getTagHideButtons(context),
          )
        : const SizedBox.shrink());
  }

  bool _showTagButtons() {
    return !isDateSummaryView.value &&
        allOrGroupTransactionsName.value == StringConstant.allTransactions;
  }

  Widget _buildFilterSection() {
    return Obx(() => (showFilter.value && _showTagButtons())
        ? filterTransaction(context)
        : const SizedBox.shrink());
  }
}
