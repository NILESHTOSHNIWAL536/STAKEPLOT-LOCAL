import 'package:flutter/material.dart';
import 'package:flutter_application_code_stakeplot/Constants/colors.dart';
import 'package:flutter_application_code_stakeplot/repository/group_Api.dart';
import 'package:flutter_application_code_stakeplot/components/helper.dart';
import 'package:flutter_application_code_stakeplot/Constants/colorcodes.dart';

import 'package:flutter_application_code_stakeplot/Constants/loader.dart';
import 'package:flutter_application_code_stakeplot/model/TransactionModel.dart';
import 'package:flutter_application_code_stakeplot/user_chat/tag_showmodal.dart';
import 'package:get/get.dart';

import '../Constants/core/app_padding_sizes.dart';
import '../components/shared_utils.dart';

class GroupTransactions extends StatefulWidget {

  const GroupTransactions({Key? key}) : super(key: key);

  @override
  State<GroupTransactions> createState() => _GroupTransactionsState();
}

class _GroupTransactionsState extends State<GroupTransactions>
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
    return Obx(
      () => !setGroupTransactions.value
          ?  Center(child: Spinner(size: 30))
          : _buildGroupList(context),
    );
  }

  // Main group list
  Widget _buildGroupList(BuildContext context) {
    if (groupTransactionList.isEmpty) return _buildEmptyState(context);

    return FadeTransition(
      opacity: _animationController!.drive(CurveTween(curve: Curves.easeIn)),
      child: Container(
        // color: Colorcodes.barGraphOrange,
        height: MediaQuery.of(context).size.height/1.38,
        child: SingleChildScrollView(
          child: Column(
                children: groupTransactionList
                    .asMap()
                    .entries
                    .map((entry) {
                      int index = entry.key;
                      var transaction = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p4),
                        child: _buildGroupCard(context, transaction, index),
                      );
                    })
                    .toList(),
              ),
        ),
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
    final narration = transaction['narrationPattern'] ?? 'Unnamed Group';
    final count = transaction['count']?.toString() ?? '0';
    final totalAmount = transaction['totalAmount']?.toString() ?? '0';

    return GestureDetector(
      onTap: () => _showTransactionModal(context, transaction, index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSizes.p8),
        padding: const EdgeInsets.all(AppSizes.p16),
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: AppColors.backgroundColor,
                    size: 28,
                  ),
                ),
                SizedBox(width: AppSizes.w16),
                // Text details
                Container(

                  width: MediaQuery.sizeOf(context).width/2.7,
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
                          fontsize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
// ... existing code ...
                      SizedBox(height: AppSizes.h6),
                      textStyle(
                        context: context,
                        text: '$count transactions',
                        c: AppColors.primaryColor.withOpacity(0.8),
                        fontsize: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          //  const SizedBox(width: 16),
            // Amount
            textStyle(
              context: context,
              text: '₹${formatMoneyIndian(totalAmount)}',
              c: AppColors.historyAmtColor,
              fontsize: 14,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
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
          padding: const EdgeInsets.only(top:AppSizes.p16, bottom:AppSizes.p16),
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
                           transaction['transactions'][0]['totalAmount']=transaction['totalAmount']??0;
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) => TagShowmodal(
                              data: TransactionModel.fromJson(transaction['transactions'][0]) , //widget.data[0]["transactions"]
                              index: index,
                              isGroupTransaction: true,
                              id: transaction['_id'],
                            ),
                          );
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: AppSizes.p8),
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
                padding: const EdgeInsets.all(AppSizes.p14),
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
                                c: AppColors.historyAmtColor,
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
                        padding: const EdgeInsets.all(AppSizes.p8),
                        decoration: BoxDecoration(
                          color: AppColors.redColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delete_rounded,
                          color: AppColors.redColor,
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
