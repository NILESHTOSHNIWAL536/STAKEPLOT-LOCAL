import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/history.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/tagandhidebutton.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;


class BalanceOutDialog extends StatelessWidget {
  const BalanceOutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width:  width/1.1,
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          final transactions = balanceOutList.values.toList();

            double creditSum = 0.0;
            double debitSum = 0.0;
            double max = 0.0;
            String id = '';
            bool isAlreadyIncluded=false;
            for (var tx in balanceOutList.values) {
              if (tx.type == 'CREDIT') {
                creditSum += tx.amount;
              } else if (tx.type == 'DEBIT') {
                debitSum += tx.amount;
              }
              if(max<tx.amount)
              {
                 max=tx.amount;
                 id=tx.id;
              }
             if(!isAlreadyIncluded)isAlreadyIncluded = tx.balanceOut==-1 || tx.isBalanceOut!;
            }

            double netAmount = creditSum - debitSum;
            bool isValid = netAmount.abs() < max;
           
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // InkWell(
                  //   onTap:(){
                  //     Navigator.pop(context);
                  //   },
                  //   child: const Icon(Icons.close, size: 20, color: Colors.grey)),
                  Text(
                    "Balance Out",
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 18,
                      lWeight: FontWeight.bold,
                      color: const Color(0xFF403E6A),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                       Navigator.pop(context);
                    },
                    child: Container(
                      height: 25,
                      width: 25,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFECEBF5),
                      ),
                      child: const Icon(Icons.close, size: 16, color: Color(0xFF403E6A)),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),

              Text(
                "You can select multiple transactions that are linked or related. "
                "Balancing them out will help keep your expense summary accurate.",
                style: FontManager().getTextStyle(
                  context,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 16),

              // Transaction List
                Container(
                  constraints: const BoxConstraints(
                    maxHeight: 400, // set your fixed max height
                  ),
                child: ListView.builder(
                  shrinkWrap: true,
                  // physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isPositive = tx.type != "DEBIT";
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9FB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Title & Credited from
                            Expanded(
                              flex: 3,
                              child: Text(
                                tx.manualTransaction ? tx.subcategory : tx.title,
                                style: FontManager().getTextStyle(
                                  context,
                                  fontSize: 11,
                                  lWeight: FontWeight.w500,
                                  color: const Color(0xFF403E6A),
                                ),
                              ),
                            ),
                
                            const SizedBox(width: 8),
                
                            // Logo or Lottie
                            Expanded(
                              flex: 2,
                              child: Container(
                                                       child: tx.manualTransaction
                                  ? Lottie.asset(
                                      'assets/splashScreen/manualTransactionIcon.json',
                                      height: 30,
                                      width: 30,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.error);
                                      },
                                    )
                                  : Image.network(
                                      tx.bankLogo ?? "",
                                      width: 22,
                                      height: 22,
                                      fit: BoxFit.contain,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const SizedBox(
                                            width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.error, size: 22);
                                      },
                                    )),
                            ),
                
                            const SizedBox(width: 8),
                
                            // Amount
                            Expanded(
                              flex: 3,
                              child: Text(
                                "${isPositive ? '+' : '-'} ₹ ${tx.amount.toStringAsFixed(0)}",
                                style: FontManager().getTextStyle(
                                  context,
                                  fontSize: 14,
                                  lWeight: FontWeight.bold,
                                  color: isPositive ? Colors.blue : Colors.black,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
              dottedDivider(),
              const SizedBox(height: 12),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "${netAmount > 0 ? '+ ' : netAmount < 0 ? '- ' : ''}₹ ${netAmount.abs().toStringAsFixed(0)}",
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 20,
                      lWeight: FontWeight.bold,
                      color: netAmount > 0 ? const Color(0xFF403E6A) : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // CTA Button
           isValid?  isAlreadyIncluded?textStyle(context: context,text: 'Already Included..',c: Colorcodes.red) :ElevatedButton(
                onPressed: () {
                  // Trigger balance logic
                  
                  updateTheGroupTransactions(context, true,id,netAmount);


                  showCheckBox.value = false;

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF403E6A),
                  minimumSize: const Size.fromHeight(45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Balance out",
                  style: FontManager().getTextStyle(
                    context,
                    fontSize: 14,
                    lWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ): textStyle(context: context,text: 'invalid balaced transactions',c: Colorcodes.red)
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
