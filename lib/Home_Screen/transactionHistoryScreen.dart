// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';
// import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
// import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
// import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
// import 'package:get/get.dart';

// // Debouncer class for search input
// class Debouncer {
//   final int milliseconds;
//   VoidCallback? action;
//   Timer? _timer;

//   Debouncer({required this.milliseconds});

//   run(VoidCallback action) {
//     if (_timer != null) {
//       _timer!.cancel();
//     }
//     _timer = Timer(Duration(milliseconds: milliseconds), action);
//   }
// }

// class TransactionHistoryScreen extends StatefulWidget {
//   const TransactionHistoryScreen({super.key});

//   @override
//   State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
// }

// class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   final RxString searchQuery = ''.obs;
//   final RxBool isSearching = false.obs;
//   final Debouncer _debouncer = Debouncer(milliseconds: 500);
//   final RxBool isSearchLoading = false.obs; // Track search loading state

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       _debouncer.run(() {
//         searchQuery.value = _searchController.text;
//         isSearchLoading.value = true;
//         getAllTransactionHistory(
//           context,
//           false,
//           false,
//           isRefreshing: true,
//           searchQuery: _searchController.text,
//         ).then((_) {
//           isSearchLoading.value = false;
//         });
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Obx(() => isSearching.value
//             ? TextField(
//                 controller: _searchController,
//                 autofocus: true,
//                 decoration: InputDecoration(
//                   hintText: 'Search by category, amount, or date...',
//                   hintStyle: FontManager().getTextStyle(
//                     context,
//                     lWeight: FontWeight.normal,
//                     fontSize: 16,
//                     color: AppColors.bg1,
//                   ),
//                   border: InputBorder.none,
//                 ),
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.normal,
//                   fontSize: 16,
//                   color: AppColors.accentColor,
//                 ),
//               )
//             : Text(
//                 'Transaction History',
//                 style: FontManager().getTextStyle(
//                   context,
//                   lWeight: FontWeight.bold,
//                   fontSize: 18,
//                   color: AppColors.accentColor,
//                 ),
//               )),
//         backgroundColor: AppColors.backgroundColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: AppColors.accentColor),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           Obx(() => IconButton(
//                 icon: Icon(
//                   isSearching.value ? Icons.close : Icons.search,
//                   color: AppColors.accentColor,
//                 ),
//                 onPressed: () {
//                   if (isSearching.value) {
//                     _searchController.clear();
//                     searchQuery.value = '';
//                     isSearchLoading.value = true;
//                     getAllTransactionHistory(
//                       context,
//                       false,
//                       false,
//                       isRefreshing: true,
//                     ).then((_) {
//                       isSearchLoading.value = false;
//                     });
//                   }
//                   isSearching.value = !isSearching.value;
//                 },
//               )),
//         ],
//       ),
//       body: Obx(() => isSearchLoading.value
//           ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
//           : TransactionHistory(
//               isflag: false,
//               showIcon: false,
//               isYearView: false,
//               pageTransition: false,
//               expandedPage: false,
//               searchQuery: searchQuery,
//             )),
//     );
//   }
// }