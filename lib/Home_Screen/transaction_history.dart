
import 'dart:convert';
import 'package:flutter_application_code_stakeplot/Home_Screen/FriendsUi.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/bill.dart';
import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

class TransactionHistory extends StatefulWidget {
   final int? selectedYear; // Optional
  final int? selectedMonth; // Optional
  final bool? isYearView;

  const TransactionHistory({
    super.key,
     this.selectedYear,
    this.selectedMonth,
    this.isYearView,
  });
 // const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  
  final Map<int, double> swipeOffsets = {};
  final List<Map<String, dynamic>> hiddenTransactions = [];
  final transactionsHistory = <dynamic>[].obs; // Corrected typo
  final scrollController = ScrollController();
  final targetKey = GlobalKey();
  final getHistory = false.obs;
  BuildContext? _stableContext;

  @override
  void initState() {
    super.initState();
    _stableContext = context;
    getAllTransaction(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stableContext ??= context;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Container(
        key: targetKey,
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
              ],
            ),
            const SizedBox(height: 20),
            Obx(() => getlist()), // Wrapped in Obx for reactivity
          ],
        ),
      ),
    );
  }

  Widget getlist() {
    return ListView.builder(
      itemCount: transactionsHistory.length, // Corrected typo
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final transaction = transactionsHistory[index];
        //   print("Transaction: $transaction");

        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                color: AppColors.primaryColor,
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
                onTap: () {
                  showCustomFriendsModal2(context, transaction);
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
                    transaction['transactionTimestamp'],
                  ),
                ),
              ),
            ),
          ],
        );
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
                  Expanded(child: FriendsUi()),
                  Obx(() => addedMembers.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: InkWell(
                            onTap: () async {
                              try {
                                double amount = double.parse(
                                    transaction["amount"].toString());
                                double sharePerFriend =
                                    amount / addedMembers.length;
                                print(
                                    "Amount: $amount, Share Per Friend: $sharePerFriend");
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
                                ScaffoldMessenger.of(modalContext).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("Error splitting amount: $e")),
                                );
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

  Widget historyTransactions(Map<String, dynamic> transaction, String? date) {
    final category = transaction['category']?.toString() ?? 'Uncategorized';
    final subcategory = transaction['subcategory']?.toString() ?? 'General';
    final amount = transaction['amount']?.toString() ?? '0';
    final formattedDate = date != null ? formatDate(date) : 'Unknown Date';
    // String? s = imageMapForHistory[
    //     transaction['category'].toString().toLowerCase()];
    //String ImageUrl = Categories.link + s.toString();
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colorcodes.greyLight, width: 0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colorcodes.greyLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AvatarProfileImage(
                      url: Categories.link +
                          (imageMapForHistory[category.toLowerCase()] ?? ''),
                      height: 16,
                      width: 20,
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
                  text: '₹$amount',
                  context: context,
                  fontWeight: FontWeight.bold,
                  fontsize: 15,
                ),
                const SizedBox(height: 6),
                textStyle(
                  text: formattedDate,
                  context: context,
                  fontWeight: FontWeight.w300,
                  fontsize: 11,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration getBoxDecoration(int index) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: [
          (1.0 - ((swipeOffsets[index] ?? 0.0).abs() / 200)).clamp(0.0, 1.0),
          1.0,
        ],
        colors: [
          AppColors.backgroundColor,
          AppColors.backgroundColor.withOpacity(0.0),
        ],
      ),
    );
  }

  void scrollLeft(DragUpdateDetails details, int index) {
    setState(() {
      swipeOffsets.forEach((key, value) {
        if (key != index) {
          swipeOffsets[key] = 0.0;
        }
      });

      double offset = swipeOffsets[index] ?? 0.0;
      offset += details.delta.dx;
      offset = offset.clamp(-90.0, 0.0);
      swipeOffsets[index] = offset;
    });
  }

  // void hideTransaction(int index) {
  //   setState(() {
  //     hiddenTransactions.add(transactionsHistory[index]);
  //     print("Hidden Transactions: $hiddenTransactions");
  //     transactionsHistory.removeAt(index);
  //     swipeOffsets.remove(index);
  //   });
  // }

  static Future<String?> getToken() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var accessToken = pref.getString("accessToken");

    if (accessToken == null) {
      print("No access token found in SharedPreferences");
      return null;
    } else {
      print("Token: $accessToken");
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
      print("Error in updateDataApiCall: $e");
      rethrow;
    }
  }

  
  void hideTransaction(int index) async {
    final transaction = transactionsHistory[index];
    final transactionId = transaction['_id']?.toString();

    if (transactionId == null) {
      print("Error: Transaction ID is null");
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

  void getAllTransaction(BuildContext context) async {
    try {
      var response =
          await getDataApiCall("${url}/transactionauto/getTransactions/1");
      if (response.statusCode == 200) {
        var his = jsonDecode(response.body);

        var obj = his['data'];

        transactionsHistory.clear();
        if (obj != null && obj is List<dynamic>) {
          transactionsHistory.addAll(obj);

          getHistory.value = !getHistory.value;
        } else {
          print("Error: 'data' is null or not a List. Data received: $obj");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No transaction data available")),
          );
        }
      } else {
        print("API call failed with status: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text("Failed to load transactions: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Exception occurred: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("An error occurred while fetching transactions")),
      );
    }
  }

  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return DateFormat("dd MMM yyyy").format(date);
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
// import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/FriendsUi.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/avatarProfile.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/getTrasactions.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/bill.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
// import 'package:flutter_application_code_stakeplot/colorcodes.dart';
// import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
// import 'package:flutter_application_code_stakeplot/finvu_screens/shareAccountLogin.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class TransactionHistory extends StatelessWidget {
//   const TransactionHistory({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Instantiate the controller
//     final TransactionController controller = Get.put(TransactionController());

//     // Initialize controller with context
//     controller.setupScrollListener(context);
//     controller.getAllTransactions(context, reset: true);

//     return Container(
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Transaction History',
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.bold,
//                   fontSize: 18,
//                   color: AppColors.accentColor,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Obx(() => controller.getHistory.value
//               ? getList(context, controller)
//               : const Center(child: CircularProgressIndicator())),
//         ],
//       ),
//     );
//   }

//   Widget getList(BuildContext context, TransactionController controller) {
//     return ListView.builder(
//       controller: controller.scrollController,
//       itemCount: controller.transactionsHistory.length +
//           (controller.isLoadingMore ? 1 : 0),
//       shrinkWrap: true,
//       physics: const ClampingScrollPhysics(),
//       itemBuilder: (context, index) {
//         if (index == controller.transactionsHistory.length) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final transaction = controller.transactionsHistory[index];

//         return Stack(
//           children: [
//             Positioned(
//               left: 0,
//               right: 0,
//               child: Container(
//                 height: 80,
//                 color: AppColors.primaryColor,
//               ),
//             ),
//             Positioned(
//               right: 10,
//               top: 25,
//               child: GestureDetector(
//                 onTap: () => controller.hideTransaction(context, index),
//                 child: const Icon(
//                   Icons.visibility_off,
//                   color: Colors.white,
//                   size: 30,
//                 ),
//               ),
//             ),
//             Positioned(
//               right: 50,
//               top: 25,
//               child: GestureDetector(
//                 onTap: () {
//                   showCustomFriendsModal2(context, transaction);
//                 },
//                 child: const Icon(
//                   Icons.person_add,
//                   color: Colors.white,
//                   size: 30,
//                 ),
//               ),
//             ),
//             GestureDetector(
//               onHorizontalDragUpdate: (details) {
//                 controller.scrollLeft(details, index);
//               },
//               child: Obx(
//                 () => Transform.translate(
//                   offset: Offset(controller.swipeOffsets[index] ?? 0.0, 0),
//                   child: Container(
//                     decoration: controller.getBoxDecoration(index),
//                     child: controller.historyTransactions(
//                       context,
//                       transaction,
//                       transaction['transactionTimestamp'],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void showCustomFriendsModal2(
//       BuildContext context, Map<String, dynamic> transaction) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
//       ),
//       builder: (BuildContext modalContext) {
//         return StatefulBuilder(
//           builder: (BuildContext modalContext, StateSetter setModalState) {
//             return Container(
//               height: MediaQuery.of(modalContext).size.height / 1.9,
//               decoration: const BoxDecoration(
//                 color: AppColors.backgroundColor,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
//               ),
//               child: Column(
//                 children: [
//                   Expanded(child: FriendsUi()),
//                   Obx(() => addedMembers.isNotEmpty
//                       ? Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: InkWell(
//                             onTap: () async {
//                               try {
//                                 double amount = double.parse(
//                                     transaction["amount"].toString());
//                                 double sharePerFriend =
//                                     amount / addedMembers.length;
//                                 splitUserAmount2(
//                                   context,
//                                   amount.toString(),
//                                   addedMembers.toList(),
//                                   transaction["category"].toString(),
//                                   transaction["subcategory"].toString(),
//                                   sharePerFriend.toString(),
//                                 );
//                                 Navigator.pop(modalContext);
//                               } catch (e) {
//                                 ScaffoldMessenger.of(modalContext).showSnackBar(
//                                   SnackBar(
//                                       content:
//                                           Text("Error splitting amount: $e")),
//                                 );
//                               }
//                             },
//                             child: getButton(modalContext, "Continue"),
//                           ),
//                         )
//                       : const SizedBox.shrink()),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

// class TransactionController extends GetxController {
//   final transactionsHistory = <dynamic>[].obs; // Made observable
//   final getHistory = false.obs;
//   final swipeOffsets = <int, double>{}.obs; // Made observable
//   final hiddenTransactions = <Map<String, dynamic>>[].obs;
//   int currentPage = 1;
//   bool isLoadingMore = false;
//   bool hasMoreData = true;
//   final int transactionsPerPage = 20;
//   final ScrollController scrollController = ScrollController();

//   @override
//   void onInit() {
//     super.onInit();
//   }

//   @override
//   void onClose() {
//     scrollController.dispose();
//     super.onClose();
//   }

//   void setupScrollListener(BuildContext context) {
//     scrollController.addListener(() {
//       if (scrollController.position.pixels >=
//               scrollController.position.maxScrollExtent * 0.7 &&
//           !isLoadingMore &&
//           hasMoreData) {
//         loadMoreTransactions(context);
//       }
//     });
//   }

//   Future<void> getAllTransactions(BuildContext context,
//       {bool reset = false}) async {
//     if (reset) {
//       currentPage = 1;
//       transactionsHistory.clear();
//       hasMoreData = true;
//     }

//     try {
//       isLoadingMore = true;
//       var response = await getDataApiCall(
//           "${url}/transactionauto/getTransactions/$currentPage");

//       if (response.statusCode == 200) {
//         var his = jsonDecode(response.body);
//         var obj = his['data'];

//         if (obj != null && obj is List<dynamic>) {
//           if (reset) {
//             transactionsHistory.clear();
//           }
//           transactionsHistory.addAll(obj);
//           getHistory.value = true;

//           hasMoreData = obj.length == transactionsPerPage;
//           currentPage++;
//         } else {
//           print("Error: 'data' is null or not a List. Data received: $obj");
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("No transaction data available")),
//           );
//           hasMoreData = false;
//         }
//       } else {
//         print("API call failed with status: ${response.statusCode}");
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content:
//                   Text("Failed to load transactions: ${response.statusCode}")),
//         );
//         hasMoreData = false;
//       }
//     } catch (e) {
//       print("Exception occurred: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text("An error occurred while fetching transactions")),
//       );
//     } finally {
//       isLoadingMore = false;
//     }
//   }

//   Future<void> loadMoreTransactions(BuildContext context) async {
//     if (!isLoadingMore && hasMoreData) {
//       await getAllTransactions(context);
//     }
//   }

//   Widget historyTransactions(
//       BuildContext context, Map<String, dynamic> transaction, String? date) {
//     final category = transaction['category']?.toString() ?? 'Uncategorized';
//     final subcategory = transaction['subcategory']?.toString() ?? 'General';
//     final amount = transaction['amount']?.toString() ?? '0';
//     final formattedDate = date != null ? formatDate(date) : 'Unknown Date';

//     return Container(
//       width: MediaQuery.of(context).size.width,
//       margin: const EdgeInsets.symmetric(vertical: 5),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colorcodes.greyLight, width: 0.3),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             flex: 3,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Expanded(
//                   flex: 1,
//                   child: Container(
//                     margin: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colorcodes.greyLight,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: AvatarProfileImage(
//                       url: Categories.link +
//                           (imageMapForHistory[category.toLowerCase()] ?? ''),
//                       height: 16,
//                       width: 20,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 5),
//                 Expanded(
//                   flex: 2,
//                   child: RichText(
//                     text: TextSpan(
//                       children: [
//                         TextSpan(
//                           text: " $category",
//                           style: FontManager().getTextStyle(
//                             context,
//                             lWeight: FontWeight.w600,
//                             fontSize: 14,
//                             lineHeight: 2.14,
//                             color: AppColors.accentColor,
//                           ),
//                         ),
//                         TextSpan(
//                           text: " ($subcategory)",
//                           style: FontManager().getTextStyle(
//                             context,
//                             lWeight: FontWeight.w400,
//                             fontSize: 12,
//                             lineHeight: 1.14,
//                             color: AppColors.accentColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Column(
//               children: [
//                 textStyle(
//                   text: '₹$amount',
//                   context: context,
//                   fontWeight: FontWeight.bold,
//                   fontsize: 15,
//                 ),
//                 const SizedBox(height: 6),
//                 textStyle(
//                   text: formattedDate,
//                   context: context,
//                   fontWeight: FontWeight.w300,
//                   fontsize: 11,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   BoxDecoration getBoxDecoration(int index) {
//     return BoxDecoration(
//       gradient: LinearGradient(
//         begin: Alignment.centerLeft,
//         end: Alignment.centerRight,
//         stops: [
//           (1.0 - ((swipeOffsets[index] ?? 0.0).abs() / 200)).clamp(0.0, 1.0),
//           1.0,
//         ],
//         colors: [
//           AppColors.backgroundColor,
//           AppColors.backgroundColor.withOpacity(0.0),
//         ],
//       ),
//     );
//   }

//   void scrollLeft(DragUpdateDetails details, int index) {
//     swipeOffsets.forEach((key, value) {
//       if (key != index) {
//         swipeOffsets[key] = 0.0;
//       }
//     });

//     double offset = swipeOffsets[index] ?? 0.0;
//     offset += details.delta.dx;
//     offset = offset.clamp(-90.0, 0.0);
//     swipeOffsets[index] = offset;
//   }

//   Future<void> hideTransaction(BuildContext context, int index) async {
//     final transaction = transactionsHistory[index];
//     final transactionId = transaction['_id']?.toString();

//     if (transactionId == null) {
//       print("Error: Transaction ID is null");
//       return;
//     }

//     final apiUrl = "$url/transactionauto/updateTransaction/$transactionId";
//     try {
//       final response = await updateDataApiCall(apiUrl, {"Hidden": true});
//       if (response.statusCode == 200) {
//         hiddenTransactions.add(transaction);
//         transactionsHistory.removeAt(index);
//         swipeOffsets.remove(index);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text(
//                   "Failed to hide transaction: ${response.statusCode} - ${response.body}")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Error hiding transaction")),
//       );
//     }
//   }

//   Future<http.Response> updateDataApiCall(
//       String url, Map<String, dynamic> body) async {
//     try {
//       var accessToken = await getToken();
//       final response = await http.patch(
//         Uri.parse(url),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//           "Authorization": "$accessToken",
//         },
//         body: jsonEncode(body),
//       );
//       return response;
//     } catch (e) {
//       print("Error in updateDataApiCall: $e");
//       rethrow;
//     }
//   }

//   Future<String?> getToken() async {
//     final SharedPreferences pref = await SharedPreferences.getInstance();
//     var accessToken = pref.getString("accessToken");
//     return accessToken;
//   }

//   String formatDate(String dateString) {
//     DateTime date = DateTime.parse(dateString);
//     return DateFormat("dd MMM yyyy").format(date);
//   }
// }