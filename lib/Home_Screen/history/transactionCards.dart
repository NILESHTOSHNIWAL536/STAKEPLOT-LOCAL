import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/app_styles.dart';
import 'package:flutter_application_code_stakeplot/GroupTrans/group_Api.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:intl/intl.dart';

class CardViewTransactions extends StatefulWidget {
  const CardViewTransactions({super.key});

  @override
  _CardViewTransactionsState createState() => _CardViewTransactionsState();
}

class _CardViewTransactionsState extends State<CardViewTransactions> {
  final Set<String> _expandedDates = {};

  // Mock textStyle
  Widget textStyle({
    required BuildContext context,
    required String text,
    required Color c,
    required double fontsize,
    required FontWeight fontWeight,
    double? lineHeight,
  }) {
    try {
      return Text(
        text,
        style: TextStyle(
          color: c,
          fontSize: fontsize,
          fontWeight: fontWeight,
          height: lineHeight,
        ),
        overflow: TextOverflow.ellipsis,
      );
    } catch (e) {
      debugPrint('Error in textStyle: $e');
      return Text('Error: $text', style: const TextStyle(color: Colors.red));
    }
  }

  // Mock getIconAvtar
  Widget getIconAvtar(double size, String category, double scaleFactor) {
    try {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.blue.withOpacity(0.1),
        child: Text(
          category.isNotEmpty ? category[0].toUpperCase() : 'U',
          style: TextStyle(
            color: Colors.blue,
            fontSize: (size / 2) * scaleFactor,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error in getIconAvtar: $e');
      return const Icon(Icons.error, size: 20, color: Colors.red);
    }
  }

  // Mock AppColors

  // Mock FontManager

  @override
  Widget build(BuildContext context) {
    try {
      debugPrint('Building CardViewTransactions');
      debugPrint(
          'groupTransactionList length: ${groupTransactionList?.length ?? 0}');

      if (groupTransactionList == null || groupTransactionList.isEmpty) {
        debugPrint('Empty or null groupTransactionList');
        return const Center(child: Text('No transactions available'));
      }

      // Group transactions by date
      Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
      int skippedTransactions = 0;
      int totalProcessedTransactions = 0;

      for (var group in groupTransactionList) {
        if (group == null) {
          debugPrint('Skipping null group');
          continue;
        }
        List<dynamic> transactions = group['transactions'] ?? [];
        debugPrint(
            'Processing group: ${group['_id']}, transactions count: ${transactions.length}');

        for (var transaction in transactions) {
          if (transaction == null) {
            debugPrint('Skipping null transaction');
            skippedTransactions++;
            continue;
          }
          totalProcessedTransactions++;
          debugPrint('Transaction keys: ${transaction.keys.toList()}');

          String? date = transaction['transactionTimestamp'];
          String? type = transaction['type'];
          dynamic amount = transaction['amount'];

          debugPrint('Attempted date: $date, type: $type, amount: $amount');

          if (date == null || date.isEmpty) {
            debugPrint('Skipping transaction due to null or empty date');
            skippedTransactions++;
            continue;
          }

          try {
            DateTime parsedDate = DateTime.parse(date);
            String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

            if (type != 'CREDIT' && type != 'DEBIT') {
              debugPrint('Skipping transaction due to invalid type: $type');
              skippedTransactions++;
              continue;
            }

            if (amount == null || amount is! num) {
              debugPrint('Skipping transaction due to invalid amount: $amount');
              skippedTransactions++;
              continue;
            }

            groupedTransactions
                .putIfAbsent(formattedDate, () => [])
                .add(transaction);
          } catch (e) {
            debugPrint('Skipping transaction due to date parsing error: $e');
            skippedTransactions++;
            continue;
          }
        }
      }

      debugPrint(
          'Grouped transactions keys: ${groupedTransactions.keys.toList()}');
      debugPrint('Total processed transactions: $totalProcessedTransactions');
      debugPrint('Skipped transactions: $skippedTransactions');

      var sortedDates = groupedTransactions.keys.toList()
        ..sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));

      if (sortedDates.isEmpty) {
        debugPrint('No valid transactions found');
        return Center(
          child: Text(
            'No valid transactions found. Processed $totalProcessedTransactions, skipped $skippedTransactions transactions.',
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        );
      }

      debugPrint('Rendering ListView with ${sortedDates.length} dates');

      return Column(
        children: sortedDates.map((date) {
          try {
            var transactions = groupedTransactions[date]!;
            debugPrint(
                'Rendering card for date: $date, transaction count: ${transactions.length}');

            double totalCredit = transactions
                .where((t) => t['type'] == 'CREDIT' && t['amount'] != null)
                .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
            print(
                "credited transactions ----------------------------------$totalCredit");
            double totalDebit = transactions
                .where((t) => t['type'] == 'DEBIT' && t['amount'] != null)
                .fold(0.0, (sum, t) => sum + (t['amount'] as num).toDouble());
            bool isExpanded = _expandedDates.contains(date);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: GestureDetector(
                onTap: () {
                  debugPrint(
                      'Tapped card for date: $date, isExpanded: $isExpanded');
                  setState(() {
                    if (isExpanded) {
                      _expandedDates.remove(date);
                    } else {
                      _expandedDates.add(date);
                    }
                  });
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Background cards for stacked effect
                    Positioned(
                      top: 2,
                      left: 2,
                      right: 2,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.bg5.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 1,
                      left: 1,
                      right: 1,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.bg5.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    // Foreground card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bg5,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('MMM dd, yyyy')
                                          .format(DateTime.parse(date)),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Credit',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              '₹${formatMoneyIndian(totalCredit.toStringAsFixed(2))}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 40),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Debit',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              '₹${formatMoneyIndian(totalDebit.toStringAsFixed(2))}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                          // Transactions (if expanded)
                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, bottom: 16),
                              child: Column(
                                children: transactions.map((transaction) {
                                  try {
                                    debugPrint(
                                        'Rendering transaction: ${transaction['_id']}');

                                    String? narration =
                                        transaction['narration'];
                                    String? title = transaction['title'];
                                    String type =
                                        transaction['type'] ?? 'DEBIT';
                                    double amount =
                                        (transaction['amount'] as num?)
                                                ?.toDouble() ??
                                            0.0;
                                    String category = transaction['category'] ??
                                        'Uncategorized';
                                    bool isManual =
                                        transaction['manualTransaction'] ??
                                            false;

                                    // Derive nameOfUser
                                    String nameOfUser = title ??
                                        narration ??
                                        'Unnamed Transaction';
                                    if (title == null && narration != null) {
                                      List<String> parts = narration.split('/');
                                      nameOfUser = parts.length >= 4
                                          ? parts[3]
                                          : parts[0];
                                    }

                                    final amtColor = type == 'DEBIT'
                                        ? Colors.red
                                        : Colors.green;
                                    final formatAmount =
                                        '₹${formatMoneyIndian(amount.toStringAsFixed(2))}';
                                    final fontSizes = FontSizeFactor(context);

                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: GestureDetector(
                                        onTap: !isManual
                                            ? () {
                                                debugPrint(
                                                    'Tapped transaction: ${transaction['_id']}');
                                                // Uncomment when TransactionDetailsPage is ready
                                                // showModalBottomSheet(
                                                //   context: context,
                                                //   builder: (_) => TransactionDetailsPage(transaction: transaction),
                                                // );
                                              }
                                            : null,
                                        child: Row(
                                          children: [
                                            getIconAvtar(
                                              fontSizes.avatarSize,
                                              category,
                                              fontSizes.scaleFactor,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  textStyle(
                                                    context: context,
                                                    text: nameOfUser,
                                                    c: Colors.black,
                                                    fontsize: 12.0,
                                                    fontWeight: FontWeight.w600,
                                                    lineHeight: 1.5,
                                                  ),
                                                  textStyle(
                                                    context: context,
                                                    text: category,
                                                    c: Colors.grey[600]!,
                                                    fontsize: 10.0,
                                                    fontWeight: FontWeight.w400,
                                                    lineHeight: 1.5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            textStyle(
                                              c: amtColor,
                                              context: context,
                                              text: formatAmount,
                                              fontsize: 12,
                                              fontWeight: FontWeight.bold,
                                              lineHeight: 1.5,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    debugPrint(
                                        'Error rendering transaction ${transaction['_id']}: $e');
                                    return const SizedBox.shrink();
                                  }
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } catch (e) {
            debugPrint('Error rendering card for date: $date: $e');
            return const SizedBox.shrink();
          }
        }).toList(),
      );
    } catch (e) {
      debugPrint('Error in CardViewTransactions build: $e');
      return Center(
        child: Text(
          'Error loading transactions: $e',
          style: const TextStyle(color: Colors.red, fontSize: 14),
        ),
      );
    }
  }
}
