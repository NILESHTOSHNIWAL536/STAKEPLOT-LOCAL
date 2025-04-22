import 'dart:convert';
import 'package:flutter_application_code_stakeplot/GroupTrans/group_transactions.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/home_page.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_details.dart';
import 'package:flutter_application_code_stakeplot/animated/pdf.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/bill.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/loader.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';
import 'package:http/http.dart' as http;
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/friends_bill_split.dart';

RxBool reloadHistory = false.obs;
RxString selectedValue = "30".obs;
RxString selectedValueType = "days".obs;
RxBool getPdgLoader = false.obs;
RxMap<int, double> swipeOffsets = <int, double>{}.obs;
RxList<Map<String, dynamic>> hiddenTransactions = <Map<String, dynamic>>[].obs;
AnimationController? _animationController;

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
  final Map<int, double> swipeOffsets = {};
  final List<Map<String, dynamic>> hiddenTransactions = [];
  final targetKey = GlobalKey();
  BuildContext? _stableContext;
  // For smooth animations
 

  @override
  void initState() {
    super.initState();
    _stableContext = context;
    if(!widget.expandedPage) currentPage = 1;

    // getAllTransactionHistory(context, widget.isflag!, widget.isYearView!);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scrollController2.addListener(() {
      if (_scrollController2.position.pixels >=
          _scrollController2.position.maxScrollExtent - 100) {
        getAllTransactionHistory(
          context,
          widget.isflag!,
          widget.isYearView!,
        ); // Fetch next page
      }
    });
    if(!widget.expandedPage) isLoadingMore.value=false;
    getAllTransactionHistory(context, widget.isflag!, widget.isYearView!,isRefreshing: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stableContext ??= context;
  }

  @override
  void dispose() {
    _scrollController2.dispose();
   
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction History',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.accentColor),
                ),
                if (!(widget.showIcon ?? false)) ...[
                  InkWell(
                    onTap: () {
                      showModal();
                    },
                    child: const Icon(
                      Icons.backup_sharp,
                      size: 30,
                      color: AppColors.accentColor,
                    ),
                  ),
                ]
              ],
            ),
            (widget.showIcon ?? false)
                ? SizedBox(
                    height: 15,
                  )
                : Obx(() => allOrGroupTransactionsName.value == StringConstant.allTransactions
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
              return allOrGroupTransactionsName.value == StringConstant.allTransactions
                  ? (reloadHistory.value ? getlist() : getlist())
                  : GroupTransactions();
            }
          })

          ],
        ),
      ),
    );
  }

  Widget getTabsForTransactions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          tabItem(StringConstant.allTransactions),
          tabItem(StringConstant.pollTransactions),
        ],
      ),
    );
  }

  Widget tabItem(text) {
    bool f = text == allOrGroupTransactionsName.value;
    return InkWell(
      onTap: () {
        allOrGroupTransactionsName.value = text;
      },
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: f ? AppColors.primaryColor : AppColors.bg5,
            border: Border.all(
              width: .5,
              color: AppColors.primaryColor,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: textStyle(
              context: context,
              text: text,
              c: f ? AppColors.bg5 : AppColors.primaryColor,
              fontsize: 15,
              fontWeight: FontWeight.w500)),
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
          DateTime istDate = utcDate.add(Duration(hours: 5, minutes: 30));
          // Use only year and month for grouping to avoid day boundary issues
          String monthYearKey =
              DateFormat('MMMM yyyy').format(istDate); // e.g., "April 2025"
          groupedTransactions
              .putIfAbsent(monthYearKey, () => [])
              .add(transaction);
          // Debug: Log the timestamp and its IST conversion
          print(
              'Timestamp: $timestamp, IST: $istDate, Grouped as: $monthYearKey');
        } catch (e) {
          print('Invalid timestamp: $timestamp');
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
          .add(Duration(hours: 5, minutes: 30)); // Convert UTC to IST
      DateTime dateB = DateFormat('MMMM yyyy')
          .parse(b, true)
          .toUtc()
          .add(Duration(hours: 5, minutes: 30)); // Convert UTC to IST
      return dateB.compareTo(dateA); // Most recent first
    });

    // Flatten the grouped transactions into a list for ListView.builder
    List<dynamic> displayItems = [];
    for (var monthYear in sortedMonths) {
      displayItems.add(monthYear); // Add the month header
      displayItems
          .addAll(groupedTransactions[monthYear] ?? []); // Null-safe access
    }

    // Show loader if no transactions are available
    // if (displayItems.isEmpty) {
    //   return const Center(
    //     child: Padding(
    //       padding: EdgeInsets.symmetric(vertical: 20),
    //       child: CircularProgressIndicator(
    //         color: AppColors.primaryColor,
    //       ),
    //     ),
    //   );
    // }

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
          int transactionCount = groupedTransactions[monthYear]?.length ?? 0;
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
                //         width: 24,
                //         height: 24,
                //         child: CircularProgressIndicator(
                //           color: AppColors.primaryColor,
                //           strokeWidth: 2,
                //         ),
                //       )
                //     : Text(
                //         '$transactionCount Transaction${transactionCount == 1 ? '' : 's'}',
                //         style: FontManager().getTextStyle(
                //           context,
                //           lWeight: FontWeight.w500,
                //           fontSize: 14,
                //           color: AppColors.primaryColor.withOpacity(0.7),
                //         ),
                //       ),
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
            ),
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

        return loadingDelay.value?
            Container(
              width: 50,height: 50,
              child:Spinner()
            ):  transactionsHistory.isEmpty 
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

  void showCustomFriendsModal2(
      BuildContext context, Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (BuildContext modalContext, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(modalContext).size.height / 1.9,
              decoration: const BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Column(
                children: [
                  // Expanded(
                  //     child: FriendsUi(
                  //   flag: false,
                  // )),
                  Obx(() => addedMembers.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: InkWell(
                            onTap: () async {
                              try {
                                double amount = double.parse(
                                    transaction["amount"].toString());
                                double sharePerFriend =
                                    amount / (addedMembers.length + 1);

                                splitUserAmount2(
                                  _stableContext ?? context,
                                  amount.toString(),
                                  addedMembers.toList(),
                                  transaction["category"].toString(),
                                  transaction["subcategory"].toString(),
                                  sharePerFriend.toString(),
                                );
                                Navigator.pop(modalContext);
                              } catch (e) {
                                snackBarCalled(
                                    context, "Error splitting Amount");
                              }
                            },
                            child: getButton(modalContext, "Continue"),
                          ),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget historyTransactions(
      Map<String, dynamic> transaction, String? date, int index) {
    String logo = transaction['bankLogo']?.toString() ?? "";
    final category = transaction['category']?.toString() ?? 'Uncategorized';
    final subcategory = transaction['subcategory']?.toString() ?? 'General';
    final double amount =
        double.parse(doubleToFixed((transaction['amount'] ?? 0.0).toString()));
    final isManual = transaction['manualTransaction'] ?? false;
    final formattedDate = date != null
        ? formatWhatsAppDate(convertStringToDateTime(date))
        : 'Date';
    final type = transaction['type']?.toString() ?? '0';
    final narration = transaction['narration'] ?? 'Unnamed Group';

    List<String> parts = narration.split('/');
    if (parts.isEmpty || parts.length == 1) parts = narration.split('-');
    if (parts.isEmpty || parts.length == 1) parts = narration.split('&');
    if (parts.isEmpty || parts.length == 1) parts = narration.split(' ');

    String nameOfUser = parts.length >= 4
        ? parts[3]
        : parts.length >= 3
            ? parts[2]
            : parts.length >= 2
                ? parts[1]
                : parts[0];

    final amtColor = type == 'CREDIT' ? Colors.green.shade700 : const Color.fromARGB(255, 207, 118, 113);
    final formatAmount = type == 'CREDIT' ? "+₹$amount" : "-₹$amount";

    // Responsive scaling with MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 360; // Base width: 360px
    final padding = 16.0 * scaleFactor;
    final margin = 12.0 * scaleFactor;
    final iconSize = 14.0 * scaleFactor; // Smaller icons for simplicity
    final avatarSize = 40.0 * scaleFactor;
    final fontSizeLarge = 14.0 * scaleFactor;
    final fontSizeMedium = 12.0 * scaleFactor;
    final fontSizeSmall = 10.0 * scaleFactor;
    final badgeSize = 20.0 * scaleFactor;

    return GestureDetector(
      onTap: () {
        if (!isManual) {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return TransactionDetailsPage(transaction: transaction);
            },
          );
        }
      },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: margin, horizontal: margin),
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16 * scaleFactor),
              gradient: LinearGradient(
                colors: [
                  AppColors.backgroundColor.withOpacity(0.03),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8 * scaleFactor,
                  offset: Offset(0, 3 * scaleFactor),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Icon, Narration, Amount
                Row(
                  children: [
                    // Icon Container
                    Container(
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
                              (imageMapForHistory[category.toLowerCase()] ??
                                  'default_image.png'),
                          height: avatarSize * 0.5,
                          width: avatarSize * 0.5,
                        ),
                      ),
                    ),
                    SizedBox(width: padding),
                    // Narration and Amount
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Tooltip(
                                message: narration,
                                child: Container(
                                  // height: 30,
                                  // color: Colorcodes.appBarColor,
                                  width: MediaQuery.sizeOf(context).width / 3,
                                  child: textStyle(
                                      context: context,
                                      text: nameOfUser,
                                      c: AppColors.accentColor,
                                      fontsize: fontSizeMedium,
                                      fontWeight: FontWeight.w600,
                                      lineHeight: 1.5),
                                ),
                              ),
                              textStyle(
                                context: context,
                                text: formattedDate,
                                c: AppColors.primaryColor.withOpacity(0.7),
                                fontsize: fontSizeSmall,
                                fontWeight: FontWeight.w400,
                              ),
                            ],
                          ),
                          textStyle(
                            context: context,
                            text: formatAmount,
                            c: amtColor,
                            fontsize: fontSizeLarge,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: padding / 2.5),
                // Bottom Row: Category and Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category
                    Container(
                      width: MediaQuery.sizeOf(context).width / 3,
                      child: textStyle(
                        context: context,
                        text: category,
                        c: AppColors.accentColor,
                        fontsize: fontSizeMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Action Icons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Hide Transaction
                   logo==""? SizedBox.shrink():
                        Image.network(
                          logo,
                          width: 30,
                          height: 30,
                          fit: BoxFit.fitWidth,
                        ),
                       SizedBox(width: 8 * scaleFactor),
                        Tooltip(
                          message: 'Hide',
                          child: GestureDetector(
                            onTap: () {
                              hideTransaction(
                                  index, true, context, transaction['_id']);
                            },
                            child: Container(
                              padding: EdgeInsets.all(6 * scaleFactor),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(8 * scaleFactor),
                              ),
                              child: Icon(
                                Icons.visibility_off_rounded,
                                color: AppColors.primaryColor,
                                size: iconSize,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * scaleFactor),
                        // Friends Modal
                        Tooltip(
                          message: 'Split with Friends',
                          child: GestureDetector(
                            onTap: () async {
                              await showCustomFriendsModal(
                                context,
                                amount,
                                false,
                                category,
                                subcategory,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(6 * scaleFactor),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(8 * scaleFactor),
                              ),
                              child: Icon(
                                Icons.group_add_rounded,
                                color: AppColors.primaryColor,
                                size: iconSize,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * scaleFactor),
                        // Tag Action
                        Tooltip(
                          message: 'Tag',
                          child: GestureDetector(
                            onTap: () {
                              tagName.value = category;
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                builder: (context) {
                                  return TagShowmodal(
                                    data: transaction,
                                    index: index,
                                  );
                                },
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(6 * scaleFactor),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(8 * scaleFactor),
                              ),
                              child: Icon(
                                Icons.tag_rounded,
                                color: AppColors.primaryColor,
                                size: iconSize,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * scaleFactor),
                        // Details Action
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Manual Badge
          if (isManual)
            Positioned(
              top: margin,
              left: margin + 4,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4 * scaleFactor,
                      offset: Offset(2 * scaleFactor, 2 * scaleFactor),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'M',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSizeSmall * 0.8,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<dynamic> showCustomFriendsModal(
    BuildContext context,
    double amount,
    bool isLendMode,
    String category,
    String subcategory,
  ) async {
    return await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext context) {
        return NewFriendsUi(
          totalAmount: amount.toDouble(),
          userId: currentId.value,
          userName: userName.value,
          userAvatar: avatar.value,
          isLendMode: isLendMode,
          category: category,
          subcategory: subcategory,
          flag: true,
        );
      },
    );
  }

  
 
  

  static Future<String?> getToken() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var accessToken = pref.getString("accessToken");

    if (accessToken == null) {
      // print("No access token found in SharedPreferences");
      return null;
    } else {
      //  print("Token: $accessToken");
      return accessToken;
    }
  }

  Future<http.Response> updateDataApiCall(
      String url, Map<String, dynamic> body) async {
    try {
      var accessToken = await getToken();
      final response = await http.patch(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "$accessToken",
        },
        body: jsonEncode(body),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return DateFormat("dd MMM yyyy").format(date);
  }

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
              getListItemListTile("1", "year", context),
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

void hideTransaction(
    int index, bool hidden, BuildContext context, String id) async {
  final transaction = transactionsHistory[index];
  print("transaction hide 1 $transaction");
  final transactionId = transaction['_id']?.toString();
  if (transactionId == null) {
    //   print("Error: Transaction ID is null");
    return;
  }
  //  /67e7d5f43afa9db7fcc3f29c
  final apiUrl = "$url/transactionauto/updateTransaction/$id";
  try {
    final response = await updateDataApiCall2(apiUrl, {"Hidden": hidden});
    print("Hidden: $apiUrl");
    printData(response);
    if (getFlagOfResponse(response)) {
      if (hidden) {
        hiddenTransactions.add(transaction);
        transactionsHistory.removeAt(index);
        swipeOffsets.clear(); // Clear all swipe offsets
        _animationController?.reset(); // Reset the animation controller
        transactionsHistory.refresh();
        snackBarCalled(context, "Transaction hidden Successfully");
      } else {
        hiddentrasactionsHistory.removeAt(index);
        hiddentrasactionsHistory.refresh();
      }
    } else {
      snackBarCalledfail(context, "Failed to hide transaction");
    }
  } catch (e) {
    snackBarCalledfail(context, "Error hiding transaction");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error hiding transaction")),
    );
  }
}
