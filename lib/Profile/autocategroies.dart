import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/repository/group_Api.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transactions_ui_component.dart';
import 'package:flutter_application_code_stakeplot/Home_Screen/history/transaction_history.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';
import 'package:flutter_application_code_stakeplot/finance_screen/Budgets/Budget.dart';
import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';

import 'package:get/get.dart';

import '../Constants/core/app_padding_sizes.dart';
import '../components/shared_utils.dart';
import '../repository/transactions_repository.dart';

class AutocategroiesTransactions extends StatefulWidget {
   AutocategroiesTransactions({Key? key}) : super(key: key);

  @override
  State<AutocategroiesTransactions> createState() => _GroupTransactionsState();
}

class _GroupTransactionsState extends State<AutocategroiesTransactions>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    getGroupTransactions();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Obx(
      () => !setAutoTransactions.value
          ?  Center(child: Spinner(size: 30))
          : _buildGroupList(context),
    );
  }

  // Main group list
  Widget _buildGroupList(BuildContext context) {
    if (autoTransactionList.isEmpty) return SizedBox.shrink();

    return FadeTransition(
      opacity: _animationController!.drive(CurveTween(curve: Curves.easeIn)),
      child: Column(
        children: autoTransactionList.asMap().entries.map((entry) {
          int index = entry.key;
          TransactionModel transaction = TransactionModel.fromJson( entry.value);
          return HistoryTransactions(
            transaction:   transaction,
             date:  transaction.transactionTimestamp.toString(),
            index:   index,
             context:   context,
            hideReview:  true
            );
        }).toList(),
      ),
);

}

  // Empty state
  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.group_off_rounded,
            size: 70,
            color: AppColors.primaryColor,
          ),
           SizedBox(height: AppSizes.h20),
          textStyle(
            context: context,
            text: "No Groups Yet!",
            c: AppColors.accentColor,
            fontsize: 20,
            fontWeight: FontWeight.bold,
          ),
          
        ],
      ),
    );
  }

  // Group card
  Widget _buildGroupCard(BuildContext context, Map<String, dynamic> transaction, int index) {
    final narration_id = transaction['_id'] ?? 'Unnamed Group';
    final category = transaction['category'] ?? 'Untagged';
    final narration = transaction['narration'] ?? 'Unnamed Group';
    // final count = transaction['count']?.toString() ?? '0';
    final totalAmount = transaction['amount']?.toString() ?? '0';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(16),  
        gradient: LinearGradient(
          colors: [
            AppColors.backgroundColor.withOpacity(0.05),
            AppColors.backgroundColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentColor.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items with equal spacing
        children: [
          // Icon container
          Row(
            children: [
               getIconAvtar(48,category, 40),
            
              SizedBox(width: AppSizes.w16),
              // Text details
              Container(
                width: MediaQuery.sizeOf(context).width/2.3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   // ... existing code ...
                    Tooltip(
                      message: narration, // Full text to show on hover
                      child: textStyle(
                        context: context,
                        text: narration,
                        c: AppColors.accentColor,
                        fontsize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
    // ... existing code ...
                    SizedBox(height: AppSizes.h6),
                    textStyle(
                    context: context,
                    text: '${"Milk(${"Dary"})"}',
                    c: AppColors.primaryColor,
                    fontsize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                    // const SizedBox(height: 6),
                    // textStyle(
                    //   context: context,
                    //   text: '$count transactions',
                    //   c: AppColors.primaryColor.withOpacity(0.8),
                    //   fontsize: 12,
                    // ),
                    SizedBox(height: AppSizes.h6),
    
                    textStyle(
                      context: context,
                      text: '₹${formatMoneyIndian(totalAmount)}',
                      c: Colors.green.shade700,
                      fontsize: 12,
                      fontWeight: FontWeight.bold,
                    ),
    
                  ],
                ),
              ),
            
            
               SizedBox(width: AppSizes.w4),
    
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    InkWell(
                      onTap: ()async{
                          // _showTransactionModal(context, transaction, index);
                         await addTagToTransactions(context,narration_id,false,index);
                      },
                      child: Icon(Icons.close_rounded,
                        color: Colorcodes.red,
                        size: 30,
                      ),
                    ),
                    SizedBox(width: AppSizes.w4),
                    InkWell(
                      onTap: ()
                      {
                        addTagToTransactions(context,narration_id,true,index);
                      },
                      child: Icon(Icons.check,
                        color: Colorcodes.budgetDarkGreen,
                        size: 30,
                      ),
                    ),
                ],
              )
            
            ],
          ),
        //  const SizedBox(width: 16),
          // Amount
          // textStyle(
          //   context: context,
          //   text: '₹${formatMoneyIndian(totalAmount)}',
          //   c: Colors.green.shade700,
          //   fontsize: 14,
          //   fontWeight: FontWeight.bold,
          // ),
        ],
      ),
    );
  }

  // Improved modal
  void _showTransactionModal(
      BuildContext context, Map<String, dynamic> transaction, int index) {
    removedGrpItemsList.clear();
    lengthOfTransactions.value = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.backgroundColor,
      builder: (modalContext) {
        return Container(
          height: MediaQuery.of(modalContext).size.height * 0.7,
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Modal handle and header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   SizedBox(width: AppSizes.w48), // Spacer for alignment
                  textStyle(
                    context: context,
                    text: "Group Transactions",
                    c: AppColors.accentColor,
                    fontsize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(modalContext),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.primaryColor,
                      size: 28,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.h8),
              // Tag button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: lengthOfTransactions.value
                      ? null
                      : () {
                          // showModalBottomSheet(
                          //   context: context,
                          //   isScrollControlled: true,
                          //   shape: const RoundedRectangleBorder(
                          //     borderRadius:
                          //         BorderRadius.vertical(top: Radius.circular(20)),
                          //   ),
                          //   builder: (context) => TagShowmodal(
                          //     data: transaction,
                          //     index: index,
                          //     isGroupTransaction: true,
                          //   ),
                          // );
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.tag_rounded,
                          color: AppColors.backgroundColor,
                          size: 20,
                        ),
                        SizedBox(width: AppSizes.w8),
                        textStyle(
                          context: context,
                          text: "Tag Group",
                          c: AppColors.backgroundColor,
                          fontsize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.h16),
              // Transaction list
              Obx(
                () => lengthOfTransactions.value
                    ? SizedBox(
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: Colors.green,
                              size: 60,
                            ),
                            SizedBox(height: AppSizes.h16),
                            textStyle(
                              context: context,
                              text: "All Cleared!",
                              c: AppColors.accentColor,
                              fontsize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: MediaQuery.of(modalContext).size.height * 0.51,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          physics: const BouncingScrollPhysics(),
                          itemCount: transaction['transactions'].length,
                          itemBuilder: (context, idx) {
                            var details = transaction['transactions'][idx];
                            return _buildUnTagItem(context, details, transaction);
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Un-tag item
  Widget _buildUnTagItem(
      BuildContext context, dynamic transactionDetails, Map<String, dynamic> transaction) {
    return Obx(
      () => removedGrpItemsList.contains(transactionDetails['_id'])
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.backgroundColor.withOpacity(0.1),
                      AppColors.backgroundColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentColor.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: AppSizes.w12),
                    // Details
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ... existing code ...
                      Tooltip(
                        message: transactionDetails['narration'] ?? 'Unnamed', // Full text to show on hover
                        child: textStyle(
                          context: context,
                          text: transactionDetails['narration'] ?? 'Unnamed',
                          c: AppColors.accentColor,
                          fontsize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
// ... existing code ...
                      
                          SizedBox(height: AppSizes.h6),
                          textStyle(
                            context: context,
                            text: transactionDetails['txnId'] ?? 'No ID',
                            c: AppColors.accentColor.withOpacity(0.7),
                            fontsize: 12,
                          ),
                         
                          SizedBox(height: AppSizes.h4),
                          Row(
                            children: [
                              textStyle(
                                context: context,
                                text: '₹${formatMoneyIndian(transactionDetails['amount'].toString())}',
                                c: Colors.green.shade700,
                                fontsize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                                SizedBox(width: AppSizes.w10),
                               textStyle(
                                context: context,
                                text:formatWhatsAppDate(convertStringToDateTime(transactionDetails['transactionTimestamp'])),
                                c: AppColors.accentColor.withOpacity(0.7),
                                fontsize: 12,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSizes.w12),
                    // Delete button
                    GestureDetector(
                      onTap: () {
                        reloadremovedTransactions.value =
                            !reloadremovedTransactions.value;
                        removedGrpItemsList.add(transactionDetails['_id']);
                        lengthOfTransactions.value =
                            removedGrpItemsList.length ==
                                transaction['transactions'].length;
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colorcodes.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_rounded,
                          color: Colorcodes.red,
                          size: 22,
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
