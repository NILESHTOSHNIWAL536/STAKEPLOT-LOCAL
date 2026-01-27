import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactions_ui_component.dart';
import 'package:flutter_application_code_stakeplot/backed_connections/apis_connect.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';

import '../../Constants/core/app_padding_sizes.dart';

class CashOutDialog extends StatelessWidget {
  double maxAmount;
   CashOutDialog({super.key,required this.maxAmount});

   TextEditingController controllerName=TextEditingController();
   TextEditingController controllerAmount=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSizes.p10),
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: AppSizes.p24),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close and Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   SizedBox(width: AppSizes.w24), // Empty box for left space
                  const Text(
                    "Cash Out",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4C4C7C),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.h24),

              // Name Label
              const Text(
                "Name",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: AppSizes.h6),
              TextFormField(
                controller: controllerName,
                decoration: InputDecoration(
                  hintText: "eg. ",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: AppSizes.h20),

              // Amount Label
              const Text(
                "Amount",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: AppSizes.h6),
              TextFormField(
                controller: controllerAmount,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "eg. ₹ 220",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: AppSizes.h32),

              // Cash Out Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle Cash out logic
                    if(controllerAmount.text.isEmpty || controllerName.text.isEmpty){
                        snackBarCalledfail(context, 'Add All Fields');
                        return;
                    }

                          final text = controllerAmount.text.trim();


                      final amount = double.tryParse(text.replaceAll(RegExp(r'[^\d.]'), ''));

                      if (amount == null) {
                        snackBarCalledfail(context, 'Enter a valid number');
                        return;
                      }

                      if (amount > maxAmount) {
                        snackBarCalledfail(context, "Amount can't be more than ₹$maxAmount");
                        return;
                      }
                       String id=UniqueKey().toString();
                       balanceOutList[id]=TransactionModel(id: id, type: 'DEBIT', mode: 'CASH', amount: amount, currentBalance: 0, narration: '', reference: '', title: controllerName.text, manualTransaction: true, category: controllerName.text, subcategory: controllerName.text, hidden: false, isBill: false, isDebt: false, isSplit: false,transactionTimestamp: DateTime.now());    
                       Navigator.pop(context);     
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C4C7C),
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:  Text(
                    "Cash out",
                    style: TextStyle(fontSize: 16,color: Colorcodes.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
