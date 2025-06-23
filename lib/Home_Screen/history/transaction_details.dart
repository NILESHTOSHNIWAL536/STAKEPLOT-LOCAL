import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';

class TransactionDetailsPage extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailsPage({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = transaction.transactionTimestamp != null
        ? formatWhatsAppDate4(convertStringToDateTime(
            transaction.transactionTimestamp.toString()))
        : 'N/A'; 

    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Transaction Details',
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.accentColor),
        ),
       
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Section
              Center(
                child: Column(
                  children: [
                    Text(
                      '₹${formatMoneyIndian(transaction.amount.toString())}',
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.bold,
                          fontSize: 36,
                          color: transaction.type == 'DEBIT'
                              ? const Color.fromARGB(255, 207, 118, 113)
                              : Colors.green),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      transaction.type,
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      context: context,
                      label: 'Transaction ID',
                      value: transaction.txnId.toString(),
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      context: context,
                      label: 'Date & Time',
                      value: formattedDate,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      context: context,
                      label: 'Narration',
                      value: transaction.narration,
                    ),
                    // Only show Category row if tagged
                    if (_isCategoryTagged(
                        transaction.category, transaction.subcategory)) ...[
                      const Divider(height: 24),
                      _buildDetailRow(
                        context: context,
                        label: 'Category',
                        value: _formatCategory(
                            transaction.category, transaction.subcategory),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build detail rows
  Widget _buildDetailRow({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w500, fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.w500, fontSize: 14, color: AppColors.bg1),
        ),
      ],
    );
  }

  // Helper method to format category and subcategory
  String _formatCategory(dynamic category, dynamic subcategory) {
    final cat = category?.toString().trim() ?? 'Uncategorized';
    final subcat = subcategory?.toString().trim() ?? null;

    if (subcat == null || subcat.isEmpty || subcat == 'Uncategorized') {
      return cat;
    }
    return '$cat - $subcat';
  }

  // Helper method to check if category is tagged
  bool _isCategoryTagged(dynamic category, dynamic subcategory) {
    final cat = category?.toString().trim() ?? 'Uncategorized';
    final subcat = subcategory?.toString().trim() ?? 'Uncategorized';
    return !(cat == 'Uncategorized' && (subcat == 'Uncategorized' || subcat.isEmpty));
  }
}