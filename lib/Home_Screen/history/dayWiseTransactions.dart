
import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apiConnect/home.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DateSummaryView extends StatelessWidget {
  final RxList<Map<String, dynamic>> dayWiseTransactions;
  final VoidCallback onBack;

  const DateSummaryView({
    super.key,
    required this.dayWiseTransactions,
    required this.onBack,
  });

  String formatAmount(num amount) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
       
        Expanded(
          child: Obx(() => ListView.builder(
                itemCount: dayWiseTransactions.length,
                padding: const EdgeInsets.all(4),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom:16),
                    child: _DateCard(
                      dateData: dayWiseTransactions[index],
                    ),
                  );
                },
              )),
        )
      ],
    );
  }
}

class _DateCard extends StatefulWidget {
  final Map<String, dynamic> dateData;

  const _DateCard({required this.dateData});

  @override
  State<_DateCard> createState() => _DateCardState();
}
class _DateCardState extends State<_DateCard> with TickerProviderStateMixin {
  bool _isExpanded = false;

  String formatAmount(num amount) {
    final formatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final creditAmount = widget.dateData['creditAmount'] ?? 0;
    final debitAmount = widget.dateData['debitAmount'] ?? 0;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4), // Adjusted padding
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none, // Allow overflow for stacked effect
              children: [
                // Third layer (furthest back)
                if (!_isExpanded) ...[
                Positioned(
                  top: 12,
                  left: 8,
                  right: 8,
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB0B0E0), // Slightly darker shade
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                // Second layer
                Positioned(
                  top: 6,
                  left: 4,
                  right: 4,
                  child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC5C5EA), // Lighter shade
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 3,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),],
                // Top layer (main card)
                InkWell(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Container(
                    
                    decoration: _isExpanded?BoxDecoration(
                      color: AppColors.finSpaceColor,
                      borderRadius: BorderRadius.circular(8),):BoxDecoration(
                      color: AppColors.finSpaceColor,
                      borderRadius: BorderRadius.circular(8),
                      
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.2),
                          offset: const Offset(0, 3),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          offset: const Offset(0, -3),
                          blurRadius: 2,
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Date
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            textStyle(
                              context: context,
                              text: "Date",
                              c: AppColors.backgroundColor,
                              fontsize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            const SizedBox(height: 6),
                            textStyle(
                              context: context,
                              text: formatWhatsAppDateWithoutTime(
                                  convertStringToDateTime(widget.dateData['date'])),
                              c: AppColors.backgroundColor,
                              fontsize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                        // Credit
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            textStyle(
                              context: context,
                              text: "Credit",
                              c: AppColors.backgroundColor,
                              fontsize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            const SizedBox(height: 6),
                            textStyle(
                              context: context,
                              text: formatAmount(creditAmount),
                              c: AppColors.backgroundColor,
                              fontsize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                        // Debit
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            textStyle(
                              context: context,
                              text: "Debit",
                              c: AppColors.backgroundColor,
                              fontsize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            const SizedBox(height: 6),
                            textStyle(
                              context: context,
                              text: formatAmount(debitAmount),
                              c: AppColors.backgroundColor,
                              fontsize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
           if (_isExpanded)
              FutureBuilder<List<Map<String, dynamic>>>(
                future: getDayWiseTransactionsForDate(context, widget.dateData['date']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(child: Text('Error loading transactions'));
                  }
                  final transactions = snapshot.data!;
                   if (transactions.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: textStyle(
                        context: context,
                        text: "No transactions",
                        c: AppColors.backgroundColor,
                        fontsize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    padding: const EdgeInsets.only(top: 8),
                    itemBuilder: (context, txIndex) {
                      final transactionData = transactions[txIndex];
                      final transaction = TransactionModel.fromJson(transactionData);
                      try {
                        return AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Transform.translate(
                            offset: Offset(0, txIndex * 4.0), // Subtle stacking offset
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                              decoration: BoxDecoration(
                                // color: AppColors.finSpaceColor.withOpacity(0.9),
                               
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: historyTransactions(
                                  transaction,
                                  transaction.transactionTimestamp.toIso8601String(),
                                  txIndex,
                                  context,
                                  true,
                                  true,
                                ),
                              ),
                            ),
                          ),
                        );
                      } catch (e) {
                        print(e);
                        return Text(e.toString());
                      }
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
