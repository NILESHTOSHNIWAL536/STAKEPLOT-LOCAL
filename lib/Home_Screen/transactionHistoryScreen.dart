import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiAutomations/autoTransactions.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:get/get.dart';

final TextEditingController searchController = TextEditingController();

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final RxList<Map<String, dynamic>> filteredTransactions = RxList<Map<String, dynamic>>([]);
    final ScrollController scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    // Initialize filtered transactions with all transactions
    scrollController.addListener(_onScroll);

  }

void _onScroll() {
    scrollController.addListener(() async{
      // print("scrollController");
      // print("Scroll position: ${scrollController.position.pixels}");
      // print("Max scroll extent: ${scrollController.position.maxScrollExtent}");
          if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100)
          {
               getAllTransactionHistory(context, false, false);
          }
    });
  
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Text(
          'Transaction History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.accentColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accentColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height/1.1,
        width: MediaQuery.of(context).size.width/.1,
        child: SingleChildScrollView(
        controller: scrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Search Bar
              TextField(
                controller: searchController,
                onChanged: (value) {
                     onChanedAutoTransactionStatus(context);
                },
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.accentColor),
                  filled: true,
                  fillColor: AppColors.bg5,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: AppColors.accentColor),
              ),
              const SizedBox(height: 10),

              // Transaction History
             transactionsHistoryList()
            ],
          ),
        ),
      ),
    );
  }


  Widget  transactionsHistoryList() {
    return  Obx(() => loadChatdataOnChnage.value
                        ? TransactionHistory(
                            isYearView: isYearView.value,
                            isflag: true,
                            showIcon: true,
                            expandedPage: true,
                          )
                        : TransactionHistory(
                            isYearView: isYearView.value,
                            isflag: true,
                             showIcon: true,
                              expandedPage: true,
                          ));
  }

}