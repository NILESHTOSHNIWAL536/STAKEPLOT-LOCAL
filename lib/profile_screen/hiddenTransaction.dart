import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';

import 'package:flutter_application_code_stakeplot/Constants/decorated_box.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';

class HiddenTransactionsScreen extends StatefulWidget {
  final List<Map<String, String>> hiddenTransactions;
  const HiddenTransactionsScreen({super.key, required this.hiddenTransactions});

  @override
  State<HiddenTransactionsScreen> createState() => _HiddenTransactionsScreenState();
}

class _HiddenTransactionsScreenState extends State<HiddenTransactionsScreen> {
  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Hidden Transactions'),
      // ),
      body: widget.hiddenTransactions.isEmpty
          ? Center(
              child: Text('No hidden transactions.',
                  style: FontManager().getTextStyle(context,
                      lWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.accentColor)),
            )
          : ListView.builder(
              itemCount: widget.hiddenTransactions.length,
              itemBuilder: (context, index) {
                final transaction = widget.hiddenTransactions[index];
                return ListTile(
                  leading: const Icon(Icons.payment),
                  title: Text(
                    transaction['merchant']!,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Date: ${transaction['date']}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        "₹${transaction['amount']} - ${transaction['description']}",
                      ),
                    ],
                  ),
                  trailing: Text(transaction['time']!),
                );
              },
            ),
    );
  }
}
