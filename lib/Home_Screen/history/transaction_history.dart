import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/search.dart';
import 'package:flutter_application_code_stakeplot/GroupTrans/group_transactions.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/Home/home_page.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactionCalender.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactions_credit_debit.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactions_search_list.dart';
import 'package:flutter_application_code_stakeplot/Utils/homepageStrings.dart.dart';
import 'package:flutter_application_code_stakeplot/animated/pdf.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

RxBool reloadHistory = false.obs;
RxString selectedValue = "30".obs;
RxString selectedValueType = "days".obs;
RxBool getPdgLoader = false.obs;
RxString bankLogo = "".obs;
RxMap<int, double> swipeOffsets = <int, double>{}.obs;
RxList<TransactionModel> hiddenTransactions = <TransactionModel>[].obs;

class TransactionHistory extends StatefulWidget {
  final bool? isYearView;
  final bool? isflag;
  final bool? showIcon;
  bool expandedPage;
  bool pageTransition;
  TransactionHistory(
      {this.isflag = false,
      this.showIcon = false,
      this.isYearView = false,
      this.pageTransition = false,
      this.expandedPage = false,
      super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory>
    with SingleTickerProviderStateMixin {
  final _scrollController2 = ScrollController();

  final List<Map<String, dynamic>> hiddenTransactions = [];
  final targetKey = GlobalKey();
  BuildContext? _stableContext;

  @override
  void initState() {
    super.initState();
    _stableContext = context;

    if (!widget.expandedPage) currentPage = 1;

    _scrollController2.addListener(() {
      if (_scrollController2.position.pixels >=
          _scrollController2.position.maxScrollExtent - 100) {
        getAllTransactionHistory(
          context,
          widget.isflag!,
          widget.isYearView!,
        );
      }
    });
    getAllTransactionHistory(context, widget.isflag!, widget.isYearView!,
        isRefreshing: true);
  }

  @override
  void didChangeDependencies()
  {
    super.didChangeDependencies();
    _stableContext ??= context;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            Obx(() => getBoolForSearch()
                ? searchTextControllerBool.value
                    ? getSearchListAndCreditDebit()
                    : getSearchListAndCreditDebit()
                : SizedBox.shrink()),
            Obx(() {
              if (widget.showIcon ?? false) {
                return reloadHistory.value ? getlist() : getlist();
              } else {
                return allOrGroupTransactionsName.value ==
                        StringConstant.allTransactions
                    ? (reloadHistory.value ? getlist() : getlist())
                    : GroupTransactions();
              }
            }),
          ],
        ),
      ),
    );
  }

  bool getBoolForSearch() {
    return (searchTextController.value.trim().isNotEmpty &&
        allOrGroupTransactionsName.value == StringConstant.allTransactions);
  }

  void changeTheBool() {
    sectionReached.value = true;
    Navigator.pop(context);
  }

  Widget getSearchListAndCreditDebit() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: TransactionsSearchList(),
        ),
        lastWeekjson.isNotEmpty && lastmonthjson.isNotEmpty
            ? TransactionCreditDebitScreen()
            : SizedBox.shrink(),
      ],
    );
  }

  Widget getlist() {
    // Group transactions by month and year
    Map<String, List<TransactionModel>> groupedTransactions = {};
    for (var transaction in transactionsHistory) {
      String? timestamp = transaction.transactionTimestamp.toString();
      // String? timestamp = transaction['transactionTimestamp']?.toString();
      if (timestamp != null) {
        try {
          // Parse as UTC and convert to IST
          DateTime utcDate = DateTime.parse(timestamp).toUtc();
          DateTime istDate = utcDate.subtract(Duration(hours: 5, minutes: 30));
          // Use only year and month for grouping to avoid day boundary issues
          String monthYearKey =
              DateFormat('MMMM yyyy').format(istDate); // e.g., "April 2025"
          groupedTransactions
              .putIfAbsent(monthYearKey, () => [])
              .add(transaction);
          // Debug: Log the timestamp and its IST conversion
        } catch (e) {
          continue;
        }
      }
    }

    // Sort months by date (descending order)
    List<String> sortedMonths = groupedTransactions.keys.toList();
    sortedMonths.sort((a, b) {
      DateTime dateA = DateFormat('MMMM yyyy')
          .parse(a, true)
          .toUtc()
          .subtract(Duration(hours: 5, minutes: 30)); // Convert UTC to IST
      DateTime dateB = DateFormat('MMMM yyyy')
          .parse(b, true)
          .toUtc()
          .subtract(Duration(hours: 5, minutes: 30)); // Convert UTC to IST
      return dateB.compareTo(dateA); // Most recent first
    });

    // Flatten the grouped transactions into a list for ListView.builder
    List<dynamic> displayItems = [];
    for (var monthYear in sortedMonths) {
      displayItems.add(monthYear); // Add the month header
      displayItems
          .addAll(groupedTransactions[monthYear] ?? []); // Null-safe access
    }

    // Add a loading indicator at the end if more data is being fetched
    if (isLoadingMore.value) {
      displayItems.add('loader'); // Use a distinct marker to avoid confusion
    }

    return ListView.builder(
      itemCount: displayItems.length,
      shrinkWrap: true,
      controller: _scrollController2,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = displayItems[index];
        if (item is String && item != 'loader') {
          String monthYear = item;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayItems.length > 0 ? monthYear : '',
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.accentColor,
                  ),
                ),
              ],
            ),
          );
        }

        // Case 2: Transaction Item
        else if (item is TransactionModel) {
          final transaction = item;
          int transactionIndex = transactionsHistory.indexOf(transaction);

          return Container(
            child: HistoryTransactions(
                transaction: transaction,
                date: transaction.transactionTimestamp.toString(),
                index: transactionIndex,
                context: context,
                hideReview: true,
                isExpanded: widget.expandedPage),
          );
        }

        return Obx(() => !isLoadingMore.value
            ? SizedBox.shrink()
            : loadingDelay.value
                ? transactionsHistory.length - 1 <= 0
                    ? Container(
                        height: 50,
                        width: 50,
                        child: Spinner(),
                      )
                    : Skeletonizer(
                        child: Column(
                          children: [1, 2, 3]
                              .map((e) => HistoryTransactions(
                                  transaction: transactionsHistory[
                                      transactionsHistory.length - 1],
                                  date: transactionsHistory[
                                          transactionsHistory.length - 1]
                                      .transactionTimestamp
                                      .toString(),
                                  index: transactionsHistory.length - 1,
                                  context: context,
                                  hideReview: true,
                                  isExpanded: widget.expandedPage))
                              .toList(),
                        ),
                      )
                : transactionsHistory.isEmpty
                    ? Container(
                        height: MediaQuery.of(context).size.height / 1.38,
                        child: Center(
                            child: textStyleImage(
                                context: context,
                                text: HomepageStringsDart().noTransactions)))
                    : SizedBox.shrink()); // Fallback for unexpected items
      },
    );
  }

  void showModal() {
    getPdgLoader.value = false;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 2,
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    textStyle(
                        context: context,
                        text: HomepageStringsDart().downloadStatement,
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
              getListItemListTile(
                  HomepageStringsDart().thirtyDays, "days", context),
              getListItemListTile(
                  HomepageStringsDart().thirtyDays, "days", context),
              getListItemListTile(
                  HomepageStringsDart().sixtyDays, "months", context),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: InkWell(
                    onTap: () async {
                      getPdgLoader.value = true;
                      getPdf(context, selectedValue, selectedValueType);
                    },
                    child: Obx(() => getPdgLoader.value
                        ? getspinner(context, "")
                        : getButton(context, HomepageStringsDart().sixMonths))),
              )
            ],
          ),
        );
      },
    );
  }
}

Widget getIconAvtar(double avatarSize, String category, double scaleFactor) {
  String lowerCategory = category?.toLowerCase() ?? '';

  final matched = custom.firstWhere(
    (item) => item['name']?.toString().toLowerCase() == lowerCategory,
    orElse: () => {},
  );

  final url = matched.isNotEmpty && matched['imageUrl'] != null
      ? matched['imageUrl']
      : imageMapForHistory[lowerCategory] != null
          ? Categories.link + imageMapForHistory[lowerCategory].toString()
          : "assets/icons/Categories2/other.svg";

  return Container(
    width: avatarSize,
    height: avatarSize,
    decoration: BoxDecoration(
      border: Border.all(
        color: Colorcodes.greyLight,
        width: 0.3,
      ),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Center(
      child: AvatarProfileImage(
        url: url,
        height: avatarSize * 0.5,
        width: avatarSize * 0.5,
      ),
    ),
  );
}

Widget getIconAvtar2(double avatarSize, String category, double scaleFactor,
    [bool f = false]) {
  String lowerCategory = category?.toLowerCase() ?? '';

  final matched = custom.firstWhere(
    (item) => item['name']?.toString().toLowerCase() == lowerCategory,
    orElse: () => {},
  );

  final url = matched.isNotEmpty && matched['imageUrl'] != null
      ? matched['imageUrl']
      : imageMapForHistory[lowerCategory] != null
          ? Categories.link + imageMapForHistory[lowerCategory].toString()
          : BudgetSubCategories.listofSubCategories[lowerCategory] ??
              Categories.link + "others.svg";

  return Center(
    child: chatAvatartImage(
      url: url,
      height: avatarSize * 1.7,
      width: avatarSize * 1.7,
    ),
  );
}

Widget getPredictedCategorySvgUrl(
    double avatarSize, String category, double scaleFactor,
    [bool f = false]) {
  String lowerCategory = category.toLowerCase();
  String upperCategory = toUpperCase(category);

  final url = imageMapForHistory[lowerCategory] != null
      ? Categories.link + imageMapForHistory[lowerCategory].toString()
      : BudgetSubCategories.listofSubCategories[upperCategory] ??
          BudgetSubCategories.listofSubCategories[lowerCategory] ??
          Categories.link + "others.svg";

  return Center(
    child: chatAvatartImage(
      url: url,
      height: avatarSize * 1.7,
      width: avatarSize * 1.7,
    ),
  );
}
