import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class BalanceOutDialog extends StatelessWidget {
  const BalanceOutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // final controller = Get.find<TransactionController>();
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isMobile ? double.infinity : 400,
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final transactions = balanceOutList.values.toList();

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              dottedDivider(),
              const SizedBox(height: 8),
              const Text(
                "Balance Out",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF403E6A)),
              ),
              const SizedBox(height: 16),

              // ✅ Dynamic Transaction List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  final isPositive = tx.type =="DEBIT";
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9FB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                            tx.manualTransaction? tx.subcategory: tx.title,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF403E6A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                         
                          const SizedBox(width: 8),

                           tx.manualTransaction?   Expanded(
                            flex: 2,
                             child: Container(
                              height: 30,
                              width: 30,
                              child: Lottie.asset(
                                'assets/splashScreen/manualTransactionIcon.json',
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error); // fallback UI
                                },
                              ),
                                                       ),
                           ):   Expanded(
                              flex: 2,
                              child: Image.network(
                            tx.bankLogo ?? '"assets/logo.png"',
                            width: 8,
                            height: 16,
                            fit: BoxFit.fitWidth,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return CircularProgressIndicator(
                                  strokeWidth: 2); // Loading indicator
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.error,
                                  size: 22); // Fallback for failed image load
                            },
                          ),
            
                           ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: Text(
                              "${isPositive ? "+" : "-"} ₹ ${tx.amount.toStringAsFixed(0)}",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isPositive ? Colors.blue : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),
              dottedDivider(),
              const SizedBox(height: 12),

              // Total Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total", style: TextStyle(fontSize: 18, color: Colors.grey)),
                  Text(
                    "₹ ${balanceOutList.values.fold(0.0, (sum, tx) => sum + (tx.amount ?? 0)).toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF403E6A)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          );
        }),
      ),
    );
  }

  Widget dottedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFB3B3D1)),
              ),
            );
          }),
        );
      },
    );
  }
}
