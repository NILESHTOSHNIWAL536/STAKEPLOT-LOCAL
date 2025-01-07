import 'package:flutter/material.dart';
//import 'package:flutter_application_code_stakeplot/Home_Screen/transaction_history.dart';

class HiddenTransactionsScreen extends StatelessWidget {
  final List<Map<String, String>> hiddenTransactions;

  const HiddenTransactionsScreen({super.key, required this.hiddenTransactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hidden Transactions'),
      ),
      body: hiddenTransactions.isEmpty
          ? const Center(
              child: Text('No hidden transactions.'),
            )
          : ListView.builder(
              itemCount: hiddenTransactions.length,
              itemBuilder: (context, index) {
                final transaction = hiddenTransactions[index];
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