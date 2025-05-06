
import 'dart:convert';
import 'package:flutter_application_code_stakeplot/Community_Page/postCard.dart';
import 'package:flutter_application_code_stakeplot/GroupTrans/group_transactions.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/home_page.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/home_page_apiCalls.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_details.dart';
import 'package:flutter_application_code_stakeplot/animated/pdf.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';

import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';

import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

RxBool reloadHistory = false.obs;
RxString selectedValue = "30".obs;
RxString selectedValueType = "days".obs;
RxBool getPdgLoader = false.obs;
RxMap<int, double> swipeOffsets = <int, double>{}.obs;
RxList<Map<String, dynamic>> hiddenTransactions = <Map<String, dynamic>>[].obs;
// AnimationController? _animationController;

class TransactionHistory extends StatefulWidget {
  /// Optional
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
  // const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory>
    with SingleTickerProviderStateMixin {
  final _scrollController2 = ScrollController();

  final List<Map<String, dynamic>> hiddenTransactions = [];
  final targetKey = GlobalKey();
  BuildContext? _stableContext;
  // For smooth animations

  @override
  void initState() {
    super.initState();
    _stableContext = context;
    //  Future.delayed(Duration(seconds: 5),() {

    //  });

    if (!widget.expandedPage) currentPage = 1;

    // getAllTransactionHistory(context, widget.isflag!, widget.isYearView!);
    // _animationController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(milliseconds: 200),
    // );
    _scrollController2.addListener(() {
      print("object");
      print(_scrollController2.position.pixels);
      print(_scrollController2.position.maxScrollExtent);
      if (_scrollController2.position.pixels >=
          _scrollController2.position.maxScrollExtent - 100) {
        getAllTransactionHistory(
          context,
          widget.isflag!,
          widget.isYearView!,
        ); // Fetch next page
      }
    });
    // if(!widget.expandedPage) isLoadingMore.value=false;
    getAllTransactionHistory(context, widget.isflag!, widget.isYearView!,
        isRefreshing: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stableContext ??= context;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            
            (widget.showIcon ?? false)
                ? SizedBox(
                    height: 15,
                  )
                : Obx(() => redioButton.isNotEmpty
                    ? getTagHideButtons()
                    : allOrGroupTransactionsName.value ==
                            StringConstant.allTransactions
                        ? getTabsForTransactions()
                        : getTabsForTransactions()),

            //  getlist()
            // Obx(() => reloadHistory.value ? getlist() : getlist())
            // (widget.showIcon ?? false)? Obx(() => reloadHistory.value ? getlist() : getlist()):
            //        Obx(() => allOrGroupTransactionsName.value ==
            //             StringConstant.allTransactions
            //         ? Obx(() => reloadHistory.value ? getlist() : getlist())
            //         : GroupTransactions()),
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
// Widget build(BuildContext context) {
//     // Get screen dimensions
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double systemPaddingTop = MediaQuery.of(context).padding.top;

//     // Heights for layout components
//     const double tabsHeight = 48.0; // Fixed height for tabs (adjust as needed)
//     const double tabsPadding = 32.0; // 16 top + 16 bottom padding in getTabsForTransactions
//     const double listTopPadding = 10.0; // Padding above transaction list

//     // Calculate available height for scrollable area
//     // Note: AppBar and search bar heights are handled by TransactionHistoryScreen
//     final double scrollableHeight = screenHeight - systemPaddingTop - tabsHeight - tabsPadding - listTopPadding;

//     return Column(
//       children: [
//         // Fixed Tabs Header
//         Container(
//           width: screenWidth,
//           color: AppColors.backgroundColor,
//           child: (widget.showIcon ?? false)
//               ? SizedBox(height: tabsHeight) // Placeholder if showIcon is true
//               : Obx(() => redioButton.isNotEmpty
//                   ? getTagHideButtons()
//                   : allOrGroupTransactionsName.value == StringConstant.allTransactions
//                       ? getTabsForTransactions()
//                       : getTabsForTransactions()),
//         ),
//         // Scrollable Transaction List
//         Container(
//           width: screenWidth,
//           height: scrollableHeight,
//           child: SingleChildScrollView(
//             controller: _scrollController2,
//             child: Obx(() {
//               if (widget.showIcon ?? false) {
//                 return reloadHistory.value ? getlist() : getlist();
//               } else {
//                 return allOrGroupTransactionsName.value == StringConstant.allTransactions
//                     ? (reloadHistory.value ? getlist() : getlist())
//                     : GroupTransactions();
//               }
//             }),
//           ),
//         ),
//       ],
//     );
//   }

  Widget getTagHideButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          actionButton(
            text: 'Tag',
            onTap: () {
              tagName.value = "Untagged";
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) {
                  return TagShowmodal(
                    data: transactionsHistory.isNotEmpty &&
                            redioButtonIndex.isNotEmpty
                        ? transactionsHistory[redioButtonIndex.values.first]
                        : {},
                    index: 0,
                    isTag: true,
                  );
                },
              );
            },
          ),
          const SizedBox(width: 10), // Spacing between buttons
          actionButton(
            text: 'Hide',
            onTap: () {
              hideSelectedTransactions(context, true);
              showCheckBox.value = false;
            },
          ),
        ],
      ),
    );
  }

  Widget actionButton({required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.primaryColor.withOpacity(0.2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.mt, // Match modal background for consistency
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: textStyle(
          context: context,
          text: text,
          c: AppColors.accentColor,
          fontsize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

 Widget getTabsForTransactions() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        tabItem(StringConstant.allTransactions),
        //const SizedBox(width: 12), // Space between tabs
        tabItem(StringConstant.pollTransactions),
      ],
    ),
  );
}

Widget tabItem(String text) {
  bool isSelected = text == allOrGroupTransactionsName.value;
  // Calculate width based on screen size for responsiveness
  double tabWidth = (MediaQuery.of(context).size.width - 44) / 2; // 44 = 16*2 padding + 12 spacing
  return InkWell(
    onTap: () {
      allOrGroupTransactionsName.value = text;
    },
    child: Container(
      width: tabWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryColor : AppColors.bg5,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          
          color: isSelected ? AppColors.primaryColor : AppColors.bg1,
        ),
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  AppColors.primaryColor,
                  AppColors.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: textStyle(
          context: context,
          text: text,
          c: isSelected ? AppColors.bg5 : AppColors.primaryColor,
          fontsize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
  void changeTheBool() {
    sectionReached.value = true;
    Navigator.pop(context);
  }

  Widget getlist() {
    // Group transactions by month and year
    Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (var transaction in transactionsHistory) {
      String? timestamp = transaction['transactionTimestamp']?.toString();
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
        // Case 1: Month Header
        if (item is String && item != 'loader') {
          String monthYear = item;
          // int transactionCount = groupedTransactions[monthYear]?.length ?? 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  monthYear,
                  style: FontManager().getTextStyle(
                    context,
                    lWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.accentColor,
                  ),
                ),
                // transactionCount == 0
                //     ? const SizedBox(
              ],
            ),
          );
        }

        // Case 2: Transaction Item
        else if (item is Map<String, dynamic>) {
          final transaction = item;
          int transactionIndex = transactionsHistory.indexOf(transaction);

          return Container(
            child: historyTransactions(
                transaction,
                transaction['transactionTimestamp']?.toString(),
                transactionIndex,
                context,
                true),
          );
        }

        // Case 3: Loading Indicator
        else if (!isLoadingMore.value) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            ),
          );
        }

        return loadingDelay.value
            ? Container(width: 50, height: 50, child: Spinner())
            : transactionsHistory.isEmpty
                ? textStyle(context: context, text: "No Transactions")
                : SizedBox.shrink(); // Fallback for unexpected items
      },
    );
  }
  // Widget getlist() {
  //   return ListView.builder(
  //     itemCount: transactionsHistory.length + 1,
  //     shrinkWrap: true,
  //     controller: _scrollController2,
  //     physics: const NeverScrollableScrollPhysics(),
  //     itemBuilder: (context, index) {
  //       if (index < transactionsHistory.length) {
  //         final transaction = transactionsHistory[index];

  //         double amount = double.parse(
  //             doubleToFixed((transaction['amount'] ?? 0.0).toString()));
  //         String category = transaction['category']?.toString() ??
  //             'Uncategorized'; // Fixed typo and added null check
  //         String subcategory =
  //             transaction['subcategory']?.toString() ?? 'General';

  //         return Container(
  //               decoration: getBoxDecoration(index),
  //               child: historyTransactions(
  //                   transaction,
  //                   transaction['transactionTimestamp']?.toString(),
  //                   index), // Ensure this is a String or null),

  //         );
  //       } else {
  //         return isLoadingMore.value
  //             ? Padding(
  //                 padding: const EdgeInsets.symmetric(vertical: 20),
  //                 child: const Center(
  //                   child: CircularProgressIndicator(
  //                     color: AppColors.primaryColor,
  //                   ),
  //                 ),
  //               )
  //             : const SizedBox.shrink();
  //       }
  //     },
  //   );
  // }

  void extractTransaction(bool isYearView, List obj) {
    // print("------------------------ extra called...");
    // print(isYearView);
    if (isYearView) {
      getTransactionByYear(obj, selectedYear.value);
    } else {
      getTransactionByMonth(obj, selectedMonth.value);
    }
  }

  void getTransactionByYear(List obj, int y) {
    obj.forEach((ele) {
      if (ele is Map<String, dynamic> &&
          isCurrentYear(ele['transactionTimestamp']?.toString() ?? '', y)) {
        transactionsHistory.add(ele);
      }
    });
  }

  void getTransactionByMonth(List obj, int m) {
    obj.forEach((ele) {
      if (ele is Map<String, dynamic> &&
          isCurrentMonth(ele['transactionTimestamp']?.toString() ?? '', m)) {
        transactionsHistory.add(ele);
      }
    });
  }

  bool isCurrentYear(String date, int y) {
    try {
      DateTime parsedDate = DateTime.parse(date); // Parse the date string
      return parsedDate.year == y; // Compare year
    } catch (e) {
      return false; // Return false if parsing fails
    }
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
                        text: "Download Statement",
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
              getListItemListTile("30", "days", context),
              getListItemListTile("60", "days", context),
              getListItemListTile("6", "months", context),
             
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
}

Widget getIconAvtar(double avatarSize, String category, double scaleFactor) {
  return Container(
    width: avatarSize,
    height: avatarSize,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.button.withOpacity(0.8),
          Colors.white.withOpacity(0.6),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12 * scaleFactor),
    ),
    child: Center(
      child: AvatarProfileImage(
        url: Categories.link +
            (imageMapForHistory[category.toLowerCase()] ?? 'default_image.png'),
        height: avatarSize * 0.5,
        width: avatarSize * 0.5,
      ),
    ),
  );
}

void hideSelectedTransactions(BuildContext context, bool hidden) {
  int index = 0; // Or get from another list/map if you have matching indexes

  redioButton.forEach((id, value) {
    hideTransaction(redioButtonIndex[id] ?? 0, hidden, context, id);
    index++;
  });

  redioButton.clear(); // Optionally clear selection after hiding
  redioButtonIndex.clear(); // Optionally clear selection after hiding
  Navigator.pop(context);
}
