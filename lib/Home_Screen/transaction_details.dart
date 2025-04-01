import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class TransactionDetailsPage extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailsPage({Key? key, required this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Assuming transactionTimestamp is a DateTime or String that can be parsed
    String formattedDate = transaction['transactionTimestamp'] is String
        ? DateFormat('MMM dd, yyyy • hh:mm a')
            .format(DateTime.parse(transaction['transactionTimestamp']))
        : transaction['transactionTimestamp'].toString();

    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background like payment apps
      appBar: AppBar(
        elevation: 0, // Flat modern look
        backgroundColor: Colors.white,
        title: const Text(
          'Transaction Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
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
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.green, // Green for success/completed
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      transaction['type'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
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
                      label: 'Transaction ID',
                      value: transaction['txnId'],
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      label: 'Date & Time',
                      value: formattedDate,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      label: 'Narration',
                      value: transaction['narration'] ?? 'N/A',
                    ),
                  ],
                ),
              ),

              // Optional: Status Chip (e.g., Success, Pending)
              const SizedBox(height: 20),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Completed', // Could be dynamic based on transaction status
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build detail rows
  Widget _buildDetailRow({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}