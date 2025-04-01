import 'dart:convert';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/home_page.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_details.dart';
import 'package:flutter_application_code_stakeplot/animated/pdf.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/curd.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/bill.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/model/transactions.dart';
import 'package:flutter_application_code_stakeplot/profile.dart';
import 'package:flutter_application_code_stakeplot/signInOut/avatar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/friends_bill_split.dart';

RxBool reloadHistory = false.obs;
RxString selectedValue = "30".obs;
RxString selectedValueType = "days".obs;
RxBool getPdgLoader = false.obs;

class TransactionHistory extends StatefulWidget {
  /// Optional
  final bool? isYearView;
  final bool? isflag;
  final bool? showIcon;
  bool pageTransition;
  TransactionHistory(
      {this.isflag = false,
      this.showIcon = false,
      this.isYearView = false,
      this.pageTransition = false,
      super.key});
  // const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory>
    with SingleTickerProviderStateMixin {
  final Map<int, double> swipeOffsets = {};
  final _scrollController2 = ScrollController();
  final List<Map<String, dynamic>> hiddenTransactions = [];
  final targetKey = GlobalKey();
  BuildContext? _stableContext;
  late AnimationController _animationController; // For smooth animations
  late Animation<double> _swipeAnimation; // Animation for swipe offset
  int? _currentSwipedIndex;

  @override
  void initState() {
    super.initState();
    _stableContext = context;
    currentPage = 1;

    // getAllTransactionHistory(context, widget.isflag!, widget.isYearView!);
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

    getAllTransactionHistory(context, widget.isflag!, widget.isYearView!,
        isRefreshing: true);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), // Animation duration
    );
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
                if (widget.showIcon ?? false) ...[
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
            const SizedBox(height: 20),
            Obx(() => reloadHistory.value
                ? getlist()
                : getlist()), // Wrapped in Obx for reactivity
          ],
        ),
      ),
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
    return ListView.builder(
      itemCount: transactionsHistory.length + 1,
      shrinkWrap: true,
      controller: _scrollController2,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < transactionsHistory.length) {
          final transaction = transactionsHistory[index];
          print("transactionslistttt : $transaction");
          double amount = (transaction['amount'] is int)
              ? (transaction['amount'] as int).toDouble()
              : (transaction['amount'] as double? ?? 0.0);
          String category = transaction['category']?.toString() ??
              'Uncategorized'; // Fixed typo and added null check
          String subcategory =
              transaction['subcategory']?.toString() ?? 'General';

          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 5,
                child: Container(
                  //static height for now 70
                  height: MediaQuery.sizeOf(context).height / 11.7,
                  decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              Positioned(
                right: 10,
                top: 25,
                child: GestureDetector(
                  onTap: () {
                    hideTransaction(index);
                  },
                  child: const Icon(
                    Icons.visibility_off,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              Positioned(
                right: 50,
                top: 25,
                child: GestureDetector(
                  onTap: () async {
                    // final result = await showCustomFriendsModal(
                    //     context, amount, false, category, subcategory);
                    final result = await showCustomFriendsModal(
                        context, amount, false, category, subcategory);

                    // showCustomFriendsModal2(context, transaction);
                  },
                  child: const Icon(
                    Icons.person_add,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              GestureDetector(
                onHorizontalDragUpdate: (details) {
                  scrollLeft(details, index);
                },
                child: Transform.translate(
                  offset: Offset(swipeOffsets[index] ?? 0.0, 0),
                  child: Container(
                    decoration: getBoxDecoration(index),
                    child: historyTransactions(
                        transaction,
                        transaction['transactionTimestamp']?.toString(),
                        index), // Ensure this is a String or null),
                  ),
                ),
              ),
            ],
          );
        } else {
          return isLoadingMore.value
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : const SizedBox.shrink();
        }
      },
    );
  }

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

  Widget historyTransactions(
      Map<String, dynamic> transaction, String? date, int index) {
    final category = transaction['category']?.toString() ?? 'Uncategorized';
    final subcategory = transaction['subcategory']?.toString() ?? 'General';
    final amount = transaction['amount']?.toString() ?? '0';
    final ismanual = transaction['manualTransaction'];
    final formattedDate = date != null
        ? formatWhatsAppDate(convertStringToDateTime(date))
        : 'Date';
    final type = transaction['type']?.toString() ?? '0';
    final amtColor = type == 'CREDIT'
        ? Colors.green
        : const Color.fromARGB(255, 207, 118, 113);
    // print("typeeeee $type");
    final formatAmount = type == 'CREDIT' ? "+₹$amount" : "-₹$amount";
    return GestureDetector(
      onLongPress: () {
        tagName.value = category;
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          builder: (context) {
            return TagShowmodal(
              data: transaction,
              index: index,
            );
          },
        );
      },
      onTap: () {
        // Navigate to the transaction details page on long press
        showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return TransactionDetailsPage(transaction: transaction);
            });
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) =>
        //         TransactionDetailsPage(transaction: transaction),
        //   ),
        // );
      },
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    AppColors.primaryColor, // Keep the border color consistent
                width: 0.2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.button,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: AvatarProfileImage(
                            url: Categories.link +
                                (imageMapForHistory[category.toLowerCase()] ??
                                    'default_image.png'),
                            height: 20,
                            width: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        flex: 2,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: " $category",
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w600,
                                  fontSize: 14,
                                  lineHeight: 2.14,
                                  color: AppColors.accentColor,
                                ),
                              ),
                              TextSpan(
                                text: " ($subcategory)",
                                style: FontManager().getTextStyle(
                                  context,
                                  lWeight: FontWeight.w400,
                                  fontSize: 12,
                                  lineHeight: 1.14,
                                  color: AppColors.accentColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      textStyle(
                        text: '$formatAmount',
                        context: context,
                        fontWeight: FontWeight.bold,
                        fontsize: 15,
                        c: amtColor,
                      ),
                      const SizedBox(height: 6),
                      textStyle(
                          text: formattedDate,
                          context: context,
                          fontWeight: FontWeight.w300,
                          fontsize: 10,
                          c: AppColors.primaryColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (ismanual)
            Positioned(
              top: 3,
              left: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'M',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  BoxDecoration getBoxDecoration(int index) {
    double swipeOffset =
        (swipeOffsets[index] ?? 0.0).abs(); // Absolute value of offset
    double totalSwipeDistance = 90.0; // Total swipe distance
    double mixStart = totalSwipeDistance * 0.7; // Start mixing at 70% (63.0)
    double swipeProgress;

    if (swipeOffset <= mixStart) {
      // Before the last 30%, no mixing (fully opaque)
      swipeProgress = 0.0;
    } else {
      // In the last 30%, calculate progress from mixStart (63.0) to totalSwipeDistance (90.0)
      swipeProgress =
          (swipeOffset - mixStart) / (totalSwipeDistance - mixStart);
      swipeProgress =
          swipeProgress.clamp(0.0, 1.0); // Ensure it stays between 0 and 1
    }

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: const [
          0.0,
          0.7,
          1.0
        ], // Gradient stops: 0% to 70% solid, 70% to 100% mixing
        colors: [
          AppColors.backgroundColor, // Solid color up to 70%
          AppColors.backgroundColor, // Still solid at 70%
          AppColors.backgroundColor
              .withOpacity(1.0 - swipeProgress), // Mixing in last 30%
        ],
      ),
    );
  }

  void scrollLeft(DragUpdateDetails details, int index) {
    setState(() {
      // Reset other items' offsets
      swipeOffsets.forEach((key, value) {
        if (key != index) {
          swipeOffsets[key] = 0.0;
        }
      });

      // Determine target offset based on drag direction
      double targetOffset = details.delta.dx < 0 ? -90.0 : 0.0;
      animateSwipe(index, targetOffset);
    });
  }

  void animateSwipe(int index, double targetOffset) {
    _currentSwipedIndex = index;
    double currentOffset = swipeOffsets[index] ?? 0.0;

    _swipeAnimation = Tween<double>(begin: currentOffset, end: targetOffset)
        .animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut, // Smooth easing curve
    ))
      ..addListener(() {
        setState(() {
          if (_currentSwipedIndex == index) {
            swipeOffsets[index] = _swipeAnimation.value;
          }
        });
      });

    _animationController.forward(from: 0.0);
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

  void hideTransaction(int index) async {
    final transaction = transactionsHistory[index];
    final transactionId = transaction['_id']?.toString();

    if (transactionId == null) {
      //   print("Error: Transaction ID is null");
      return;
    }

    final apiUrl = "$url/transactionauto/updateTransaction/$transactionId";
    try {
      final response = await updateDataApiCall(apiUrl, {"Hidden": true});
      if (response.statusCode == 200) {
        hiddenTransactions.add(transaction);
        transactionsHistory.removeAt(index);
        swipeOffsets.remove(index);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Failed to hide transaction: ${response.statusCode} - ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error hiding transaction")),
      );
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
                        : getButton(context, "Containue"))),
              )
            ],
          ),
        );
      },
    );
  }
}
