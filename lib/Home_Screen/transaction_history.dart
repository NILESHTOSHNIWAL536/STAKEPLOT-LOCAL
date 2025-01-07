import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/colors.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  final List<Map<String, String>> transactions = [
    {
      "date": "Nov 15",
      "merchant": "Starbucks",
      "amount": "1500",
      "description": "coffee",
      "time": "10:01 PM"
    },
    {
      "date": "Nov 14",
      "merchant": "Amazon",
      "amount": "2500",
      "description": "electronics",
      "time": "5:15 PM"
    },
    {
      "date": "Nov 13",
      "merchant": "McDonald's",
      "amount": "800",
      "description": "burger",
      "time": "2:45 PM"
    },
  ];
  final Map<int, double> swipeOffsets = {};
  bool showAllTransactions = false;
  final List<Map<String, String>> hiddenTransactions = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Transaction History',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  showAllTransactions = !showAllTransactions;
                });
              },
              child: Text(
                showAllTransactions ? 'Show Less' : 'More',
                style: const TextStyle(fontSize: 16, color: Colors.greenAccent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ListView.builder(
          itemCount: showAllTransactions ? transactions.length : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            if (index >= transactions.length) {
              return const SizedBox.shrink(); // Prevent index errors
            }

            final transaction = transactions[index];
            double offset = swipeOffsets[index] ?? 0;

            return GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  offset += details.delta.dx;
                  offset = offset.clamp(-40.0, 0.0); // Limit swipe range
                  swipeOffsets[index] = offset;
                });
              },
              child: Stack(
                children: [
                  // Background with hide icon
                  Container(
                    height: 80,
                    color: AppColors.primaryColor,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          hiddenTransactions.add(transactions[index]);
                          transactions.removeAt(index);
                          swipeOffsets.remove(index);
                        });
                      },
                      child: const Icon(
                        Icons.visibility_off,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  // Foreground content
                  Transform.translate(
                    offset: Offset(offset, 0),
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [
                            (1.0 - (offset.abs() / 200))
                                .clamp(0.0, 1.0), // Adjust blending
                            1.0,
                          ],
                          colors: [
                            AppColors.backgroundColor,
                            AppColors.backgroundColor.withOpacity(0.0),
                          ],
                        ),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.payment),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${transaction['date']} - ${transaction['merchant']}",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "₹${transaction['amount']} (${transaction['description']})",
                            ),
                          ],
                        ),
                        trailing: Text(
                            transaction['time'] ?? '-'), // Handle null safely
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
