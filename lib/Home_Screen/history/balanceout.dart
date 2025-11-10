import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/Constants/font_manager.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/balanceout_mismatch.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/cashout_dialog.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactions_ui_component.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/tagandhidebutton.dart';
import 'package:flutter_application_code_stakeplot/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;


class BalanceOutDialog extends StatelessWidget {
  const BalanceOutDialog({super.key});


  @override
  Widget build(BuildContext context) {
  
    final width = MediaQuery.of(context).size.width;

    return Dialog(
      insetPadding: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
           color: AppColors.backgroundColor,
           borderRadius: BorderRadius.circular(16)

        ),
       
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
             if(!isAlreadyIncluded)isAlreadyIncluded =  (tx.balanceOut !=null && tx.isBalanceOut!=null) ? ( tx.balanceOut==-1 || tx.isBalanceOut!):false;
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
                  InkWell(
                    onTap:(){
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.close, size: 20, color: Colors.grey)),
                  Text(
                    "Balance Out",
                    style: FontManager().getTextStyle(
                      context,
                      fontSize: 18,
                      lWeight: FontWeight.w600,
                      color: AppColors.finSpaceColor
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      showDialog(
                        context: context,
                        builder: (context) => CashOutDialog(maxAmount: max,),
                      );
                    },
                    child: Container(
                      height: 25,
                      width: 25,
                      decoration:  BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(5),
                        color: Color(0xFFF6F6F6),
                      ),
                      child: const Icon(Icons.add, size: 16, color: Color(0xFF403E6A)),
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

              // Transaction List
            isValid?  getListOfTransactions(context, transactions, isValid, netAmount, isAlreadyIncluded, id):
            GetMisMatchSlider(id: id,isAlreadyIncluded: isAlreadyIncluded,isValid: isValid,transactions:transactions,netAmount: netAmount,parentContext: context),

              //textStyle(context: context,text: 'invalid balaced transactions',c: Colorcodes.red)
            ],
          );
        }),
      ),
    );
  }

}



Widget getTotalAndAddButton(context,netAmount,isValid,isAlreadyIncluded,id){
   return Column(
     children: [
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
           isValid?  isAlreadyIncluded?Container(
            // width: MediaQuery.of(context).size.width/1.1,
            child: textStyleImage(iswrap: true,context: context,text: "Some of these transactions are already balanced out.",c: Colorcodes.red)) :ElevatedButton(
                onPressed: () 
                {
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
                    lWeight: FontWeight.w600,
                    color: AppColors.backgroundColor,
                  ),
                ),
              ):SizedBox(),
     ],
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



  Widget getListOfTransactions(context,List<TransactionModel> transactions,isValid,netAmount,isAlreadyIncluded,id)
  {
    return   Column(
      children: [
         const SizedBox(height: 16),
        Container(
                      constraints:  BoxConstraints(
                        maxHeight: isValid? 400:200, // set your fixed max height
                      ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final isPositive = tx.type != "DEBIT";
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(5),
    color: AppColors.backgroundColor,
    boxShadow: [
      BoxShadow(
        color: Color.fromRGBO(156, 156, 156, 0.25),
        blurRadius: 4,
        spreadRadius: 0,
        offset: Offset(0, 0),
      ),
    ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Title & Credited from
                                Container(
                                 width: MediaQuery.sizeOf(context).width/3.3,
                                  child: Text(
                                    tx.manualTransaction ? tx.subcategory : tx.title,
                                    style: FontManager().getTextStyle(
                                      context,
                                      fontSize: 11,
                                      lWeight: FontWeight.w500,
                                      color: AppColors.finSpaceColor,
                                    ),
                                  ),
                                ),
                    
                                const SizedBox(width: 4),
                    
                                // Logo or Lottie
                                Container(
                                 width: MediaQuery.sizeOf(context).width/9,
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
                    
                                const SizedBox(width: 4),
                    
                                // Amount
                                Container(
                                 width: MediaQuery.sizeOf(context).width/4.3,
                                  child: Text(
                                    
                                    "${isPositive ? '+' : '-'} ₹ ${tx.amount.toStringAsFixed(0)}",
                                    style: FontManager().getTextStyle(
                                      context,
                                      fontSize: 14,
                                      lWeight: FontWeight.bold,
                                      color:  AppColors.finSpaceColor,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                  
                                ),
                                 const SizedBox(width: 8),
                                InkWell(
                                  onTap: ()
                                  {
                                       balanceOutList.remove(tx.id);
                                       redioButton.remove(tx.id);
                                  },
                                  child:const Icon(
                                    Icons.close,
                                    size: 14,
                                  ),
                                ),

                                
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
        const SizedBox(height: 12),
        getTotalAndAddButton(context, netAmount, isValid, isAlreadyIncluded, id),
      ],
    );
  }