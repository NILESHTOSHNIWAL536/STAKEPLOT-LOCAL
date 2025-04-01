import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/helper.dart';
import 'package:intl/intl.dart'; // For date formatting

class TransactionDetailsPage extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailsPage({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Assuming transactionTimestamp is a DateTime or String that can be parsed
    // String formattedDate = transaction['transactionTimestamp'] is String
    //     ? DateFormat('MMM dd, yyyy • hh:mm a')
    //         .format(DateTime.parse(transaction['transactionTimestamp']))
    //     : transaction['transactionTimestamp'].toString();
    final formattedDate = transaction['transactionTimestamp'] != null
        ? formatWhatsAppDate(convertStringToDateTime(
            transaction['transactionTimestamp'].toString()))
        : 'N/A'; // Default value if transactionTimestamp is null

    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background like payment apps
      appBar: AppBar(
        elevation: 0, // Flat modern look
        backgroundColor: Colors.white,
        title: Text(
          'Transaction Details',
          style: FontManager().getTextStyle(context,
              lWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.accentColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Section (Prominent)
              Center(
                child: Column(
                  children: [
                    Text(
                      '₹${transaction['amount']}',
                      style: FontManager().getTextStyle(context,
                          lWeight: FontWeight.bold,
                          fontSize: 36,
                          color: transaction['type'] == 'DEBIT'
                              ? const Color.fromARGB(255, 207, 118, 113)
                              : Colors.green),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      transaction['type'],
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
                      value: transaction['txnId'],
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
                      value: transaction['narration'] ?? 'N/A',
                    ),
                  ],
                ),
              ),

              // Optional: Status Chip (e.g., Success, Pending)
              const SizedBox(height: 20),
              // Center(
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              //     decoration: BoxDecoration(
              //       color: Colors.green[50],
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     child: Text(
              //       'Completed', // Could be dynamic based on transaction status
              //       style: TextStyle(
              //         color: Colors.green[700],
              //         fontWeight: FontWeight.w600,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build detail rows
  Widget _buildDetailRow(
      {required BuildContext context,
      required String label,
      required String value}) {
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
}
